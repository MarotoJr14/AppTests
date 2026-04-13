import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color navy        = Color(0xFF0A1628);
  static const Color navyLight   = Color(0xFF132240);
  static const Color ocean       = Color(0xFF1A4B8C);
  static const Color oceanLight  = Color(0xFF2E6BC4);
  static const Color gold        = Color(0xFFE8B84B);
  static const Color goldLight   = Color(0xFFF5D07A);
  static const Color surface     = Color(0xFF0F1F38);
  static const Color surfaceCard = Color(0xFF162942);
  static const Color onSurface   = Color(0xFFE8EEF7);
  static const Color onSurfaceSub= Color(0xFF8AA3C8);
  static const Color correct     = Color(0xFF2ECC71);
  static const Color incorrect   = Color(0xFFE74C3C);
  static const Color selected    = Color(0xFFE8B84B);

  // ── Text styles ──────────────────────────────────────────────────────────
  static TextStyle get displayFont => GoogleFonts.playfairDisplay();
  static TextStyle get bodyFont    => GoogleFonts.inter();

  // ── Theme ────────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: navy,
    colorScheme: ColorScheme.dark(
      primary: gold,
      secondary: oceanLight,
      surface: surface,
      onSurface: onSurface,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        color: onSurface, fontSize: 32, fontWeight: FontWeight.w700,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        color: onSurface, fontSize: 24, fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.inter(
        color: onSurface, fontSize: 18, fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.inter(
        color: onSurface, fontSize: 16, fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.inter(color: onSurface, fontSize: 15),
      bodyMedium: GoogleFonts.inter(color: onSurfaceSub, fontSize: 13),
      labelLarge: GoogleFonts.inter(
        color: navy, fontSize: 14, fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: navyLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        color: onSurface, fontSize: 20, fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: onSurface),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: navy,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ocean),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ocean.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: gold, width: 2),
      ),
      labelStyle: GoogleFonts.inter(color: onSurfaceSub),
      hintStyle: GoogleFonts.inter(color: onSurfaceSub),
    ),
    cardTheme: CardThemeData(
      color: surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ocean.withOpacity(0.3)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: ocean.withOpacity(0.3),
      thickness: 1,
    ),
  );
}
