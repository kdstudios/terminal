import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'game_state.dart';
import 'settings.dart';
import 'sfx.dart';

class _Loop {
  final String file;
  AudioPlayer? player;
  bool playing = false, busy = false;
  DateTime lastTry = DateTime(2000);
  _Loop(this.file);
}

/// Plays sound effects, ambient wind (while exploring) and the music loop.
/// Every call is wrapped so a missing audio backend can never break the game.
/// Browsers refuse sound until the first tap, so loops are retried on taps.
class AudioSystem {
  static const _files = <Sfx, String>{
    Sfx.tick: 'audio/tick.wav',
    Sfx.beep: 'audio/beep.wav',
    Sfx.confirm: 'audio/confirm.wav',
    Sfx.deny: 'audio/deny.wav',
    Sfx.click: 'audio/click.wav',
    Sfx.snap: 'audio/snap.wav',
    Sfx.hit: 'audio/hit.wav',
    Sfx.swing: 'audio/swing.wav',
    Sfx.hurt: 'audio/hurt.wav',
    Sfx.loot: 'audio/loot.wav',
    Sfx.levelup: 'audio/levelup.wav',
    Sfx.alarm: 'audio/alarm.wav',
    Sfx.startup: 'audio/startup.wav',
    Sfx.growl: 'audio/growl.wav',
  };

  final Settings settings;
  final GameState state;
  final List<AudioPlayer> _pool = [];
  AudioPlayer? _tickPlayer;
  final _Loop _music = _Loop('audio/music.wav');
  final _Loop _wind = _Loop('audio/wind.wav');
  int _next = 0;
  DateTime _lastTick = DateTime(2000);
  bool _suspended = false;

  AudioSystem(this.settings, this.state);

  double get _musicVol => settings.musicVolume * 0.6;
  double get _windVol => settings.sfxVolume * 0.5;

  Future<void> init() async {
    try {
      for (var i = 0; i < 6; i++) {
        _pool.add(AudioPlayer());
      }
      _tickPlayer = AudioPlayer();
    } catch (e) {
      debugPrint('Audio unavailable: $e');
    }
    settings.addListener(_onSettings);
    state.addListener(_ensureLoops);
  }

  void _onSettings() {
    _music.player?.setVolume(_musicVol).catchError((_) {});
    _wind.player?.setVolume(_windVol).catchError((_) {});
    _ensureLoops();
  }

  void _ensureLoops() {
    if (_suspended) return;
    _sync(_music, settings.musicOn, _musicVol);
    _sync(_wind, settings.sfxOn && state.mode == GameMode.exploring, _windVol);
  }

  Future<void> _sync(_Loop l, bool want, double volume) async {
    if (want == l.playing || l.busy) return;
    if (want && DateTime.now().difference(l.lastTry).inMilliseconds < 1500) return;
    l.busy = true;
    l.lastTry = DateTime.now();
    try {
      final p = l.player ??= AudioPlayer();
      if (want) {
        await p.setReleaseMode(ReleaseMode.loop);
        await p.play(AssetSource(l.file), volume: volume);
      } else {
        await p.stop();
      }
      l.playing = want;
    } catch (_) {
      // e.g. the browser blocks sound until the first tap; retried on the next one
    } finally {
      l.busy = false;
    }
  }

  void play(Sfx s, {double gain = 1.0}) {
    try {
      _ensureLoops(); // a tap is also the chance to start blocked music
      if (!settings.sfxOn) return;
      if (s == Sfx.tick) {
        final now = DateTime.now();
        if (now.difference(_lastTick).inMilliseconds < 55) return;
        _lastTick = now;
        _tickPlayer
            ?.play(AssetSource(_files[s]!), volume: settings.sfxVolume * 0.35)
            .catchError((_) {});
        return;
      }
      final p = _pool[_next++ % _pool.length];
      p.play(AssetSource(_files[s]!), volume: settings.sfxVolume * gain).catchError((_) {});
    } catch (_) {}
  }

  /// App went to the background: silence everything.
  void suspend() {
    _suspended = true;
    for (final l in [_music, _wind]) {
      l.player?.stop().catchError((_) {});
      l.playing = false;
    }
  }

  void resume() {
    _suspended = false;
    _ensureLoops();
  }

  void dispose() {
    settings.removeListener(_onSettings);
    state.removeListener(_ensureLoops);
    for (final p in _pool) {
      p.dispose();
    }
    _tickPlayer?.dispose();
    _music.player?.dispose();
    _wind.player?.dispose();
  }
}
