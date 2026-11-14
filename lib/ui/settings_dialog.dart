import 'package:flutter/material.dart';
import '../game/fx.dart';
import '../game/game_state.dart';
import '../game/settings.dart';
import 'theme.dart';

Future<void> showSettings(
  BuildContext context, {
  required Settings settings,
  required GameState state,
  required Future<void> Function() onNewGame,
}) {
  return showDialog(
    context: context,
    builder: (_) =>
        _SettingsDialog(settings: settings, state: state, onNewGame: onNewGame),
  );
}

class _SettingsDialog extends StatelessWidget {
  final Settings settings;
  final GameState state;
  final Future<void> Function() onNewGame;
  const _SettingsDialog({
    required this.settings,
    required this.state,
    required this.onNewGame,
  });

  static const _speeds = ['SLOW', 'NORMAL', 'FAST', 'INSTANT'];
  static const _sizes = ['SMALL', 'NORMAL', 'LARGE'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([settings, state]),
      builder: (context, _) => Dialog(
        backgroundColor: T.panel,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: T.dim, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('SETTINGS', style: T.mono(T.green, size: 16, bold: true)),
                const SizedBox(height: 12),
                _section('TEXT & DISPLAY'),
                _choice('TEXT SPEED', _speeds[state.textSpeed], state.cycleTextSpeed),
                _choice('TEXT SIZE', _sizes[settings.textSize],
                    () => settings.update(() => settings.textSize = (settings.textSize + 1) % 3)),
                _choice('TERMINAL THEME', termThemes[settings.theme].name,
                    () => settings.update(() =>
                        settings.theme = (settings.theme + 1) % Settings.themeCount)),
                _toggle('REDUCED MOTION', settings.reducedMotion,
                    () => settings.update(() => settings.reducedMotion = !settings.reducedMotion)),
                _toggle('HAPTICS', settings.haptics,
                    () => settings.update(() => settings.haptics = !settings.haptics)),
                const SizedBox(height: 10),
                _section('AUDIO'),
                _toggle('SOUND EFFECTS', settings.sfxOn,
                    () => settings.update(() => settings.sfxOn = !settings.sfxOn)),
                _slider('SOUND VOLUME', settings.sfxVolume,
                    (v) => settings.update(() => settings.sfxVolume = v)),
                _toggle('MUSIC', settings.musicOn,
                    () => settings.update(() => settings.musicOn = !settings.musicOn)),
                _slider('MUSIC VOLUME', settings.musicVolume,
                    (v) => settings.update(() => settings.musicVolume = v)),
                const SizedBox(height: 12),
                _Btn('[NEW GAME]', () => _confirmNewGame(context), color: T.amber),
                const SizedBox(height: 8),
                _Btn('[CLOSE]', () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmNewGame(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: T.panel,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: T.red, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('ERASE ALL PROGRESS?', style: T.mono(T.red, size: 15, bold: true)),
              const SizedBox(height: 12),
              _Btn('[YES - ERASE]', () async {
                Navigator.pop(ctx); // this confirmation
                Navigator.pop(context); // the settings dialog
                await onNewGame();
              }, color: T.red),
              const SizedBox(height: 8),
              _Btn('[CANCEL]', () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: T.mono(T.dim, size: 12)),
      );

  Widget _choice(String label, String value, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Expanded(child: Text(label, style: T.mono(T.green, size: 13))),
          _Btn('[$value]', onTap, minWidth: 150),
        ]),
      );

  Widget _toggle(String label, bool on, VoidCallback onTap) =>
      _choice(label, on ? 'ON' : 'OFF', onTap);

  Widget _slider(String label, double v, ValueChanged<double> onChanged) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          SizedBox(width: 120, child: Text(label, style: T.mono(T.dim, size: 12))),
          Expanded(
            child: Slider(
              value: v,
              onChanged: onChanged,
              activeColor: T.green,
              inactiveColor: T.dim,
            ),
          ),
        ]),
      );
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double minWidth;
  final Color? color;
  const _Btn(this.label, this.onTap, {this.minWidth = 0, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Fx.play(Sfx.beep);
        onTap();
      },
      child: Container(
        constraints: BoxConstraints(minHeight: 40, minWidth: minWidth),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color ?? T.green),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: T.mono(color ?? T.green, size: 12, bold: true)),
      ),
    );
  }
}
