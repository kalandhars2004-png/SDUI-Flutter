import 'package:flutter/material.dart';

/// Theme layer for SDUI - host app can inject its own design system.
/// Same JSON renders differently depending on theme.
class SduiTheme {
  final Color primaryColor;
  final Color surfaceColor;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final double spacingUnit;
  final double radius;
  final TextTheme textTheme;
  final ButtonStyle? elevatedButtonStyle;
  final ButtonStyle? outlinedButtonStyle;

  const SduiTheme({
    this.primaryColor = const Color(0xFF0F172A),
    this.surfaceColor = const Color(0xFFF8FAFC),
    this.cardColor = Colors.white,
    this.textColor = const Color(0xFF0F172A),
    this.secondaryTextColor = const Color(0xFF64748B),
    this.spacingUnit = 8,
    this.radius = 12,
    this.textTheme = const TextTheme(),
    this.elevatedButtonStyle,
    this.outlinedButtonStyle,
  });

  static const light = SduiTheme();

  static const dark = SduiTheme(
    primaryColor: Color(0xFFF8FAFC),
    surfaceColor: Color(0xFF0F172A),
    cardColor: Color(0xFF1E293B),
    textColor: Colors.white,
    secondaryTextColor: Color(0xFF94A3B8),
  );

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceColor,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      textTheme: textTheme,
    );
  }
}
