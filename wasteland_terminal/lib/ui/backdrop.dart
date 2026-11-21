import 'package:flutter/material.dart';
import 'atlas.dart';
import 'crt.dart';
import 'theme.dart';

/// A dim, tiled interior wall behind a minigame or encounter screen (tiles are
/// derived art: 'bg.wall' concrete + pipe, 'bg.steel' riveted plate + hazard band).
/// Kept dark so the UI on top stays readable.
class Backdrop extends StatelessWidget {
  final String tile;
  final Widget child;
  const Backdrop({super.key, required this.tile, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!Atlas.has('derived')) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _TilePainter(tile, T.green)))),
        child,
      ],
    );
  }
}

class _TilePainter extends CustomPainter {
  final String tile;
  final Color tint;
  _TilePainter(this.tile, this.tint);

  @override
  void paint(Canvas canvas, Size size) {
    final sp = Atlas.named('derived', tile);
    if (sp == null) return;
    final s = (size.shortestSide / 3.2) / sp.w; // ~3 tiles across the short side
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..colorFilter = Crt.phosphor(tint, keep: 0.1, gain: 0.5);
    final tw = sp.w * s, th = sp.h * s;
    for (double y = 0; y < size.height; y += th - 0.5) {
      for (double x = 0; x < size.width; x += tw - 0.5) {
        sp.drawRect(canvas, Rect.fromLTWH(x, y, tw, th), paint);
      }
    }
    // Pull it back so text on top stays legible; darker towards the edges.
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = Colors.black.withValues(alpha: 0.5));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.95,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
          stops: const [0.4, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _TilePainter old) => old.tile != tile || old.tint != tint;
}
