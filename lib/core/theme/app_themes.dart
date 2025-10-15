import 'package:flutter/material.dart';

/// Enum representing available country themes
enum AppTheme { india, bangladesh, nepal, bhutan, singapore, sriLanka }

/// Theme configuration for the Shopping Assistant app
class AppThemes {
  /// Map of country themes to their corresponding ThemeData
  static final Map<AppTheme, ThemeData> themes = {
    AppTheme.india: _buildTheme(
      primary: const Color(0xFFD97D55),
      background: const Color(0xFFF4E9D7),
      accent: const Color(0xFFB8C4A9),
      contrast: const Color(0xFF6FA4AF),
    ),
    AppTheme.bangladesh: _buildTheme(
      primary: const Color(0xFFDF2E38),
      background: const Color(0xFFDDF7E3),
      accent: const Color(0xFFC7E8CA),
      contrast: const Color(0xFF5D9C59),
    ),
    AppTheme.nepal: _buildTheme(
      primary: const Color(0xFFEB455F),
      background: const Color(0xFFFCFFE7),
      accent: const Color(0xFFBAD7E9),
      contrast: const Color(0xFF2B3467),
    ),
    AppTheme.bhutan: _buildTheme(
      primary: const Color(0xFFF54D42),
      background: const Color(0xFFFF8356),
      accent: const Color(0xFFFFCD00),
      contrast: const Color(0xFFF5F5F5),
    ),
    AppTheme.singapore: _buildTheme(
      primary: const Color(0xFFE70000),
      background: const Color(0xFFFFFDEF),
      accent: const Color(0xFFF1F1F1),
      contrast: const Color(0xFFC50000),
    ),
    AppTheme.sriLanka: _buildTheme(
      primary: const Color(0xFF990000),
      background: const Color(0xFFFFEE63),
      accent: const Color(0xFFD4D925),
      contrast: const Color(0xFFFF5B00),
    ),
  };

  /// Build a ThemeData object with the given colors
  static ThemeData _buildTheme({
    required Color primary,
    required Color background,
    required Color accent,
    required Color contrast,
  }) {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: background,
        tertiary: contrast,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: contrast,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  /// Get theme name for display
  static String getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.india:
        return 'India';
      case AppTheme.bangladesh:
        return 'Bangladesh';
      case AppTheme.nepal:
        return 'Nepal';
      case AppTheme.bhutan:
        return 'Bhutan';
      case AppTheme.singapore:
        return 'Singapore';
      case AppTheme.sriLanka:
        return 'Sri Lanka';
    }
  }
}
