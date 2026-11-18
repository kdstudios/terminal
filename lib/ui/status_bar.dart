import 'package:flutter/material.dart';
import '../game/game_state.dart';
import 'crt.dart';
import 'metal_frame.dart';
import 'theme.dart';

/// HP / SCRAP / PICKS / DIST / MENU in its own framed panel, cells divided by
/// thin rules like the concept art.
class StatusBar extends StatelessWidget {
  final GameState state;
  final VoidCallback? onMenu;
  const StatusBar({super.key, required this.state, this.onMenu});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (_, __) {
        final hpColor = state.hp < state.maxHp * 0.3 ? T.red : T.green;
        return MetalFrame(
          child: CrtScreen(
            child: Row(
              children: [
                _cell('HP', '${state.hp}/${state.maxHp}', hpColor, flex: 4),
                _rule(),
                _cell('SCRAP', '${state.scrap}', T.loot, flex: 3),
                _rule(),
                _cell('PICKS', '${state.lockpicks}', T.amber, flex: 3),
                _rule(),
                _cell('DIST', '${state.distanceKm.toStringAsFixed(2)}KM', T.green, flex: 4),
                _rule(),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: InkWell(
                      onTap: onMenu,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: T.amber.withValues(alpha: 0.7)),
                          borderRadius: BorderRadius.circular(4),
                          color: T.amber.withValues(alpha: 0.08),
                        ),
                        child: Text('[MENU]', style: T.mono(T.amber, size: 13, bold: true)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _rule() => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: T.dim.withValues(alpha: 0.6),
      );

  Widget _cell(String label, String value, Color c, {required int flex}) => Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: T.mono(T.label, size: 11)),
                Text(value, style: T.mono(c, size: 17, bold: true)),
              ],
            ),
          ),
        ),
      );
}
