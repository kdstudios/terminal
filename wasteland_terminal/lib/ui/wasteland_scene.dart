import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../game/fx.dart';
import 'atlas.dart';
import 'crt.dart';
import 'dweller_rig.dart';
import 'theme.dart';

/// What each region is built from. Refs are "sheet:name" (one sprite) or
/// "sheet#pool" (cycled through evenly, see Atlas.resolveAt). Index = the
/// region's index in world.dart's [regions].
class SceneTheme {
  final List<String> ground; // patchwork of ground chunks
  final List<String> far, mid, near; // skyline / ruins / roadside props
  final List<String> detail; // small clutter on the ground line (also foreground)
  final String ridge; // distant ridge / treeline tile behind the far plain
  final bool mushroom; // the cloud hangs over the horizon
  SceneTheme({
    required this.ridge,
    required this.ground,
    required this.far,
    required this.mid,
    required this.near,
    required this.detail,
    this.mushroom = false,
  });
}

// All scenery now comes from the 'scenery' atlas (tools/pack_scenery.py). Short names keep the
// theme tables readable: _s('bld.block.tan') -> 'scenery#bld.block.tan'.
String _s(String pool) => 'scenery#$pool';

final _clutter = [
  _s('rock.small'), _s('shrub'), _s('prop.tiny'), _s('rock.small'), _s('shrub'), _s('prop.tiny'),
  _s('tumble'),
];

/// Floor strip geometry, in sheet pixels. The dweller and the props stand near
/// the BOTTOM of the textured strip (kFeetDepth), like the artwork implies.
const double kBandHeight = 40;
const double kFeetDepth = 36;

// Far clouds are small and dim; near clouds are big, layered banks.
const _cloudsFar = ['derived:sky.cloud0', 'derived:sky.cloud6', 'derived:sky.cloud5', 'derived:sky.cloud1'];
const _cloudsNear = ['derived:sky.cloud2', 'derived:sky.cloud3', 'derived:sky.cloud4', 'derived:sky.cloud7'];

final sceneThemes = <SceneTheme>[
  // 0 DUSTY HIGHWAY: tan ruins, roadside signs, wrecks on the shoulder
  SceneTheme(
    ridge: 'derived:ridge.hills',
    ground: [_s('ground.road'), _s('ground.road'), _s('ground.dirt'), _s('ground.road')],
    far: [
      _s('bld.far.tan'), _s('bld.block.tan'), _s('bld.low.tan'), _s('bld.far.tan'), _s('tree.dead'),
      _s('bld.block.tan'), _s('bld.landmark'), _s('bld.low.tan'), _s('bld.block.tan'),
    ],
    mid: [
      _s('bld.roadside'), _s('bld.block.tan'), _s('bld.low.tan'), _s('prop.landsign'),
      _s('bld.landmark'), _s('bld.block.tan'), _s('bld.roadside'), _s('bld.spire'), _s('bld.low.tan'),
    ],
    near: [
      _s('prop.pole'), _s('veh.any'), _s('prop.sign'), _s('prop.small'), _s('prop.fence'),
      _s('tree.dead'), _s('prop.pole'), _s('veh.wreck'), _s('prop.small'), _s('prop.sign'),
    ],
    detail: _clutter,
  ),
  // 1 RUSTED OUTSKIRTS: industry, towers, crates and fences
  SceneTheme(
    ridge: 'derived:ridge.hills',
    ground: [_s('ground.dirt'), _s('ground.rubble'), _s('ground.dirt'), _s('ground.grass')],
    far: [
      _s('bld.block.tan'), _s('bld.far.tan'), _s('bld.low.tan'), _s('bld.landmark'), _s('tree.dead'),
      _s('bld.block.tan'), _s('bld.far.tan'), _s('bld.low.tan'),
    ],
    mid: [
      _s('bld.landmark'), _s('bld.block.tan'), _s('bld.roadside'), _s('bld.low.tan'), _s('bld.spire'),
      _s('bld.block.tan'), _s('prop.big'), _s('bld.landmark'), _s('bld.block.tan'), _s('bld.pole'),
    ],
    near: [
      _s('prop.small'), _s('prop.fence'), _s('veh.any'), _s('prop.pole'), _s('prop.sign'),
      _s('prop.small'), _s('prop.fence'), _s('tree.dead'), _s('rock.big'), _s('prop.big'),
    ],
    detail: _clutter,
  ),
  // 2 GLASSED BASIN: bleached desert under the cloud
  SceneTheme(
    ridge: 'derived:ridge.mountains',
    ground: [_s('ground.dirt'), _s('ground.rubble'), _s('ground.dirt')],
    far: [
      _s('bld.far.tan'), _s('tree.dead'), _s('bld.block.tan'), _s('tree.cactus'), _s('bld.spire'),
      _s('bld.low.tan'), _s('tree.dead'), _s('bld.far.tan'), _s('tree.cactus'),
    ],
    mid: [
      _s('bld.block.tan'), _s('bld.landmark'), _s('tree.cactus'), _s('bld.low.tan'), _s('bunker'),
      _s('tree.dead'), _s('bld.block.tan'), _s('bld.spire'), _s('tree.cactus'),
    ],
    near: [
      _s('rock.big'), _s('tree.dead'), _s('tree.cactus'), _s('prop.small'), _s('veh.wreck'),
      _s('prop.sign'), _s('bones'), _s('rock.big'), _s('tree.cactus'), _s('prop.pole'),
    ],
    detail: _clutter,
    mushroom: true,
  ),
  // 3 DROWNED SUBURBS: overgrown houses and ruins in forest
  SceneTheme(
    ridge: 'derived:ridge.treeline',
    ground: [_s('ground.grass'), _s('ground.dirt'), _s('ground.grass'), _s('ground.road')],
    far: [
      _s('bld.far.green'), _s('tree.pine'), _s('tree.leaf'), _s('bld.block.green'), _s('tree.leaf'),
      _s('tree.pine'), _s('bld.low.green'), _s('tree.leaf'), _s('bld.far.green'), _s('tree.pine'),
    ],
    mid: [
      _s('house'), _s('tree.leaf'), _s('house'), _s('bld.block.green'), _s('tree.pine'),
      _s('tree.leaf'), _s('bld.roadside'), _s('bld.low.green'), _s('house'), _s('tree.leaf'),
    ],
    near: [
      _s('tree.leaf'), _s('tree.pine'), _s('shrub'), _s('prop.fence'), _s('veh.any'),
      _s('prop.pole'), _s('prop.small'), _s('tree.leaf'), _s('prop.sign'), _s('shrub'),
    ],
    detail: _clutter,
  ),
  // 4 IRON GRAVEYARD: wrecks, bunkers, radar and rust
  SceneTheme(
    ridge: 'derived:ridge.hills',
    ground: [_s('ground.rubble'), _s('ground.dirt'), _s('ground.rubble'), _s('ground.road')],
    far: [
      _s('bld.far.tan'), _s('bld.spire'), _s('bld.block.tan'), _s('bld.landmark'), _s('bld.pole'),
      _s('bld.low.tan'), _s('bld.far.tan'), _s('bld.block.tan'),
    ],
    mid: [
      _s('veh.crashed'), _s('bld.block.tan'), _s('bunker'), _s('bld.landmark'), _s('bld.low.tan'),
      _s('bld.spire'), _s('veh.wreck'), _s('bld.block.tan'), _s('prop.big'),
    ],
    near: [
      _s('veh.wreck'), _s('veh.any'), _s('prop.big'), _s('prop.small'), _s('prop.fence'),
      _s('rock.big'), _s('prop.pole'), _s('prop.tiny'), _s('veh.truck'), _s('tree.dead'),
    ],
    detail: _clutter,
  ),
  // 5 ASHEN HEIGHTS: pines, mossy towers, broken rock
  SceneTheme(
    ridge: 'derived:ridge.mountains',
    ground: [_s('ground.rubble'), _s('ground.grass'), _s('ground.dirt'), _s('ground.rubble')],
    far: [
      _s('bld.far.green'), _s('tree.pine'), _s('bld.block.green'), _s('tree.dead'), _s('tree.pine'),
      _s('bld.far.green'), _s('tree.leaf'), _s('bld.low.green'), _s('tree.pine'),
    ],
    mid: [
      _s('bld.block.green'), _s('tree.pine'), _s('bld.landmark'), _s('tree.pine'), _s('bld.low.green'),
      _s('tree.dead'), _s('bld.spire'), _s('tree.leaf'), _s('bld.block.green'), _s('bunker'),
    ],
    near: [
      _s('tree.pine'), _s('tree.dead'), _s('rock.big'), _s('tree.pine'), _s('prop.pole'),
      _s('prop.small'), _s('shrub'), _s('rock.big'), _s('tree.leaf'), _s('prop.fence'),
    ],
    detail: _clutter,
  ),
];

/// Drives the scene. Time-based and integrated every frame (NOT from the game's
/// distance ticks, which arrive in steps and made everything jump). Units are
/// "sheet pixels": the painter converts to screen pixels, so the gait stays in
/// step with the scroll at any screen size.
class SceneClock extends ChangeNotifier {
  static const double speed = 62; // sheet px per second at full walk
  double scroll = 0; // sheet px walked
  double phase = 0; // gait phase, radians (tied to distance => feet don't skate)
  double energy = 0; // 0 standing .. 1 full stride (eased: smooth start / stop)
  double time = 0; // seconds, for idle breathing

  void step(double dt, {required bool walking, required bool animate}) {
    if (animate) time += dt;
    final target = (walking && animate) ? 1.0 : 0.0;
    energy += (target - energy) * (1 - exp(-dt * 7));
    if ((energy - target).abs() < 0.003) energy = target;
    final d = speed * energy * dt;
    scroll += d;
    phase += d / DwellerRig.stridePx * 2 * pi;
    notifyListeners();
  }
}

/// Hosts the clock + painter. Rebuilt by the game only when [walking] / [region]
/// change; the per-frame work is the Ticker, not widget rebuilds.
class WastelandView extends StatefulWidget {
  final int region;
  final bool walking;
  const WastelandView({super.key, required this.region, required this.walking});

  @override
  State<WastelandView> createState() => _WastelandViewState();
}

class _WastelandViewState extends State<WastelandView> with SingleTickerProviderStateMixin {
  // Shared on purpose: coming back from an encounter must not rewind the world.
  static final SceneClock _shared = SceneClock();
  SceneClock get _clock => _shared;
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05).toDouble();
      _last = elapsed;
      _clock.step(dt, walking: widget.walking, animate: !Fx.settings.reducedMotion);
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: WastelandScenePainter(clock: _clock, region: widget.region),
        ),
      );
}

class _Placed {
  final AtlasSprite sp;
  final double u; // 0..1 across the chunk
  final bool flip;
  final double scaleMul;
  final double dy; // 0..1 random, for layers with vertical scatter (clouds)
  const _Placed(this.sp, this.u, this.flip, this.scaleMul, this.dy);
}

/// Side-on wasteland: sky (+ cloud) -> far ruins -> haze -> mid ruins -> ground
/// -> clutter -> roadside props -> the dweller -> foreground. Scenery is generated
/// per fixed-width chunk from the chunk index, so it is endless, identical on
/// every pass and never stored. Each layer goes through the CRT phosphor filter,
/// dimmer the further away it is.
class WastelandScenePainter extends CustomPainter {
  final SceneClock clock;
  final int region;
  final bool drawDweller; // false = backdrop only (combat draws its own fighters)
  WastelandScenePainter({required this.clock, required this.region, this.drawDweller = true})
      : super(repaint: clock);

  static final Map<String, List<_Placed>> _cache = {};
  static DwellerRig? _rig;
  static bool _rigTried = false;

  static Paint _paint(double keep, double gain, [double opacity = 1]) => Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.medium
    ..colorFilter = Crt.phosphor(T.green, keep: keep, gain: gain)
    ..color = Colors.white.withValues(alpha: opacity);

  /// Some families look wrong at building scale (a lamp post as tall as a block of flats), so
  /// each pool gets a size multiplier. Keyed by the pool name after '#'.
  static const Map<String, double> _poolScale = {
    'prop.pole': 0.6,
    'prop.sign': 0.75,
    'prop.landsign': 0.6,
    'prop.big': 0.8,
    'tree.leaf': 0.95,
    'tree.pine': 0.95,
    'tree.dead': 0.95,
    'tree.cactus': 0.95,
    'tree.any': 0.95,
    'veh.any': 0.85,
    'veh.bus': 0.85,
    'veh.car': 0.85,
    'veh.truck': 0.85,
    'veh.wreck': 0.85,
    'veh.crashed': 0.85,
    'house': 0.9,
    'bunker': 0.9,
  };

  static double _refScale(String ref) {
    final i = ref.indexOf('#');
    return (i < 0 ? null : _poolScale[ref.substring(i + 1)]) ?? 1.0;
  }

  /// Chance that a sprite is mirrored. Sprites with lettering are marked `flip: false` in the
  /// atlas (tools/pack_scenery.py) and are never mirrored, whatever this says.
  static const double kFlipChance = 0.5;

  static int _hash(int a, int b, int c) {
    int h = (a * 73856093) ^ (b * 19349663) ^ (c * 83492791);
    h = (h ^ (h >> 13)) & 0x7fffffff;
    return h;
  }

  List<_Placed> _chunk(int layer, int idx, List<String> refs, int count,
      {double gapChance = 0.15, double scale = 1.0, double overlap = 1.0}) {
    final key = '$layer:$idx:$region';
    final hit = _cache[key];
    if (hit != null) return hit;
    if (_cache.length > 500) _cache.clear();
    final rng = Random(_hash(layer, idx, region));
    final out = <_Placed>[];
    double prevRight = -1e9; // right edge of the last placed sprite, in sheet px across the chunk
    for (int k = 0; k < count; k++) {
      if (rng.nextDouble() < gapChance) continue; // breathing room
      final n = idx * count + k; // global running number on this layer
      // Even spread through the refs AND through each pool: no clumps of repeats.
      final ref = refs[((n * 0.6180339887498949) % 1.0 * refs.length).floor() % refs.length];
      final sp = Atlas.resolveAt(ref, n + layer * 31);
      if (sp == null) continue;
      final u = (k + 0.1 + rng.nextDouble() * 0.8) / count;
      final flipRoll = rng.nextDouble(); // always drawn, so edits elsewhere never reshuffle flips
      final mul = _refScale(ref) * (0.9 + rng.nextDouble() * 0.2);
      final dy = rng.nextDouble();
      // Keep neighbours from stacking on top of each other (layers choose how strict).
      final w = sp.w * scale * mul;
      final left = u * 520 - sp.ax * scale * mul;
      if (left < prevRight - w * overlap) continue;
      prevRight = left + w;
      out.add(_Placed(sp, u, sp.flippable && flipRoll < kFlipChance, mul, dy));
    }
    return _cache[key] = out;
  }

  void _layer(Canvas canvas, Size size, double scrollDp, int layer, List<String> refs,
      {required double speed,
      required double scale,
      required Paint paint,
      required double footY,
      required double unit,
      required int count,
      double gapChance = 0.15,
      double maxH = 0.7, // tallest a sprite may get, as a fraction of the panel
      double yJitter = 0,
      double overlap = 1.0, // 1 = sprites may fully overlap, 0 = never overlap
      double extraOff = 0}) {
    final chunkW = 520 * unit;
    final off = scrollDp * speed + extraOff;
    final first = (off / chunkW).floor() - 1;
    final last = ((off + size.width) / chunkW).ceil() + 1;
    for (int idx = first; idx <= last; idx++) {
      for (final p in _chunk(layer, idx, refs, count,
          gapChance: gapChance, scale: scale, overlap: overlap)) {
        final x = idx * chunkW + p.u * chunkW - off;
        final s = min(unit * scale * p.scaleMul, maxH * size.height / p.sp.h);
        if (x + p.sp.w * s < -20 || x - p.sp.w * s > size.width + 20) continue;
        p.sp.draw(canvas, Offset(x, footY + (p.dy - 0.5) * yJitter), s, paint, flip: p.flip);
      }
    }
  }

  /// A seamless ridge / treeline tile, scrolled slowly, standing on [baseY].
  void _ridge(Canvas canvas, Size size, double scrollDp, String ref, double speed, double baseY,
      double heightPx, Paint paint) {
    final sp = Atlas.resolveAt(ref, 0);
    if (sp == null) return;
    final s = heightPx / sp.h;
    final tw = sp.w * s;
    final off = (scrollDp * speed) % tw;
    for (double x = -off; x < size.width; x += tw - 0.6) {
      sp.drawRect(canvas, Rect.fromLTWH(x, baseY - heightPx, tw, heightPx), paint);
    }
  }

  /// Patchwork ground: each 6-tile patch uses one chunk type (picked per patch),
  /// tiled as mirrored central slices so seams inside a patch are continuous.
  void _ground(Canvas canvas, Size size, double scrollDp, SceneTheme th, double unit, double groundY) {
    final patchW = 600 * unit;
    final firstPatch = (scrollDp / patchW).floor();
    final gp = _paint(0.0, 0.85);
    for (int pi = firstPatch; pi * patchW - scrollDp < size.width; pi++) {
      final ref = th.ground[_hash(pi, region, 7) % th.ground.length];
      final g = Atlas.resolveAt(ref, 0);
      if (g == null) continue;
      final slice = g.crop(left: 22, right: 22, bottom: max(0.0, g.h - kBandHeight));
      final tw = slice.w * unit, tH = slice.h * unit;
      final start = pi * patchW - scrollDp, end = start + patchW;
      int i = 0;
      for (double x = start; x < end && x < size.width; x += tw, i++) {
        if (x + tw < 0) continue;
        final visible = min(tw, end - x);
        final part = visible >= tw - 0.5
            ? slice
            : (i.isOdd
                ? slice.crop(left: slice.w * (1 - visible / tw))
                : slice.crop(right: slice.w * (1 - visible / tw)));
        part.drawRect(canvas, Rect.fromLTWH(x, groundY, visible + 0.8, tH), gp, flip: i.isOdd);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final th = sceneThemes[min(max(region, 0), sceneThemes.length - 1)];
    final w = size.width, h = size.height;
    final unit = h * 0.2 / 78; // logical px per sheet px: the dweller is 20% of the panel
    final groundY = h * 0.78; // top of the near floor strip
    final midY = groundY - h * 0.035; // the mid plain's horizon
    final farY = groundY - h * 0.095; // the far plain's horizon
    final scrollDp = clock.scroll * unit;
    Color tone(double t) => Color.lerp(T.bg, T.green, t)!;

    // Sky: near-black at the top, glowing towards the horizon.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tone(0.03), tone(0.26)],
          stops: const [0.0, 0.78],
        ).createShader(Rect.fromLTWH(0, 0, w, groundY)),
    );

    // Two cloud layers fill the upper sky; they drift even while standing still.
    _layer(canvas, size, scrollDp, 6, _cloudsFar,
        speed: 0.02, scale: 0.7, paint: _paint(0.0, 0.34, 0.6), footY: h * 0.26, unit: unit,
        count: 3, gapChance: 0.25, maxH: 0.16, yJitter: h * 0.2, extraOff: clock.time * 3 * unit);
    _layer(canvas, size, scrollDp, 7, _cloudsNear,
        speed: 0.045, scale: 1.0, paint: _paint(0.0, 0.55, 0.78), footY: h * 0.36, unit: unit,
        count: 2, gapChance: 0.3, maxH: 0.3, yJitter: h * 0.26, extraOff: clock.time * 6 * unit);

    if (th.mushroom) {
      final cloud = Atlas.named('derived', 'sky.mushroom');
      if (cloud != null) {
        cloud.draw(canvas, Offset(w * 0.4 - scrollDp * 0.02, farY),
            0.5 * h / cloud.h, _paint(0.0, 0.5, 0.8));
      }
    }

    // Distant ridge, then the far plain that the far skyline stands on.
    _ridge(canvas, size, scrollDp, th.ridge, 0.05, farY + h * 0.03, h * 0.2, _paint(0.0, 0.34));
    canvas.drawRect(
      Rect.fromLTWH(0, farY, w, groundY - farY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tone(0.15), tone(0.09)],
        ).createShader(Rect.fromLTWH(0, farY, w, groundY - farY)),
    );
    _layer(canvas, size, scrollDp, 1, th.far,
        speed: 0.10, scale: 0.85, paint: _paint(0.0, 0.42), footY: farY + h * 0.004,
        unit: unit, count: 8, gapChance: 0.08, maxH: 0.6, overlap: 0.6);

    // Atmospheric haze between far and mid layers.
    final hazeRect = Rect.fromLTWH(0, midY - h * 0.5, w, h * 0.5);
    canvas.drawRect(
      hazeRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, T.green.withValues(alpha: 0.16)],
        ).createShader(hazeRect),
    );

    // Mid plain + mid skyline: bigger and clearer.
    canvas.drawRect(
      Rect.fromLTWH(0, midY, w, groundY - midY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tone(0.11), tone(0.06)],
        ).createShader(Rect.fromLTWH(0, midY, w, groundY - midY)),
    );
    _layer(canvas, size, scrollDp, 2, th.mid,
        speed: 0.40, scale: 1.1, paint: _paint(0.0, 0.72), footY: midY + h * 0.004,
        unit: unit, count: 5, gapChance: 0.12, maxH: 0.68, overlap: 0.5);

    // Near floor: dark undersoil, then the patchwork surface.
    canvas.drawRect(Rect.fromLTWH(0, groundY, w, h - groundY), Paint()..color = tone(0.05));
    _ground(canvas, size, scrollDp, th, unit, groundY);

    // Ground clutter and roadside props stand at the same depth as the dweller.
    _layer(canvas, size, scrollDp, 4, th.detail,
        speed: 1.0, scale: 0.8, paint: _paint(0.0, 0.9), footY: groundY + (kFeetDepth - 5) * unit,
        unit: unit, count: 7, gapChance: 0.3, overlap: 0.3);
    _layer(canvas, size, scrollDp, 3, th.near,
        speed: 1.0, scale: 1.0, paint: _paint(0.0, 1.0), footY: groundY + (kFeetDepth - 2) * unit,
        unit: unit, count: 6, gapChance: 0.2, maxH: 0.55, overlap: 0.15);

    // The dweller: a rig driven by the clock's gait phase.
    if (drawDweller) {
      if (!_rigTried) {
        _rigTried = true;
        _rig = DwellerRig.load();
      }
      final foot = Offset(w * 0.3, groundY + kFeetDepth * unit);
      canvas.drawOval(
        Rect.fromCenter(center: foot, width: 30 * unit, height: 5 * unit),
        Paint()..color = Colors.black.withValues(alpha: 0.35),
      );
      if (_rig != null) {
        _rig!.draw(canvas,
            ground: foot,
            scale: unit,
            phase: clock.phase,
            energy: clock.energy,
            t: clock.time,
            near: _paint(0.6, 1.1),
            far: _paint(0.6, 0.85));
      } else {
        final frames = Atlas.frames('world_b', 'dweller.b');
        if (frames.length > 13) frames[13].draw(canvas, foot, unit, _paint(0.6, 1.1));
      }
    }

    // Foreground clutter passes in front of the dweller, a little faster.
    _layer(canvas, size, scrollDp, 5, th.detail,
        speed: 1.3, scale: 1.1, paint: _paint(0.0, 0.8), footY: groundY + (kFeetDepth + 18) * unit,
        unit: unit, count: 2, gapChance: 0.45);
  }

  @override
  bool shouldRepaint(covariant WastelandScenePainter o) => o.region != region || o.clock != clock;
}
