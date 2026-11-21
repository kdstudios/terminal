import 'package:flutter/material.dart';
import '../game/fx.dart';

/// Swaps one panel for another with a CRT-style flicker. The child must have a
/// key; the flicker plays whenever the key changes. (Reduced motion: instant.)
class FlickerSwitch extends StatefulWidget {
  final Widget child;
  const FlickerSwitch({super.key, required this.child});
  @override
  State<FlickerSwitch> createState() => _FlickerSwitchState();
}

class _FlickerSwitchState extends State<FlickerSwitch> {
  @override
  void didUpdateWidget(FlickerSwitch old) {
    super.didUpdateWidget(old);
    if (old.child.key != widget.child.key) Fx.play(Sfx.click, gain: 0.9);
  }

  static double _flick(double v) {
    if (v >= 1) return 1;
    if (v <= 0.08) return 0;
    final step = (v * 24).floor();
    return step % 3 == 1 ? 0.2 : 0.45 + 0.55 * v;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Fx.settings.reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 420),
      transitionBuilder: (child, anim) => AnimatedBuilder(
        animation: anim,
        child: child,
        builder: (_, c) {
          final v = anim.value;
          final jitter = (v < 1 && (v * 24).floor() % 2 == 0) ? 3.0 : 0.0;
          return Opacity(
            opacity: _flick(v),
            child: Transform.translate(offset: Offset(jitter, 0), child: c),
          );
        },
      ),
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        children: [...previous, if (current != null) current],
      ),
      child: widget.child,
    );
  }
}
