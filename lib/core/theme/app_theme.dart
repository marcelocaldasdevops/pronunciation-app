import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF141A29);
  static const Color surfaceLight = Color(0xFF1F293D);
  static const Color primary = Color(0xFF38BDF8); // Cyan
  static const Color accent = Color(0xFF6366F1);  // Indigo
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Cores de avaliação fonética
  static const Color scoreGreen = Color(0xFF10B981);  // >= 80%
  static const Color scoreYellow = Color(0xFFF59E0B); // 60% - 79%
  static const Color scoreRed = Color(0xFFEF4444);    // < 60%

  static Color getScoreColor(double score) {
    if (score >= 80.0) return scoreGreen;
    if (score >= 60.0) return scoreYellow;
    return scoreRed;
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      fontFamily: GoogleFonts.outfit().fontFamily,
      textTheme: TextTheme(
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: surfaceLight.withValues(alpha: 0.6)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
    );
  }
}
