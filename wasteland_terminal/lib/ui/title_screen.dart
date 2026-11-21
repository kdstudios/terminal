import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../version.dart';
import 'atlas.dart';
import 'crt.dart';
import 'dweller_rig.dart';
import 'metal_frame.dart';
import 'theme.dart';
import 'wasteland_scene.dart';

/// The first screen: the logo over a night camp, the dweller sitting by the
/// fire, a PLAY button and the version. Pressing PLAY loads the latest save
/// (or starts a new game), which main.dart does.
class TitleScreen extends StatefulWidget {
  final VoidCallback onPlay;
  final bool starting; // true once PLAY was pressed and the save is loading
  const TitleScreen({super.key, required this.onPlay, required this.starting});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _t = ValueNotifier(0);
  final SceneClock _still = SceneClock()..scroll = 1400; // a fixed stretch of forest ruins
  late final Ticker _ticker;
  DwellerRig? _rig;

  @override
  void initState() {
    super.initState();
    _rig = DwellerRig.load();
    _ticker = createTicker((e) => _t.value = e.inMicroseconds / 1e6)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _t.dispose();
    _still.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        child: MetalFrame(
          child: CrtScreen(
            child: LayoutBuilder(builder: (context, c) {
              final short = c.maxHeight < 360;
              return Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(
                    child: CustomPaint(painter: _CampPainter(_t, _still, _rig)),
                  ),
                  Positioned(left: 0, right: 0, top: short ? 8 : 26, child: _Logo(compact: short)),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: short ? 8 : 22,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _PlayButton(onTap: widget.starting ? null : widget.onPlay, loading: widget.starting),
                      const SizedBox(height: 8),
                      Text('v$kVersion', style: T.mono(T.label, size: 12)),
                    ]),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final bool compact;
  const _Logo({required this.compact});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final big = (w * 0.11).clamp(28.0, compact ? 38.0 : 56.0).toDouble();
    TextStyle glow(double size, Color col) => T.mono(col, size: size, bold: true).copyWith(
          letterSpacing: size * 0.18,
          shadows: [
            Shadow(color: T.green.withValues(alpha: 0.9), blurRadius: 16),
            Shadow(color: T.green.withValues(alpha: 0.5), blurRadius: 34),
          ],
        );
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('WASTELAND', style: glow(big * 0.62, T.green)),
      Text('TERMINAL', style: glow(big, T.green)),
      const SizedBox(height: 6),
      Container(width: big * 5.2, height: 2, color: T.dim),
      const SizedBox(height: 6),
      Text('[ SURVIVAL TERMINAL // EXPEDITION LOG ]', style: T.mono(T.label, size: 11)),
    ]);
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool loading;
  const _PlayButton({required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    final col = loading ? T.dim : T.amber;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          border: Border.all(color: col, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(loading ? 'LOADING...' : '[ PLAY ]', style: T.mono(col, size: 18, bold: true)),
      ),
    );
  }
}

class _CampPainter extends CustomPainter {
  final ValueNotifier<double> time;
  final SceneClock still;
  final DwellerRig? rig;
  _CampPainter(this.time, this.still, this.rig) : super(repaint: time);

  Paint _img(Color tint, double keep, double gain) => Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.medium
    ..colorFilter = Crt.phosphor(tint, keep: keep, gain: gain);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    if (w < 60 || h < 60) return;
    final t = time.value;
    final unit = h * 0.2 / 78;
    final groundY = h * 0.78;
    final footY = groundY + kFeetDepth * unit;
    final f = unit * 1.45; // the camp is drawn larger than the world: it's the hero shot

    // The night world: the suburbs forest, dimmed.
    WastelandScenePainter(clock: still, region: 3, drawDweller: false).paint(canvas, size);
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black.withValues(alpha: 0.55));
    final rnd = Random(7);
    for (int i = 0; i < 46; i++) {                                   // stars
      final x = rnd.nextDouble() * w, y = rnd.nextDouble() * h * 0.42;
      final tw = 0.5 + 0.5 * sin(t * (1 + rnd.nextDouble() * 2) + i);
      canvas.drawRect(Rect.fromLTWH(x, y, 2, 2), Paint()..color = T.green.withValues(alpha: 0.25 + 0.5 * tw));
    }

    // Fire light.
    final fx = w * 0.6;
    final flick = 0.85 + 0.15 * sin(t * 13) * sin(t * 5.3) + 0.05 * sin(t * 31);
    final glowR = 150 * f * flick;
    final glow = Rect.fromCircle(center: Offset(fx, footY - 18 * f), radius: glowR);
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(colors: [
            T.amber.withValues(alpha: 0.38 * flick),
            T.amber.withValues(alpha: 0.10 * flick),
            Colors.transparent,
          ], stops: const [0.0, 0.5, 1.0]).createShader(glow));

    // Seat, dweller, fire.
    final seat = Atlas.named('derived', 'camp.seat');
    final logs = Atlas.named('derived', 'camp.logs');
    final fire = Atlas.named('derived', 'camp.fire${(t * 9).floor() % 4}');
    final px = fx - 58 * f;
    seat?.draw(canvas, Offset(px, footY + 2 * f), f * 0.5, _img(T.green, 0.35, 0.9));
    rig?.drawPose(canvas,
        ground: Offset(px, footY),
        scale: f,
        thighDeg: const [96, 100],
        flexDeg: const [92, 96],
        leanDeg: 4,
        breathe: sin(t * 1.7) * 0.5,
        near: _img(T.green, 0.6, 1.0),
        far: _img(T.green, 0.6, 0.8));
    logs?.draw(canvas, Offset(fx, footY + 2 * f), f * 0.55, _img(T.amber, 0.55, 1.0));
    fire?.draw(canvas, Offset(fx, footY - 5 * f), f * 0.95, _img(T.amber, 0.6, 1.15));

    // Embers drifting up.
    for (int i = 0; i < 16; i++) {
      final u = (t * 0.32 + i / 16) % 1.0;
      final x = fx + sin(i * 12.9 + t * 0.9) * 22 * f * u;
      final y = footY - 22 * f - u * 120 * f;
      canvas.drawRect(Rect.fromLTWH(x, y, 2.2 * f / 1.4, 2.2 * f / 1.4),
          Paint()..color = T.amber.withValues(alpha: (1 - u) * 0.9));
    }
  }

  @override
  bool shouldRepaint(covariant _CampPainter old) => true;
}
