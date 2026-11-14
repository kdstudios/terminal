import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/combat_system.dart';
import '../game/event_system.dart';
import '../game/game_state.dart';
import '../game/hacking_system.dart';
import '../game/home_system.dart';
import '../game/lockpicking_system.dart';
import '../game/save_system.dart';
import '../game/typewriter.dart';
import 'encounter_log.dart';
import 'exploration_terminal.dart';
import 'flicker_switch.dart';
import 'menu_dialog.dart';
import 'narrative_terminal.dart';
import 'status_bar.dart';

/// Three framed panels: the main screen, the log, and the status bar. Portrait
/// stacks them (ConceptPortrait); landscape puts the main screen on the left and
/// the log + status bar on the right (ConceptLandscape). The log side is the narrative log, and flickers over to
/// the encounter log during hacks, fights and choice encounters.
class DualTerminalScreen extends StatelessWidget {
  final GameState state;
  final HackingSystem hacking;
  final LockpickingSystem lockpicking;
  final CombatSystem combat;
  final HomeSystem home;
  final EventSystem events;
  final TypewriterController typer; // narrative log
  final TypewriterController consoleTyper; // encounter text
  final SaveSystem save;
  final Future<void> Function() onNewGame;
  const DualTerminalScreen({
    super.key,
    required this.state,
    required this.hacking,
    required this.lockpicking,
    required this.combat,
    required this.home,
    required this.events,
    required this.typer,
    required this.consoleTyper,
    required this.save,
    required this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    // On a keyboard, Enter acknowledges a waiting encounter.
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
            state.pending != null) {
          state.acknowledgeEncounter();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(builder: (context, box) {
            final landscape = box.maxWidth > box.maxHeight;
            final main = ExplorationTerminal(
              state: state,
              hacking: hacking,
              lockpicking: lockpicking,
              combat: combat,
              home: home,
              events: events,
              consoleTyper: consoleTyper,
            );
            final logPanel = ValueListenableBuilder<bool>(
              valueListenable: state.encounterLog,
              builder: (_, encounter, __) => FlickerSwitch(
                child: encounter
                    ? EncounterLog(
                        key: const ValueKey('encounter'),
                        state: state,
                        events: events,
                        typer: consoleTyper,
                        combat: combat,
                      )
                    : NarrativeTerminal(
                        key: const ValueKey('narrative'),
                        state: state,
                        typer: typer,
                      ),
              ),
            );
            final status = StatusBar(
              state: state,
              onMenu: () => showSystemMenu(context,
                  state: state, save: save, home: home, onNewGame: onNewGame),
            );
            // Concept proportions: portrait = main 49% / log 40% / status ~9.5%;
            // landscape = main on the left, log + status stacked on the right.
            final statusH = (box.maxHeight * (landscape ? 0.17 : 0.095)).clamp(58.0, 88.0).toDouble();
            if (landscape) {
              return Row(children: [
                Expanded(child: main),
                Expanded(
                  child: Column(children: [
                    Expanded(child: logPanel),
                    SizedBox(height: statusH, child: status),
                  ]),
                ),
              ]);
            }
            return Column(children: [
              Expanded(flex: 49, child: main),
              Expanded(flex: 40, child: logPanel),
              SizedBox(height: statusH, child: status),
            ]);
          }),
        ),
      ),
    );
  }
}
