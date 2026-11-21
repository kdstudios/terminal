import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/fx.dart';
import 'crt.dart';
import 'theme.dart';

/// The riveted-metal border texture (assets/ui/terminal_frame.png, 938x937).
/// Measured once from the art: border thickness per side, and the square corner
/// patch that holds the rivet + the rounded inner corner.
class FrameSkin {
  static ui.Image? image;

  static const double left = 26, right = 22, top = 20, bottom = 20; // border thickness (px)
  static const double corner = 40; // square corner patch (px)
  static const double seg = 200; // length of the edge segment that is tiled (px)

  static Future<void> load() async {
    try {
      final data = await rootBundle.load('assets/ui/terminal_frame.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      image = (await codec.getNextFrame()).image;
    } catch (_) {
      // missing art: MetalFrame falls back to a plain bordered box
    }
  }
}

/// Wraps [child] in the metal frame at any size, 9-slice style and WITHOUT
/// stretching: the four corners are drawn 1:1 (scaled uniformly), and each edge
/// is a short central segment of the texture repeated along the side, every
/// second copy mirrored so the seams are invisible. The content is clipped to
/// the frame's rounded window and the frame is drawn over it.
class MetalFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  const MetalFrame({super.key, required this.child, this.margin = const EdgeInsets.all(3)});

  /// Uniform texture scale (logical px per texture px). Tracks the screen so the
  /// border keeps the concept's proportions on phones and tablets alike.
  static double scaleFor(BuildContext context) =>
      (MediaQuery.of(context).size.shortestSide / 760).clamp(0.42, 0.6).toDouble();

  @override
  Widget build(BuildContext context) {
    final img = FrameSkin.image;
    if (img == null) return _fallback();
    final k = scaleFor(context);
    final pad = EdgeInsets.fromLTRB(
        FrameSkin.left * k, FrameSkin.top * k, FrameSkin.right * k, FrameSkin.bottom * k);
    // Non-green themes recolour the metal so amber / ice frames still match.
    final filter = Fx.settings.theme == 0 ? null : Crt.phosphor(T.green, keep: 0.3);
    return Padding(
      padding: margin,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: pad,
            child: ClipRRect(borderRadius: BorderRadius.circular(12 * k * 1.6), child: child),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _FramePainter(img, k, filter)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Padding(
        padding: margin,
        child: Container(
          decoration: BoxDecoration(
            color: T.panel,
            border: Border.all(color: T.dim, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
        ),
      );
}

class _FramePainter extends CustomPainter {
  final ui.Image img;
  final double k;
  final ColorFilter? filter;
  _FramePainter(this.img, this.k, this.filter);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..filterQuality = FilterQuality.medium // mip-mapped: crisp when scaled down
      ..colorFilter = filter;
    final iw = img.width.toDouble(), ih = img.height.toDouble();
    const cn = FrameSkin.corner;
    final cs = cn * k;

    // Corners (never stretched, only uniformly scaled).
    c.drawImageRect(img, const Rect.fromLTWH(0, 0, cn, cn), Rect.fromLTWH(0, 0, cs, cs), p);
    c.drawImageRect(img, Rect.fromLTWH(iw - cn, 0, cn, cn), Rect.fromLTWH(s.width - cs, 0, cs, cs), p);
    c.drawImageRect(img, Rect.fromLTWH(0, ih - cn, cn, cn), Rect.fromLTWH(0, s.height - cs, cs, cs), p);
    c.drawImageRect(img, Rect.fromLTWH(iw - cn, ih - cn, cn, cn),
        Rect.fromLTWH(s.width - cs, s.height - cs, cs, cs), p);

    // Horizontal edges: tile a central segment, mirroring every other copy.
    void hEdge(double srcY, double srcH, double dstY) {
      final src = Rect.fromLTWH(iw / 2 - FrameSkin.seg / 2, srcY, FrameSkin.seg, srcH);
      final tw = FrameSkin.seg * k, th = srcH * k, end = s.width - cs;
      double x = cs;
      for (int i = 0; x < end - 0.01; i++, x += tw) {
        c.save();
        c.clipRect(Rect.fromLTWH(x, dstY, min(tw, end - x), th), doAntiAlias: false);
        if (i.isOdd) {
          c.translate(x + tw, dstY);
          c.scale(-1, 1);
          c.drawImageRect(img, src, Rect.fromLTWH(0, 0, tw, th), p);
        } else {
          c.drawImageRect(img, src, Rect.fromLTWH(x, dstY, tw, th), p);
        }
        c.restore();
      }
    }

    // Vertical edges: same idea, mirrored top-to-bottom.
    void vEdge(double srcX, double srcW, double dstX) {
      final src = Rect.fromLTWH(srcX, ih / 2 - FrameSkin.seg / 2, srcW, FrameSkin.seg);
      final tw = srcW * k, th = FrameSkin.seg * k, end = s.height - cs;
      double y = cs;
      for (int i = 0; y < end - 0.01; i++, y += th) {
        c.save();
        c.clipRect(Rect.fromLTWH(dstX, y, tw, min(th, end - y)), doAntiAlias: false);
        if (i.isOdd) {
          c.translate(dstX, y + th);
          c.scale(1, -1);
          c.drawImageRect(img, src, Rect.fromLTWH(0, 0, tw, th), p);
        } else {
          c.drawImageRect(img, src, Rect.fromLTWH(dstX, y, tw, th), p);
        }
        c.restore();
      }
    }

    hEdge(0, FrameSkin.top, 0);
    hEdge(ih - FrameSkin.bottom, FrameSkin.bottom, s.height - FrameSkin.bottom * k);
    vEdge(0, FrameSkin.left, 0);
    vEdge(iw - FrameSkin.right, FrameSkin.right, s.width - FrameSkin.right * k);
  }

  @override
  bool shouldRepaint(covariant _FramePainter old) =>
      old.img != img || old.k != k || old.filter != filter;
}
