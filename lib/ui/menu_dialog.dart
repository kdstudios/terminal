import 'package:flutter/material.dart';
import '../game/fx.dart';
import '../game/game_state.dart';
import '../game/home_system.dart';
import '../game/quests.dart';
import '../game/save_system.dart';
import 'settings_dialog.dart';
import 'theme.dart';

Future<void> showSystemMenu(
  BuildContext context, {
  required GameState state,
  required SaveSystem save,
  required HomeSystem home,
  required Future<void> Function() onNewGame,
}) {
  return showDialog(
    context: context,
    builder: (_) =>
        _MenuDialog(state: state, save: save, home: home, onNewGame: onNewGame),
  );
}

class _MenuDialog extends StatelessWidget {
  final GameState state;
  final SaveSystem save;
  final HomeSystem home;
  final Future<void> Function() onNewGame;
  const _MenuDialog({
    required this.state,
    required this.save,
    required this.home,
    required this.onNewGame,
  });

  String _quest(QuestProgress q) {
    final d = questById(q.id);
    final status = q.ready ? 'READY' : '${q.progress}/${d.target}';
    return '${d.title}  $status';
  }

  String _time(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final t = save.lastSaved;
    return Dialog(
      backgroundColor: T.panel,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: T.dim, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('SYSTEM MENU', style: T.mono(T.green, size: 16, bold: true)),
              const SizedBox(height: 4),
              Text(
                t == null ? 'AUTOSAVE: ON' : 'LAST SAVE: ${_time(t)}',
                style: T.mono(T.dim, size: 12),
              ),
              if (state.quests.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('ACTIVE QUESTS', style: T.mono(T.green, size: 12, bold: true)),
                for (final q in state.quests)
                  Text(_quest(q), style: T.mono(q.ready ? T.loot : T.dim, size: 11)),
              ],
              const SizedBox(height: 14),
              _MenuBtn('[SAVE NOW]', T.green, () async {
                await save.save(force: true);
                state.addLog('> GAME SAVED', LogKind.system);
                if (context.mounted) Navigator.pop(context);
              }),
              if (state.mode == GameMode.exploring) ...[
                const SizedBox(height: 8),
                _MenuBtn(
                  state.walkingPaused ? '[START WALKING]' : '[STOP WALKING]',
                  state.walkingPaused ? T.loot : T.amber,
                  () {
                    state.toggleWalking();
                    Navigator.pop(context);
                  },
                ),
              ],
              const SizedBox(height: 8),
              _MenuBtn(
                '[SETTINGS]',
                T.green,
                () => showSettings(
                  context,
                  settings: Fx.settings,
                  state: state,
                  onNewGame: () async {
                    await onNewGame();
                    if (context.mounted) Navigator.pop(context); // close the menu too
                  },
                ),
              ),
              if (state.mode == GameMode.exploring) ...[
                const SizedBox(height: 8),
                _MenuBtn('[RETURN HOME]', T.green, () {
                  home.returnHome();
                  Navigator.pop(context);
                }),
              ],
              const SizedBox(height: 8),
              _MenuBtn('[EXIT MENU]', T.green, () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuBtn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Fx.play(Sfx.beep);
        onTap();
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: T.mono(color, bold: true)),
      ),
    );
  }
}
