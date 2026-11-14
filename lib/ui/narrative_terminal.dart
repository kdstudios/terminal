import 'dart:math';
import 'package:flutter/material.dart';
import '../game/game_state.dart';
import '../game/typewriter.dart';
import 'blink_cursor.dart';
import 'enter_key.dart';
import 'terminal_frame.dart';
import 'theme.dart';

/// Terminal B: the adventure log, typed out line by line. When an encounter is
/// waiting, an ENTER key appears at its bottom right for the player to press.
class NarrativeTerminal extends StatelessWidget {
  final GameState state;
  final TypewriterController typer;
  const NarrativeTerminal({super.key, required this.state, required this.typer});

  @override
  Widget build(BuildContext context) {
    return TerminalFrame(
      title: 'NARRATIVE LOG',
      child: Stack(
        children: [
          Positioned.fill(
            child: ListenableBuilder(
              listenable: Listenable.merge([typer, state.hasPending]),
              builder: (_, __) {
                final lines = typer.revealed;
                final cur = typer.current;
                final hasCur = cur != null;
                final total = lines.length + (hasCur ? 1 : 0);
                // Leave room for the ENTER key so it never covers the text.
                final bottom = state.hasPending.value ? 70.0 : 10.0;
                // reverse: true pins the newest line to the bottom automatically.
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.fromLTRB(10, 10, 10, bottom),
                  itemCount: max(total, 1),
                  itemBuilder: (_, i) {
                    if (total == 0) {
                      return const Text.rich(TextSpan(children: [
                        WidgetSpan(child: BlinkCursor()),
                      ]));
                    }
                    if (hasCur) {
                      if (i == 0) return _line(cur!, typer.partial, cursor: true, solid: true);
                      final line = lines[lines.length - i];
                      return _line(line, line.text);
                    }
                    final line = lines[lines.length - 1 - i];
                    return _line(line, line.text, cursor: i == 0);
                  },
                );
              },
            ),
          ),
          Positioned(
            right: 12,
            bottom: 10,
            child: ValueListenableBuilder<bool>(
              valueListenable: state.hasPending,
              builder: (_, pending, __) => pending
                  ? EnterKey(onTap: state.acknowledgeEncounter)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(LogLine line, String shown, {bool cursor = false, bool solid = false}) {
    final quiet = line.kind == LogKind.narrative || line.kind == LogKind.thought;
    final style = T.mono(T.forKind(line.kind), size: 14, bold: !quiet).copyWith(
        fontStyle: line.kind == LogKind.thought ? FontStyle.italic : FontStyle.normal);
    return Padding(
      padding: EdgeInsets.only(top: quiet ? 0 : 8, bottom: 2),
      child: Text.rich(
        TextSpan(text: shown, style: style, children: [
          if (cursor)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: BlinkCursor(solid: solid),
            ),
        ]),
      ),
    );
  }
}
