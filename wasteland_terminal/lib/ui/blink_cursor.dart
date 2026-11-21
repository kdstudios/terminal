import 'dart:async';
import 'package:flutter/material.dart';
import '../game/fx.dart';
import 'theme.dart';

/// A solid block that blinks by fading, never by changing size, so blinking
/// can never move any text.
class BlinkCursor extends StatefulWidget {
  final bool solid; // true while typing: no blinking
  final double size; // height of the block
  const BlinkCursor({super.key, this.solid = false, this.size = 14});
  @override
  State<BlinkCursor> createState() => _BlinkCursorState();
}

class _BlinkCursorState extends State<BlinkCursor> {
  Timer? _t;
  bool _on = true;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (mounted && !widget.solid && !Fx.settings.reducedMotion) {
        setState(() => _on = !_on);
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final show = widget.solid || Fx.settings.reducedMotion || _on;
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Opacity(
        opacity: show ? 1 : 0,
        child: Container(width: widget.size * 0.57, height: widget.size, color: T.green),
      ),
    );
  }
}
