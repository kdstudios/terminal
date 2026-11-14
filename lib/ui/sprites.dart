import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/combat_session.dart';
import 'theme.dart';

/// Every choice-encounter picture that has art.
const eventSpriteIds = [
  'merchant', 'survivor', 'building', 'signal', 'camp', 'cave', 'vault', 'wreck',
  'shrine', 'rival', 'tunnel', 'nest', 'drifter', 'drone', 'pond', 'gang',
];

/// Pixel-art images (white with four alpha levels), loaded once at start-up and
/// tinted with the current terminal theme colour when drawn. If an image is
/// missing, callers fall back to the old vector drawings.
class Sprites {
  static final Map<String, ui.Image> _img = {};

  static List<String> get names => [
        for (final t in EnemyType.values) 'enemy_${t.name}',
        for (int i = 0; i < 4; i++) 'player_$i',
        for (int i = 0; i < 6; i++) ...['bg_far_$i', 'bg_mid_$i', 'ground_$i'],
        for (final e in eventSpriteIds) 'event_$e',
        'loc_terminal',
        'loc_chest',
        'loc_safehouse',
      ];

  static Future<void> loadAll() async {
    for (final n in names) {
      try {
        final data = await rootBundle.load('assets/images/$n.png');
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _img[n] = frame.image;
      } catch (_) {
        // missing art: the game falls back to its vector drawings
      }
    }
  }

  static ui.Image? get(String name) => _img[name];
  static bool has(String name) => _img.containsKey(name);

  /// Draw [name] into [dst] with crisp pixels, tinted [color]. False if missing.
  static bool draw(Canvas canvas, String name, Rect dst, Color color, {double opacity = 1}) {
    final im = _img[name];
    if (im == null) return false;
    final src = Rect.fromLTWH(0, 0, im.width.toDouble(), im.height.toDouble());
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..colorFilter = ColorFilter.mode(color.withOpacity(opacity), BlendMode.srcIn);
    canvas.drawImageRect(im, src, dst, paint);
    return true;
  }
}

/// A sprite shown at a fixed height, keeping its proportions.
class SpriteView extends StatelessWidget {
  final String name;
  final double height;
  final Color? color;
  const SpriteView({super.key, required this.name, required this.height, this.color});

  @override
  Widget build(BuildContext context) {
    final im = Sprites.get(name);
    if (im == null) return const SizedBox.shrink();
    return SizedBox(
      height: height,
      child: AspectRatio(
        aspectRatio: im.width / im.height,
        child: CustomPaint(painter: _SpritePainter(name, color ?? T.green)),
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final String name;
  final Color color;
  _SpritePainter(this.name, this.color);

  @override
  void paint(Canvas canvas, Size size) =>
      Sprites.draw(canvas, name, Offset.zero & size, color);

  @override
  bool shouldRepaint(covariant _SpritePainter old) => old.name != name || old.color != color;
}
