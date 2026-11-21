import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'fx.dart';
import 'game_state.dart';
import 'lockpick_session.dart';
import 'quests.dart';

/// Runs lockpicking: offering, the physics tick, rewards and pick breakage.
class LockpickingSystem {
  final GameState state;
  final Random _rng;
  Timer? _timer;
  final Stopwatch _sw = Stopwatch();
  int _ticks = 0;

  LockpickingSystem(this.state, {Random? rng}) : _rng = rng ?? Random();

  void dispose() => _stop();

  /// Called by exploration when a locked container is found.
  void offerLock() {
    if (state.lockpicks <= 0) {
      state.addLog('> LOCKED CONTAINER DETECTED', LogKind.warning, notify: false);
      state.addLog('You have no lockpicks, so you leave it behind.', LogKind.narrative);
      return;
    }
    state.resetConsole();
    var level = min(6, 1 + state.distanceKm ~/ 2.7);
    if (level > 1 && _rng.nextDouble() < 0.3) level--;
    state.lockpick = LockpickSession.generate(level, _rng,
        strain: state.pickStrain, skill: state.skill('LOCKPICKING'));
    state.mode = GameMode.lockpicking;
    state.refresh(); // the prompt screen shows the lock and your pick's wear
  }

  void engage() {
    final s = state.lockpick;
    if (s == null || s.engaged) return;
    s.engaged = true;
    Fx.play(Sfx.click);
    state.addLog('Drag to aim the pick, pull the lever to turn. Over-pulling strains it.',
        LogKind.narrative);
    _startTimer();
  }

  /// After loading a save: restart the physics if a lock was in progress.
  void resume() {
    final s = state.lockpick;
    if (s == null || !s.engaged || s.finished) return;
    _startTimer();
  }

  void _startTimer() {
    _sw
      ..reset()
      ..start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  void ignore() {
    _end();
    state.addLog('You leave the lock alone and press on.', LogKind.narrative);
  }

  void leave() {
    final s = state.lockpick;
    if (s == null || !s.finished) return;
    _end();
  }

  double _clickAcc = 0;

  /// A quiet ratchet click every few degrees as the pick turns.
  void rotate(double degrees) {
    final s = state.lockpick;
    if (s == null) return;
    final before = s.pickAngle;
    s.rotate(degrees);
    _clickAcc += (s.pickAngle - before).abs();
    if (_clickAcc >= 4) {
      _clickAcc = 0;
      Fx.play(Sfx.click, gain: 0.3);
    }
  }
  void grip(bool v) => state.lockpick?.grip(v);
  void dragLever(double d) => state.lockpick?.dragLever(d);

  void _tick() {
    final s = state.lockpick;
    if (s == null || !s.engaged || s.finished) {
      _stop();
      return;
    }
    final dt = min(0.05, _sw.elapsedMicroseconds / 1e6);
    _sw.reset();
    _ticks++;
    final ev = s.step(dt);
    state.pickStrain = s.stress; // wear persists between locks
    if (s.blocked && _ticks % 8 == 0) {
      Fx.light();
      Fx.play(Sfx.click);
    }
    if (ev == LockEvent.opened) _opened(s);
    if (ev == LockEvent.snapped) _snapped(s);
  }

  void _opened(LockpickSession s) {
    _stop();
    Fx.play(Sfx.confirm);
    Fx.heavy();
    s.flawless = s.broken == 0;
    final reward = state.withBench(20 * s.level + _rng.nextInt(15));
    final bonus = s.flawless ? 10 * s.level : 0;
    state.addLog('> LOCK OPENED', LogKind.system, notify: false);
    if (s.flawless) {
      state.addLog('> CLEAN OPEN BONUS', LogKind.loot, notify: false, recap: false);
    }
    state.addLog('+ ${reward + bonus} SCRAP', LogKind.loot, notify: false);
    if (_rng.nextDouble() < 0.25) {
      state.lockpicks++;
      state.addLog('+ 1 LOCKPICK', LogKind.loot, notify: false);
    }
    // Every lock leaves its mark on the pick, even a clean open.
    s.stress = min(0.97, s.stress + 0.05 + 0.04 * s.level);
    state.pickStrain = s.stress;
    state.gainXp(15 * s.level);
    state.gainSkill('LOCKPICKING');
    state.questEvent(QuestKind.locks, 1);
    state.addScrap(reward + bonus);
    s.refresh();
  }

  void _snapped(LockpickSession s) {
    state.lockpicks--;
    s.broken++;
    Fx.play(Sfx.snap);
    Fx.heavy();
    state.pickStrain = 0; // fresh pick
    state.addLog('> LOCKPICK SNAPPED. PICKS LEFT: ${state.lockpicks}', LogKind.danger);
    if (state.lockpicks <= 0) {
      s.finished = true;
      s.success = false;
      _stop();
      state.addLog('> LOCK JAMMED. OUT OF LOCKPICKS.', LogKind.danger);
      s.refresh();
    } else {
      s.resetPick();
    }
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _end() {
    _stop();
    final s = state.lockpick;
    final String result = s == null || !s.finished ? 'IGNORED' : (s.success ? 'SUCCESS' : 'FAILED');
    state.lockpick = null;
    state.mode = GameMode.exploring;
    state.endEncounter(
        summary: '> LOCKPICK: $result',
        kind: result == 'FAILED' ? LogKind.warning : LogKind.system);
    state.refresh();
    state.onEncounterEnd?.call('lock', result.toLowerCase());
  }
}
