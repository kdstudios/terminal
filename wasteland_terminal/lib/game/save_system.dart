import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';

/// Persists the whole GameState (including a minigame in progress) as JSON.
/// Uses shared_preferences, which works on iOS, Android and web.
///
/// Saves every few seconds (skipping writes when nothing changed) and when the
/// app is backgrounded. A corrupt or outdated save is ignored, never a crash.
class SaveSystem {
  static const _key = 'wasteland_terminal_save';
  static const _version = 1;

  final GameState state;
  Timer? _timer;
  String? _last;
  DateTime? lastSaved;

  SaveSystem(this.state);

  /// Returns true if a save was found and restored.
  Future<bool> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return false;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['version'] != _version) return false;
      state.loadJson(data['state'] as Map<String, dynamic>);
      _last = raw;
      state.addLog('> SAVE RESTORED', LogKind.system);
      return true;
    } catch (e) {
      debugPrint('Save load failed, starting fresh: $e');
      return false;
    }
  }

  Future<void> save({bool force = false}) async {
    try {
      final raw = jsonEncode({'version': _version, 'state': state.toJson()});
      if (!force && raw == _last) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, raw);
      _last = raw;
      lastSaved = DateTime.now();
    } catch (e) {
      debugPrint('Save failed: $e');
    }
  }

  void startAutosave() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => save());
  }

  Future<void> wipe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _last = null;
    lastSaved = null;
  }

  void dispose() => _timer?.cancel();
}
