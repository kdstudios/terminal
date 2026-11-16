import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/audio_system.dart';
import 'game/combat_system.dart';
import 'game/event_system.dart';
import 'game/exploration_system.dart';
import 'game/fx.dart';
import 'game/game_state.dart';
import 'game/hacking_system.dart';
import 'game/home_system.dart';
import 'game/lockpicking_system.dart';
import 'game/save_system.dart';
import 'game/typewriter.dart';
import 'ui/dual_terminal_screen.dart';
import 'ui/atlas.dart';
import 'ui/metal_frame.dart';
import 'ui/sprites.dart';
import 'ui/theme.dart';
import 'ui/title_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Allow both portrait and landscape.
  SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  runApp(const WastelandApp());
}

class WastelandApp extends StatefulWidget {
  const WastelandApp({super.key});
  @override
  State<WastelandApp> createState() => _WastelandAppState();
}

class _WastelandAppState extends State<WastelandApp> with WidgetsBindingObserver {
  // Owned above the layout so rotation never resets game state.
  final GameState _state = GameState();
  late final HackingSystem _hacking = HackingSystem(_state);
  late final LockpickingSystem _lockpicking = LockpickingSystem(_state);
  late final CombatSystem _combat = CombatSystem(_state);
  late final HomeSystem _home = HomeSystem(_state);
  late final EventSystem _events = EventSystem(_state, _hacking, _lockpicking, _combat);
  late final TypewriterController _typer = TypewriterController(_state);
  late final TypewriterController _consoleTyper =
      TypewriterController(_state, console: true);
  late final ExplorationSystem _exploration =
      ExplorationSystem(_state, _hacking, _lockpicking, _combat, _events, _typer);
  late final SaveSystem _save = SaveSystem(_state);
  late final AudioSystem _audio = AudioSystem(Fx.settings, _state);
  bool _assetsReady = false; // art + settings loaded: the title screen can show
  bool _started = false; // PLAY pressed
  bool _ready = false; // save loaded: the game can show

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _boot();
  }

  /// Loads settings and art so the title screen can appear.
  Future<void> _boot() async {
    await Fx.settings.load();
    T.setTheme(Fx.settings.theme);
    Fx.audio = _audio;
    await Sprites.loadAll();
    await FrameSkin.load(); // metal frame texture
    await Atlas.load(); // full-colour sprite sheets
    if (mounted) setState(() => _assetsReady = true);
  }

  /// PLAY: start audio (browsers need a tap first), then load the latest save,
  /// or begin a new game when there is none.
  Future<void> _start() async {
    if (_started) return;
    setState(() => _started = true);
    await _audio.init();
    final loaded = await _save.load();
    _typer.clear(); // creates the typewriters and hooks them into the log
    _consoleTyper.clear();
    if (loaded) {
      _typer.syncAll(); // restored log appears instantly
      _consoleTyper.syncAll();
    } else {
      _state.arriveHome(intro: true); // a new game's intro types out
    }
    _lockpicking.resume(); // restarts the lock physics if a lock was in progress
    _exploration.start();
    _save.startAutosave();
    Fx.play(Sfx.startup);
    if (mounted) setState(() => _ready = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) {
      _audio.resume();
    } else {
      _audio.suspend(); // silence in the background
      if (_ready) _save.save(); // save when the app leaves the foreground (never on the title screen)
    }
  }

  Future<void> _newGame() async {
    _lockpicking.dispose(); // stops any running lock timer
    await _save.wipe();
    _state.reset();
    _typer.clear();
    _consoleTyper.clear();
    _state.arriveHome(intro: true);
    await _save.save(force: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _exploration.dispose();
    _lockpicking.dispose();
    _save.dispose();
    _typer.dispose();
    _consoleTyper.dispose();
    _audio.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds when any setting changes (theme, text size, ...).
    return ListenableBuilder(
      listenable: Fx.settings,
      builder: (context, _) {
        final s = Fx.settings;
        T.setTheme(s.theme);
        return MaterialApp(
          title: 'Wasteland Terminal',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: T.bg),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(s.textScale)),
            child: child!,
          ),
          // The key makes a theme change rebuild every screen with the new colours.
          home: KeyedSubtree(
            key: ValueKey('theme${s.theme}'),
            child: _ready
                ? DualTerminalScreen(
                    state: _state,
                    hacking: _hacking,
                    lockpicking: _lockpicking,
                    combat: _combat,
                    home: _home,
                    events: _events,
                    typer: _typer,
                    consoleTyper: _consoleTyper,
                    save: _save,
                    onNewGame: _newGame,
                  )
                : _assetsReady
                    ? TitleScreen(onPlay: _start, starting: _started)
                    : Scaffold(
                        body: Center(child: Text('BOOTING...', style: T.mono(T.green))),
                      ),
          ),
        );
      },
    );
  }
}
