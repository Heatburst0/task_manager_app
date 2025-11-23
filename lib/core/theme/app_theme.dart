import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Color Palette ---
  static const Color primaryColor = Color(0xFF004D40); // Deep Teal
  static const Color primaryLightColor = Color(0xFF00796B);
  static const Color accentColor = Color(0xFFFFA726); // Warm Amber
  static const Color backgroundColorLight = Color(0xFFF1F4F8);
  static const Color cardColorLight = Colors.white;
  static const Color textColorLight = Color(0xFF1C2A3A);

  static const Color backgroundColorDark = Color(0xFF121212);
  static const Color cardColorDark = Color(0xFF1E1E1E);
  static const Color textColorDark = Color(0xFFE0E0E0);

  // --- Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorLight,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardColorLight,
      onSurface: textColorLight,
      background: backgroundColorLight,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme)
        .apply(bodyColor: textColorLight),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: primaryColor),
      titleTextStyle: GoogleFonts.poppins(
          color: primaryColor, fontSize: 20, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: cardColorLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: primaryColor.withOpacity(0.1),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.3),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );

  // --- Dark Theme ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryLightColor,
    scaffoldBackgroundColor: backgroundColorDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryLightColor,
      secondary: accentColor,
      surface: cardColorDark,
      onSurface: textColorDark,
      background: backgroundColorDark,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
        .apply(bodyColor: textColorDark),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textColorDark),
      titleTextStyle: GoogleFonts.poppins(
          color: textColorDark, fontSize: 20, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: cardColorDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black.withOpacity(0.5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade800.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryLightColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLightColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: primaryLightColor.withOpacity(0.3),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryLightColor,
      foregroundColor: Colors.white,
    ),
  );
}