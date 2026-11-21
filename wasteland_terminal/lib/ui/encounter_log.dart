import 'package:flutter/material.dart';
import '../game/combat_system.dart';
import '../game/event_system.dart';
import '../game/fx.dart';
import '../game/game_state.dart';
import '../game/typewriter.dart';
import 'combat_actions.dart';
import 'console_box.dart';
import 'terminal_frame.dart';
import 'theme.dart';

/// The right-hand panel during hacks, fights and choice encounters. It takes
/// over from the narrative log (with a flicker) and holds the encounter's text
/// and, for choice encounters, its buttons.
class EncounterLog extends StatelessWidget {
  final GameState state;
  final EventSystem events;
  final TypewriterController typer; // the encounter console
  final CombatSystem combat; // its buttons get their own box during fights
  const EncounterLog({
    super.key,
    required this.state,
    required this.events,
    required this.typer,
    required this.combat,
  });

  @override
  Widget build(BuildContext context) {
    final log = _log();
    return ListenableBuilder(
      listenable: state,
      builder: (_, __) {
        if (state.mode != GameMode.combat || state.combat == null) return log;
        // Fight: the log keeps the left, the action box takes a thumb-width strip on the right.
        return LayoutBuilder(builder: (context, c) {
          final bw = (c.maxWidth * 0.36).clamp(120.0, 176.0).toDouble();
          return Row(children: [
            Expanded(child: log),
            SizedBox(width: bw, child: CombatActions(state: state, system: combat, typer: typer)),
          ]);
        });
      },
    );
  }

  Widget _log() {
    return TerminalFrame(
      title: 'ENCOUNTER LOG',
      child: ListenableBuilder(
        listenable: Listenable.merge([state, typer.busyNotifier]),
        builder: (_, __) {
          final ev = state.mode == GameMode.event ? state.event : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ConsoleBox(typer: typer, fontSize: 13),
                ),
              ),
              if (ev != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: _controls(ev),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Choices (or Continue) appear once the story has finished typing, in space
  /// that is always reserved, so the text never shifts.
  Widget _controls(dynamic ev) {
    final busy = typer.busy;
    final opts = events.optionsFor(ev);
    Widget btn(int i) => _Btn(
          opts[i].label,
          opts[i].enabled ? T.green : T.label,
          opts[i].enabled ? () => events.choose(i) : null,
        );
    Widget body;
    if (ev.finished as bool) {
      body = _Btn('[CONTINUE]', T.green, events.leave);
    } else if (opts.length <= 2) {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < opts.length; i++)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: btn(i)),
        ],
      );
    } else {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < opts.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(child: btn(i)),
                const SizedBox(width: 8),
                Expanded(child: i + 1 < opts.length ? btn(i + 1) : const SizedBox.shrink()),
              ]),
            ),
        ],
      );
    }
    return Opacity(
      opacity: busy ? 0 : 1,
      child: IgnorePointer(ignoring: busy, child: body),
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
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              Fx.play(Sfx.beep);
              onTap!();
            },
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            textAlign: TextAlign.center, style: T.mono(color, size: 12, bold: true)),
      ),
    );
  }
}
