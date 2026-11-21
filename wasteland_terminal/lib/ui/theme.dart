import 'dart:math';
import 'package:flutter/material.dart';
import '../game/game_state.dart';

class TermTheme {
  final String name;
  final Color bg, panel, primary, dim, warn, danger, loot, thought;
  final bool glow;
  const TermTheme(
    this.name, {
    required this.bg,
    required this.panel,
    required this.primary,
    required this.dim,
    required this.warn,
    required this.danger,
    required this.loot,
    required this.thought,
    this.glow = true,
  });
}

const termThemes = <TermTheme>[
  TermTheme('GREEN PHOSPHOR',
      bg: Color(0xFF030704), panel: Color(0xFF07110A), primary: Color(0xFF39FF6A),
      dim: Color(0xFF2BB052), warn: Color(0xFFFFB000), danger: Color(0xFFFF3B30),
      loot: Color(0xFFC8FF3A), thought: Color(0xFF8FD9B6)),
  TermTheme('AMBER',
      bg: Color(0xFF0A0600), panel: Color(0xFF130C02), primary: Color(0xFFFFB000),
      dim: Color(0xFF9A6A10), warn: Color(0xFFFF7A1A), danger: Color(0xFFFF4B3A),
      loot: Color(0xFFFFE066), thought: Color(0xFFD9A85B)),
  TermTheme('ICE BLUE',
      bg: Color(0xFF02070A), panel: Color(0xFF06121A), primary: Color(0xFF4FD8FF),
      dim: Color(0xFF1D6F8C), warn: Color(0xFFFFC857), danger: Color(0xFFFF5A5A),
      loot: Color(0xFFA8F0FF), thought: Color(0xFF8EC9DE)),
  TermTheme('MONOCHROME',
      bg: Color(0xFF050505), panel: Color(0xFF0E0E0E), primary: Color(0xFFE8E8E8),
      dim: Color(0xFF8A8A8A), warn: Color(0xFFFFD27A), danger: Color(0xFFFF6B6B),
      loot: Color(0xFFFFFFFF), thought: Color(0xFFB8B8B8)),
  TermTheme('HIGH CONTRAST',
      bg: Color(0xFF000000), panel: Color(0xFF000000), primary: Color(0xFFFFFFFF),
      dim: Color(0xFFC8C8C8), warn: Color(0xFFFFFF00), danger: Color(0xFFFF5050),
      loot: Color(0xFF00FF88), thought: Color(0xFFE0E0E0), glow: false),
];

/// The colours the whole game draws with. They read from the current theme,
/// so changing the theme changes everything (the app rebuilds on change).
class T {
  static TermTheme current = termThemes[0];

  static void setTheme(int i) {
    current = termThemes[min(max(i, 0), termThemes.length - 1)];
  }

  static Color get bg => current.bg;
  static Color get panel => current.panel;
  static Color get green => current.primary;
  static Color get dim => current.dim;
  static Color get amber => current.warn;
  static Color get red => current.danger;
  static Color get loot => current.loot;
  static Color get thought => current.thought;

  /// Secondary text (labels, hints): clearly a step below the main colour but
  /// bright enough to read as part of the same screen. Use this for TEXT; T.dim is
  /// for borders and rules.
  static Color get label => Color.lerp(dim, green, 0.55)!;

  /// Drop a condensed techno TTF into assets/fonts, declare it in pubspec.yaml and
  /// set this to its family name to match the concept's lettering.
  static const String fontFamily = 'monospace';

  static TextStyle mono(Color c, {double size = 14, bool bold = false}) => TextStyle(
        color: c,
        fontSize: size,
        height: 1.35,
        fontFamily: fontFamily,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        shadows: current.glow ? [Shadow(color: c.withValues(alpha: 0.6), blurRadius: 6)] : null,
      );

  static Color forKind(LogKind k) => switch (k) {
        LogKind.system => green,
        LogKind.narrative => dim,
        LogKind.loot => loot,
        LogKind.warning => amber,
        LogKind.danger => red,
        LogKind.thought => thought,
      };
}
