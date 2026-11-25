import 'package:flutter/material.dart';

class JirisColors {
  static const Color primary = Color(0xFF39204F);
  static const Color secondary = Color(0xFF806493);

  static const Color lavender = Color(0xFFF4EFF8);
  static const Color background = Color(0xFFFFFEFF);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF302638);
  static const Color textSecondary = Color(0xFF817987);

  static const Color border = Color(0xFFE9E3ED);
  static const Color success = Color(0xFF64866C);
  static const Color error = Color(0xFFB84C58);
}

class JirisTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: JirisColors.background,

      colorScheme: const ColorScheme.light(
        primary: JirisColors.primary,
        secondary: JirisColors.secondary,
        surface: JirisColors.surface,
        error: JirisColors.error,
      ),

      fontFamily: 'Inter',

      appBarTheme: const AppBarTheme(
        backgroundColor: JirisColors.background,
        foregroundColor: JirisColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: JirisColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w600,
          color: JirisColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: JirisColors.textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: JirisColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 13, color: JirisColors.textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JirisColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JirisColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JirisColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JirisColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
