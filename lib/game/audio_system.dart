import 'dart:async';

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
///
/// Each effect has its own preloaded AudioPool. This avoids repeatedly
/// replacing the source on a small set of shared players, which can cut off
/// effects and cause delays in mobile browsers.
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
  final Map<Sfx, AudioPool> _sfxPools = {};
  final _Loop _music = _Loop('audio/music.wav');
  final _Loop _wind = _Loop('audio/wind.wav');
  DateTime _lastTick = DateTime(2000);
  bool _suspended = false;

  AudioSystem(this.settings, this.state);

  double get _musicVol => settings.musicVolume * 0.6;
  double get _windVol => settings.sfxVolume * 0.5;

  Future<void> init() async {
    // Prepare effects in advance so playback does not need to swap the
    // source URL on a shared player every time a different sound is requested.
    for (final entry in _files.entries) {
      try {
        _sfxPools[entry.key] = await AudioPool.createFromAsset(
          path: entry.value,
          minPlayers: 1,
          maxPlayers: 2,
        );
      } catch (e) {
        debugPrint('Could not prepare sound ${entry.key}: $e');
      }
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
    if (want && DateTime.now().difference(l.lastTry).inMilliseconds < 1500) {
      return;
    }
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
      // Browsers may block playback until the user interacts with the game.
    } finally {
      l.busy = false;
    }
  }

  Future<void> _startEffect(AudioPool pool, double volume) async {
    try {
      await pool.start(volume: volume);
    } catch (e) {
      debugPrint('Sound effect playback failed: $e');
    }
  }

  void play(Sfx s, {double gain = 1.0}) {
    try {
      if (_suspended) return;
      _ensureLoops();
      if (!settings.sfxOn) return;

      if (s == Sfx.tick) {
        final now = DateTime.now();
        if (now.difference(_lastTick).inMilliseconds < 55) return;
        _lastTick = now;
      }

      final pool = _sfxPools[s];
      if (pool == null) return;
      final volume = settings.sfxVolume * (s == Sfx.tick ? 0.35 : gain);
      unawaited(_startEffect(pool, volume));
    } catch (_) {
      // Audio must never prevent the game itself from running.
    }
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
    for (final pool in _sfxPools.values) {
      unawaited(pool.dispose());
    }
    _music.player?.dispose();
    _wind.player?.dispose();
  }
}
