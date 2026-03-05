import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/generic_ctrl.dart';
import '../../controller/theme_ctrl.dart';
import '../../models/generic/generic_details_model.dart';
import 'app_theme.dart';
import 'brand_detail_screen.dart';
import 'brands_screen.dart';

class GenericsScreen extends StatefulWidget {
  const GenericsScreen({Key? key}) : super(key: key);
  @override
  State<GenericsScreen> createState() => _GenericsScreenState();
}

class _GenericsScreenState extends State<GenericsScreen> {
  final GenericCtrl _ctrl = Get.put(GenericCtrl());
  final ThemeCtrl _themeCtrl = Get.put(ThemeCtrl());
  final TextEditingController _searchCtrl = TextEditingController();

  GenericDetailsModel? _selectedGeneric;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onGenericTap(GenericDetailsModel generic) {
    setState(() {
      _selectedGeneric = generic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = _themeCtrl.currentTheme;
      final fontSizeScale = _themeCtrl.fontSizeScale;
      final accentColor = theme.accent;

      return Row(
        children: [
          // Left: List panel
          Container(
            width: 360,
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(right: BorderSide(color: theme.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelHeader(
                  title: 'Generics',
                  icon: Icons.science_outlined,
                  theme: theme,
                  fontSizeScale: fontSizeScale,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SearchInput(
                    controller: _searchCtrl,
                    hint: 'Search generics...',
                    onChanged: _ctrl.searchGenerics,
                    fontSizeScale: fontSizeScale,
                    accentColor: accentColor,
                  ),
                ),
                Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    '${_ctrl.filteredGenericList.length} results',
                    style: TextStyle(
                      fontSize: 11 * fontSizeScale,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                )),
                Expanded(
                  child: Obx(() => ListView.builder(
                    itemCount: _ctrl.filteredGenericList.length,
                    itemBuilder: (_, i) {
                      final g = _ctrl.filteredGenericList[i];
                      return _GenericListItem(
                        generic: g,
                        isSelected: _selectedGeneric?.generic_id == g.generic_id,
                        onTap: () => _onGenericTap(g),
                        theme: theme,
                        fontSizeScale: fontSizeScale,
                      );
                    },
                  )),
                ),
              ],
            ),
          ),

          // Right: Detail panel
          Expanded(
            child: _selectedGeneric != null
                ? _buildGenericDetail(_selectedGeneric!, theme, fontSizeScale)
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.science_outlined,
                    color: theme.textMuted,
                    size: 48 * fontSizeScale,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select a generic to view details',
                    style: TextStyle(
                      fontSize: 13 * fontSizeScale,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildGenericDetail(GenericDetailsModel generic, ThemeDefinition theme, double fontSizeScale) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24 * fontSizeScale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Generic header
          Container(
            padding: EdgeInsets.all(20 * fontSizeScale),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(14 * fontSizeScale),
              border: Border.all(color: theme.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48 * fontSizeScale,
                      height: 48 * fontSizeScale,
                      decoration: BoxDecoration(
                        color: theme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12 * fontSizeScale),
                      ),
                      child: Icon(
                        Icons.science_outlined,
                        color: theme.accent,
                        size: 24 * fontSizeScale,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            generic.generic_name,
                            style: TextStyle(
                              fontSize: 24 * fontSizeScale,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (generic.pregnancy_category_id != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: _PregnancyBadge(
                                categoryId: generic.pregnancy_category_id!,
                                theme: theme,
                                fontSizeScale: fontSizeScale,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * fontSizeScale),
                Divider(color: theme.divider, height: 1),
                SizedBox(height: 16 * fontSizeScale),

                // View Brands Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16 * fontSizeScale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * fontSizeScale),
                      ),
                    ),
                    icon: Icon(Icons.local_pharmacy_outlined, size: 20 * fontSizeScale),
                    label: Text(
                      'View All Brands',
                      style: TextStyle(
                        fontSize: 16 * fontSizeScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: theme.surfaceElevated,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16 * fontSizeScale),
                              side: BorderSide(color: theme.divider),
                            ),
                            content: Container(
                              width: 900 * fontSizeScale,
                              height: 600 * fontSizeScale,
                              child: BrandsScreen(
                                initialGenericId: generic.generic_id,
                                isInDialog: true,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24 * fontSizeScale),

          // Generic details sections
          _buildInfoSection(
            'Indication',
            generic.indication,
            Icons.info_outline,
            theme,
            fontSizeScale,
          ),
          _buildInfoSection(
            'Dose',
            generic.dose,
            Icons.medication_outlined,
            theme,
            fontSizeScale,
          ),
          _buildInfoSection(
            'Adult Dose',
            generic.adult_dose,
            Icons.person_outline,
            theme,
            fontSizeScale,
          ),
          _buildInfoSection(
            'Child Dose',
            generic.child_dose,
            Icons.child_care_outlined,
            theme,
            fontSizeScale,
          ),
          _buildInfoSection(
            'Renal Dose',
            generic.renal_dose,
            Icons.water_drop_outlined,
            theme,
            fontSizeScale,
          ),
          _buildInfoSection(
            'Administration',
            generic.administration,
            Icons.route_outlined,
            theme,
            fontSizeScale,
          ),
          _buildInfoSection(
            'Side Effects',
            generic.side_effect,
            Icons.warning_amber_outlined,
            theme,
            fontSizeScale,
            color: AppTheme.accentAmber,
          ),
          _buildInfoSection(
            'Contraindications',
            generic.contra_indication,
            Icons.block_outlined,
            theme,
            fontSizeScale,
            color: AppTheme.accentRed,
          ),
          _buildInfoSection(
            'Precautions',
            generic.precaution,
            Icons.shield_outlined,
            theme,
            fontSizeScale,
            color: AppTheme.accentAmber,
          ),
          _buildInfoSection(
            'Mode of Action',
            generic.mode_of_action,
            Icons.biotech_outlined,
            theme,
            fontSizeScale,
          ),
          _buildInfoSection(
            'Interactions',
            generic.interaction,
            Icons.compare_arrows_outlined,
            theme,
            fontSizeScale,
            color: AppTheme.accentRed,
          ),
          _buildInfoSection(
            'Pregnancy Note',
            generic.pregnancy_category_note,
            Icons.pregnant_woman_outlined,
            theme,
            fontSizeScale,
            color: AppTheme.accentAmber,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
      String title,
      String? content,
      IconData icon,
      ThemeDefinition theme,
      double fontSizeScale, {
        Color? color,
      }) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 12 * fontSizeScale),
      padding: EdgeInsets.all(16 * fontSizeScale),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12 * fontSizeScale),
        border: Border.all(color: theme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16 * fontSizeScale,
                color: color ?? theme.accent,
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11 * fontSizeScale,
                  fontWeight: FontWeight.w600,
                  color: color ?? theme.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * fontSizeScale),
          Text(
            content,
            style: TextStyle(
              fontSize: 13 * fontSizeScale,
              color: theme.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenericListItem extends StatefulWidget {
  final GenericDetailsModel generic;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _GenericListItem({
    required this.generic,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_GenericListItem> createState() => _GenericListItemState();
}

class _GenericListItemState extends State<_GenericListItem> {
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
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.theme.accent.withOpacity(0.1)
                : _hover ? widget.theme.surfaceHighlight : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: widget.theme.divider.withOpacity(0.4)),
              left: BorderSide(
                color: widget.isSelected ? widget.theme.accent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 28 * widget.fontSizeScale,
                height: 28 * widget.fontSizeScale,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.theme.accent.withOpacity(0.2)
                      : widget.theme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6 * widget.fontSizeScale),
                ),
                child: Icon(
                  Icons.science_outlined,
                  size: 14 * widget.fontSizeScale,
                  color: widget.isSelected ? widget.theme.accent : widget.theme.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.generic.generic_name,
                      style: TextStyle(
                        fontSize: 13 * widget.fontSizeScale,
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: widget.isSelected ? widget.theme.accent : widget.theme.textPrimary,
                      ),
                    ),
                    if (widget.generic.pregnancy_category_id != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Pregnancy Cat: ${widget.generic.pregnancy_category_id}',
                          style: TextStyle(
                            fontSize: 10 * widget.fontSizeScale,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accentAmber,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18 * widget.fontSizeScale,
                color: widget.isSelected ? widget.theme.accent : widget.theme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PregnancyBadge extends StatelessWidget {
  final int categoryId;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _PregnancyBadge({
    required this.categoryId,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * fontSizeScale,
        vertical: 3 * fontSizeScale,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentAmber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4 * fontSizeScale),
        border: Border.all(color: AppTheme.accentAmber.withOpacity(0.4)),
      ),
      child: Text(
        'Pregnancy Category $categoryId',
        style: TextStyle(
          fontSize: 11 * fontSizeScale,
          fontWeight: FontWeight.w500,
          color: AppTheme.accentAmber,
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _PanelHeader({
    required this.title,
    required this.icon,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.divider)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16 * fontSizeScale,
            color: theme.accent,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14 * fontSizeScale,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}