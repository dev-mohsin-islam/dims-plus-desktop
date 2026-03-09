import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_theme.dart';
import '../controller/theme_ctrl.dart';
import 'about_screen.dart';
import 'ai_demo_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeCtrl _themeCtrl = Get.put(ThemeCtrl());

  // Local state for UI
  late String _selectedTheme;
  late String _selectedFontSize;
  late bool _showStrengthInSearch;
  late bool _showPriceInList;
  late bool _expandGenericByDefault;

  // Group themes by type
  final List<Map<String, dynamic>> _darkThemes = [
    {'name': 'Dark Blue', 'accent': AppTheme.accentBlue, 'preview': Colors.blue},
    {'name': 'Dark Green', 'accent': AppTheme.accentGreen, 'preview': Colors.green},
    {'name': 'Dark Purple', 'accent': AppTheme.accentPurple, 'preview': Colors.purple},
    {'name': 'Dark Amber', 'accent': AppTheme.accentAmber, 'preview': Colors.amber},
    {'name': 'Dark Rose', 'accent': AppTheme.accentRose, 'preview': Colors.pink},
    {'name': 'Slate', 'accent': AppTheme.accentSlate, 'preview': Colors.blueGrey},
  ];

  final List<Map<String, dynamic>> _lightThemes = [
    {'name': 'Light Blue', 'accent': AppTheme.accentBlue, 'preview': Colors.blue},
    {'name': 'Light Green', 'accent': AppTheme.accentGreen, 'preview': Colors.green},
    {'name': 'Light Purple', 'accent': AppTheme.accentPurple, 'preview': Colors.purple},
    {'name': 'Light Amber', 'accent': AppTheme.accentAmber, 'preview': Colors.amber},
    {'name': 'Light Rose', 'accent': AppTheme.accentRose, 'preview': Colors.pink},
    {'name': 'Light Slate', 'accent': AppTheme.accentSlate, 'preview': Colors.blueGrey},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTheme = _themeCtrl.selectedTheme.value;
    _selectedFontSize = _themeCtrl.selectedFontSize.value;
    _showStrengthInSearch = _themeCtrl.showStrengthInSearch.value;
    _showPriceInList = _themeCtrl.showPriceInList.value;
    _expandGenericByDefault = _themeCtrl.expandGenericByDefault.value;
  }

  void _applySettings() {
    _themeCtrl.updateTheme(_selectedTheme);
    _themeCtrl.updateFontSize(_selectedFontSize);
    _themeCtrl.toggleShowStrength(_showStrengthInSearch);
    _themeCtrl.toggleShowPrice(_showPriceInList);
    _themeCtrl.toggleExpandGeneric(_expandGenericByDefault);

    Get.snackbar(
      'Settings Saved',
      'Your preferences have been applied.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _themeCtrl.accentColor.withOpacity(0.9),
      colorText: _themeCtrl.isDark ? Colors.white : _themeCtrl.textPrimaryColor,
      duration: const Duration(seconds: 2),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _selectedTheme = 'Dark Blue';
      _selectedFontSize = 'Medium';
      _showStrengthInSearch = true;
      _showPriceInList = true;
      _expandGenericByDefault = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = _themeCtrl.currentTheme;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left sidebar
          Container(
            width: 220,
            color: theme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: theme.divider)),
                  ),
                  child: Row(children: [
                    Icon(Icons.settings_outlined, size: 16, color: theme.accent),
                    const SizedBox(width: 8),
                    Text('Settings', style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    )),
                  ]),
                ),
                _SideItem(
                  Icons.palette_outlined,
                  'Appearance',
                  true,
                  theme: theme,
                  onTap: () {}, // Already on appearance
                ),
                _SideItem(
                  Icons.text_fields_rounded,
                  'Display',
                  false,
                  theme: theme,
                  onTap: () {},
                ),
                _SideItem(
                  Icons.sync_rounded,
                  'Sync',
                  false,
                  theme: theme,
                  onTap: () {},
                ),
                _SideItem(
                  Icons.auto_awesome_rounded,
                  'AI Features',
                  false,
                  theme: theme,
                  onTap: () => Get.to(() => const AiDemoScreen()),
                ),
                _SideItem(
                  Icons.info_outline_rounded,
                  'About',
                  false,
                  theme: theme,
                  onTap: () => Get.to(() => const AboutScreen()),
                ),
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
                  _SectionHeader('Appearance', theme: theme),
                  const SizedBox(height: 16),

                  // Dark Themes
                  Text('Dark Themes', style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _darkThemes.map((t) {
                      final isSelected = _selectedTheme == t['name'];
                      final accentColor = t['accent'] as Color;

                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTheme = t['name'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 130,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? accentColor.withOpacity(0.12) : theme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? accentColor : theme.divider,
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
                                      color: accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded, size: 14, color: accentColor),
                                ]),
                                const SizedBox(height: 8),
                                Text(
                                  t['name'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? accentColor : theme.textSecondary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Light Themes
                  Text('Light Themes', style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _lightThemes.map((t) {
                      final isSelected = _selectedTheme == t['name'];
                      final accentColor = t['accent'] as Color;

                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTheme = t['name'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 130,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? accentColor.withOpacity(0.12) : theme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? accentColor : theme.divider,
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
                                      color: accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded, size: 14, color: accentColor),
                                ]),
                                const SizedBox(height: 8),
                                Text(
                                  t['name'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? accentColor : theme.textSecondary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                  Divider(color: theme.divider, height: 1),
                  const SizedBox(height: 24),

                  _SectionHeader('Display', theme: theme),
                  const SizedBox(height: 16),

                  // AI Promo Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.accent, theme.accent.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI Clinical Assistant',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('BETA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Experience the future of drug indices with AI-powered interaction checks, clinical smart search, and patient guide generation.',
                                style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => Get.to(() => const AiDemoScreen()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: theme.accent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Explore AI Features', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Icon(Icons.psychology_rounded, size: 80, color: Colors.white.withOpacity(0.2)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Font size
                  Text('Font Size', style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  )),
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
                                color: sel ? theme.accent.withOpacity(0.15) : theme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: sel ? theme.accent : theme.divider,
                                ),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: sel ? theme.accent : theme.textSecondary,
                                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
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
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    label: 'Show price in brand list',
                    description: 'Show price column in the brand listing views.',
                    value: _showPriceInList,
                    onChanged: (v) => setState(() => _showPriceInList = v),
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    label: 'Expand generic details by default',
                    description: 'Auto-expand all sections when opening a generic.',
                    value: _expandGenericByDefault,
                    onChanged: (v) => setState(() => _expandGenericByDefault = v),
                    theme: theme,
                  ),

                  const SizedBox(height: 32),
                  Divider(color: theme.divider, height: 1),
                  const SizedBox(height: 24),

                  _SectionHeader('About', theme: theme),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [theme.accent, theme.accent.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.medication_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('DIMS Desktop', style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.textPrimary,
                            )),
                            Text(
                              'Drug Information Management System',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textSecondary,
                              ),
                            ),
                          ]),
                        ]),
                        const SizedBox(height: 16),
                        Divider(color: theme.divider, height: 1),
                        const SizedBox(height: 12),
                        _AboutRow('Version', '1.0.0', theme: theme),
                        _AboutRow('Build', 'Flutter Desktop', theme: theme),
                        _AboutRow('Database', 'Hive (Local)', theme: theme),
                        _AboutRow('State Management', 'GetX', theme: theme),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => Get.to(() => const AboutScreen()),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'View More Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      // Apply button
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _applySettings,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Apply Settings',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Reset button
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _resetToDefaults,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.divider),
                            ),
                            child: Text(
                              'Reset to Defaults',
                              style: TextStyle(
                                color: theme.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _SideItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final ThemeDefinition theme;
  final VoidCallback onTap;

  const _SideItem(
      this.icon,
      this.label,
      this.isActive, {
        required this.theme,
        required this.onTap,
      });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? theme.accent.withOpacity(0.1) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isActive ? theme.accent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? theme.accent : theme.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? theme.accent : theme.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeDefinition theme;

  const _SectionHeader(this.title, {required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 3,
        height: 18,
        decoration: BoxDecoration(
          color: theme.accent,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: theme.textPrimary,
      )),
    ]);
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ThemeDefinition theme;

  const _ToggleRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textSecondary,
                ),
              ),
            ]),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.accent,
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String key2;
  final String val;
  final ThemeDefinition theme;

  const _AboutRow(this.key2, this.val, {required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
          width: 160,
          child: Text(
            key2,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
            ),
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            color: theme.textSecondary,
          ),
        ),
      ]),
    );
  }
}