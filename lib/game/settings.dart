import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Player preferences. Saved separately from the game, so a New Game never
/// resets them.
class Settings extends ChangeNotifier {
  static const _key = 'wasteland_terminal_settings';
  static const themeCount = 5;

  bool sfxOn = true;
  bool musicOn = true;
  bool haptics = true;
  bool reducedMotion = false;
  double sfxVolume = 0.8;
  double musicVolume = 0.5;
  int theme = 0; // index into termThemes
  int textSize = 1; // 0 small, 1 normal, 2 large
  double colorBleed = 0.0; // 0 = pure green phosphor .. 1 = the sprites' own colours

  double get textScale => const [0.9, 1.0, 1.2][textSize];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      sfxOn = (j['sfxOn'] as bool?) ?? sfxOn;
      musicOn = (j['musicOn'] as bool?) ?? musicOn;
      haptics = (j['haptics'] as bool?) ?? haptics;
      reducedMotion = (j['reducedMotion'] as bool?) ?? reducedMotion;
      sfxVolume = ((j['sfxVolume'] as num?)?.toDouble() ?? sfxVolume).clamp(0.0, 1.0).toDouble();
      musicVolume = ((j['musicVolume'] as num?)?.toDouble() ?? musicVolume).clamp(0.0, 1.0).toDouble();
      theme = min(themeCount - 1, max(0, (j['theme'] as num?)?.toInt() ?? 0));
      textSize = min(2, max(0, (j['textSize'] as num?)?.toInt() ?? 1));
      colorBleed = ((j['colorBleed'] as num?)?.toDouble() ?? colorBleed).clamp(0.0, 1.0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('Settings load failed: $e');
    }
  }

  /// Change something, tell listeners, and save.
  void update(void Function() change) {
    change();
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode({
          'sfxOn': sfxOn,
          'musicOn': musicOn,
          'haptics': haptics,
          'reducedMotion': reducedMotion,
          'sfxVolume': sfxVolume,
          'musicVolume': musicVolume,
          'theme': theme,
          'textSize': textSize,
          'colorBleed': colorBleed,
        }),
      );
    } catch (e) {
      debugPrint('Settings save failed: $e');
    }
  }
}
