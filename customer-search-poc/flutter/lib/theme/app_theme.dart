import 'package:flutter/material.dart';

class AppTheme {
  // Colors matching React frontend
  static const Color primaryBlue = Color(0xFF3498DB);
  static const Color darkBlue = Color(0xFF2980B9);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color lightGray = Color(0xFF7F8C8D);
  static const Color veryLightGray = Color(0xFFECF0F1);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorRed = Color(0xFFE74C3C);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: darkGray,
        elevation: 2,
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkGray,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
      // cardTheme will be applied via Card widgets directly
    );
  }
}
