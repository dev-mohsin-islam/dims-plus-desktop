import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/theme_ctrl.dart';
import 'app_theme.dart';

class SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final double? fontSizeScale;
  final Color? accentColor;

  const SearchInput({
    Key? key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.fontSizeScale,
    this.accentColor,
  }) : super(key: key);

  // Get theme controller
  ThemeCtrl get _themeCtrl => Get.put(ThemeCtrl());

  // Get current theme
  ThemeDefinition get _theme => _themeCtrl.currentTheme;

  // Get values from theme controller if not provided
  double get _fontSizeScale => fontSizeScale ?? _themeCtrl.fontSizeScale;
  Color get _accentColor => accentColor ?? _themeCtrl.accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36 * _fontSizeScale,
      decoration: BoxDecoration(
        color: _theme.bg,
        borderRadius: BorderRadius.circular(8 * _fontSizeScale),
        border: Border.all(color: _theme.divider),
      ),
      child: Row(
        children: [
          SizedBox(width: 10 * _fontSizeScale),
          Icon(
            Icons.search_rounded,
            size: 14 * _fontSizeScale,
            color: _theme.textMuted,
          ),
          SizedBox(width: 8 * _fontSizeScale),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 12 * _fontSizeScale,
                fontWeight: FontWeight.w400,
                color: _theme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: _theme.textMuted,
                  fontSize: 12 * _fontSizeScale,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Padding(
                padding: EdgeInsets.only(right: 8 * _fontSizeScale),
                child: Icon(
                  Icons.close_rounded,
                  size: 12 * _fontSizeScale,
                  color: _theme.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}