import 'atlas.dart';
import 'crt.dart';
import 'wasteland_scene.dart';
import '../game/world.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../game/combat_session.dart';
import '../game/combat_system.dart';
import '../game/game_state.dart';
import '../game/typewriter.dart';
import '../game/fx.dart';
import 'sprites.dart';
import 'theme.dart';

String _bar(int cur, int total) {
  final f = total <= 0 ? 0 : min(10, max(0, (cur / total * 10).ceil()));
  return '[${'■' * f}${'□' * (10 - f)}]';
}

/// Terminal A during a fight: the enemy, both health bars, and action buttons.
class CombatView extends StatelessWidget {
  final GameState state;
  final CombatSystem system;
  final TypewriterController typer;
  const CombatView({
    super.key,
    required this.state,
    required this.system,
    required this.typer,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.combat!;
    return LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth > box.maxHeight * 1.25;

      final enemyInfo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.name, style: T.mono(T.red, size: 14, bold: true)),
          Text('HP ${s.hp}/${s.maxHp} ${_bar(s.hp, s.maxHp)}',
              style: T.mono(T.green, size: 12)),
          if (s.charging && !s.finished)
            Text('!! CHARGING HEAVY ATTACK !!',
                style: T.mono(T.red, size: 12, bold: true)),
        ],
      );
      final art = SizedBox.expand(
        child: _DuelStage(
          session: s,
          region: regions.indexOf(regionAt(state.distanceKm)),
          scroll: state.distanceKm * 400,
        ),
      );
      final playerInfo = Text(
        'YOU ${state.hp}/${state.maxHp} ${_bar(state.hp, state.maxHp)}  STIM:${state.stimpacks}',
        style: T.mono(state.hp < state.maxHp * 0.3 ? T.red : T.green, size: 12),
      );
      // Buttons and the victory/defeat screen wait until the log has finished.
      final busy = typer.busy;
      final controls = (s.finished && !busy) ? _result(s) : _actions(s, busy: busy, cols: wide ? 2 : 3);

      return Padding(
        padding: const EdgeInsets.all(8),
        child: wide
            ? Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [enemyInfo, Expanded(child: art), playerInfo],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 190,
                  child: Center(child: SingleChildScrollView(child: controls)),
                ),
              ])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  enemyInfo,
                  Expanded(child: art),
                  playerInfo,
                  const SizedBox(height: 6),
                  controls,
                ],
              ),
      );
    });
  }

  Widget _actions(CombatSession s, {bool busy = false, int cols = 2}) {
    final off = busy || s.finished;
    VoidCallback? go(PlayerAction a) => off ? null : () => system.act(a);
    Color c(Color x) => off ? T.dim : x;
    final noStim = state.stimpacks <= 0 || off;
    final buttons = <Widget>[
      _Btn('ATTACK', c(T.green), go(PlayerAction.attack)),
      _Btn('HEAVY', c(T.amber), go(PlayerAction.heavy)),
      _Btn('DEFEND', c(T.green), go(PlayerAction.defend)),
      _Btn('ITEM x${state.stimpacks}', noStim ? T.dim : T.loot,
          noStim ? null : () => system.act(PlayerAction.item)),
      _Btn('ESCAPE', c(T.amber), go(PlayerAction.escape)),
    ];
    final rows = <Widget>[];
    for (int i = 0; i < buttons.length; i += cols) {
      rows.add(Row(children: [
        for (int j = 0; j < cols; j++) ...[
          if (j > 0) const SizedBox(width: 6),
          Expanded(child: i + j < buttons.length ? buttons[i + j] : const SizedBox.shrink()),
        ],
      ]));
      if (i + cols < buttons.length) rows.add(const SizedBox(height: 6));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  Widget _result(CombatSession s) {
    final String text;
    final Color color;
    switch (s.outcome) {
      case CombatOutcome.won:
        text = 'VICTORY  +${s.scrapGained} SCRAP';
        color = T.loot;
        break;
      case CombatOutcome.fled:
        text = 'YOU ESCAPED';
        color = T.amber;
        break;
      default:
        text = s.scrapGained < 0
            ? 'YOU HAVE FALLEN  ${s.scrapGained} SCRAP'
            : 'YOU HAVE FALLEN';
        color = T.red;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(text, textAlign: TextAlign.center, style: T.mono(color, bold: true)),
        const SizedBox(height: 6),
        _Btn('[CONTINUE]', T.green, system.leave),
      ],
    );
  }
}

/// The duel: the region's wasteland as a backdrop, the dweller on the left in an
/// aiming pose (kneeling while she defends), the enemy on the right facing her.
/// Humanoid enemies use the trooper art; creatures keep their existing sprites.
const _humanSprites = <EnemyType, String>{
  EnemyType.raider: 'trooper.0',
  EnemyType.straggler: 'trooper.1',
  EnemyType.sentry: 'trooper.2',
  EnemyType.brute: 'trooper.3',
  EnemyType.warmachine: 'trooper.4',
  EnemyType.captain: 'trooper.5',
};

class _DuelStage extends StatefulWidget {
  final CombatSession session;
  final int region;
  final double scroll;
  const _DuelStage({required this.session, required this.region, required this.scroll});

  @override
  State<_DuelStage> createState() => _DuelStageState();
}

class _DuelStageState extends State<_DuelStage> with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _t = ValueNotifier(0);
  final SceneClock _clock = SceneClock(); // never ticked: a still backdrop
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _clock.scroll = widget.scroll;
    _ticker = createTicker((e) {
      if (!Fx.settings.reducedMotion) _t.value = e.inMicroseconds / 1e6;
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _t.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _DuelPainter(widget.session, widget.region, _clock, _t),
        ),
      );
}

class _DuelPainter extends CustomPainter {
  final CombatSession s;
  final int region;
  final SceneClock clock;
  final ValueNotifier<double> t;
  _DuelPainter(this.s, this.region, this.clock, this.t) : super(repaint: t);

  Paint _img(Color tint, {double keep = 0.55, double gain = 1.05}) => Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.medium
    ..colorFilter = Crt.phosphor(tint, keep: keep, gain: gain);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    if (w < 40 || h < 40) return;

    // Backdrop: same scene as exploration, minus the walker.
    WastelandScenePainter(clock: clock, region: region, drawDweller: false).paint(canvas, size);

    final unit = h * 0.2 / 78; // the scene's scale, to find its ground line
    final footY = h * 0.78 + 10 * unit;
    final f = h * 0.52 / 98; // fighters are ~half the panel tall
    final bob = sin(t.value * pi) * 1.2 * unit;

    // The dweller.
    final frames = Atlas.frames('world_b', 'dweller.b');
    if (frames.length > 12) {
      final sp = s.playerDefending ? frames[12] : frames[10];
      canvas.drawOval(
          Rect.fromCenter(center: Offset(w * 0.27, footY), width: 36 * f, height: 6 * f),
          Paint()..color = Colors.black.withValues(alpha: 0.35));
      sp.draw(canvas, Offset(w * 0.27, footY + bob), f, _img(T.green, keep: 0.6, gain: 1.1));
    }

    // The enemy.
    final name = _humanSprites[s.type];
    final sp = name == null ? null : Atlas.named('world_a', name);
    final hurt = s.hp < s.maxHp * 0.3;
    // A telegraphed heavy attack pulses red.
    final warn = s.charging && !s.finished && (sin(t.value * 14) > 0);
    if (sp != null) {
      canvas.drawOval(
          Rect.fromCenter(center: Offset(w * 0.73, footY), width: 40 * f, height: 6 * f),
          Paint()..color = Colors.black.withValues(alpha: 0.35));
      sp.draw(canvas, Offset(w * 0.73, footY - bob), f * 1.02,
          _img((hurt || warn) ? T.red : T.green, keep: warn ? 0.3 : 0.5),
          flip: true); // the trooper art faces right; she is on the left
    } else {
      // Creatures: the existing sprite / vector art, on the right-hand side.
      canvas.save();
      canvas.translate(w * 0.42, 0);
      _EnemyPainter(s).paint(canvas, Size(w * 0.58, h));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _DuelPainter old) => true;
}

/// Simple vector art, one look per enemy. Turns red as it nears death.
class _EnemyPainter extends CustomPainter {
  final CombatSession s;
  _EnemyPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    final u = min(size.width / 10, size.height / 8);
    if (u < 3) return;
    final c = Offset(size.width / 2, size.height / 2);
    final col = s.hp < s.maxHp * 0.3 ? T.red : T.green;

    // Pixel-art enemy if the image is available (the vector art below is the fallback).
    final im = Sprites.get('enemy_${s.type.name}');
    if (im != null) {
      final side = min(size.width, size.height) * 0.95;
      final k = side / im.width;
      final sc = k >= 2 ? k.floorToDouble() : k;
      final w = im.width * sc, h = im.height * sc;
      canvas.drawLine(Offset(0, size.height - 2), Offset(size.width, size.height - 2),
          Paint()
            ..color = T.dim
            ..strokeWidth = 2);
      Sprites.draw(
        canvas,
        'enemy_${s.type.name}',
        Rect.fromLTWH((size.width - w) / 2, size.height - 4 - h, w, h),
        col,
      );
      return;
    }
    final p = Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = col;

    // Ground line.
    canvas.drawLine(Offset(0, c.dy + u * 3.4), Offset(size.width, c.dy + u * 3.4),
        Paint()
          ..color = T.dim
          ..strokeWidth = 2);

    switch (s.type) {
      case EnemyType.skitter:
        canvas.drawOval(Rect.fromCenter(center: c, width: u * 5, height: u * 2.6), p);
        for (int i = 0; i < 3; i++) {
          final x = c.dx - u * 1.5 + i * u * 1.5;
          canvas.drawLine(Offset(x, c.dy + u * 1.2), Offset(x - u * 0.8, c.dy + u * 3.2), p);
          canvas.drawLine(Offset(x, c.dy - u * 1.2), Offset(x + u * 0.6, c.dy - u * 2.6), p);
        }
        canvas.drawCircle(Offset(c.dx + u * 1.8, c.dy - u * 0.3), u * 0.3, fill);
        break;
      case EnemyType.hound:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: c, width: u * 5, height: u * 2), Radius.circular(u * 0.6)),
          p,
        );
        final head = Path()
          ..moveTo(c.dx + u * 2.5, c.dy - u * 1.1)
          ..lineTo(c.dx + u * 4.3, c.dy - u * 0.2)
          ..lineTo(c.dx + u * 2.5, c.dy + u * 0.7)
          ..close();
        canvas.drawPath(head, p);
        for (final dx in [-2.0, -1.0, 1.0, 2.0]) {
          canvas.drawLine(Offset(c.dx + u * dx, c.dy + u), Offset(c.dx + u * dx, c.dy + u * 3.2), p);
        }
        canvas.drawLine(Offset(c.dx - u * 2.5, c.dy - u * 0.5),
            Offset(c.dx - u * 3.6, c.dy - u * 1.6), p);
        canvas.drawCircle(Offset(c.dx + u * 3.1, c.dy - u * 0.5), u * 0.22, fill);
        break;
      case EnemyType.sentry:
        canvas.drawRect(Rect.fromCenter(center: c, width: u * 3, height: u * 3.4), p);
        canvas.drawRect(
            Rect.fromCenter(center: Offset(c.dx, c.dy - u * 2.4), width: u * 1.6, height: u * 1.1), p);
        canvas.drawCircle(Offset(c.dx, c.dy - u * 2.4), u * 0.28, fill);
        canvas.drawLine(Offset(c.dx + u * 1.5, c.dy - u * 0.4), Offset(c.dx + u * 4, c.dy - u * 0.4),
            p..strokeWidth = 5);
        p.strokeWidth = 2.5;
        canvas.drawRect(
            Rect.fromCenter(center: Offset(c.dx, c.dy + u * 2.7), width: u * 4.2, height: u * 0.9), p);
        break;
      case EnemyType.raider:
        canvas.drawCircle(Offset(c.dx, c.dy - u * 2.3), u * 0.8, p);
        canvas.drawLine(Offset(c.dx, c.dy - u * 1.5), Offset(c.dx, c.dy + u * 1.2), p);
        canvas.drawLine(Offset(c.dx, c.dy - u * 0.8), Offset(c.dx + u * 2.2, c.dy - u * 0.4), p);
        canvas.drawLine(Offset(c.dx + u * 1.2, c.dy - u * 0.6),
            Offset(c.dx + u * 3.2, c.dy - u * 0.9), p..strokeWidth = 4);
        p.strokeWidth = 2.5;
        canvas.drawLine(Offset(c.dx, c.dy - u * 0.8), Offset(c.dx - u * 1.2, c.dy + u * 0.3), p);
        canvas.drawLine(Offset(c.dx, c.dy + u * 1.2), Offset(c.dx - u * 0.9, c.dy + u * 3.2), p);
        canvas.drawLine(Offset(c.dx, c.dy + u * 1.2), Offset(c.dx + u * 0.9, c.dy + u * 3.2), p);
        break;
      case EnemyType.crawler:
        canvas.drawOval(Rect.fromCenter(center: c, width: u * 6, height: u * 1.6), p);
        for (int i = 0; i < 5; i++) {
          final x = c.dx - u * 2.2 + i * u * 1.1;
          canvas.drawLine(Offset(x, c.dy + u * 0.8), Offset(x - u * 0.9, c.dy + u * 1.8), p);
          canvas.drawLine(Offset(x - u * 0.9, c.dy + u * 1.8), Offset(x - u * 0.5, c.dy + u * 3.2), p);
        }
        canvas.drawCircle(Offset(c.dx + u * 2.6, c.dy - u * 0.2), u * 0.35, fill);
        break;
      case EnemyType.brute:
        canvas.drawRect(Rect.fromCenter(center: c, width: u * 4, height: u * 3.4), p);
        canvas.drawCircle(Offset(c.dx, c.dy - u * 2.4), u * 0.9, p);
        canvas.drawCircle(Offset(c.dx - u * 2.6, c.dy + u * 0.6), u * 1.0, p);
        canvas.drawCircle(Offset(c.dx + u * 2.6, c.dy + u * 0.6), u * 1.0, p);
        canvas.drawLine(Offset(c.dx - u, c.dy + u * 1.7), Offset(c.dx - u, c.dy + u * 3.2), p);
        canvas.drawLine(Offset(c.dx + u, c.dy + u * 1.7), Offset(c.dx + u, c.dy + u * 3.2), p);
        break;
      case EnemyType.lurker:
        canvas.drawOval(
            Rect.fromCenter(center: Offset(c.dx, c.dy - u * 1.2), width: u * 2.4, height: u * 3.4), p);
        canvas.drawLine(Offset(c.dx - u * 1.1, c.dy - u * 0.4), Offset(c.dx - u * 2.4, c.dy + u * 3.0), p);
        canvas.drawLine(Offset(c.dx + u * 1.1, c.dy - u * 0.4), Offset(c.dx + u * 2.4, c.dy + u * 3.0), p);
        canvas.drawCircle(Offset(c.dx - u * 0.45, c.dy - u * 1.6), u * 0.25, fill);
        canvas.drawCircle(Offset(c.dx + u * 0.45, c.dy - u * 1.6), u * 0.25, fill);
        break;
      case EnemyType.warmachine:
        canvas.drawRect(Rect.fromCenter(center: c, width: u * 4.6, height: u * 3), p);
        canvas.drawRect(
            Rect.fromCenter(center: Offset(c.dx, c.dy - u * 2.3), width: u * 2.4, height: u * 1.4), p);
        canvas.drawCircle(Offset(c.dx, c.dy - u * 2.3), u * 0.35, fill);
        canvas.drawLine(Offset(c.dx + u * 2.3, c.dy - u * 0.8),
            Offset(c.dx + u * 4.6, c.dy - u * 0.8), p..strokeWidth = 5);
        canvas.drawLine(Offset(c.dx + u * 2.3, c.dy + u * 0.2), Offset(c.dx + u * 4.6, c.dy + u * 0.2), p);
        p.strokeWidth = 2.5;
        canvas.drawRect(
            Rect.fromCenter(center: Offset(c.dx, c.dy + u * 2.6), width: u * 5.4, height: u * 1), p);
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _EnemyPainter old) => true;
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _Btn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              Fx.play(Sfx.beep);
              onTap!();
            },
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: T.mono(color, size: 13, bold: true)),
      ),
    );
  }
}
