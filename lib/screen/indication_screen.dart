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
  final ThemeCtrl _themeCtrl = Get.put(ThemeCtrl());
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
              width: 280,
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
              ),
            ),

          // ── Right: Brands + detail ─────────────────────────────────────────
          Expanded(
            child: _selectedGeneric != null
                ? _BrandsAndDetailPanel(
              generic: _selectedGeneric!,
              theme: theme,
              fontSizeScale: fontSizeScale,
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
    });
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

  const _GenericsForIndication({
    required this.indication,
    required this.onGenericTap,
    this.selectedGenericId,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    final indGenCtrl = Get.find<IndicationGenIndCtrl>();
    final genericCtrl = Get.put(GenericCtrl());

    final rawIds = indGenCtrl.getGenericIdsByIndication(indication.id);
    final genericIds = rawIds.map((e) => e.toString()).toSet().toList();
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
                  isSelected: selectedGenericId == g.generic_id,
                  onTap: () => onGenericTap(g),
                  theme: theme,
                  fontSizeScale: fontSizeScale,
                );
              },
            ),
          ),
      ],
    );
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

// ─── Brands + detail panel ────────────────────────────────────────────────────

class _BrandsAndDetailPanel extends StatefulWidget {
  final GenericDetailsModel generic;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _BrandsAndDetailPanel({
    required this.generic,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_BrandsAndDetailPanel> createState() => _BrandsAndDetailPanelState();
}

class _BrandsAndDetailPanelState extends State<_BrandsAndDetailPanel> {
  DrugBrandModel? _selectedBrand;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _filterCompanyId;

  @override
  void didUpdateWidget(_BrandsAndDetailPanel old) {
    super.didUpdateWidget(old);
    if (old.generic.generic_id != widget.generic.generic_id) {
      _selectedBrand = null;
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
      b.brand_name.toLowerCase().contains(_searchQuery) ||
          (b.strength?.toLowerCase().contains(_searchQuery) ?? false) ||
          (b.form?.toLowerCase().contains(_searchQuery) ?? false)
      ).toList();
    }
    if (_filterCompanyId != null) {
      result = result.where((b) => b.company_id.toString() == _filterCompanyId).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final brandCtrl = Get.put(DrugBrandCtrl());
    final companyCtrl = Get.put(CompanyCtrl());
    final themeCtrl = Get.put(ThemeCtrl());

    final allBrands = brandCtrl.drugBrandList
        .where((b) => b.generic_id.toString() == widget.generic.generic_id.toString())
        .toList();

    final displayed = _getFilteredBrands(allBrands);
    final companyIds = allBrands
        .map((b) => b.company_id.toString())
        .toSet()
        .toList()
      ..sort();

    if (_filterCompanyId != null && !companyIds.contains(_filterCompanyId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _filterCompanyId = null);
      });
    }

    return Row(
      children: [
        // Brand list panel
        Container(
          width: 260,
          decoration: BoxDecoration(
            color: widget.theme.surface,
            border: Border(right: BorderSide(color: widget.theme.divider)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: widget.theme.divider)),
                ),
                child: Text(
                  widget.generic.generic_name,
                  style: TextStyle(
                    fontSize: 14 * widget.fontSizeScale,
                    fontWeight: FontWeight.w600,
                    color: widget.theme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    SearchInput(
                      controller: _searchCtrl,
                      hint: 'Search brands...',
                      onChanged: (q) => setState(() => _searchQuery = q.toLowerCase().trim()),
                      fontSizeScale: widget.fontSizeScale,
                      accentColor: widget.theme.accent,
                    ),
                    const SizedBox(height: 6),
                    _SafeCompanyDropdown(
                      companyIds: companyIds,
                      selectedId: _filterCompanyId,
                      onChanged: (id) => setState(() => _filterCompanyId = id),
                      theme: widget.theme,
                      fontSizeScale: widget.fontSizeScale,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${displayed.length} brands',
                    style: TextStyle(
                      fontSize: 11 * widget.fontSizeScale,
                      fontWeight: FontWeight.w600,
                      color: widget.theme.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: displayed.isEmpty
                    ? Center(
                  child: Text(
                    'No brands found',
                    style: TextStyle(
                      fontSize: 12 * widget.fontSizeScale,
                      color: widget.theme.textMuted,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: displayed.length,
                  itemBuilder: (_, i) {
                    final b = displayed[i];
                    return _BrandItem(
                      brand: b,
                      isSelected: _selectedBrand?.brand_id == b.brand_id,
                      onTap: () => setState(() => _selectedBrand = b),
                      theme: widget.theme,
                      fontSizeScale: widget.fontSizeScale,
                      showPrice: themeCtrl.showPriceInList.value,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Detail panel
        Expanded(
          child: _selectedBrand != null
              ? BrandDetailView(
            brand: _selectedBrand!,
            accentColor: widget.theme.accent,
            fontSizeScale: widget.fontSizeScale,
          )
              : _EmptyHint(
            icon: Icons.local_pharmacy_outlined,
            message: 'Select a brand to view details',
            theme: widget.theme,
            fontSizeScale: widget.fontSizeScale,
          ),
        ),
      ],
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
    final companyCtrl = Get.put(CompanyCtrl());
    final safeSelected = (selectedId != null && companyIds.contains(selectedId)) ? selectedId : null;

    return Container(
      height: 34 * fontSizeScale,
      padding: EdgeInsets.symmetric(horizontal: 10 * fontSizeScale),
      decoration: BoxDecoration(
        color: theme.bg,
        borderRadius: BorderRadius.circular(8 * fontSizeScale),
        border: Border.all(color: theme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: safeSelected,
          hint: Text(
            'Company',
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
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Companies'),
            ),
            ...companyIds.map((id) {
              final c = companyCtrl.getCompanyById(int.parse(id));
              return DropdownMenuItem<String?>(
                value: id,
                child: Text(
                  c?.company_name ?? 'Company $id',
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

// ─── Brand list item ──────────────────────────────────────────────────────────

class _BrandItem extends StatefulWidget {
  final DrugBrandModel brand;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;
  final bool showPrice;

  const _BrandItem({
    required this.brand,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.fontSizeScale,
    required this.showPrice,
  });

  @override
  State<_BrandItem> createState() => _BrandItemState();
}

class _BrandItemState extends State<_BrandItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.brand;

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.brand_name,
                      style: TextStyle(
                        fontSize: 13 * widget.fontSizeScale,
                        fontWeight: FontWeight.w600,
                        color: widget.theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(spacing: 5, runSpacing: 4, children: [
                      if (b.strength != null)
                        _Mini(
                          b.strength!,
                          widget.theme.accent,
                          widget.fontSizeScale,
                        ),
                      if (b.form != null)
                        _Mini(
                          b.form!,
                          AppTheme.accentGreen,
                          widget.fontSizeScale,
                        ),
                    ]),
                  ],
                ),
              ),
              if (b.price != null && widget.showPrice)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    '৳${b.price}',
                    style: TextStyle(
                      fontSize: 12 * widget.fontSizeScale,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGreen,
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

class _Mini extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSizeScale;

  const _Mini(this.label, this.color, this.fontSizeScale);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9 * fontSizeScale,
          fontWeight: FontWeight.w500,
          color: color,
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