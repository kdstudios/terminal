import 'package:flutter/services.dart';
import 'audio_system.dart';
import 'settings.dart';
import 'sfx.dart';

export 'sfx.dart';

/// Global hooks for sound and haptics. Both respect the player's settings.
class Fx {
  static Settings settings = Settings();
  static AudioSystem? audio;

  /// True while the combat stage is on screen: it plays the fight's sounds in
  /// sync with its animations, so the typewriter must not duplicate them.
  static bool stageSounds = false;

  static void play(Sfx s, {double gain = 1.0}) => audio?.play(s, gain: gain);

  static void light() {
    if (settings.haptics) HapticFeedback.lightImpact();
  }

  static void medium() {
    if (settings.haptics) HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (settings.haptics) HapticFeedback.heavyImpact();
  }
}
