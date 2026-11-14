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
  final bool mushroom; // the cloud hangs over the horizon
  const SceneTheme({
    required this.ground,
    required this.far,
    required this.mid,
    required this.near,
    required this.detail,
    this.mushroom = false,
  });
}

const _clutter = ['world_a#rock_a', 'world_b#rock_b', 'world_a#plants_a'];

const sceneThemes = <SceneTheme>[
  // 0 DUSTY HIGHWAY
  SceneTheme(
    ground: ['world_a:ground.road2', 'world_a:ground.road', 'world_a:ground.dirt', 'world_a:ground.road2'],
    far: ['world_b#bld_b', 'world_a#bld_a'],
    mid: ['world_b:gasstation', 'world_b:motel', 'world_b:billboard', 'world_a#bld_a', 'world_b#bld_b'],
    near: [
      'world_b#poles_b', 'world_b:car.rust', 'derived:sign.stoppost', 'world_b#crates_b',
      'derived:sign.route66post', 'world_a:tree.dead1', 'world_a#fence_a', 'world_b#fence_b',
      'world_a#crates_a', 'world_a:pole.a', 'world_a:pole.c',
    ],
    detail: _clutter,
  ),
  // 1 RUSTED OUTSKIRTS
  SceneTheme(
    ground: ['world_a:ground.dirt', 'world_a:ground.dirt2', 'world_a:ground.grass'],
    far: ['world_a#bld_a', 'world_b#bld_b'],
    mid: ['world_b:watertower', 'world_b:gasstation', 'world_a#bld_a', 'world_b:watchtower', 'world_b#bld_b'],
    near: [
      'world_b#crates_b', 'world_a#crates_a', 'world_b#poles_b', 'world_a:sign.gas',
      'world_b:car.rust', 'world_a:trafficlight', 'world_b#fence_b', 'world_a#fence_a',
      'world_b:barrel.0', 'world_a:sign.welcome',
    ],
    detail: _clutter,
  ),
  // 2 GLASSED BASIN (the concept art)
  SceneTheme(
    ground: ['world_a:ground.dirt2', 'world_a:ground.dirt', 'world_a:ground.dirt2'],
    far: ['world_b#bld_b', 'world_a#bld_a'],
    mid: ['world_a#bld_a', 'world_b#bld_b', 'world_b:radar'],
    near: [
      'derived:sign.radpost', 'world_a:tree.dead1', 'world_a#crates_a', 'world_a:tree.dead2',
      'world_b#poles_b', 'world_a:pole.b', 'world_a#fence_a', 'world_b#crates_b',
      'world_b:barrel.0', 'world_b:car.rust',
    ],
    detail: _clutter,
    mushroom: true,
  ),
  // 3 DROWNED SUBURBS
  SceneTheme(
    ground: ['world_a:ground.grass', 'world_a:ground.dirt', 'world_a:ground.grass'],
    far: ['world_b:church', 'world_b:house', 'world_a#bld_a', 'world_b#bld_b'],
    mid: ['world_b:house', 'world_b:church', 'world_b:motel', 'world_a#bld_a'],
    near: [
      'world_a:tree.green', 'world_a:tree.autumn', 'world_a:tree.pine2', 'world_a:sign.food',
      'world_a#fence_a', 'world_b#fence_b', 'world_b:car.rust', 'world_b#crates_b',
      'world_a:pole.c', 'world_a:tree.green',
    ],
    detail: _clutter,
  ),
  // 4 IRON GRAVEYARD
  SceneTheme(
    ground: ['world_a:ground.dirt', 'world_a:ground.dirt2', 'world_a:ground.dirt'],
    far: ['world_b:radar', 'world_b:radome', 'world_b#bld_b', 'world_a#bld_a'],
    mid: ['world_b:plane.wreck', 'world_b:watchtower', 'world_b:radar', 'world_a#bld_a'],
    near: [
      'world_b:car.rust', 'world_b:tent', 'world_b#crates_b', 'world_a#crates_a',
      'world_a:tree.dead2', 'world_b:barrel.0', 'world_b#fence_b', 'world_b#poles_b',
    ],
    detail: _clutter,
  ),
  // 5 ASHEN HEIGHTS
  SceneTheme(
    ground: ['world_a:ground.dirt2', 'world_a:ground.grass', 'world_a:ground.dirt'],
    far: ['world_b#bld_b', 'world_a#bld_a'],
    mid: ['world_a#bld_a', 'world_b#bld_b', 'world_b:radome'],
    near: [
      'world_a:tree.pine1', 'world_a:tree.pine2', 'world_a:tree.dead1', 'world_a:rock.big',
      'world_b#poles_b', 'world_a#crates_a', 'world_a:tree.pine1', 'world_a:tree.dead2',
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
  const _Placed(this.sp, this.u, this.flip, this.scaleMul);
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

  /// Props that stand on a post look too big at building scale.
  static double _refScale(String ref) {
    if (ref.startsWith('derived:sign')) return 0.55;
    if (ref.contains(':sign.')) return 0.6;
    if (ref.contains('tree.')) return 0.95;
    if (ref.contains('car.') || ref.contains('tent') || ref.contains('watchtower')) return 0.8;
    if (ref.contains('barrel') || ref.contains('trafficlight')) return 0.7;
    return 1.0;
  }

  /// Mirroring a sign or billboard would mirror its lettering.
  static bool _flippable(String ref) =>
      ref.contains('#') || ref.contains('tree.') || ref.contains('rock') || ref.contains('ground');

  static int _hash(int a, int b, int c) {
    int h = (a * 73856093) ^ (b * 19349663) ^ (c * 83492791);
    h = (h ^ (h >> 13)) & 0x7fffffff;
    return h;
  }

  List<_Placed> _chunk(int layer, int idx, List<String> refs, int count, {double gapChance = 0.15}) {
    final key = '$layer:$idx:$region';
    final hit = _cache[key];
    if (hit != null) return hit;
    if (_cache.length > 500) _cache.clear();
    final rng = Random(_hash(layer, idx, region));
    final out = <_Placed>[];
    for (int k = 0; k < count; k++) {
      if (rng.nextDouble() < gapChance) continue; // breathing room
      final n = idx * count + k; // global running number on this layer
      // Even spread through the refs AND through each pool: no clumps of repeats.
      final ref = refs[((n * 0.6180339887498949) % 1.0 * refs.length).floor() % refs.length];
      final sp = Atlas.resolveAt(ref, n + layer * 31);
      if (sp == null) continue;
      out.add(_Placed(
        sp,
        (k + 0.1 + rng.nextDouble() * 0.8) / count,
        _flippable(ref) && rng.nextBool(),
        _refScale(ref) * (0.9 + rng.nextDouble() * 0.2),
      ));
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
      double gapChance = 0.15}) {
    final chunkW = 520 * unit;
    final off = scrollDp * speed;
    final first = (off / chunkW).floor() - 1;
    final last = ((off + size.width) / chunkW).ceil() + 1;
    for (int idx = first; idx <= last; idx++) {
      for (final p in _chunk(layer, idx, refs, count, gapChance: gapChance)) {
        final x = idx * chunkW + p.u * chunkW - off;
        final s = unit * scale * p.scaleMul;
        if (x + p.sp.w * s < -20 || x - p.sp.w * s > size.width + 20) continue;
        p.sp.draw(canvas, Offset(x, footY), s, paint, flip: p.flip);
      }
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
      final slice = g.crop(left: 22, right: 22, bottom: g.h * 0.35);
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
    final groundY = h * 0.78;
    final scrollDp = clock.scroll * unit;

    // Sky: near-black at the top, glowing towards the horizon.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(T.bg, T.green, 0.03)!, Color.lerp(T.bg, T.green, 0.26)!],
          stops: const [0.0, 0.78],
        ).createShader(Rect.fromLTWH(0, 0, w, groundY)),
    );

    if (th.mushroom) {
      final cloud = Atlas.named('derived', 'sky.mushroom');
      if (cloud != null) {
        cloud.draw(canvas, Offset(w * 0.4 - scrollDp * 0.02, groundY - h * 0.02),
            0.46 * h / cloud.h, _paint(0.0, 0.5, 0.8));
      }
    }

    _layer(canvas, size, scrollDp, 1, th.far,
        speed: 0.10, scale: 0.55, paint: _paint(0.0, 0.42), footY: groundY - h * 0.01,
        unit: unit, count: 5, gapChance: 0.1);

    // Atmospheric haze between far and mid layers.
    final hazeRect = Rect.fromLTWH(0, groundY - h * 0.45, w, h * 0.45);
    canvas.drawRect(
      hazeRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, T.green.withValues(alpha: 0.16)],
        ).createShader(hazeRect),
    );

    _layer(canvas, size, scrollDp, 2, th.mid,
        speed: 0.40, scale: 0.8, paint: _paint(0.0, 0.75), footY: groundY + h * 0.004,
        unit: unit, count: 4, gapChance: 0.2);

    // Ground: dark undersoil, then the patchwork surface.
    canvas.drawRect(Rect.fromLTWH(0, groundY, w, h - groundY),
        Paint()..color = Color.lerp(T.bg, T.green, 0.05)!);
    _ground(canvas, size, scrollDp, th, unit, groundY);

    // Ground clutter (rocks, bushes) then roadside props.
    _layer(canvas, size, scrollDp, 4, th.detail,
        speed: 1.0, scale: 0.8, paint: _paint(0.0, 0.9), footY: groundY + 14 * unit,
        unit: unit, count: 7, gapChance: 0.3);
    _layer(canvas, size, scrollDp, 3, th.near,
        speed: 1.0, scale: 1.0, paint: _paint(0.0, 1.0), footY: groundY + 10 * unit,
        unit: unit, count: 6, gapChance: 0.25);

    // The dweller: a rig driven by the clock's gait phase.
    if (drawDweller) {
    if (!_rigTried) {
      _rigTried = true;
      _rig = DwellerRig.load();
    }
    final foot = Offset(w * 0.3, groundY + 10 * unit);
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
        speed: 1.3, scale: 1.1, paint: _paint(0.0, 0.8), footY: groundY + 30 * unit,
        unit: unit, count: 2, gapChance: 0.45);
  }

  @override
  bool shouldRepaint(covariant WastelandScenePainter o) => o.region != region || o.clock != clock;
}
