import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../game/combat_session.dart';
import '../game/combat_system.dart';
import '../game/fx.dart';
import '../game/game_state.dart';
import '../game/typewriter.dart';
import '../game/world.dart';
import 'atlas.dart';
import 'crt.dart';
import 'theme.dart';
import 'wasteland_scene.dart';

/// The main screen during a fight: a full-panel stage (the region's wasteland,
/// the dweller on the left, the enemy on the right) with health bars on top.
/// The action buttons live in their own box beside the encounter log
/// (see combat_actions.dart), so this view is all picture.
class CombatView extends StatelessWidget {
  final GameState state;
  final CombatSystem system;
  final TypewriterController typer;
  const CombatView({super.key, required this.state, required this.system, required this.typer});

  @override
  Widget build(BuildContext context) {
    final s = state.combat!;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (Atlas.ready)
          _DuelStage(
            session: s,
            region: regions.indexOf(regionAt(state.distanceKm)),
            scroll: state.distanceKm * 400,
          ),
        Positioned(left: 8, top: 8, child: _EnemyHud(s)),
        Positioned(left: 8, bottom: 8, child: _PlayerHud(state)),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double frac;
  final Color color;
  final double width;
  const _Bar(this.frac, this.color, {this.width = 130});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: 10,
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.8)),
          color: Colors.black.withValues(alpha: 0.4),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: frac.clamp(0.0, 1.0).toDouble(),
            child: Container(color: color),
          ),
        ),
      );
}

class _Hud extends StatelessWidget {
  final Widget child;
  const _Hud({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      );
}

class _EnemyHud extends StatelessWidget {
  final CombatSession s;
  const _EnemyHud(this.s);

  @override
  Widget build(BuildContext context) => _Hud(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.name, style: T.mono(T.red, size: 13, bold: true)),
            const SizedBox(height: 3),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _Bar(s.maxHp <= 0 ? 0 : s.hp / s.maxHp, T.red),
              const SizedBox(width: 6),
              Text('${s.hp}/${s.maxHp}', style: T.mono(T.green, size: 11)),
            ]),
            if (s.charging && !s.finished)
              Text('!! CHARGING !!', style: T.mono(T.red, size: 11, bold: true)),
          ],
        ),
      );
}

class _PlayerHud extends StatelessWidget {
  final GameState state;
  const _PlayerHud(this.state);

  @override
  Widget build(BuildContext context) {
    final low = state.hp < state.maxHp * 0.3;
    return _Hud(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('YOU', style: T.mono(low ? T.red : T.green, size: 11, bold: true)),
        const SizedBox(width: 6),
        _Bar(state.maxHp <= 0 ? 0 : state.hp / state.maxHp, low ? T.red : T.green, width: 110),
        const SizedBox(width: 6),
        Text('${state.hp}/${state.maxHp}', style: T.mono(T.green, size: 11)),
        const SizedBox(width: 10),
        Text('STIM ${state.stimpacks}', style: T.mono(T.loot, size: 11)),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Animation timeline
// ---------------------------------------------------------------------------

class _Anim {
  final CombatFx fx;
  final double t0, dur;
  const _Anim(this.fx, this.t0, this.dur);
  double p(double now) => ((now - t0) / dur).clamp(0.0, 1.0).toDouble();
  bool active(double now) => now >= t0 && now <= t0 + dur;
}

/// Turns the system's fx events into a timeline: each starts when the previous
/// one has finished, so a round reads as "you act ... it answers".
class _Board {
  final List<_Anim> anims = [];
  double queueEnd = 0, kneelFrom = -1, kneelUntil = -1, deathStart = -1;
  bool _finished = false;

  static double _dur(CombatFxKind k) {
    switch (k) {
      case CombatFxKind.shot:
        return 0.62;
      case CombatFxKind.heavy:
        return 0.9;
      case CombatFxKind.miss:
        return 0.6;
      case CombatFxKind.defend:
        return 0.6;
      case CombatFxKind.heal:
        return 0.9;
      case CombatFxKind.enemyHit:
        return 0.75;
      case CombatFxKind.enemyMiss:
        return 0.6;
      case CombatFxKind.enemyCharge:
        return 0.7;
      case CombatFxKind.enemyCover:
        return 0.6;
    }
  }

  void update(CombatSession s, double now, {required bool animate}) {
    while (s.fx.isNotEmpty) {
      final f = s.fx.removeAt(0);
      if (!animate) continue;
      final start = max(now, queueEnd);
      final d = _dur(f.kind);
      anims.add(_Anim(f, start, d));
      queueEnd = start + d + 0.08;
      if (f.kind == CombatFxKind.defend) {
        kneelFrom = start;
        kneelUntil = start + 2.4; // brace through the enemy's answer
      }
    }
    anims.removeWhere((a) => now > a.t0 + a.dur + 1.2);
    if (s.finished && !_finished) {
      _finished = true;
      deathStart = max(now, queueEnd);
    }
  }
}

/// Which sprite each enemy uses. Troopers come from the artist's sheet; the rest
/// were derived in the same style. Everything faces LEFT, towards the dweller.
const _enemySprites = <EnemyType, String>{
  EnemyType.raider: 'world_a:trooper.0',
  EnemyType.straggler: 'world_a:trooper.1',
  EnemyType.captain: 'world_a:trooper.5',
  EnemyType.skitter: 'derived:enemy.skitter',
  EnemyType.hound: 'derived:enemy.hound',
  EnemyType.crawler: 'derived:enemy.crawler',
  EnemyType.lurker: 'derived:enemy.lurker',
  EnemyType.swarm: 'derived:enemy.swarm',
  EnemyType.spitter: 'derived:enemy.spitter',
  EnemyType.colossus: 'derived:enemy.colossus',
  EnemyType.wyrm: 'derived:enemy.wyrm',
  EnemyType.sentry: 'derived:enemy.sentry',
  EnemyType.warmachine: 'derived:enemy.warmachine',
  EnemyType.brute: 'derived:enemy.brute',
};

AtlasSprite? _enemySprite(EnemyType t) {
  final ref = _enemySprites[t];
  return ref == null ? null : Atlas.resolveAt(ref, 0);
}

// ---------------------------------------------------------------------------
// The stage
// ---------------------------------------------------------------------------

class _DuelStage extends StatefulWidget {
  final CombatSession session;
  final int region;
  final double scroll;
  const _DuelStage({required this.session, required this.region, required this.scroll});

  @override
  State<_DuelStage> createState() => _DuelStageState();
}

class _DuelStageState extends State<_DuelStage> with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _now = ValueNotifier(0);
  final _Board _board = _Board();
  final SceneClock _clock = SceneClock(); // never ticked: a still backdrop
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _clock.scroll = widget.scroll;
    _ticker = createTicker((e) {
      final t = e.inMicroseconds / 1e6;
      _board.update(widget.session, t, animate: !Fx.settings.reducedMotion);
      _now.value = t;
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _now.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _DuelPainter(widget.session, widget.region, _clock, _board, _now),
        ),
      );
}

class _DuelPainter extends CustomPainter {
  final CombatSession s;
  final int region;
  final SceneClock clock;
  final _Board board;
  final ValueNotifier<double> time;
  _DuelPainter(this.s, this.region, this.clock, this.board, this.time) : super(repaint: time);

  static double _bump(double p, double a, double b) =>
      (p <= a || p >= b) ? 0.0 : sin(pi * (p - a) / (b - a));

  Paint _img(Color tint, {double keep = 0.55, double gain = 1.05, double alpha = 1}) => Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.medium
    ..colorFilter = Crt.phosphor(tint, keep: keep, gain: gain)
    ..color = Colors.white.withValues(alpha: alpha);

  Paint _flash(double a) => Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.medium
    ..colorFilter = ColorFilter.mode(Colors.white.withValues(alpha: a), BlendMode.srcATop);

  void _text(Canvas c, String t, Offset at, Color col, double size, double alpha) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: T.mono(col.withValues(alpha: alpha.clamp(0.0, 1.0).toDouble()), size: size, bold: true),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    if (w < 60 || h < 60) return;
    final now = time.value;
    final unit = h * 0.2 / 78;
    final groundY = h * 0.78;
    final footY = groundY + 16 * unit; // feet sink into the grass: no floating
    final f = min(h * 0.46 / 98, w * 0.0058);
    final ts = (min(w, h) / 420).clamp(0.8, 1.7).toDouble();

    // ---- derive this frame's pose from the timeline
    double shake = 0, pRecoil = 0, eKnock = 0, eLunge = 0, eDip = 0;
    double eFlash = 0, pFlash = 0;
    bool charging = s.charging && !s.finished;
    for (final a in board.anims) {
      if (!a.active(now)) continue;
      final p = a.p(now);
      switch (a.fx.kind) {
        case CombatFxKind.shot:
        case CombatFxKind.heavy:
          final heavy = a.fx.kind == CombatFxKind.heavy;
          pRecoil += _bump(p, 0.05, 0.3) * (heavy ? 7 : 4);
          eKnock += _bump(p, 0.3, 0.75) * (heavy ? 12 : 6) * (a.fx.crit ? 1.4 : 1);
          if (p > 0.3 && p < 0.46) eFlash = 0.85;
          if (p > 0.3) shake += (heavy || a.fx.crit ? 6.0 : 2.5) * (1 - p) * sin(now * 70);
          break;
        case CombatFxKind.miss:
          pRecoil += _bump(p, 0.05, 0.3) * 3;
          break;
        case CombatFxKind.enemyHit:
        case CombatFxKind.enemyMiss:
          eLunge += _bump(p, 0.08, 0.6);
          if (a.fx.kind == CombatFxKind.enemyHit && p > 0.32) {
            if (p < 0.5) pFlash = 0.8;
            shake += (a.fx.crit ? 8.0 : 3.5) * (1 - p) * sin(now * 70);
          }
          break;
        case CombatFxKind.enemyCover:
          eDip += _bump(p, 0.0, 1.0);
          break;
        default:
          break;
      }
    }

    canvas.save();
    canvas.translate(shake * ts, shake * 0.6 * ts);

    // ---- backdrop
    WastelandScenePainter(clock: clock, region: region, drawDweller: false).paint(canvas, size);

    // ---- fighters
    final px0 = w * 0.24, ex0 = w * 0.74;
    final frames = Atlas.frames('world_b', 'dweller.b');
    final kneeling = now >= board.kneelFrom && now < board.kneelUntil;
    final player = frames.length > 12 ? (kneeling ? frames[12] : frames[10]) : null;
    final enemy = _enemySprite(s.type);

    double dt = board.deathStart >= 0 ? max(0.0, now - board.deathStart) : 0;
    final died = s.outcome == CombatOutcome.died, won = s.outcome == CombatOutcome.won;
    final fled = s.outcome == CombatOutcome.fled;
    var px = px0 - pRecoil * f - (fled ? dt * 180 * unit : 0);
    final pAlpha = died ? (1 - dt / 0.9).clamp(0.0, 1.0).toDouble() : (fled ? (1 - dt / 0.8).clamp(0.0, 1.0).toDouble() : 1.0);

    // the enemy is scaled to the panel but never wider than ~46% of it
    double es = f;
    if (enemy != null) es = min(f, 0.46 * w / enemy.w);
    final hover = s.type == EnemyType.swarm ? 26 * f : 0.0;
    var ex = ex0 + eKnock * f - eLunge * (ex0 - px0) * 0.3;
    final eAlpha = won ? (1 - dt / 0.9).clamp(0.0, 1.0).toDouble() : 1.0;
    final eSink = won ? dt * 10 * f : 0.0;
    final jitter = won && dt < 0.9 ? sin(now * 90) * 2 * f : 0.0;
    final ey = footY + eDip * 6 * f + eSink - hover;

    // shadows
    canvas.drawOval(Rect.fromCenter(center: Offset(px, footY), width: 38 * f, height: 7 * f),
        Paint()..color = Colors.black.withValues(alpha: 0.35 * pAlpha));
    if (enemy != null && eAlpha > 0) {
      canvas.drawOval(
          Rect.fromCenter(center: Offset(ex, footY), width: enemy.w * es * 0.8, height: 7 * f),
          Paint()..color = Colors.black.withValues(alpha: 0.35 * eAlpha));
    }

    // dweller
    if (player != null && pAlpha > 0) {
      final tint = pFlash > 0 ? T.red : T.green;
      player.draw(canvas, Offset(px, footY), f, _img(tint, keep: pFlash > 0 ? 0.3 : 0.6, gain: 1.1, alpha: pAlpha));
    }
    // enemy (all enemy sprites face left already)
    if (enemy != null && eAlpha > 0) {
      final warn = charging && (sin(now * 14) > 0);
      final hurt = s.hp < s.maxHp * 0.3 && !won;
      final paint = eFlash > 0
          ? _flash(eFlash)
          : _img((hurt || warn) ? T.red : T.green, keep: warn ? 0.3 : 0.5, alpha: eAlpha);
      enemy.draw(canvas, Offset(ex + jitter, ey), es, paint);
    }

    // ---- effects
    final muzzle = player == null
        ? Offset(px + 30 * f, footY - 50 * f)
        : Offset(px + (player.w - player.ax) * f * 0.98, footY - player.h * f * (kneeling ? 0.6 : 0.62));
    final eh = enemy == null ? 60 * f : enemy.h * es;
    final target = Offset(ex, footY - eh * 0.55 - hover);
    final head = Offset(ex, footY - eh - hover - 10 * f);

    for (final a in board.anims) {
      if (!a.active(now)) continue;
      final p = a.p(now);
      switch (a.fx.kind) {
        case CombatFxKind.shot:
        case CombatFxKind.heavy:
        case CombatFxKind.miss:
          final heavy = a.fx.kind == CombatFxKind.heavy || (a.fx.kind == CombatFxKind.miss && a.fx.crit);
          final miss = a.fx.kind == CombatFxKind.miss;
          if (p > 0.05 && p < 0.22) _muzzleFlash(canvas, muzzle, (heavy ? 11 : 7) * f, (p - 0.05) / 0.17);
          if (p > 0.1 && p < 0.34) {
            final u = (p - 0.1) / 0.24;
            final end = miss ? Offset(target.dx + 140 * f, target.dy - 30 * f) : target;
            final tip = Offset.lerp(muzzle, end, min(1.0, u * 1.8))!;
            final tail = Offset.lerp(muzzle, end, max(0.0, u * 1.8 - 0.45))!;
            canvas.drawLine(tail, tip, Paint()
              ..color = T.amber.withValues(alpha: (1 - u * 0.6))
              ..strokeWidth = (heavy ? 3.5 : 2) * ts
              ..strokeCap = StrokeCap.round);
          }
          if (!miss && p > 0.3 && p < 0.62) {
            final u = (p - 0.3) / 0.32;
            final ring = Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5 * ts
              ..color = (a.fx.crit ? T.loot : T.amber).withValues(alpha: 1 - u);
            canvas.drawCircle(target, (10 + 26 * u) * f * (heavy ? 1.4 : 1), ring);
            for (int i = 0; i < 7; i++) {
              final ang = i * 2 * pi / 7 + 0.4;
              final d1 = (8 + 24 * u) * f, d2 = (14 + 32 * u) * f;
              canvas.drawLine(target + Offset(cos(ang), sin(ang)) * d1, target + Offset(cos(ang), sin(ang)) * d2, ring);
            }
          }
          if (p > 0.34) {
            final u = (p - 0.34) / 0.66;
            final at = (miss ? target : head) + Offset(0, -34 * f * u);
            if (miss) {
              _text(canvas, 'MISS', at, T.amber, 17 * ts, 1 - u * u);
            } else {
              _text(canvas, '-${a.fx.amount}${a.fx.crit ? '!' : ''}', at, a.fx.crit ? T.loot : T.amber,
                  (a.fx.crit ? 26 : 21) * ts, 1 - u * u);
              if (a.fx.crit) _text(canvas, 'CRITICAL', at + Offset(0, -22 * ts), T.loot, 12 * ts, 1 - u * u);
            }
          }
          break;
        case CombatFxKind.defend:
          final u = p;
          final c = Offset(px + 6 * f, footY - 34 * f);
          canvas.drawArc(Rect.fromCenter(center: c, width: 70 * f, height: 90 * f), -pi * 0.45, pi * 0.9, false,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3 * ts
                ..color = T.green.withValues(alpha: 0.9 * (1 - u * 0.6)));
          _text(canvas, 'BRACE', Offset(px, footY - 84 * f - 16 * u * f), T.green, 14 * ts, 1 - u * u);
          break;
        case CombatFxKind.heal:
          for (int i = 0; i < 6; i++) {
            final seed = i * 1.7;
            final x = px + sin(seed * 3) * 24 * f;
            final y = footY - (10 + 60 * ((p + i / 6) % 1.0)) * f;
            _text(canvas, '+', Offset(x, y), T.loot, 18 * ts, 1 - ((p + i / 6) % 1.0));
          }
          _text(canvas, '+${a.fx.amount} HP', Offset(px, footY - 90 * f - 20 * p * f), T.loot, 17 * ts, 1 - p * p);
          break;
        case CombatFxKind.enemyHit:
          if (p > 0.32) {
            final u = (p - 0.32) / 0.68;
            final at = Offset(px, footY - 88 * f - 30 * u * f);
            _text(canvas, a.fx.blocked ? 'BLOCKED -${a.fx.amount}' : '-${a.fx.amount}${a.fx.crit ? '!' : ''}', at,
                a.fx.blocked ? T.green : T.red, (a.fx.crit ? 26 : 21) * ts, 1 - u * u);
          }
          break;
        case CombatFxKind.enemyMiss:
          if (p > 0.3) {
            final u = (p - 0.3) / 0.7;
            _text(canvas, 'MISS', Offset(px, footY - 88 * f - 24 * u * f), T.green, 17 * ts, 1 - u * u);
          }
          break;
        case CombatFxKind.enemyCharge:
          _text(canvas, '!', head + Offset(0, -6 * f * sin(p * 14)), T.red, 34 * ts, 1.0 - p * 0.3);
          break;
        case CombatFxKind.enemyCover:
          _text(canvas, 'COVER', head, T.amber, 15 * ts, 1 - p * p);
          break;
      }
    }

    canvas.restore();
  }

  void _muzzleFlash(Canvas c, Offset at, double r, double u) {
    final path = Path();
    for (int i = 0; i < 16; i++) {
      final ang = i * pi / 8;
      final rad = (i.isEven ? r : r * 0.42) * (1 - u * 0.5);
      final pt = at + Offset(cos(ang) * rad * (cos(ang) > 0 ? 1.6 : 0.7), sin(ang) * rad);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    c.drawPath(path, Paint()..color = const Color(0xFFFFE9A0).withValues(alpha: 1 - u * 0.5));
    c.drawCircle(at, r * 0.3, Paint()..color = Colors.white.withValues(alpha: 1 - u));
  }

  @override
  bool shouldRepaint(covariant _DuelPainter old) => true;
}
