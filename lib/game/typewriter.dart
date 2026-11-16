import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'fx.dart';
import 'game_state.dart';

/// Types the narrative log out letter by letter, line by line, with a reading
/// pause after each line. It lives above the layout, so rotating the device
/// never restarts or repeats the typing.
///
/// New log lines arrive through GameState.onLog and wait in a queue. A line can
/// carry an `effect` (e.g. "+12 SCRAP") that fires the moment the line finishes
/// typing, so the HUD changes exactly when the text reveals the result.
/// If the queue backs up (fast combat), typing speeds up to catch up.
class TypewriterController extends ChangeNotifier {
  static const _tickMs = 30;
  static const _maxLines = 200;
  static const _cps = [30.0, 55.0, 110.0]; // characters per second: slow, normal, fast
  static const _holdScale = [1.3, 1.0, 0.5]; // scales the reading pause

  final GameState state;
  final bool console; // false = narrative log, true = encounter console
  final Queue<LogLine> _queue = Queue<LogLine>();
  final List<LogLine> revealed = [];
  LogLine? current;
  int chars = 0;
  double _carry = 0;
  int _holdMs = 0;
  bool _effectRun = false;
  Timer? _timer;
  DateTime _idleSince = DateTime.now();
  int _tickCount = 0;

  /// Flips true while any text is still typing or being read. Screens that
  /// would move on (combat results, Continue buttons) wait for it to clear.
  final ValueNotifier<bool> busyNotifier = ValueNotifier<bool>(false);

  void _syncBusy() {
    final b = busy;
    if (busyNotifier.value != b) busyNotifier.value = b;
  }

  TypewriterController(this.state, {this.console = false}) {
    if (console) {
      state.onConsole = _onLog;
      state.onConsoleReset = clear;
    } else {
      state.onLog = _onLog;
    }
  }

  bool get busy => current != null || _queue.isNotEmpty;

  /// True once everything is typed AND the player has had a moment to read it.
  /// Exploration waits for this before rolling the next event.
  bool get settled =>
      !busy && DateTime.now().difference(_idleSince).inMilliseconds >= 1200;

  String get partial {
    final c = current;
    return c == null ? '' : c.text.substring(0, min(chars, c.text.length));
  }

  /// Show the whole current log instantly (after loading a save).
  void syncAll() {
    _reset();
    revealed.addAll(console ? state.console : state.log);
    _trim();
    notifyListeners();
  }

  /// Empty the display (new game).
  void clear() {
    _reset();
    notifyListeners();
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    _queue.clear();
    current = null;
    chars = 0;
    _carry = 0;
    _holdMs = 0;
    _effectRun = false;
    revealed.clear();
    _idleSince = DateTime.now();
    _syncBusy();
  }

  void _trim() {
    while (revealed.length > _maxLines) {
      revealed.removeAt(0);
    }
  }

  void _run(LogLine l) {
    final e = l.effect;
    if (e != null) {
      l.effect = null; // fire once
      e();
    }
  }

  void _onLog(LogLine line) {
    _queue.add(line);
    if (state.textSpeed >= 3 || _minigame) {
      _flushAll();
      return;
    }
    _timer ??= Timer.periodic(const Duration(milliseconds: _tickMs), (_) => _tick());
    _syncBusy();
  }

  /// Hacking and lockpicking show text instantly so it can be read at once.
  bool get _minigame =>
      state.mode == GameMode.hacking || state.mode == GameMode.lockpicking;

  /// Instant mode (or a minigame): reveal everything now.
  void _flushAll() {
    LogLine? soundLine;
    void reveal(LogLine l) {
      revealed.add(l); // add first so lines made by the effect stay in order
      if (l.kind == LogKind.loot || l.text.startsWith('DAMAGE')) soundLine = l;
      _run(l);
    }

    final cur = current;
    if (cur != null) {
      current = null;
      reveal(cur);
    }
    while (_queue.isNotEmpty) {
      reveal(_queue.removeFirst());
    }
    chars = 0;
    _holdMs = 0;
    _effectRun = false;
    _trim();
    _idleSince = DateTime.now();
    _timer?.cancel();
    _timer = null;
    final s = soundLine;
    if (s != null) _lineSound(s);
    _syncBusy();
    notifyListeners();
  }

  static DateTime _lastLootSfx = DateTime.fromMillisecondsSinceEpoch(0);

  /// Sounds are tied to the text, so they land as each line appears.
  void _lineSound(LogLine l) {
    if (l.silent) return;
    final t = l.text;
    if (t.startsWith('> LEVEL UP')) {
      Fx.play(Sfx.levelup);
    } else if (l.kind == LogKind.loot) {
      // One chime per reward burst (+scrap, +xp, ...), not one per line.
      final now = DateTime.now();
      if (now.difference(_lastLootSfx).inMilliseconds > 1800) Fx.play(Sfx.loot);
      _lastLootSfx = now;
    } else if (t.startsWith('> ENCOUNTER')) {
      Fx.play(Sfx.alarm);
    } else if (t.startsWith('> HOSTILE')) {
      Fx.play(Sfx.growl);
    } else if (t.startsWith('> HAZARD') || t.startsWith('> YOU HAVE FALLEN')) {
      Fx.play(Sfx.alarm);
    } else if (!Fx.stageSounds && t.startsWith('DAMAGE DEALT')) {
      Fx.play(Sfx.hit);
    } else if (!Fx.stageSounds && t.startsWith('You miss')) {
      Fx.play(Sfx.swing);
    } else if (!Fx.stageSounds && t.startsWith('DAMAGE RECEIVED')) {
      Fx.play(Sfx.hurt);
    }
  }

  int _hold(LogLine l) {
    if (l.pauseMs != null) return l.pauseMs!;
    switch (l.kind) {
      case LogKind.system:
        return 200;
      case LogKind.loot:
        return 450;
      case LogKind.warning:
      case LogKind.danger:
        return 350;
      case LogKind.narrative:
      case LogKind.thought:
        return min(2200, 400 + 14 * l.text.length); // time to actually read it
    }
  }

  void _tick() {
    if (current == null) {
      if (_queue.isEmpty) {
        _timer?.cancel();
        _timer = null;
        _idleSince = DateTime.now();
        _syncBusy();
        return;
      }
      current = _queue.removeFirst();
      chars = 0;
      _carry = 0;
      _holdMs = 0;
      _effectRun = false;
      notifyListeners();
    }
    final speed = state.textSpeed;
    if (speed >= 3 || _minigame) {
      _flushAll();
      return;
    }
    final cur = current!;
    final backlog = _queue.length;
    final base = backlog > 14 ? 6.0 : backlog > 6 ? 3.0 : backlog > 3 ? 1.8 : 1.0;
    final boost = state.mode == GameMode.combat ? base * 1.6 : base; // fights read faster

    if (chars < cur.text.length) {
      _carry += _cps[speed] * boost * _tickMs / 1000;
      final n = _carry.floor();
      if (n > 0) {
        chars = min(cur.text.length, chars + n);
        _carry -= n;
        _tickCount++;
        if (_tickCount % 2 == 0) Fx.play(Sfx.tick);
        notifyListeners();
      }
      return;
    }
    if (!_effectRun) {
      _effectRun = true;
      _run(cur); // the result lands as the line finishes typing
      _lineSound(cur);
      _holdMs = (_hold(cur) * _holdScale[speed] / boost).round();
      return;
    }
    _holdMs -= _tickMs;
    if (_holdMs <= 0) {
      revealed.add(cur);
      _trim();
      current = null;
      chars = 0;
      _syncBusy();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (console) {
      state.onConsole = null;
      state.onConsoleReset = null;
    } else {
      state.onLog = null;
    }
    _timer?.cancel();
    busyNotifier.dispose();
    super.dispose();
  }
}
