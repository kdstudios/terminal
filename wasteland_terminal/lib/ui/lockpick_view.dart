import 'dart:math';
import 'package:flutter/material.dart';
import '../game/fx.dart';
import '../game/game_state.dart';
import '../game/lockpick_session.dart';
import '../game/lockpicking_system.dart';
import '../game/typewriter.dart';
import 'console_box.dart';
import 'atlas.dart';
import 'crt.dart';
import 'sprites.dart';
import 'theme.dart';

String _hp(double stress) => '${((1 - stress.clamp(0.0, 1.0)) * 100).round()}%';

String _strainBar(double stress) {
  final filled = min(8, max(0, (stress * 8).ceil()));
  return '[${'■' * filled}${'□' * (8 - filled)}]';
}

/// Main screen while picking a lock.
/// Drag the lock = aim the pick. Pull the lever left = turn the lock.
/// The lever slot has a fixed height and is reused for the result, so the lock
/// never moves when the lock opens.
class LockpickView extends StatelessWidget {
  final GameState state;
  final LockpickingSystem system;
  final TypewriterController typer; // encounter console (instant during locks)
  const LockpickView({
    super.key,
    required this.state,
    required this.system,
    required this.typer,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.lockpick!;
    if (!s.engaged) return _prompt(s);

    return ListenableBuilder(
      listenable: s,
      builder: (context, _) => LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth > box.maxHeight * 1.25;

        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LOCK: ${s.lockName}   PICKS: ${'▮ ' * max(0, state.lockpicks)}',
                style: T.mono(T.green, size: 13, bold: true)),
            Text('PICK HP: ${_hp(s.stress)}',
                style: T.mono(s.stress > 0.6 ? T.red : T.green, size: 13)),
            Text('DRAG LOCK: AIM  //  PULL LEVER: TURN', style: T.mono(T.label, size: 10)),
          ],
        );

        final lock = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) => system.rotate(d.delta.dx * 0.5),
          child: SizedBox.expand(child: _LockStage(s)),
        );

        final controls = SizedBox(
          height: 56,
          child: s.finished
              ? Row(children: [
                  Expanded(
                    child: Text(
                      s.success ? 'LOCK OPENED' : 'LOCK JAMMED',
                      style: T.mono(s.success ? T.loot : T.red, bold: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Btn('[CONTINUE]', T.green, system.leave),
                ])
              : _Lever(session: s, system: system),
        );

        return Padding(
          padding: const EdgeInsets.all(8),
          child: wide
              ? Row(children: [
                  Expanded(
                    child: Column(children: [
                      Expanded(child: lock),
                      const SizedBox(height: 6),
                      controls,
                    ]),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header,
                        const SizedBox(height: 6),
                        Expanded(child: ConsoleBox(typer: typer, fontSize: 11)),
                      ],
                    ),
                  ),
                ])
              : Column(children: [
                  Align(alignment: Alignment.centerLeft, child: header),
                  const SizedBox(height: 4),
                  ConsoleBox(typer: typer, lines: 2, fontSize: 12),
                  Expanded(child: lock),
                  const SizedBox(height: 6),
                  controls,
                ]),
        );
      }),
    );
  }

  Widget _prompt(LockpickSession s) => LayoutBuilder(builder: (context, c) {
        final img = (c.maxHeight - 170).clamp(48.0, 100.0).toDouble();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LOCKED CONTAINER DETECTED', style: T.mono(T.amber, bold: true)),
              Text('LOCK: ${s.lockName}', style: T.mono(T.label)),
              Text('LOCKPICKS: ${state.lockpicks}', style: T.mono(T.label)),
              Text('PICK HP: ${_hp(s.stress)}',
                  style: T.mono(s.stress > 0.6 ? T.red : T.label)),
              const SizedBox(height: 8),
              AtlasImage(
                sheet: 'minigame',
                name: 'iso.chest',
                height: img,
                fallback: const SpriteView(name: 'loc_chest', height: 70),
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 10, children: [
                _Btn('[PICK LOCK]', T.green, system.engage),
                _Btn('[IGNORE]', T.amber, system.ignore),
              ]),
            ],
          ),
        );
      });
}

/// The tension lever. Rests at the right; drag the handle left to pull.
/// The handle follows the finger 1:1, so pulling halfway attempts a half turn.
/// Release and it springs back. Uses raw pointer events (no tap delay) and lets
/// go if the layout is rebuilt mid-press (e.g. device rotation).
class _Lever extends StatefulWidget {
  final LockpickSession session;
  final LockpickingSystem system;
  const _Lever({required this.session, required this.system});
  @override
  State<_Lever> createState() => _LeverState();
}

class _LeverState extends State<_Lever> {
  static const double _handleW = 56;

  @override
  void dispose() {
    widget.session.gripping = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final strained = s.blocked;
    final color = strained ? (s.stress > 0.6 ? T.red : T.amber) : T.green;

    return LayoutBuilder(builder: (context, box) {
      final travel = max(1.0, box.maxWidth - _handleW);
      final left = travel * (1 - s.lever);
      return Listener(
        onPointerDown: (_) => widget.system.grip(true),
        onPointerMove: (e) => widget.system.dragLever(-e.delta.dx / travel),
        onPointerUp: (_) => widget.system.grip(false),
        onPointerCancel: (_) => widget.system.grip(false),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: T.dim, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: T.panel,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Pulled-in fill behind the handle.
                Positioned(
                  left: left,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(color: color.withOpacity(0.25)),
                ),
                // Quarter marks along the track.
                for (final f in [0.25, 0.5, 0.75])
                  Positioned(
                    left: _handleW / 2 + travel * (1 - f),
                    top: 14,
                    bottom: 14,
                    child: Container(width: 1, color: T.dim),
                  ),
                if (s.lever < 0.02)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: _handleW),
                      child: Text('◀ PULL LEVER TO TURN',
                          style: T.mono(T.label, size: 12)),
                    ),
                  ),
                // Handle.
                Positioned(
                  left: left,
                  top: 3,
                  bottom: 3,
                  width: _handleW,
                  child: Container(
                    decoration: BoxDecoration(
                      color: s.gripping ? color : T.dim,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text('|||', style: T.mono(T.bg, bold: true)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Lock plate by level (simplest -> most ornate), and where each plate's keyhole
/// sits in its sprite (pixels). All plates share one scale, so the standalone
/// cylinder disc drops straight over each plate's own cylinder ring.
const _plateByLevel = ['lock.0', 'lockplate.0', 'lock.1', 'lockplate.1', 'lockplate.2', 'lockplate.2'];
const _keyhole = <String, Offset>{
  'lock.0': Offset(52, 133),
  'lockplate.0': Offset(83, 135),
  'lock.1': Offset(78, 135),
  'lockplate.1': Offset(83, 130),
  'lockplate.2': Offset(111, 130),
};

/// Hosts the lock painter and plays the "pick snapped" animation: the session
/// resets the pick instantly, so the view keeps the broken one falling for a moment.
class _LockStage extends StatefulWidget {
  final LockpickSession s;
  const _LockStage(this.s);

  @override
  State<_LockStage> createState() => _LockStageState();
}

class _LockStageState extends State<_LockStage> with SingleTickerProviderStateMixin {
  late final AnimationController _snap =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
  late int _broken = widget.s.broken;

  @override
  void initState() {
    super.initState();
    widget.s.addListener(_onSession);
  }

  void _onSession() {
    if (widget.s.broken > _broken && !Fx.settings.reducedMotion) _snap.forward(from: 0);
    _broken = widget.s.broken;
  }

  @override
  void dispose() {
    widget.s.removeListener(_onSession);
    _snap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _LockPainter(widget.s, _snap));
}

class _LockPainter extends CustomPainter {
  final LockpickSession s;
  final AnimationController snap;
  _LockPainter(this.s, this.snap) : super(repaint: Listenable.merge([s, snap]));

  @override
  void paint(Canvas canvas, Size size) {
    final plateName = _plateByLevel[min(max(s.level - 1, 0), _plateByLevel.length - 1)];
    final plate = Atlas.named('minigame', plateName);
    final cyl = Atlas.named('minigame', 'cylinder');
    final pick = Atlas.named('minigame', 'pickpin');
    if (plate == null || cyl == null || pick == null) {
      _VectorLockPainter(s).paint(canvas, size); // art missing: old vector lock
      return;
    }
    final kh = _keyhole[plateName]!;
    // Fit: 135px of plate above the keyhole, ~195px of pick + gauge below it.
    final sc = min((size.height - 10) / 335, (size.width - 10) / 400);
    if (sc < 0.15) return;
    final c = Offset(size.width / 2, 6 + kh.dy * sc);

    Paint img({Color? tint, double keep = 0.5, double gain = 1.0, double alpha = 1}) => Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.medium
      ..colorFilter = Crt.phosphor(tint ?? T.green, keep: keep, gain: gain)
      ..color = Colors.white.withValues(alpha: alpha);

    // Gauge under the lock: the pick's range, ticks every 15 degrees.
    final dim = Paint()
      ..color = T.dim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final ra = 185 * sc;
    canvas.drawArc(Rect.fromCircle(center: c, radius: ra), 0, pi, false, dim);
    for (int k = -6; k <= 6; k++) {
      final a = pi / 2 - k * pi / 12;
      final d = Offset(cos(a), sin(a));
      canvas.drawLine(c + d * (ra * 0.95), c + d * (ra * 1.05), dim);
    }

    // Plate, glowing when the lock opens.
    plate.drawRect(
        canvas, Rect.fromLTWH(c.dx - kh.dx * sc, c.dy - kh.dy * sc, plate.w * sc, plate.h * sc),
        img());
    if (s.finished && s.success) {
      canvas.drawCircle(
          c,
          120 * sc,
          Paint()
            ..shader = RadialGradient(colors: [T.loot.withValues(alpha: 0.35), Colors.transparent])
                .createShader(Rect.fromCircle(center: c, radius: 120 * sc)));
    }

    // The cylinder turns with progress (towards the lever's pull).
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-s.progress * pi / 2);
    cyl.drawRect(canvas,
        Rect.fromLTWH(-cyl.w * sc / 2, -cyl.h * sc / 2, cyl.w * sc, cyl.h * sc), img());
    canvas.restore();

    // The pick pivots about its tip in the keyhole; shakes when over-pulled.
    final t = DateTime.now().millisecondsSinceEpoch.toDouble();
    final shake = (s.blocked && !Fx.settings.reducedMotion)
        ? Offset(sin(t * 0.09), cos(t * 0.13)) * ((1 + s.stress * 4) * sc * 1.6)
        : Offset.zero;
    canvas.save();
    canvas.translate(c.dx + shake.dx, c.dy + shake.dy);
    canvas.rotate(-s.pickAngle * pi / 180);
    pick.drawRect(canvas, Rect.fromLTWH(-pick.w * sc / 2, 0, pick.w * sc, pick.h * sc),
        img(tint: s.stress > 0.6 ? T.red : T.amber, keep: 0.55));
    canvas.restore();

    // A snapped pick tumbles away.
    if (snap.isAnimating) {
      final broken = Atlas.named('minigame', 'pick.broken');
      if (broken != null) {
        final u = snap.value;
        canvas.save();
        canvas.translate(c.dx, c.dy + (95 + 150 * u * u) * sc);
        canvas.rotate(u * 1.3);
        broken.drawRect(
            canvas,
            Rect.fromLTWH(-broken.w * sc * 0.4, -broken.h * sc * 0.4, broken.w * sc * 0.8,
                broken.h * sc * 0.8),
            img(tint: T.red, keep: 0.4, alpha: 1 - u));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LockPainter old) => true;
}

class _VectorLockPainter extends CustomPainter {
  final LockpickSession s;
  _VectorLockPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    final r = min((size.height - 24) / 2.3, (size.width - 10) / 2.7);
    if (r <= 8) return;
    final c = Offset(size.width / 2, r + 14);
    Paint stroke(Color col, double w) => Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    final dim = stroke(T.dim, 2);
    final green = stroke(T.green, 3);

    // Gauge arc under the lock showing the pick's range, ticks every 15 degrees.
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 1.25), 0, pi, false, dim);
    for (int k = -6; k <= 6; k++) {
      final a = pi / 2 - k * pi / 12;
      final d = Offset(cos(a), sin(a));
      canvas.drawLine(c + d * (r * 1.2), c + d * (r * 1.3), dim);
    }

    // Fixed housing + marker, and the cylinder that turns with progress.
    canvas.drawCircle(c, r, dim);
    final mark = Path()
      ..moveTo(c.dx, c.dy - r - 2)
      ..lineTo(c.dx - 6, c.dy - r - 12)
      ..lineTo(c.dx + 6, c.dy - r - 12)
      ..close();
    canvas.drawPath(mark, Paint()..color = T.amber);

    final th = s.progress * pi / 2;
    canvas.drawCircle(c, r * 0.8, green);
    for (int i = 0; i < 8; i++) {
      final a = th + i * pi / 4 - pi / 2;
      final d = Offset(cos(a), sin(a));
      canvas.drawLine(c + d * (r * 0.66), c + d * (r * 0.8), green);
    }
    final kd = Offset(cos(th + pi / 2), sin(th + pi / 2));
    canvas.drawLine(c, c + kd * (r * 0.4), green);
    canvas.drawCircle(c, r * 0.1, Paint()..color = T.green);

    // The pick. It shakes when you're pulling past what the lock allows.
    final pa = s.pickAngle * pi / 180;
    final dir = Offset(sin(pa), cos(pa));
    final t = DateTime.now().millisecondsSinceEpoch.toDouble();
    final shake = (s.blocked && !Fx.settings.reducedMotion)
        ? Offset(sin(t * 0.09), cos(t * 0.13)) * (1 + s.stress * 4)
        : Offset.zero;
    final col = s.stress > 0.6 ? T.red : T.amber;
    canvas.drawLine(c + shake, c + dir * (r * 1.2) + shake, stroke(col, 3));
    canvas.drawCircle(c + dir * (r * 1.2) + shake, 5, Paint()..color = col);
  }

  @override
  bool shouldRepaint(covariant _VectorLockPainter old) => true;
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Btn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Fx.play(Sfx.beep);
        onTap();
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: T.mono(color, bold: true)),
      ),
    );
  }
}
