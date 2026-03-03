import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color bgDark = Color(0xFF0F1117);
  static const Color surface = Color(0xFF171B26);
  static const Color surfaceElevated = Color(0xFF1E2333);
  static const Color surfaceHighlight = Color(0xFF252B3D);
  static const Color divider = Color(0xFF2A3047);
  static const Color accent = Color(0xFF4F8EF7);
  static const Color accentDim = Color(0xFF2563EB);
  static const Color accentGreen = Color(0xFF34D399);
  static const Color accentAmber = Color(0xFFFBBF24);
  static const Color accentRed = Color(0xFFF87171);
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF8B97B0);
  static const Color textMuted = Color(0xFF4A5568);

  // Text Styles
  static const TextStyle logo = TextStyle(
    fontFamily: 'Courier',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 2.5,
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyPrimary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.8,
  );

  static const TextStyle chip = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  // ThemeData
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      surface: surface,
    ),
    fontFamily: 'SF Pro Display',
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(divider),
      thickness: WidgetStateProperty.all(4),
      radius: const Radius.circular(4),
    ),
  );
}
