import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'theme.dart';

/// Green-phosphor CRT look: a colour filter for sprites plus a screen overlay.
class Crt {
  static final Map<String, ColorFilter> _cache = {};

  /// Maps luminance onto [tint] (the terminal theme colour), keeping [keep] of
  /// the original colour so key sprites (the dweller's suit) still read.
  /// [gain] dims (<1) or boosts (>1) everything; far scenery uses a low gain.
  /// Cached: building matrices every frame would be wasteful on mobile.
  static ColorFilter phosphor(Color tint, {double keep = 0.12, double gain = 1.0}) {
    return _cache.putIfAbsent('${tint.toARGB32()}|$keep|$gain', () {
      const lr = 0.2126, lg = 0.7152, lb = 0.0722;
      final k = 1 - keep;
      List<double> row(int channel, double t) {
        final m = k * t;
        return [
          (channel == 0 ? keep : 0) * gain + m * lr * gain,
          (channel == 1 ? keep : 0) * gain + m * lg * gain,
          (channel == 2 ? keep : 0) * gain + m * lb * gain,
          0,
          0,
        ];
      }

      return ColorFilter.matrix([
        ...row(0, tint.r),
        ...row(1, tint.g),
        ...row(2, tint.b),
        0, 0, 0, 1, 0,
      ]);
    });
  }
}

/// A CRT monitor face: dark tube gradient, optional title strip, content, and
/// the scanline / vignette / glass-sheen overlay on top.
class CrtScreen extends StatelessWidget {
  final String? title;
  final Widget child;
  const CrtScreen({super.key, this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [T.panel, Color.lerp(T.panel, T.green, 0.06)!],
            ),
          ),
        ),
        Column(
          children: [
            if (title != null) _TitleStrip(title!),
            Expanded(child: child),
          ],
        ),
        const Positioned.fill(child: CrtOverlay()),
      ],
    );
  }
}

class _TitleStrip extends StatelessWidget {
  final String title;
  const _TitleStrip(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: T.green.withValues(alpha: 0.10),
        border: Border(bottom: BorderSide(color: T.dim.withValues(alpha: 0.55))),
      ),
      child: Text('[$title]',
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: T.mono(T.green, size: 13, bold: true)),
    );
  }
}

/// Static overlay (no animation, so it costs one cheap repaint per layout).
class CrtOverlay extends StatelessWidget {
  const CrtOverlay({super.key});

  @override
  Widget build(BuildContext context) =>
      IgnorePointer(child: CustomPaint(painter: _CrtPainter(T.green, T.current.glow)));
}

class _CrtPainter extends CustomPainter {
  final Color tint;
  final bool enabled; // the high-contrast theme turns the effect off
  const _CrtPainter(this.tint, this.enabled);

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) return;
    final rect = Offset.zero & size;
    // Glass sheen on the upper part of the tube.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.35),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tint.withValues(alpha: 0.06), Colors.transparent],
        ).createShader(rect),
    );
    // Vignette: the tube is darker towards its curved edges.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 1.0,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.42)],
          stops: const [0.62, 1.0],
        ).createShader(rect),
    );
    // Scanlines: one batched draw call.
    final pts = <Offset>[];
    for (double y = 1; y < size.height; y += 3) {
      pts.add(Offset(0, y));
      pts.add(Offset(size.width, y));
    }
    canvas.drawPoints(
      ui.PointMode.lines,
      pts,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _CrtPainter old) => old.tint != tint || old.enabled != enabled;
}
