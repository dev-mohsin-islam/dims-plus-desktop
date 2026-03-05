import 'package:flutter/material.dart';

class AppTheme {
  // Dark Theme Colors
  static const Color darkBg = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF171B26);
  static const Color darkSurfaceElevated = Color(0xFF1E2333);
  static const Color darkSurfaceHighlight = Color(0xFF252B3D);
  static const Color darkDivider = Color(0xFF2A3047);
  static const Color darkTextPrimary = Color(0xFFE2E8F0);
  static const Color darkTextSecondary = Color(0xFF8B97B0);
  static const Color darkTextMuted = Color(0xFF4A5568);

  // Light Theme Colors
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightSurfaceHighlight = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Accent Colors (same for both themes)
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRose = Color(0xFFEC4899);
  static const Color accentSlate = Color(0xFF64748B);
  static const Color accentRed = Color(0xFFEF4444);

  // Theme definitions
  static const Map<String, ThemeDefinition> themes = {
    'Dark Blue': ThemeDefinition(
      name: 'Dark Blue',
      isDark: true,
      bg: darkBg,
      surface: darkSurface,
      surfaceElevated: darkSurfaceElevated,
      surfaceHighlight: darkSurfaceHighlight,
      divider: darkDivider,
      textPrimary: darkTextPrimary,
      textSecondary: darkTextSecondary,
      textMuted: darkTextMuted,
      accent: accentBlue,
    ),
    'Dark Green': ThemeDefinition(
      name: 'Dark Green',
      isDark: true,
      bg: darkBg,
      surface: darkSurface,
      surfaceElevated: darkSurfaceElevated,
      surfaceHighlight: darkSurfaceHighlight,
      divider: darkDivider,
      textPrimary: darkTextPrimary,
      textSecondary: darkTextSecondary,
      textMuted: darkTextMuted,
      accent: accentGreen,
    ),
    'Dark Purple': ThemeDefinition(
      name: 'Dark Purple',
      isDark: true,
      bg: darkBg,
      surface: darkSurface,
      surfaceElevated: darkSurfaceElevated,
      surfaceHighlight: darkSurfaceHighlight,
      divider: darkDivider,
      textPrimary: darkTextPrimary,
      textSecondary: darkTextSecondary,
      textMuted: darkTextMuted,
      accent: accentPurple,
    ),
    'Dark Amber': ThemeDefinition(
      name: 'Dark Amber',
      isDark: true,
      bg: darkBg,
      surface: darkSurface,
      surfaceElevated: darkSurfaceElevated,
      surfaceHighlight: darkSurfaceHighlight,
      divider: darkDivider,
      textPrimary: darkTextPrimary,
      textSecondary: darkTextSecondary,
      textMuted: darkTextMuted,
      accent: accentAmber,
    ),
    'Dark Rose': ThemeDefinition(
      name: 'Dark Rose',
      isDark: true,
      bg: darkBg,
      surface: darkSurface,
      surfaceElevated: darkSurfaceElevated,
      surfaceHighlight: darkSurfaceHighlight,
      divider: darkDivider,
      textPrimary: darkTextPrimary,
      textSecondary: darkTextSecondary,
      textMuted: darkTextMuted,
      accent: accentRose,
    ),
    'Slate': ThemeDefinition(
      name: 'Slate',
      isDark: true,
      bg: darkBg,
      surface: darkSurface,
      surfaceElevated: darkSurfaceElevated,
      surfaceHighlight: darkSurfaceHighlight,
      divider: darkDivider,
      textPrimary: darkTextPrimary,
      textSecondary: darkTextSecondary,
      textMuted: darkTextMuted,
      accent: accentSlate,
    ),
    // Light Themes
    'Light Blue': ThemeDefinition(
      name: 'Light Blue',
      isDark: false,
      bg: lightBg,
      surface: lightSurface,
      surfaceElevated: lightSurfaceElevated,
      surfaceHighlight: lightSurfaceHighlight,
      divider: lightDivider,
      textPrimary: lightTextPrimary,
      textSecondary: lightTextSecondary,
      textMuted: lightTextMuted,
      accent: accentBlue,
    ),
    'Light Green': ThemeDefinition(
      name: 'Light Green',
      isDark: false,
      bg: lightBg,
      surface: lightSurface,
      surfaceElevated: lightSurfaceElevated,
      surfaceHighlight: lightSurfaceHighlight,
      divider: lightDivider,
      textPrimary: lightTextPrimary,
      textSecondary: lightTextSecondary,
      textMuted: lightTextMuted,
      accent: accentGreen,
    ),
    'Light Purple': ThemeDefinition(
      name: 'Light Purple',
      isDark: false,
      bg: lightBg,
      surface: lightSurface,
      surfaceElevated: lightSurfaceElevated,
      surfaceHighlight: lightSurfaceHighlight,
      divider: lightDivider,
      textPrimary: lightTextPrimary,
      textSecondary: lightTextSecondary,
      textMuted: lightTextMuted,
      accent: accentPurple,
    ),
    'Light Amber': ThemeDefinition(
      name: 'Light Amber',
      isDark: false,
      bg: lightBg,
      surface: lightSurface,
      surfaceElevated: lightSurfaceElevated,
      surfaceHighlight: lightSurfaceHighlight,
      divider: lightDivider,
      textPrimary: lightTextPrimary,
      textSecondary: lightTextSecondary,
      textMuted: lightTextMuted,
      accent: accentAmber,
    ),
    'Light Rose': ThemeDefinition(
      name: 'Light Rose',
      isDark: false,
      bg: lightBg,
      surface: lightSurface,
      surfaceElevated: lightSurfaceElevated,
      surfaceHighlight: lightSurfaceHighlight,
      divider: lightDivider,
      textPrimary: lightTextPrimary,
      textSecondary: lightTextSecondary,
      textMuted: lightTextMuted,
      accent: accentRose,
    ),
    'Light Slate': ThemeDefinition(
      name: 'Light Slate',
      isDark: false,
      bg: lightBg,
      surface: lightSurface,
      surfaceElevated: lightSurfaceElevated,
      surfaceHighlight: lightSurfaceHighlight,
      divider: lightDivider,
      textPrimary: lightTextPrimary,
      textSecondary: lightTextSecondary,
      textMuted: lightTextMuted,
      accent: accentSlate,
    ),
  };
}

class ThemeDefinition {
  final String name;
  final bool isDark;
  final Color bg;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceHighlight;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;

  const ThemeDefinition({
    required this.name,
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHighlight,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
  });

  // Helper to get dimmed accent
  Color get accentDim => accent.withOpacity(0.7);

  // Helper to get accent with opacity
  Color accentWithOpacity(double opacity) => accent.withOpacity(opacity);
}