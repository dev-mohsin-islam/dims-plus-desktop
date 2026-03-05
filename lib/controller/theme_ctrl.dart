import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/app_theme.dart';

class ThemeCtrl extends GetxController {
  // Observable settings
  var selectedTheme = 'Dark Blue'.obs;
  var selectedFontSize = 'Medium'.obs;
  var showStrengthInSearch = true.obs;
  var showPriceInList = true.obs;
  var expandGenericByDefault = false.obs;

  // SharedPreferences keys
  static const String _themeKey = 'selected_theme';
  static const String _fontSizeKey = 'selected_font_size';
  static const String _strengthKey = 'show_strength_in_search';
  static const String _priceKey = 'show_price_in_list';
  static const String _expandKey = 'expand_generic_by_default';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme
      selectedTheme.value = prefs.getString(_themeKey) ?? 'Dark Blue';

      // Load font size
      selectedFontSize.value = prefs.getString(_fontSizeKey) ?? 'Medium';

      // Load boolean settings
      showStrengthInSearch.value = prefs.getBool(_strengthKey) ?? true;
      showPriceInList.value = prefs.getBool(_priceKey) ?? true;
      expandGenericByDefault.value = prefs.getBool(_expandKey) ?? false;

      print('✅ Settings loaded from SharedPreferences');
    } catch (e) {
      print('❌ Error loading settings: $e');
    }
  }

  // Save all settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_themeKey, selectedTheme.value);
      await prefs.setString(_fontSizeKey, selectedFontSize.value);
      await prefs.setBool(_strengthKey, showStrengthInSearch.value);
      await prefs.setBool(_priceKey, showPriceInList.value);
      await prefs.setBool(_expandKey, expandGenericByDefault.value);

      print('✅ Settings saved to SharedPreferences');
    } catch (e) {
      print('❌ Error saving settings: $e');
    }
  }

  // Font size scale factors
  double get fontSizeScale {
    switch (selectedFontSize.value) {
      case 'Small':
        return 0.85;
      case 'Large':
        return 1.15;
      default:
        return 1.0;
    }
  }

  // Get current theme definition
  ThemeDefinition get currentTheme =>
      AppTheme.themes[selectedTheme.value] ?? AppTheme.themes['Dark Blue']!;

  // Get current accent color
  Color get accentColor => currentTheme.accent;

  // Get current background color
  Color get bgColor => currentTheme.bg;

  // Get current surface color
  Color get surfaceColor => currentTheme.surface;

  // Get current elevated surface color
  Color get surfaceElevatedColor => currentTheme.surfaceElevated;

  // Get current highlight color
  Color get surfaceHighlightColor => currentTheme.surfaceHighlight;

  // Get current divider color
  Color get dividerColor => currentTheme.divider;

  // Get current text colors
  Color get textPrimaryColor => currentTheme.textPrimary;
  Color get textSecondaryColor => currentTheme.textSecondary;
  Color get textMutedColor => currentTheme.textMuted;

  // Check if current theme is dark
  bool get isDark => currentTheme.isDark;

  // Update settings with auto-save
  void updateTheme(String theme) {
    selectedTheme.value = theme;
    _saveSettings();
  }

  void updateFontSize(String size) {
    selectedFontSize.value = size;
    _saveSettings();
  }

  void toggleShowStrength(bool value) {
    showStrengthInSearch.value = value;
    _saveSettings();
  }

  void toggleShowPrice(bool value) {
    showPriceInList.value = value;
    _saveSettings();
  }

  void toggleExpandGeneric(bool value) {
    expandGenericByDefault.value = value;
    _saveSettings();
  }

  // Reset to defaults with save
  void resetToDefaults() {
    selectedTheme.value = 'Dark Blue';
    selectedFontSize.value = 'Medium';
    showStrengthInSearch.value = true;
    showPriceInList.value = true;
    expandGenericByDefault.value = false;
    _saveSettings();
  }
}