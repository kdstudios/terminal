import 'package:flutter/material.dart';
import '../game/combat_session.dart';
import '../game/combat_system.dart';
import '../game/fx.dart';
import '../game/game_state.dart';
import '../game/typewriter.dart';
import 'crt.dart';
import 'metal_frame.dart';
import 'theme.dart';

/// The fight's buttons, in their own framed box beside the encounter log: a
/// single column on the right edge, so a thumb reaches every button one-handed
/// in portrait or landscape. After the fight it shows the result and CONTINUE.
class CombatActions extends StatelessWidget {
  final GameState state;
  final CombatSystem system;
  final TypewriterController typer;
  const CombatActions({super.key, required this.state, required this.system, required this.typer});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([state, typer.busyNotifier]),
      builder: (_, __) {
        final s = state.combat;
        if (s == null) return const SizedBox.shrink();
        // Buttons and the result wait until the log has finished typing.
        final busy = typer.busy;
        return MetalFrame(
          child: CrtScreen(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: (s.finished && !busy) ? _result(s) : _actions(s, busy),
            ),
          ),
        );
      },
    );
  }

  Widget _actions(CombatSession s, bool busy) {
    final off = busy || s.finished;
    VoidCallback? go(PlayerAction a) => off ? null : () => system.act(a);
    Color c(Color x) => x; // disabled buttons dim themselves (see _Btn)
    final noStim = state.stimpacks <= 0 || off;
    final buttons = <Widget>[
      _Btn('ATTACK', c(T.green), go(PlayerAction.attack)),
      _Btn('HEAVY', c(T.amber), go(PlayerAction.heavy)),
      _Btn('DEFEND', c(T.green), go(PlayerAction.defend)),
      _Btn('ITEM x${state.stimpacks}', T.loot,
          noStim ? null : () => system.act(PlayerAction.item)),
      _Btn('ESCAPE', c(T.amber), go(PlayerAction.escape)),
    ];
    return Column(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          Expanded(child: buttons[i]),
        ],
      ],
    );
  }

  Widget _result(CombatSession s) {
    final String text;
    final Color color;
    switch (s.outcome) {
      case CombatOutcome.won:
        text = 'VICTORY\n+${s.scrapGained} SCRAP';
        color = T.loot;
        break;
      case CombatOutcome.fled:
        text = 'YOU\nESCAPED';
        color = T.amber;
        break;
      default:
        text = s.scrapGained < 0 ? 'YOU HAVE FALLEN\n${s.scrapGained} SCRAP' : 'YOU HAVE\nFALLEN';
        color = T.red;
    }
    return Column(
      children: [
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text, textAlign: TextAlign.center, style: T.mono(color, size: 15, bold: true)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(height: 52, child: _Btn('CONTINUE', T.green, system.leave)),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _Btn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    final on = onTap != null;
    // Disabled = the same colour, a little dimmer (never a different dark grey).
    final color = on ? this.color : Color.lerp(this.color, T.bg, 0.38)!;
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              Fx.play(Sfx.beep);
              onTap!();
            },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        constraints: const BoxConstraints(minHeight: 30),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: on ? 0.07 : 0.0),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: T.mono(color, size: 14, bold: true)),
        ),
      ),
    );
  }
}
