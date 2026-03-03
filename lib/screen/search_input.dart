import 'package:flutter/material.dart';
import 'app_theme.dart';

class SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  const SearchInput({Key? key, required this.controller, required this.hint, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search_rounded, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTheme.bodyPrimary.copyWith(fontSize: 12),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                border: InputBorder.none,
                isDense: true,
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
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.close_rounded, size: 12, color: AppTheme.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}
