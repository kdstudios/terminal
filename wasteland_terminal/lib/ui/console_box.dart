import 'package:flutter/material.dart';
import '../game/game_state.dart';
import '../game/typewriter.dart';
import 'blink_cursor.dart';
import 'theme.dart';

/// A typed text area on the main screen. Encounters (fights, events, hacks,
/// locks) write here instead of the narrative log, which stays quiet until
/// the encounter is over.
class ConsoleBox extends StatelessWidget {
  final TypewriterController typer;
  final int? lines; // fixed height in lines; null = fill the space it is given
  final double fontSize;
  const ConsoleBox({super.key, required this.typer, this.lines, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final list = ListenableBuilder(
      listenable: typer,
      builder: (_, __) {
        final revealed = typer.revealed;
        final cur = typer.current;
        final hasCur = cur != null;
        final total = revealed.length + (hasCur ? 1 : 0);
        // reverse: true keeps the newest line at the bottom.
        return ListView.builder(
          reverse: true,
          padding: EdgeInsets.zero,
          itemCount: total,
          itemBuilder: (_, i) {
            if (hasCur) {
              if (i == 0) return _line(cur!, typer.partial, cursor: true, solid: true);
              final l = revealed[revealed.length - i];
              return _line(l, l.text);
            }
            final l = revealed[revealed.length - 1 - i];
            return _line(l, l.text, cursor: i == 0);
          },
        );
      },
    );
    if (lines == null) return list;
    return SizedBox(height: lines! * fontSize * 1.4 + 4, child: list);
  }

  Widget _line(LogLine line, String shown, {bool cursor = false, bool solid = false}) {
    final quiet = line.kind == LogKind.narrative || line.kind == LogKind.thought;
    final style = T.mono(T.forKind(line.kind), size: fontSize, bold: !quiet).copyWith(
        fontStyle: line.kind == LogKind.thought ? FontStyle.italic : FontStyle.normal);
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Text.rich(
        TextSpan(text: shown, style: style, children: [
          if (cursor)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: BlinkCursor(solid: solid, size: fontSize),
            ),
        ]),
      ),
    );
  }
}
