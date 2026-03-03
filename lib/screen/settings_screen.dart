import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'Dark Blue';
  String _selectedFontSize = 'Medium';
  bool _showStrengthInSearch = true;
  bool _showPriceInList = true;
  bool _expandGenericByDefault = false;

  final List<Map<String, dynamic>> _themes = [
    {'name': 'Dark Blue',   'bg': const Color(0xFF0F1117), 'accent': const Color(0xFF4F8EF7), 'preview': Colors.blue},
    {'name': 'Dark Green',  'bg': const Color(0xFF0D1410), 'accent': const Color(0xFF34D399), 'preview': Colors.green},
    {'name': 'Dark Purple', 'bg': const Color(0xFF110F17), 'accent': const Color(0xFFA78BFA), 'preview': Colors.purple},
    {'name': 'Dark Amber',  'bg': const Color(0xFF141008), 'accent': const Color(0xFFFBBF24), 'preview': Colors.amber},
    {'name': 'Dark Rose',   'bg': const Color(0xFF17090D), 'accent': const Color(0xFFF472B6), 'preview': Colors.pink},
    {'name': 'Slate',       'bg': const Color(0xFF0F1117), 'accent': const Color(0xFF94A3B8), 'preview': Colors.blueGrey},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left sidebar
        Container(
          width: 220,
          color: AppTheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider))),
                child: Row(children: [
                  const Icon(Icons.settings_outlined, size: 16, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  Text('Settings', style: AppTheme.headingSmall),
                ]),
              ),
              _SideItem(Icons.palette_outlined, 'Appearance', true),
              _SideItem(Icons.text_fields_rounded, 'Display', false),
              _SideItem(Icons.sync_rounded, 'Sync', false),
              _SideItem(Icons.info_outline_rounded, 'About', false),
            ],
          ),
        ),
        // Right content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader('Appearance'),
                const SizedBox(height: 16),

                // Theme picker
                Text('Color Theme', style: AppTheme.headingSmall),
                const SizedBox(height: 4),
                Text('Choose a color accent for the application.', style: AppTheme.bodySecondary),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _themes.map((t) {
                    final isSelected = _selectedTheme == t['name'];
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTheme = t['name'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 130,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? (t['accent'] as Color).withOpacity(0.12) : AppTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? (t['accent'] as Color) : AppTheme.divider,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    color: t['accent'] as Color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded, size: 14, color: t['accent'] as Color),
                              ]),
                              const SizedBox(height: 8),
                              Text(t['name'] as String,
                                  style: AppTheme.bodySecondary.copyWith(
                                    color: isSelected ? (t['accent'] as Color) : AppTheme.textSecondary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),
                const Divider(color: AppTheme.divider),
                const SizedBox(height: 24),

                _SectionHeader('Display'),
                const SizedBox(height: 16),

                // Font size
                Text('Font Size', style: AppTheme.headingSmall),
                const SizedBox(height: 12),
                Row(
                  children: ['Small', 'Medium', 'Large'].map((s) {
                    final sel = _selectedFontSize == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFontSize = s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? AppTheme.accent.withOpacity(0.15) : AppTheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: sel ? AppTheme.accent : AppTheme.divider),
                            ),
                            child: Text(s,
                                style: AppTheme.bodySecondary.copyWith(
                                  color: sel ? AppTheme.accent : AppTheme.textSecondary,
                                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                )),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Toggles
                _ToggleRow(
                  label: 'Show strength in search results',
                  description: 'Display strength info alongside brand name in search.',
                  value: _showStrengthInSearch,
                  onChanged: (v) => setState(() => _showStrengthInSearch = v),
                ),
                const SizedBox(height: 12),
                _ToggleRow(
                  label: 'Show price in brand list',
                  description: 'Show price column in the brand listing views.',
                  value: _showPriceInList,
                  onChanged: (v) => setState(() => _showPriceInList = v),
                ),
                const SizedBox(height: 12),
                _ToggleRow(
                  label: 'Expand generic details by default',
                  description: 'Auto-expand all sections when opening a generic.',
                  value: _expandGenericByDefault,
                  onChanged: (v) => setState(() => _expandGenericByDefault = v),
                ),

                const SizedBox(height: 32),
                const Divider(color: AppTheme.divider),
                const SizedBox(height: 24),

                _SectionHeader('About'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppTheme.accent, AppTheme.accentDim]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.medication_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('DIMS Desktop', style: AppTheme.headingSmall),
                          Text('Drug Information Management System', style: AppTheme.bodySecondary.copyWith(fontSize: 11)),
                        ]),
                      ]),
                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.divider),
                      const SizedBox(height: 12),
                      _AboutRow('Version', '1.0.0'),
                      _AboutRow('Build', 'Flutter Desktop'),
                      _AboutRow('Database', 'Hive (Local)'),
                      _AboutRow('State Management', 'GetX'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                // Apply button
                Align(
                  alignment: Alignment.centerLeft,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Get.snackbar(
                          'Settings Saved',
                          'Your preferences have been applied.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppTheme.accentGreen.withOpacity(0.9),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Apply Settings',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SideItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  const _SideItem(this.icon, this.label, this.isActive);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.accent.withOpacity(0.1) : Colors.transparent,
        border: Border(left: BorderSide(color: isActive ? AppTheme.accent : Colors.transparent, width: 3)),
      ),
      child: Row(children: [
        Icon(icon, size: 15, color: isActive ? AppTheme.accent : AppTheme.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: AppTheme.bodySecondary.copyWith(
            color: isActive ? AppTheme.accent : AppTheme.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 3, height: 18, decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: AppTheme.headingMedium),
    ]);
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.description, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: AppTheme.bodyPrimary.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(description, style: AppTheme.bodySecondary.copyWith(fontSize: 11)),
            ]),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accent,
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String key2;
  final String val;
  const _AboutRow(this.key2, this.val);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 160, child: Text(key2, style: AppTheme.label)),
        Text(val, style: AppTheme.bodySecondary),
      ]),
    );
  }
}
