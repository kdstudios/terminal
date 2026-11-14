import 'package:flutter/material.dart';
import 'crt.dart';
import 'metal_frame.dart';

/// A window of the game: the riveted metal frame (9-slice, see metal_frame.dart)
/// around a CRT screen with a title strip and scanline / glow overlay.
class TerminalFrame extends StatelessWidget {
  final String title;
  final Widget child;
  const TerminalFrame({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) =>
      MetalFrame(child: CrtScreen(title: title, child: child));
}
