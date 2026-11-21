import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crt.dart';
import 'theme.dart';

/// One sprite cut out of a sheet. Sheets are shared images; a sprite is only a
/// source rectangle plus a "foot anchor" (the x pixel its feet / base stand on),
/// so animation frames stay planted even when a rifle swings out.
class AtlasSprite {
  final ui.Image image;
  final Rect src;
  final double ax; // foot anchor x, in source pixels from the sprite's left edge
  /// False for sprites with lettering (signs, billboards): the scene never mirrors them.
  final bool flippable;
  const AtlasSprite(this.image, this.src, this.ax, [this.flippable = true]);

  double get w => src.width;
  double get h => src.height;

  /// A sub-rectangle of this sprite (pixels trimmed from each side).
  AtlasSprite crop({double left = 0, double right = 0, double top = 0, double bottom = 0}) =>
      AtlasSprite(
        image,
        Rect.fromLTRB(src.left + left, src.top + top, src.right - right, src.bottom - bottom),
        ax - left,
        flippable,
      );

  /// Draw with the foot anchor (bottom edge, [ax]) at [foot].
  void draw(Canvas canvas, Offset foot, double scale, Paint paint, {bool flip = false}) {
    final dw = w * scale, dh = h * scale;
    if (!flip) {
      canvas.drawImageRect(
          image, src, Rect.fromLTWH(foot.dx - ax * scale, foot.dy - dh, dw, dh), paint);
    } else {
      canvas.save();
      canvas.translate(foot.dx, foot.dy);
      canvas.scale(-1, 1);
      canvas.drawImageRect(image, src, Rect.fromLTWH(-ax * scale, -dh, dw, dh), paint);
      canvas.restore();
    }
  }

  /// Draw stretched into [dst] (used for tiling; [flip] mirrors horizontally).
  void drawRect(Canvas canvas, Rect dst, Paint paint, {bool flip = false}) {
    if (!flip) {
      canvas.drawImageRect(image, src, dst, paint);
    } else {
      canvas.save();
      canvas.translate(dst.right, 0);
      canvas.scale(-1, 1);
      canvas.drawImageRect(image, src, Rect.fromLTWH(0, dst.top, dst.width, dst.height), paint);
      canvas.restore();
    }
  }
}

class _Sheet {
  final ui.Image image;
  final List<AtlasSprite> sprites;
  final Map<String, int> names;
  final Map<String, List<int>> rows;
  final Map<String, List<int>> pools;
  final Map<String, dynamic> rigs;
  _Sheet(this.image, this.sprites, this.names, this.rows, this.pools, this.rigs);
}

/// The full-colour sprite sheets (see tools/slice_sheets.py). Loaded once at
/// start-up. Everything degrades to null / empty lists if a sheet is missing,
/// so callers can fall back to the older vector drawings.
///
/// Addressing:
///   Atlas.named('world_b', 'car.rust')        one sprite
///   Atlas.frames('world_b', 'dweller.b')      an animation row, left -> right
///   Atlas.pool('world_a', 'bld_a')            a pool for procedural scenery
///   Atlas.resolve('world_b#bld_b', rng)       "sheet:name" or "sheet#pool" strings
class Atlas {
  static const sheetNames = ['world_a', 'world_b', 'minigame', 'derived', 'scenery'];
  static final Map<String, _Sheet> _sheets = {};

  static bool get ready => _sheets.containsKey('world_a') && _sheets.containsKey('world_b');
  static bool has(String sheet) => _sheets.containsKey(sheet);

  static Future<void> load() async {
    for (final n in sheetNames) {
      try {
        final json = jsonDecode(await rootBundle.loadString('assets/atlas/$n.json'))
            as Map<String, dynamic>;
        final data = await rootBundle.load('assets/atlas/${json['image']}');
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final image = (await codec.getNextFrame()).image;
        final sprites = <AtlasSprite>[
          for (final s in json['sprites'] as List)
            AtlasSprite(
              image,
              Rect.fromLTWH((s['x'] as num).toDouble(), (s['y'] as num).toDouble(),
                  (s['w'] as num).toDouble(), (s['h'] as num).toDouble()),
              ((s['ax'] ?? (s['w'] as num) / 2) as num).toDouble(),
              (s['flip'] ?? true) as bool,
            ),
        ];
        Map<String, List<int>> lists(String k) => {
              for (final e in ((json[k] ?? {}) as Map<String, dynamic>).entries)
                e.key: (e.value as List).cast<int>(),
            };
        _sheets[n] = _Sheet(
          image,
          sprites,
          {
            for (final e in ((json['names'] ?? {}) as Map<String, dynamic>).entries)
              e.key: e.value as int,
          },
          lists('rows'),
          lists('pools'),
          Map<String, dynamic>.from((json['rigs'] ?? {}) as Map),
        );
      } catch (_) {
        // missing sheet: callers fall back to vector art
      }
    }
  }

  static AtlasSprite? named(String sheet, String name) {
    final s = _sheets[sheet];
    final i = s?.names[name];
    return (s == null || i == null) ? null : s.sprites[i];
  }

  static List<AtlasSprite> frames(String sheet, String row) {
    final s = _sheets[sheet];
    final r = s?.rows[row];
    return (s == null || r == null) ? const [] : [for (final i in r) s.sprites[i]];
  }

  static List<AtlasSprite> pool(String sheet, String pool) {
    final s = _sheets[sheet];
    final r = s?.pools[pool];
    return (s == null || r == null) ? const [] : [for (final i in r) s.sprites[i]];
  }

  /// Raw rig description (joint pivots etc.) written by tools/rig_dweller.py.
  static Map<String, dynamic>? rig(String sheet, String name) {
    final r = _sheets[sheet]?.rigs[name];
    return r == null ? null : Map<String, dynamic>.from(r as Map);
  }

  /// Like [resolve] but deterministic: pool members are picked by a golden-ratio
  /// sequence on [n], so consecutive picks are always different and spread
  /// evenly (a plain Random repeats the same few sprites far too often).
  static AtlasSprite? resolveAt(String ref, int n) {
    final hash = ref.indexOf('#');
    if (hash > 0) {
      final p = pool(ref.substring(0, hash), ref.substring(hash + 1));
      if (p.isEmpty) return null;
      return p[((n * 0.7548776662466927) % 1.0 * p.length).floor()];
    }
    final colon = ref.indexOf(':');
    return colon < 0 ? null : named(ref.substring(0, colon), ref.substring(colon + 1));
  }

  /// "sheet:name" -> that sprite; "sheet#pool" -> a random member of the pool.
  static AtlasSprite? resolve(String ref, Random rng) {
    final hash = ref.indexOf('#');
    if (hash > 0) {
      final p = pool(ref.substring(0, hash), ref.substring(hash + 1));
      return p.isEmpty ? null : p[rng.nextInt(p.length)];
    }
    final colon = ref.indexOf(':');
    return colon < 0 ? null : named(ref.substring(0, colon), ref.substring(colon + 1));
  }
}

/// A full-colour sprite shown at a fixed height, run through the CRT phosphor
/// filter so it sits in the same green world as the rest of the UI.
/// [keep] = how much of the original colour survives (0 = pure monochrome).
class AtlasImage extends StatelessWidget {
  final String sheet, name;
  final double height;
  final double keep;
  final Widget? fallback;
  const AtlasImage({
    super.key,
    required this.sheet,
    required this.name,
    required this.height,
    this.keep = 0.45,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final sp = Atlas.named(sheet, name);
    if (sp == null) return fallback ?? const SizedBox.shrink();
    return SizedBox(
      height: height,
      child: AspectRatio(
        aspectRatio: sp.w / sp.h,
        child: CustomPaint(painter: _AtlasImagePainter(sp, T.green, keep)),
      ),
    );
  }
}

class _AtlasImagePainter extends CustomPainter {
  final AtlasSprite sp;
  final Color tint;
  final double keep;
  _AtlasImagePainter(this.sp, this.tint, this.keep);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..colorFilter = Crt.phosphor(tint, keep: keep);
    sp.drawRect(canvas, Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _AtlasImagePainter old) =>
      old.sp != sp || old.tint != tint || old.keep != keep;
}
