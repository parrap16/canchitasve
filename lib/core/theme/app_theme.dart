import 'package:flutter/material.dart';

/// Identidad visual de CAIMANEROS:
/// Estética minimalista, tema oscuro mate (sin sombras, bordes finos de 1px),
/// verde de césped deportivo de alto contraste y tipografía nítida.
abstract final class AppTheme {
  // ── Paleta de Colores Mate ──────────────────────────────────────────────────
  static const primaryGreen = Color(0xFF22C55E); // Turf Green
  static const primaryGreenDark = Color(0xFF16A34A);
  static const backgroundDark = Color(0xFF0F1110); // Dark Matte Pitch
  static const surfaceDark = Color(0xFF161817); // Card Surface
  static const surfaceDarkLighter = Color(0xFF1E211F);
  static const borderColor = Color(0xFF2A2E2C); // 1px borders
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);
  static const error = Color(0xFFEF4444);

  // ── Estilo de Borde Minimalista 1px ─────────────────────────────────────────
  static const border1px = BorderSide(color: borderColor, width: 1.0);
  static final roundedBorder12 = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: border1px,
  );
  static final roundedBorder8 = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    side: border1px,
  );

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        onPrimary: Color(0xFF042F15),
        surface: surfaceDark,
        onSurface: textPrimary,
        error: error,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: roundedBorder12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: border1px,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: border1px,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: error, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: const Color(0xFF042F15),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          elevation: 0,
          side: border1px,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
