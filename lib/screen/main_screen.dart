import 'package:dims_desktop/screen/search_bar_widget.dart';
import 'package:dims_desktop/screen/settings_screen.dart';
import 'package:dims_desktop/screen/bookmark_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_ctrl.dart';
import '../controller/favourite_ctrl.dart';
import '../controller/data_get_and_sync_ctrl.dart';
import '../controller/drug_brand_ctrl.dart';
import '../controller/generic_ctrl.dart';
import '../controller/company_ctrl.dart';
import '../controller/theme_ctrl.dart';
import 'brands_screen.dart';
import 'companies_screen.dart';
import 'drug_class_screen.dart';
import 'generics_screen.dart';
import 'indication_screen.dart';
import 'app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DataGetAndSyncCtrl _dataGetAndSyncCtrl = Get.put(DataGetAndSyncCtrl());
  Widget? _currentBody;
  String _activeNav = '';
  final ThemeCtrl _themeCtrl = Get.put(ThemeCtrl()); // Find existing controller

  void _navigateTo(Widget screen, String label) {
    setState(() {
      _currentBody = screen;
      _activeNav = label;
    });
  }

  void _goHome() {
    setState(() {
      _currentBody = null;
      _activeNav = '';
    });
  }

  @override
  void initState() {
    super.initState();
    _dataGetAndSyncCtrl.initialCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeCtrl.bgColor, // Dynamic background
      body: Obx(() {
        final theme = _themeCtrl.currentTheme;
        final accentColor = theme.accent;
        final fontSizeScale = _themeCtrl.fontSizeScale;

        return Column(
          children: [
            _TopAppBar(
              activeNav: _activeNav,
              onNavigate: _navigateTo,
              onHome: _goHome,
              theme: theme,
              fontSizeScale: fontSizeScale,
            ),
            _SearchBarArea(
              onNavigate: _navigateTo,
              theme: theme,
              fontSizeScale: fontSizeScale,
            ),
            Expanded(
              child: _currentBody ?? _WelcomeView(
                theme: theme,
                fontSizeScale: fontSizeScale,
                onNavigate: _navigateTo,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─── TOP APP BAR ─────────────────────────────────────────────────────────────

class _TopAppBar extends StatelessWidget {
  final String activeNav;
  final Function(Widget, String) onNavigate;
  final VoidCallback onHome;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _TopAppBar({
    required this.activeNav,
    required this.onNavigate,
    required this.onHome,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(bottom: BorderSide(color: theme.divider, width: 1)),
        boxShadow: [
          BoxShadow(
            color: theme.isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Clickable Logo → home
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onHome,
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      // decoration: BoxDecoration(
                      //   gradient: LinearGradient(
                      //     colors: [theme.accent, theme.accent.withOpacity(0.7)],
                      //   ),
                      //   borderRadius: BorderRadius.circular(8),
                      // ),
                      child: Image.asset(
                        'assets/images/dims_plus_logo.png',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'DIMS',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16 * fontSizeScale,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          _MedicinesMenu(
            activeNav: activeNav,
            onNavigate: onNavigate,
            theme: theme,
            fontSizeScale: fontSizeScale,
          ),
          const SizedBox(width: 4),
          _NavButton(
            label: 'Drug Class',
            icon: Icons.category_outlined,
            isActive: activeNav == 'Drug Class',
            onTap: () => onNavigate(const DrugClassScreen(), 'Drug Class'),
            theme: theme,
            fontSizeScale: fontSizeScale,
          ),
          const SizedBox(width: 4),
          _NavButton(
            label: 'Indication',
            icon: Icons.health_and_safety_outlined,
            isActive: activeNav == 'Indication',
            onTap: () => onNavigate(const IndicationScreen(), 'Indication'),
            theme: theme,
            fontSizeScale: fontSizeScale,
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _IconAction(
                  icon: Icons.sync_rounded,
                  tooltip: 'Sync Data',
                  onTap: () {
                    Get.find<DataGetAndSyncCtrl>().dataSyncFromServer();
                    Get.snackbar(
                      'Syncing',
                      'Data sync started…',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: theme.accent.withOpacity(0.9),
                      colorText: theme.isDark ? Colors.white : theme.textPrimary,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  theme: theme,
                  fontSizeScale: fontSizeScale,
                ),
                const SizedBox(width: 8),
                _IconAction(
                  icon: Icons.person_outline_rounded,
                  tooltip: 'Profile',
                  onTap: () => _showProfileDialog(context, theme, fontSizeScale),
                  theme: theme,
                  fontSizeScale: fontSizeScale,
                ),
                const SizedBox(width: 8),
                _IconAction(
                  icon: Icons.settings_outlined,
                  tooltip: 'Settings',
                  onTap: () => onNavigate(const SettingsScreen(), 'Settings'),
                  theme: theme,
                  fontSizeScale: fontSizeScale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context, ThemeDefinition theme, double fontSizeScale) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.divider),
        ),
        title: Row(children: [
          Icon(Icons.person_rounded, color: theme.accent),
          const SizedBox(width: 10),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 14 * fontSizeScale,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72 * fontSizeScale,
              height: 72 * fontSizeScale,
              decoration: BoxDecoration(
                color: theme.accent.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: theme.accent.withOpacity(0.4), width: 2),
              ),
              child: Icon(Icons.person_rounded, size: 36 * fontSizeScale, color: theme.accent),
            ),
            const SizedBox(height: 16),
            Text(
              'Doctor / User',
              style: TextStyle(
                fontSize: 14 * fontSizeScale,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'DIMS Desktop v1.0',
              style: TextStyle(
                fontSize: 13 * fontSizeScale,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.find<AuthCtrl>().logout();
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: theme.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicinesMenu extends StatelessWidget {
  final String activeNav;
  final Function(Widget, String) onNavigate;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _MedicinesMenu({
    required this.activeNav,
    required this.onNavigate,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = ['Generics', 'Brands', 'Bookmarks', 'Companies'].contains(activeNav);

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 46),
      color: theme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.divider),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? theme.accent.withOpacity(0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.medication_outlined,
              size: 16 * fontSizeScale,
              color: isActive ? theme.accent : theme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Medicines',
              style: TextStyle(
                fontSize: 13 * fontSizeScale,
                fontWeight: FontWeight.w500,
                color: isActive ? theme.accent : theme.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16 * fontSizeScale,
              color: isActive ? theme.accent : theme.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (_) => [
        _menuItem(Icons.science_outlined, 'Generics', theme, fontSizeScale),
        _menuItem(Icons.local_pharmacy_outlined, 'Brands', theme, fontSizeScale),
        _menuItem(Icons.bookmark_outline_rounded, 'Bookmarks', theme, fontSizeScale),
        _menuItem(Icons.business_outlined, 'Companies', theme, fontSizeScale),
      ],
      onSelected: (val) {
        switch (val) {
          case 'Generics':  onNavigate(const GenericsScreen(), 'Generics'); break;
          case 'Brands':    onNavigate(BrandsScreen(), 'Brands'); break;
          case 'Bookmarks': onNavigate(const BookmarkScreen(), 'Bookmarks'); break;
          case 'Companies': onNavigate(const CompaniesScreen(), 'Companies'); break;
        }
      },
    );
  }

  PopupMenuItem<String> _menuItem(IconData icon, String label, ThemeDefinition theme, double fontSizeScale) {
    return PopupMenuItem(
      value: label,
      height: 44,
      child: Row(children: [
        Icon(icon, size: 16 * fontSizeScale, color: theme.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13 * fontSizeScale,
            fontWeight: FontWeight.w500,
            color: theme.textPrimary,
          ),
        ),
      ]),
    );
  }
}

class _NavButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.theme.accent.withOpacity(0.15)
                : _hover ? widget.theme.surfaceHighlight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isActive ? widget.theme.accent.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 16 * widget.fontSizeScale,
                color: widget.isActive ? widget.theme.accent : widget.theme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13 * widget.fontSizeScale,
                  fontWeight: FontWeight.w500,
                  color: widget.isActive ? widget.theme.accent : widget.theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 34 * widget.fontSizeScale,
            height: 34 * widget.fontSizeScale,
            decoration: BoxDecoration(
              color: _hover ? widget.theme.surfaceHighlight : widget.theme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.theme.divider),
            ),
            child: Icon(
              widget.icon,
              size: 16 * widget.fontSizeScale,
              color: _hover ? widget.theme.accent : widget.theme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SEARCH BAR AREA ─────────────────────────────────────────────────────────

class _SearchBarArea extends StatelessWidget {
  final Function(Widget, String) onNavigate;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _SearchBarArea({
    required this.onNavigate,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.bg,
        border: Border(bottom: BorderSide(color: theme.divider.withOpacity(0.5))),
      ),
      child: GlobalSearchBar(
        onNavigate: onNavigate,
        accentColor: theme.accent,
        fontSizeScale: fontSizeScale,
      ),
    );
  }
}

// ─── WELCOME VIEW ─────────────────────────────────────────────────────────────

class _WelcomeView extends StatelessWidget {
  final ThemeDefinition theme;
  final double fontSizeScale;
  final Function(Widget, String) onNavigate;

  const _WelcomeView({
    required this.theme,
    required this.fontSizeScale,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final brandCtrl = Get.put(DrugBrandCtrl());
    final genericCtrl = Get.put(GenericCtrl());
    final companyCtrl = Get.put(CompanyCtrl());
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80 * fontSizeScale,
            height: 80 * fontSizeScale,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.accent, theme.accent.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20 * fontSizeScale),
              boxShadow: [
                BoxShadow(
                  color: theme.accent.withOpacity(0.1),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/dims_plus_logo.png',
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Drug Information Management System',
            style: TextStyle(
              fontSize: 24 * fontSizeScale,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for medicines above, or use the navigation bar to browse.',
            style: TextStyle(
              fontSize: 13 * fontSizeScale,
              color: theme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Obx(() {
            final favCtrl = Get.put(FavouriteCtrl());

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatCard(
                  Icons.science_outlined,
                  'Generics',
                  genericCtrl.genericList.length.toString(),
                  theme.accent,
                  theme,
                  fontSizeScale,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  Icons.local_pharmacy_outlined,
                  'Brands',
                  brandCtrl.drugBrandList.length.toString(),
                  AppTheme.accentGreen,
                  theme,
                  fontSizeScale,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  Icons.bookmark_rounded,
                  'Bookmarks',
                  favCtrl.favourites.length.toString(),
                  AppTheme.accentAmber,
                  theme,
                  fontSizeScale,
                  onTap: () => onNavigate(const BookmarkScreen(), 'Bookmarks'),
                ),
                const SizedBox(width: 16),
                _StatCard(
                  Icons.business_outlined,
                  'Companies',
                  companyCtrl.companyList.length.toString(),
                  theme.textSecondary,
                  theme,
                  fontSizeScale,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final ThemeDefinition theme;
  final double fontSizeScale;
  final VoidCallback? onTap;

  const _StatCard(
      this.icon,
      this.label,
      this.count,
      this.color,
      this.theme,
      this.fontSizeScale, {
        this.onTap,
      });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 150 * fontSizeScale,
          height: 100 * fontSizeScale,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.divider),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26 * fontSizeScale),
              const SizedBox(height: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 18 * fontSizeScale,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11 * fontSizeScale,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}