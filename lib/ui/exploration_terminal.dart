import 'dart:math';
import 'package:flutter/material.dart';
import '../game/game_state.dart';
import '../game/hacking_system.dart';
import '../game/combat_system.dart';
import '../game/lockpicking_system.dart';
import '../game/event_system.dart';
import '../game/home_system.dart';
import 'combat_view.dart';
import 'event_view.dart';
import 'home_view.dart';
import 'hacking_view.dart';
import 'lockpick_view.dart';
import 'terminal_frame.dart';
import '../game/fx.dart';
import '../game/world.dart';
import '../game/typewriter.dart';
import 'atlas.dart';
import 'backdrop.dart';
import 'sprites.dart';
import 'wasteland_scene.dart';
import 'theme.dart';

/// Terminal A: wasteland simulation, or the active minigame/encounter view.
class ExplorationTerminal extends StatefulWidget {
  final GameState state;
  final HackingSystem hacking;
  final LockpickingSystem lockpicking;
  final CombatSystem combat;
  final HomeSystem home;
  final EventSystem events;
  final TypewriterController consoleTyper; // encounter text
  const ExplorationTerminal({
    super.key,
    required this.state,
    required this.hacking,
    required this.lockpicking,
    required this.combat,
    required this.home,
    required this.events,
    required this.consoleTyper,
  });
  @override
  State<ExplorationTerminal> createState() => _ExplorationTerminalState();
}

class _ExplorationTerminalState extends State<ExplorationTerminal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _walk =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
        ..repeat();

  @override
  void dispose() {
    _walk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.state, widget.consoleTyper.busyNotifier]),
      builder: (_, __) {
        final inHack =
            widget.state.mode == GameMode.hacking && widget.state.hacking != null;
        final inLock =
            widget.state.mode == GameMode.lockpicking && widget.state.lockpick != null;
        final inCombat =
            widget.state.mode == GameMode.combat && widget.state.combat != null;
        final inHome = widget.state.mode == GameMode.home;
        final inEvent =
            widget.state.mode == GameMode.event && widget.state.event != null;
        return TerminalFrame(
          title: inHack
              ? 'SECURITY TERMINAL'
              : inLock
                  ? 'LOCKPICKING'
                  : inCombat
                      ? 'COMBAT'
                      : inHome
                          ? 'SAFEHOUSE'
                          : inEvent
                              ? 'ENCOUNTER'
                              : 'EXPLORATION // ${widget.state.region}${widget.state.walkingPaused ? ' (STOPPED)' : ''}',
          child: inHack
              ? HackingView(
                  state: widget.state,
                  system: widget.hacking,
                  typer: widget.consoleTyper)
              : inLock
              ? LockpickView(
                  state: widget.state,
                  system: widget.lockpicking,
                  typer: widget.consoleTyper)
              : inCombat
              ? CombatView(state: widget.state, system: widget.combat, typer: widget.consoleTyper)
              : inHome
              ? HomeView(state: widget.state, system: widget.home)
              : inEvent
              ? Backdrop(tile: 'bg.wall', child: EventView(state: widget.state))
              : Atlas.ready
              ? WastelandView(
                  region: regions.indexOf(regionAt(widget.state.distanceKm)),
                  walking: widget.state.exploring &&
                      !widget.state.walkingPaused &&
                      widget.state.pending == null,
                )
              : ListenableBuilder(
                  listenable: Fx.settings.reducedMotion ? widget.state : _walk,
                  builder: (_, __) => CustomPaint(
                    size: Size.infinite,
                    painter: Sprites.has('bg_far_0')
                        ? _SpriteWastelandPainter(
                            phase: Fx.settings.reducedMotion ? 0 : _walk.value,
                            scroll: Fx.settings.reducedMotion ? 0 : widget.state.distanceKm * 4000,
                            walking: widget.state.exploring &&
                                !widget.state.walkingPaused &&
                                widget.state.pending == null &&
                                !Fx.settings.reducedMotion,
                            region: regions.indexOf(regionAt(widget.state.distanceKm)),
                          )
                        : _WastelandPainter(
                      phase: Fx.settings.reducedMotion ? 0 : _walk.value,
                      scroll: Fx.settings.reducedMotion ? 0 : widget.state.distanceKm * 6000,
                      walking: widget.state.exploring &&
                          !widget.state.walkingPaused &&
                          widget.state.pending == null &&
                          !Fx.settings.reducedMotion,
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _WastelandPainter extends CustomPainter {
  final double phase, scroll;
  final bool walking;
  _WastelandPainter({required this.phase, required this.scroll, required this.walking});

  double _h(int i) => 20 + ((i * 7919) % 53).toDouble(); // deterministic "random"

  @override
  void paint(Canvas canvas, Size size) {
    final ground = size.height * 0.75;
    final line = Paint()
      ..color = T.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final faint = Paint()
      ..color = T.dim
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, ground), Offset(size.width, ground), line);

    _ruins(canvas, size, ground, scroll * 0.3, 90, faint, 1.0); // distant
    _ruins(canvas, size, ground, scroll, 160, line, 0.6); // near

    // Player, fixed horizontally.
    final px = size.width * 0.3;
    final s = min(size.height / 160, 1.6);
    final swing = walking ? sin(phase * 2 * pi) : 0.0;
    final bob = walking ? (cos(phase * 4 * pi).abs() * 2 * s) : 0.0;
    final hip = Offset(px, ground - 28 * s - bob);
    final shoulder = hip.translate(0, -22 * s);
    canvas.drawCircle(shoulder.translate(0, -8 * s), 6 * s, line);
    canvas.drawLine(shoulder, hip, line);
    canvas.drawLine(shoulder, shoulder.translate(10 * s * swing, 14 * s), line);
    canvas.drawLine(hip, Offset(px + 12 * s * swing, ground), line);
    canvas.drawLine(hip, Offset(px - 12 * s * swing, ground), line);
    canvas.drawRect(Rect.fromLTWH(px - 12 * s, shoulder.dy, 7 * s, 16 * s), line);
  }

  void _ruins(Canvas c, Size size, double ground, double off, double spacing,
      Paint p, double hScale) {
    final first = (off / spacing).floor();
    final count = (size.width / spacing).ceil() + 2;
    for (int k = 0; k < count; k++) {
      final i = first + k;
      final x = i * spacing - off;
      final h = _h(i) * hScale;
      final w = 22 + (i.abs() * 13 % 25).toDouble();
      final top = ground - h;
      final path = Path()
        ..moveTo(x, ground)
        ..lineTo(x, top + 8)
        ..lineTo(x + w * 0.4, top)
        ..lineTo(x + w * 0.6, top + 12)
        ..lineTo(x + w, top + 4)
        ..lineTo(x + w, ground);
      c.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _WastelandPainter o) =>
      o.phase != phase || o.scroll != scroll || o.walking != walking;
}


/// The pixel-art exploration scene: a sky layer, a scenery layer and a ground
/// layer scrolling at different speeds behind a walking survivor.
class _SpriteWastelandPainter extends CustomPainter {
  final double phase, scroll;
  final bool walking;
  final int region;
  _SpriteWastelandPainter({
    required this.phase,
    required this.scroll,
    required this.walking,
    required this.region,
  });

  static const double _h = 120, _gy = 96;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = max(1.0, (size.height / _h).floorToDouble());
    final top = ((size.height - _h * sc) / 2).floorToDouble();

    void layer(String name, double speed, double yArt, double opacity) {
      final im = Sprites.get(name);
      if (im == null) return;
      final tileW = im.width * sc;
      final off = (scroll * speed) % tileW;
      for (double x = -off.floorToDouble(); x < size.width; x += tileW) {
        Sprites.draw(
          canvas,
          name,
          Rect.fromLTWH(x, top + yArt * sc, tileW, im.height * sc),
          T.green,
          opacity: opacity,
        );
      }
    }

    layer('bg_far_$region', 0.2, 0, 0.55);
    layer('bg_mid_$region', 0.6, 0, 1.0);
    layer('ground_$region', 1.0, _gy, 0.85);

    final frame = walking ? (phase * 4).floor() % 4 : 0;
    final pw = 32 * sc, ph = 48 * sc;
    final feet = top + (_gy + 6) * sc;
    Sprites.draw(
      canvas,
      'player_$frame',
      Rect.fromLTWH((size.width * 0.3 - pw / 2).floorToDouble(), feet - ph, pw, ph),
      T.green,
    );
  }

  @override
  bool shouldRepaint(covariant _SpriteWastelandPainter o) =>
      o.phase != phase || o.scroll != scroll || o.walking != walking || o.region != region;
}
