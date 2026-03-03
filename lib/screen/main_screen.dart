import 'package:dims_desktop/screen/search_bar_widget.dart';
import 'package:dims_desktop/screen/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/data_get_and_sync_ctrl.dart';
import '../controller/drug_brand_ctrl.dart';
import '../controller/generic_ctrl.dart';
import '../controller/company_ctrl.dart';
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
  Widget? _currentBody;
  String _activeNav = '';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Column(
        children: [
          _TopAppBar(
            activeNav: _activeNav,
            onNavigate: _navigateTo,
            onHome: _goHome,
          ),
          _SearchBarArea(onNavigate: _navigateTo),
          Expanded(
            child: _currentBody ?? const _WelcomeView(),
          ),
        ],
      ),
    );
  }
}

// ─── TOP APP BAR ─────────────────────────────────────────────────────────────

class _TopAppBar extends StatelessWidget {
  final String activeNav;
  final Function(Widget, String) onNavigate;
  final VoidCallback onHome;

  const _TopAppBar({
    required this.activeNav,
    required this.onNavigate,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 3)),
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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppTheme.accent, AppTheme.accentDim]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.medication_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text('DIMS', style: AppTheme.logo),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          _MedicinesMenu(activeNav: activeNav, onNavigate: onNavigate),
          const SizedBox(width: 4),
          _NavButton(
            label: 'Drug Class',
            icon: Icons.category_outlined,
            isActive: activeNav == 'Drug Class',
            onTap: () => onNavigate(const DrugClassScreen(), 'Drug Class'),
          ),
          const SizedBox(width: 4),
          _NavButton(
            label: 'Indication',
            icon: Icons.health_and_safety_outlined,
            isActive: activeNav == 'Indication',
            onTap: () => onNavigate(const IndicationScreen(), 'Indication'),
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
                      backgroundColor: AppTheme.accent.withOpacity(0.9),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _IconAction(
                  icon: Icons.person_outline_rounded,
                  tooltip: 'Profile',
                  onTap: () => _showProfileDialog(context),
                ),
                const SizedBox(width: 8),
                _IconAction(
                  icon: Icons.settings_outlined,
                  tooltip: 'Settings',
                  onTap: () => onNavigate(const SettingsScreen(), 'Settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.divider),
        ),
        title: Row(children: [
          const Icon(Icons.person_rounded, color: AppTheme.accent),
          const SizedBox(width: 10),
          Text('Profile', style: AppTheme.headingSmall),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.person_rounded, size: 36, color: AppTheme.accent),
            ),
            const SizedBox(height: 16),
            Text('Doctor / User', style: AppTheme.headingSmall),
            const SizedBox(height: 4),
            Text('DIMS Desktop v1.0', style: AppTheme.bodySecondary),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}

class _MedicinesMenu extends StatelessWidget {
  final String activeNav;
  final Function(Widget, String) onNavigate;
  const _MedicinesMenu({required this.activeNav, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isActive = ['Generics', 'Brands', 'Companies'].contains(activeNav);
    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 46),
      color: AppTheme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppTheme.divider),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? AppTheme.accent.withOpacity(0.5) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(Icons.medication_outlined, size: 16, color: isActive ? AppTheme.accent : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text('Medicines', style: AppTheme.navLabel.copyWith(color: isActive ? AppTheme.accent : AppTheme.textSecondary)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: isActive ? AppTheme.accent : AppTheme.textSecondary),
          ],
        ),
      ),
      itemBuilder: (_) => [
        _menuItem(Icons.science_outlined, 'Generics'),
        _menuItem(Icons.local_pharmacy_outlined, 'Brands'),
        _menuItem(Icons.business_outlined, 'Companies'),
      ],
      onSelected: (val) {
        switch (val) {
          case 'Generics':  onNavigate(const GenericsScreen(), 'Generics'); break;
          case 'Brands':    onNavigate(const BrandsScreen(), 'Brands');     break;
          case 'Companies': onNavigate(const CompaniesScreen(), 'Companies'); break;
        }
      },
    );
  }

  PopupMenuItem<String> _menuItem(IconData icon, String label) => PopupMenuItem(
    value: label,
    height: 44,
    child: Row(children: [
      Icon(icon, size: 16, color: AppTheme.textSecondary),
      const SizedBox(width: 10),
      Text(label, style: AppTheme.navLabel.copyWith(color: AppTheme.textPrimary)),
    ]),
  );
}

class _NavButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _NavButton({required this.label, required this.icon, required this.isActive, required this.onTap});
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
                ? AppTheme.accent.withOpacity(0.15)
                : _hover ? AppTheme.surfaceHighlight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.isActive ? AppTheme.accent.withOpacity(0.5) : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 16,
                  color: widget.isActive ? AppTheme.accent : AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(widget.label,
                  style: AppTheme.navLabel.copyWith(
                      color: widget.isActive ? AppTheme.accent : AppTheme.textSecondary)),
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
  const _IconAction({required this.icon, required this.tooltip, required this.onTap});
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
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _hover ? AppTheme.surfaceHighlight : AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Icon(widget.icon, size: 16,
                color: _hover ? AppTheme.accent : AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}

// ─── SEARCH BAR AREA ─────────────────────────────────────────────────────────

class _SearchBarArea extends StatelessWidget {
  final Function(Widget, String) onNavigate;
  const _SearchBarArea({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        border: Border(bottom: BorderSide(color: AppTheme.divider.withOpacity(0.5))),
      ),
      child: GlobalSearchBar(onNavigate: onNavigate),
    );
  }
}

// ─── WELCOME VIEW ─────────────────────────────────────────────────────────────

class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accent, AppTheme.accentDim],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 24, spreadRadius: 4),
              ],
            ),
            child: const Icon(Icons.medication_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          Text('Drug Information Management System', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text(
            'Search for medicines above, or use the navigation bar to browse.',
            style: AppTheme.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Obx(() {
            final brandCtrl = Get.find<DrugBrandCtrl>();
            final genericCtrl = Get.find<GenericCtrl>();
            final companyCtrl = Get.find<CompanyCtrl>();
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatCard(Icons.science_outlined, 'Generics',
                    genericCtrl.genericList.length.toString(), AppTheme.accent),
                const SizedBox(width: 16),
                _StatCard(Icons.local_pharmacy_outlined, 'Brands',
                    brandCtrl.drugBrandList.length.toString(), AppTheme.accentGreen),
                const SizedBox(width: 16),
                _StatCard(Icons.business_outlined, 'Companies',
                    companyCtrl.companyList.length.toString(), AppTheme.accentAmber),
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
  const _StatCard(this.icon, this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(count, style: AppTheme.headingMedium.copyWith(color: color)),
          Text(label, style: AppTheme.bodySecondary.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
