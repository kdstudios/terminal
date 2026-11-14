import 'package:flutter/material.dart';
import '../game/fx.dart';
import 'theme.dart';

/// A retro keycap that waits for the player to acknowledge an encounter.
class EnterKey extends StatefulWidget {
  final VoidCallback onTap;
  const EnterKey({super.key, required this.onTap});
  @override
  State<EnterKey> createState() => _EnterKeyState();
}

class _EnterKeyState extends State<EnterKey> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Fx.play(Sfx.beep);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) {
          final p = Fx.settings.reducedMotion ? 0.5 : _pulse.value;
          return Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 96),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: T.panel,
              border: Border.all(color: T.green, width: 2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: T.dim, offset: const Offset(0, 3)), // keycap depth
                BoxShadow(
                  color: T.green.withOpacity(0.15 + 0.35 * p),
                  blurRadius: 8 + 10 * p,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ENTER', style: T.mono(T.green, size: 13, bold: true)),
                const SizedBox(width: 8),
                Icon(Icons.keyboard_return, color: T.green, size: 22),
              ],
            ),
          );
        },
      ),
    );
  }
}
