import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../game/fx.dart';
import '../game/game_state.dart';
import '../game/hacking_session.dart';
import '../game/hacking_system.dart';
import '../game/typewriter.dart';
import 'blink_cursor.dart';
import 'atlas.dart';
import 'sprites.dart';
import 'theme.dart';

/// Main screen while hacking: a dense two-column wall of characters.
///
/// Every character is drawn in its own fixed cell, and taps are converted to
/// cells with the same numbers, so painting and touch can never drift apart
/// and nothing moves when a word is dotted out.
///
/// Grid columns per line (37): addr(4) space(1) chars(12) gap(3) addr(4) space(1) chars(12)
class HackingView extends StatelessWidget {
  static const int _cols = 37;
  static const int _leftStart = 5, _rightStart = 25, _width = 12;

  final GameState state;
  final HackingSystem system;
  final TypewriterController typer; // encounter console (instant during hacks)
  const HackingView({
    super.key,
    required this.state,
    required this.system,
    required this.typer,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.hacking!;
    if (!s.engaged) return _prompt(s);

    return LayoutBuilder(builder: (context, box) {
      const pad = 8.0;
      final lines = HackingSession.rowsPerColumn;
      final w = box.maxWidth - pad * 2;
      final h = (box.maxHeight.isFinite ? box.maxHeight : 600) - pad * 2;

      // Fit width AND height: 2 header lines, 16 grid rows, a 36px prompt row
      // and a 3-line console.
      final cellW = w / _cols;
      var fs = min(18.0, cellW / 0.55);
      fs = min(fs, (h - 48) / 21.1);
      fs = max(fs, 6.0);
      final cellH = max(fs * 1.1, min((h - 2.7 * fs - 48) / lines, fs * 1.9));
      final cur = s.selected == null ? null : s.tokens[s.selected!];
      final shown = cur == null ? '' : s.rows[cur.row].substring(cur.start, cur.end);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SEC LV ${s.level}   ENTER PASSWORD NOW',
                style: T.mono(T.green, size: fs, bold: true)),
            Text(
              'ATTEMPTS: ${'■ ' * s.attempts}${'□ ' * (s.maxAttempts - s.attempts)}',
              style: T.mono(s.attempts <= 1 ? T.red : T.green, size: fs, bold: true),
            ),
            const SizedBox(height: 4),
            Stack(children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => _tap(
                  (d.localPosition.dy / cellH).floor(),
                  (d.localPosition.dx / cellW).floor(),
                ),
                child: CustomPaint(
                  size: Size(cellW * _cols, cellH * lines),
                  painter: _GridPainter(s, fs, cellW, cellH),
                ),
              ),
              Positioned.fill(
                child: _ResultFlash(
                  attempts: s.attempts,
                  finished: s.finished,
                  success: s.success,
                  height: cellH * lines,
                ),
              ),
            ]),
            // Fixed-height row so nothing shifts when the hack finishes.
            SizedBox(
              height: 36,
              child: s.finished
                  ? Row(children: [
                      Expanded(
                        child: Text(
                          s.success
                              ? (s.flawless ? 'ACCESS GRANTED - FLAWLESS' : 'ACCESS GRANTED')
                              : 'TERMINAL LOCKED OUT',
                          style: T.mono(s.success ? T.loot : T.red, size: fs, bold: true),
                        ),
                      ),
                      _Btn('[CONTINUE]', T.green, system.leave, minHeight: 34),
                    ])
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: _TypedPrompt(
                        text: shown,
                        style: T.mono(T.green, size: fs, bold: true),
                        size: fs,
                        instant: state.textSpeed >= 3,
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  void _tap(int r, int c) {
    final lines = HackingSession.rowsPerColumn;
    if (r < 0 || r >= lines) return;
    if (c >= _leftStart && c < _leftStart + _width) {
      system.tap(r, c - _leftStart);
    } else if (c >= _rightStart && c < _rightStart + _width) {
      system.tap(r + lines, c - _rightStart);
    } else {
      system.tap(-1, -1); // clears highlight
    }
  }

  Widget _prompt(HackingSession s) => LayoutBuilder(builder: (context, c) {
        // The picture takes whatever room is left (the framed panel is smaller than
        // the old bare one); the column scrolls only as a last resort.
        final img = (c.maxHeight - 150).clamp(48.0, 120.0).toDouble();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SECURITY TERMINAL DETECTED', style: T.mono(T.amber, bold: true)),
              Text('SECURITY LEVEL: ${s.level}', style: T.mono(T.dim)),
              Text('TYPE: ${s.typeName}', style: T.mono(T.dim)),
              const SizedBox(height: 8),
              AtlasImage(
                sheet: 'minigame',
                name: s.level.isEven ? 'iso.desk' : 'computer',
                height: img,
                fallback: const SpriteView(name: 'loc_terminal', height: 84),
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 10, children: [
                _Btn('[HACK]', T.green, system.engage),
                _Btn('[IGNORE]', T.amber, system.ignore),
              ]),
            ],
          ),
        );
      });
}

/// The selected word, typed out quickly with key clicks each time it changes.
class _TypedPrompt extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double size;
  final bool instant;
  const _TypedPrompt({
    required this.text,
    required this.style,
    required this.size,
    required this.instant,
  });
  @override
  State<_TypedPrompt> createState() => _TypedPromptState();
}

class _TypedPromptState extends State<_TypedPrompt> {
  Timer? _t;
  int _n = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(_TypedPrompt old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) _start();
  }

  void _start() {
    _t?.cancel();
    _n = 0;
    final len = widget.text.length;
    if (len == 0) return;
    if (widget.instant) {
      _n = len;
      return;
    }
    _t = Timer.periodic(const Duration(milliseconds: 30), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _n++);
      Fx.play(Sfx.tick);
      if (_n >= len) t.cancel();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final len = widget.text.length;
    final shown = widget.text.substring(0, min(_n, len));
    return Text.rich(
      TextSpan(text: '> $shown', style: widget.style, children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: BlinkCursor(solid: _n < len, size: widget.size),
        ),
      ]),
    );
  }
}

class _GridPainter extends CustomPainter {
  final HackingSession s;
  final double fs, cellW, cellH;
  final Map<String, TextPainter> _cache = {};
  _GridPainter(this.s, this.fs, this.cellW, this.cellH);

  String _addr(int row) =>
      (0xF4A0 + row * 12).toRadixString(16).toUpperCase().padLeft(4, '0');

  // style: 0 = normal, 1 = dim, 2 = highlighted (dark on green)
  TextPainter _glyph(String ch, int style) {
    return _cache.putIfAbsent('$style$ch', () {
      final color = style == 0 ? T.green : (style == 1 ? T.dim : T.bg);
      return TextPainter(
        text: TextSpan(
          text: ch,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: fs,
            color: color,
            fontWeight: style == 2 ? FontWeight.bold : FontWeight.normal,
            shadows: style == 2 || !T.current.glow
                ? null
                : [Shadow(color: color.withOpacity(0.5), blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    });
  }

  void _put(Canvas canvas, String ch, int style, int col, int line) {
    if (ch == ' ') return;
    final tp = _glyph(ch, style);
    // Centre each glyph in its own cell, so the grid is fixed whatever the font.
    tp.paint(
      canvas,
      Offset(col * cellW + (cellW - tp.width) / 2, line * cellH + (cellH - tp.height) / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final lines = HackingSession.rowsPerColumn;
    final cur = s.selected == null ? null : s.tokens[s.selected!];

    // Highlight block behind the selected token.
    if (cur != null) {
      final right = cur.row >= lines;
      final base = right ? HackingView._rightStart : HackingView._leftStart;
      canvas.drawRect(
        Rect.fromLTWH((base + cur.start) * cellW, (cur.row % lines) * cellH,
            cur.length * cellW, cellH),
        Paint()..color = T.green,
      );
    }

    for (int line = 0; line < lines; line++) {
      for (int side = 0; side < 2; side++) {
        final row = line + side * lines;
        final colBase = side == 0 ? HackingView._leftStart : HackingView._rightStart;
        final addr = _addr(row);
        for (int i = 0; i < 4; i++) {
          _put(canvas, addr[i], 1, colBase - 5 + i, line);
        }
        final text = s.rows[row];
        for (int c = 0; c < text.length; c++) {
          final hi = cur != null && cur.row == row && c >= cur.start && c < cur.end;
          _put(canvas, text[c], hi ? 2 : 0, colBase + c, line);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => true;
}

/// CRT result screens from the art sheet: "Access Denied" flashes on a wrong
/// guess; "CORRECT" / "System Lockout" stay once the hack is over.
class _ResultFlash extends StatefulWidget {
  final int attempts;
  final bool finished, success;
  final double height;
  const _ResultFlash({
    required this.attempts,
    required this.finished,
    required this.success,
    required this.height,
  });

  @override
  State<_ResultFlash> createState() => _ResultFlashState();
}

class _ResultFlashState extends State<_ResultFlash> {
  Timer? _timer;
  bool _denied = false;

  @override
  void didUpdateWidget(covariant _ResultFlash old) {
    super.didUpdateWidget(old);
    if (widget.attempts < old.attempts && !widget.finished) {
      _timer?.cancel();
      setState(() => _denied = true);
      _timer = Timer(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _denied = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.finished
        ? (widget.success ? 'screen.correct' : 'screen.lockout')
        : (_denied ? 'screen.denied' : null);
    if (name == null || !Atlas.has('minigame')) return const SizedBox.shrink();
    return IgnorePointer(
      child: Center(
        child: AtlasImage(
          sheet: 'minigame',
          name: name,
          height: min(widget.height * 0.5, 170).toDouble(),
          keep: 0.7,
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final double minHeight;
  const _Btn(this.label, this.color, this.onTap, {this.minHeight = 44});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              Fx.play(Sfx.beep);
              onTap!();
            },
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label, style: T.mono(color, bold: true)),
        ),
      ),
    );
  }
}
