import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/indication_ctrl.dart';
import '../../controller/indication_gen_ind_ctrl.dart';
import '../../controller/generic_ctrl.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../controller/company_ctrl.dart';
import '../../controller/theme_ctrl.dart';
import '../../models/indication/indication_model.dart';
import '../../models/generic/generic_details_model.dart';
import '../../models/brand/drug_brand_model.dart';
import 'app_theme.dart';
import 'brand_detail_screen.dart';

class IndicationScreen extends StatefulWidget {
  const IndicationScreen({Key? key}) : super(key: key);
  @override
  State<IndicationScreen> createState() => _IndicationScreenState();
}

class _IndicationScreenState extends State<IndicationScreen> {
  final IndicationCtrl _indCtrl = Get.find<IndicationCtrl>();
  final ThemeCtrl _themeCtrl = Get.find<ThemeCtrl>();
  final IndicationGenIndCtrl _indGenCtrl = Get.find<IndicationGenIndCtrl>();
  final GenericCtrl _genericCtrl = Get.find<GenericCtrl>();
  
  final TextEditingController _searchCtrl = TextEditingController();

  IndicationModel? _selectedIndication;
  GenericDetailsModel? _selectedGeneric;

  @override
  void initState() {
    super.initState();
    _indCtrl.searchIndications('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openBrandDetail(DrugBrandModel brand, ThemeDefinition theme, double fss) {
    showDialog(
      context: context,
      builder: (_) => BrandDetailModal(brand: brand, theme: theme, fss: fss),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeCtrl.currentTheme;
    final fontSizeScale = _themeCtrl.fontSizeScale;

    return Row(
      children: [
        // ── Left: Indication list ──────────────────────────────────────────
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border(right: BorderSide(color: theme.divider)),
          ),
          child: Column(
            children: [
              _PanelHeader(
                title: 'Indications',
                icon: Icons.health_and_safety_outlined,
                theme: theme,
                fontSizeScale: fontSizeScale,
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SearchInput(
                  controller: _searchCtrl,
                  hint: 'Search indications...',
                  onChanged: (q) {
                    _indCtrl.searchIndications(q);
                  },
                  fontSizeScale: fontSizeScale,
                  accentColor: theme.accent,
                ),
              ),
              Obx(() {
                final list = _indCtrl.filteredIndicationList;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${list.length} indications',
                      style: TextStyle(
                        fontSize: 11 * fontSizeScale,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                );
              }),
              Expanded(
                child: Obx(() {
                  final list = _indCtrl.filteredIndicationList;
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'No indications found',
                        style: TextStyle(
                          fontSize: 12 * fontSizeScale,
                          color: theme.textMuted,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final ind = list[i];
                      return _IndicationItem(
                        indication: ind,
                        isSelected: _selectedIndication?.id == ind.id,
                        onTap: () => setState(() {
                          _selectedIndication = ind;
                          _selectedGeneric = null;
                        }),
                        theme: theme,
                        fontSizeScale: fontSizeScale,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),

        // ── Middle: Generics for selected indication ───────────────────────
        if (_selectedIndication != null)
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(right: BorderSide(color: theme.divider)),
            ),
            child: _GenericsForIndication(
              indication: _selectedIndication!,
              onGenericTap: (g) => setState(() => _selectedGeneric = g),
              selectedGenericId: _selectedGeneric?.generic_id,
              theme: theme,
              fontSizeScale: fontSizeScale,
              indGenCtrl: _indGenCtrl,
              genericCtrl: _genericCtrl,
            ),
          ),

        // ── Right: Brands ──────────────────────────────────────────────────
        Expanded(
          child: _selectedGeneric != null
              ? _BrandsPanel(
            generic: _selectedGeneric!,
            theme: theme,
            fontSizeScale: fontSizeScale,
            onBrandTap: (b) => _openBrandDetail(b, theme, fontSizeScale),
          )
              : _selectedIndication != null
              ? _EmptyHint(
            icon: Icons.science_outlined,
            message: 'Select a generic to view brands',
            theme: theme,
            fontSizeScale: fontSizeScale,
          )
              : _EmptyHint(
            icon: Icons.health_and_safety_outlined,
            message: 'Select an indication from the list',
            theme: theme,
            fontSizeScale: fontSizeScale,
          ),
        ),
      ],
    );
  }
}

// ─── Indication list item ─────────────────────────────────────────────────────

class _IndicationItem extends StatefulWidget {
  final IndicationModel indication;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _IndicationItem({
    required this.indication,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_IndicationItem> createState() => _IndicationItemState();
}

class _IndicationItemState extends State<_IndicationItem> {
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
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.theme.accent.withOpacity(0.12)
                : _hover ? widget.theme.surfaceHighlight : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: widget.theme.divider.withOpacity(0.4)),
              left: BorderSide(
                color: widget.isSelected ? widget.theme.accent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            widget.indication.name,
            style: TextStyle(
              fontSize: 13 * widget.fontSizeScale,
              color: widget.isSelected ? widget.theme.accent : widget.theme.textSecondary,
              fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Generics panel for a selected indication ─────────────────────────────────

class _GenericsForIndication extends StatelessWidget {
  final IndicationModel indication;
  final Function(GenericDetailsModel) onGenericTap;
  final int? selectedGenericId;
  final ThemeDefinition theme;
  final double fontSizeScale;
  final IndicationGenIndCtrl indGenCtrl;
  final GenericCtrl genericCtrl;

  const _GenericsForIndication({
    required this.indication,
    required this.onGenericTap,
    this.selectedGenericId,
    required this.theme,
    required this.fontSizeScale,
    required this.indGenCtrl,
    required this.genericCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rawIds = indGenCtrl.getGenericIdsByIndication(indication.id);
      final genericIds = rawIds.map((e) => e.toString()).toSet();
      
      final generics = genericCtrl.genericList
          .where((g) => genericIds.contains(g.generic_id.toString()))
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.divider)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  size: 14 * fontSizeScale,
                  color: AppTheme.accentAmber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    indication.name,
                    style: TextStyle(
                      fontSize: 14 * fontSizeScale,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${generics.length} generics',
              style: TextStyle(
                fontSize: 11 * fontSizeScale,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          if (generics.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No generics linked to this indication',
                  style: TextStyle(
                    fontSize: 12 * fontSizeScale,
                    color: theme.textMuted,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: generics.length,
                itemBuilder: (_, i) {
                  final g = generics[i];
                  return _GenericRowItem(
                    generic: g,
                    isSelected: selectedGenericId?.toString() == g.generic_id.toString(),
                    onTap: () => onGenericTap(g),
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                  );
                },
              ),
            ),
        ],
      );
    });
  }
}

class _GenericRowItem extends StatefulWidget {
  final GenericDetailsModel generic;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _GenericRowItem({
    required this.generic,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_GenericRowItem> createState() => _GenericRowItemState();
}

class _GenericRowItemState extends State<_GenericRowItem> {
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
          duration: const Duration(milliseconds: 120),
          color: widget.isSelected
              ? AppTheme.accentAmber.withOpacity(0.1)
              : _hover ? widget.theme.surfaceHighlight : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.isSelected ? AppTheme.accentAmber : widget.theme.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.generic.generic_name,
                  style: TextStyle(
                    fontSize: 13 * widget.fontSizeScale,
                    color: widget.isSelected ? AppTheme.accentAmber : widget.theme.textSecondary,
                    fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Brands panel ─────────────────────────────────────────────────────────────

class _BrandsPanel extends StatefulWidget {
  final GenericDetailsModel generic;
  final ThemeDefinition theme;
  final double fontSizeScale;
  final Function(DrugBrandModel) onBrandTap;

  const _BrandsPanel({
    required this.generic,
    required this.theme,
    required this.fontSizeScale,
    required this.onBrandTap,
  });

  @override
  State<_BrandsPanel> createState() => _BrandsPanelState();
}

class _BrandsPanelState extends State<_BrandsPanel> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _filterCompanyId;

  @override
  void didUpdateWidget(_BrandsPanel old) {
    super.didUpdateWidget(old);
    if (old.generic.generic_id != widget.generic.generic_id) {
      _filterCompanyId = null;
      _searchQuery = '';
      _searchCtrl.clear();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DrugBrandModel> _getFilteredBrands(List<DrugBrandModel> all) {
    var result = all;
    if (_searchQuery.isNotEmpty) {
      result = result.where((b) =>
      (b.brand_name.toLowerCase().contains(_searchQuery)) ||
          (b.strength != null && b.strength!.toLowerCase().contains(_searchQuery)) ||
          (b.form != null && b.form!.toLowerCase().contains(_searchQuery))
      ).toList();
    }
    if (_filterCompanyId != null) {
      result = result.where((b) => b.company_id.toString() == _filterCompanyId).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final brandCtrl = Get.find<DrugBrandCtrl>();
    final themeCtrl = Get.find<ThemeCtrl>();

    return Obx(() {
      final allBrands = brandCtrl.drugBrandList
          .where((b) => b.generic_id.toString() == widget.generic.generic_id.toString())
          .toList();

      final displayed = _getFilteredBrands(allBrands);
      final companyIds = allBrands
          .map((b) => b.company_id.toString())
          .toSet()
          .toList()
        ..sort();

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: widget.theme.surface,
              border: Border(bottom: BorderSide(color: widget.theme.divider)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.theme.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.science_outlined,
                    color: widget.theme.accent,
                    size: 20 * widget.fontSizeScale,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.generic.generic_name,
                        style: TextStyle(
                          fontSize: 16 * widget.fontSizeScale,
                          fontWeight: FontWeight.w700,
                          color: widget.theme.textPrimary,
                        ),
                      ),
                      Text(
                        '${allBrands.length} brands available',
                        style: TextStyle(
                          fontSize: 12 * widget.fontSizeScale,
                          color: widget.theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SearchInput(
                    controller: _searchCtrl,
                    hint: 'Search brands...',
                    onChanged: (q) => setState(() => _searchQuery = q.toLowerCase().trim()),
                    fontSizeScale: widget.fontSizeScale,
                    accentColor: widget.theme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SafeCompanyDropdown(
                    companyIds: companyIds,
                    selectedId: _filterCompanyId,
                    onChanged: (id) => setState(() => _filterCompanyId = id),
                    theme: widget.theme,
                    fontSizeScale: widget.fontSizeScale,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${displayed.length} brands shown',
                  style: TextStyle(
                    fontSize: 11 * widget.fontSizeScale,
                    fontWeight: FontWeight.w600,
                    color: widget.theme.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                if (_searchQuery.isNotEmpty || _filterCompanyId != null)
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _searchQuery = '';
                      _filterCompanyId = null;
                      _searchCtrl.clear();
                    }),
                    icon: const Icon(Icons.clear_all_rounded, size: 14),
                    label: const Text('Clear Filters', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(foregroundColor: widget.theme.accent),
                  ),
              ],
            ),
          ),
          Expanded(
            child: displayed.isEmpty
                ? _EmptyHint(
              icon: Icons.local_pharmacy_outlined,
              message: 'No brands match your search',
              theme: widget.theme,
              fontSizeScale: widget.fontSizeScale,
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: displayed.length,
              itemBuilder: (_, i) {
                final b = displayed[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _BrandListItem(
                    brand: b,
                    onTap: () => widget.onBrandTap(b),
                    theme: widget.theme,
                    fontSizeScale: widget.fontSizeScale,
                    showPrice: themeCtrl.showPriceInList.value,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _BrandListItem extends StatefulWidget {
  final DrugBrandModel brand;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;
  final bool showPrice;

  const _BrandListItem({
    required this.brand,
    required this.onTap,
    required this.theme,
    required this.fontSizeScale,
    required this.showPrice,
  });

  @override
  State<_BrandListItem> createState() => _BrandListItemState();
}

class _BrandListItemState extends State<_BrandListItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final companyCtrl = Get.find<CompanyCtrl>();
    final company = companyCtrl.getCompanyById(widget.brand.company_id);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hover ? widget.theme.accent.withOpacity(0.08) : widget.theme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hover ? widget.theme.accent.withOpacity(0.3) : widget.theme.divider,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38 * widget.fontSizeScale,
                height: 38 * widget.fontSizeScale,
                decoration: BoxDecoration(
                  color: widget.theme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_pharmacy_outlined,
                  size: 18 * widget.fontSizeScale,
                  color: widget.theme.accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.brand.brand_name,
                      style: TextStyle(
                        fontSize: 14 * widget.fontSizeScale,
                        fontWeight: FontWeight.w600,
                        color: _hover ? widget.theme.accent : widget.theme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (widget.brand.strength != null)
                          Text(
                            widget.brand.strength!,
                            style: TextStyle(
                              fontSize: 11 * widget.fontSizeScale,
                              color: widget.theme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (widget.brand.strength != null && widget.brand.form != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text('•', style: TextStyle(color: widget.theme.textMuted)),
                          ),
                        if (widget.brand.form != null)
                          Text(
                            widget.brand.form!,
                            style: TextStyle(
                              fontSize: 11 * widget.fontSizeScale,
                              color: widget.theme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    if (company != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        company.company_name,
                        style: TextStyle(
                          fontSize: 10 * widget.fontSizeScale,
                          color: widget.theme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.brand.price != null && widget.showPrice)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.accentGreen.withOpacity(0.2)),
                  ),
                  child: Text(
                    '৳${widget.brand.price}',
                    style: TextStyle(
                      fontSize: 12 * widget.fontSizeScale,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20 * widget.fontSizeScale,
                color: _hover ? widget.theme.accent : widget.theme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Safe Company Dropdown ────────────────────────────────────────────────────

class _SafeCompanyDropdown extends StatelessWidget {
  final List<String> companyIds;
  final String? selectedId;
  final Function(String?) onChanged;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _SafeCompanyDropdown({
    required this.companyIds,
    this.selectedId,
    required this.onChanged,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    final companyCtrl = Get.find<CompanyCtrl>();
    final safeSelected = (selectedId != null && companyIds.contains(selectedId)) ? selectedId : null;

    return Container(
      height: 38 * fontSizeScale,
      padding: EdgeInsets.symmetric(horizontal: 12 * fontSizeScale),
      decoration: BoxDecoration(
        color: theme.bg,
        borderRadius: BorderRadius.circular(8 * fontSizeScale),
        border: Border.all(color: theme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: safeSelected,
          hint: Text(
            'Filter by company',
            style: TextStyle(
              fontSize: 12 * fontSizeScale,
              color: theme.textSecondary,
            ),
          ),
          isExpanded: true,
          dropdownColor: theme.surfaceElevated,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16 * fontSizeScale,
            color: theme.textSecondary,
          ),
          style: TextStyle(
            fontSize: 12 * fontSizeScale,
            color: theme.textPrimary,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All Companies',
                style: TextStyle(
                  fontSize: 12 * fontSizeScale,
                  color: theme.textPrimary,
                ),
              ),
            ),
            ...companyIds.map((id) {
              final c = companyCtrl.getCompanyById(int.parse(id));
              return DropdownMenuItem<String?>(
                value: id,
                child: Text(
                  c?.company_name ?? 'Company $id',
                  style: TextStyle(
                    fontSize: 12 * fontSizeScale,
                    color: theme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Empty hint ───────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String message;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _EmptyHint({
    required this.icon,
    required this.message,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: theme.textMuted,
            size: 44 * fontSizeScale,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 13 * fontSizeScale,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Panel header ─────────────────────────────────────────────────────────────

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
