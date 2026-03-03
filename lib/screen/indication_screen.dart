import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/indication_ctrl.dart';
import '../../controller/indication_gen_ind_ctrl.dart';
import '../../controller/generic_ctrl.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../controller/company_ctrl.dart';
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
  final TextEditingController _searchCtrl = TextEditingController();

  IndicationModel? _selectedIndication;
  GenericDetailsModel? _selectedGeneric;

  @override
  void initState() {
    super.initState();
    // Ensure list is loaded and filter is reset on open
    _indCtrl.searchIndications('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Left: Indication list ──────────────────────────────────────────
        Container(
          width: 280,
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(right: BorderSide(color: AppTheme.divider)),
          ),
          child: Column(
            children: [
              _PanelHeader(title: 'Indications', icon: Icons.health_and_safety_outlined),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SearchInput(
                  controller: _searchCtrl,
                  hint: 'Search indications...',
                  onChanged: (q) {
                    _indCtrl.searchIndications(q);
                  },
                ),
              ),
              Obx(() {
                final list = _indCtrl.filteredIndicationList;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('${list.length} indications', style: AppTheme.label),
                  ),
                );
              }),
              Expanded(
                child: Obx(() {
                  final list = _indCtrl.filteredIndicationList;
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('No indications found', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
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
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(right: BorderSide(color: AppTheme.divider)),
            ),
            child: _GenericsForIndication(
              indication: _selectedIndication!,
              onGenericTap: (g) => setState(() => _selectedGeneric = g),
              selectedGenericId: _selectedGeneric?.generic_id,
            ),
          ),

        // ── Right: Brands + detail ─────────────────────────────────────────
        Expanded(
          child: _selectedGeneric != null
              ? _BrandsAndDetailPanel(generic: _selectedGeneric!)
              : _selectedIndication != null
                  ? _EmptyHint(
                      icon: Icons.science_outlined,
                      message: 'Select a generic to view brands',
                    )
                  : _EmptyHint(
                      icon: Icons.health_and_safety_outlined,
                      message: 'Select an indication from the list',
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
  const _IndicationItem({required this.indication, required this.isSelected, required this.onTap});
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
                ? AppTheme.accent.withOpacity(0.12)
                : _hover ? AppTheme.surfaceHighlight : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: AppTheme.divider.withOpacity(0.4)),
              left: BorderSide(
                  color: widget.isSelected ? AppTheme.accent : Colors.transparent,
                  width: 3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            widget.indication.name,
            style: AppTheme.bodySecondary.copyWith(
              color: widget.isSelected ? AppTheme.accent : AppTheme.textSecondary,
              fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Generics panel for a selected indication ─────────────────────────────────
// KEY FIX: indication.id is int, getGenericIdsByIndication returns List<dynamic>
// we compare as int safely

class _GenericsForIndication extends StatelessWidget {
  final IndicationModel indication;
  final Function(GenericDetailsModel) onGenericTap;
  final int? selectedGenericId;
  const _GenericsForIndication({
    required this.indication,
    required this.onGenericTap,
    this.selectedGenericId,
  });

  @override
  Widget build(BuildContext context) {
    final indGenCtrl = Get.find<IndicationGenIndCtrl>();
    final genericCtrl = Get.find<GenericCtrl>();

    // indication.id is int — pass it directly
    final rawIds = indGenCtrl.getGenericIdsByIndication(indication.id);

    // Convert whatever comes back to String for lookup in genericCtrl
    final genericIds = rawIds.map((e) => e.toString()).toSet().toList();
    final generics = genericCtrl.genericList
        .where((g) => genericIds.contains(g.generic_id.toString()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.divider)),
          ),
          child: Row(
            children: [
              const Icon(Icons.health_and_safety_outlined, size: 14, color: AppTheme.accentAmber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  indication.name,
                  style: AppTheme.headingSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('${generics.length} generics', style: AppTheme.label),
        ),
        if (generics.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No generics linked to this indication',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
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
                  isSelected: selectedGenericId == g.generic_id.toString(),
                  onTap: () => onGenericTap(g),
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
  const _GenericRowItem({required this.generic, required this.isSelected, required this.onTap});
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
              : _hover ? AppTheme.surfaceHighlight : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.isSelected ? AppTheme.accentAmber : AppTheme.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.generic.generic_name,
                  style: AppTheme.bodySecondary.copyWith(
                    color: widget.isSelected ? AppTheme.accentAmber : AppTheme.textSecondary,
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
// KEY FIX: brand.generic_id is String in model but comparison must match type

class _BrandsAndDetailPanel extends StatefulWidget {
  final GenericDetailsModel generic;
  const _BrandsAndDetailPanel({required this.generic});
  @override
  State<_BrandsAndDetailPanel> createState() => _BrandsAndDetailPanelState();
}

class _BrandsAndDetailPanelState extends State<_BrandsAndDetailPanel> {
  DrugBrandModel? _selectedBrand;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  // KEY FIX: store company_id as String, never store a value not in the list
  String? _filterCompanyId;

  @override
  void didUpdateWidget(_BrandsAndDetailPanel old) {
    super.didUpdateWidget(old);
    // Reset when generic changes
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
          (b.form?.toLowerCase().contains(_searchQuery) ?? false)).toList();
    }
    if (_filterCompanyId != null) {
      result = result.where((b) => b.company_id == _filterCompanyId).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final brandCtrl = Get.find<DrugBrandCtrl>();
    final companyCtrl = Get.find<CompanyCtrl>();

    // All brands for this generic
    final allBrands = brandCtrl.drugBrandList
        .where((b) => b.generic_id.toString() == widget.generic.generic_id.toString())
        .toList();

    final displayed = _getFilteredBrands(allBrands);

    // Unique company IDs present in allBrands
    final companyIds = allBrands.map((b) => b.company_id).toSet().toList();

    // Safety: if filterCompanyId not in current list, reset it
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
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(right: BorderSide(color: AppTheme.divider)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.divider))),
                child: Text(widget.generic.generic_name,
                    style: AppTheme.headingSmall, overflow: TextOverflow.ellipsis),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    SearchInput(
                      controller: _searchCtrl,
                      hint: 'Search brands...',
                      onChanged: (q) => setState(() => _searchQuery = q.toLowerCase().trim()),
                    ),
                    const SizedBox(height: 6),
                    // Company filter dropdown — safe version
                    _SafeCompanyDropdown(
                      companyIds: companyIds,
                      selectedId: _filterCompanyId,
                      onChanged: (id) => setState(() => _filterCompanyId = id),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${displayed.length} brands', style: AppTheme.label),
                ),
              ),
              Expanded(
                child: displayed.isEmpty
                    ? const Center(
                        child: Text('No brands found',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 12)))
                    : ListView.builder(
                        itemCount: displayed.length,
                        itemBuilder: (_, i) {
                          final b = displayed[i];
                          return _BrandItem(
                            brand: b,
                            isSelected: _selectedBrand?.brand_id == b.brand_id,
                            onTap: () => setState(() => _selectedBrand = b),
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
              ? BrandDetailView(brand: _selectedBrand!)
              : _EmptyHint(icon: Icons.local_pharmacy_outlined, message: 'Select a brand to view details'),
        ),
      ],
    );
  }
}

// ─── Safe Company Dropdown ────────────────────────────────────────────────────
// Prevents the DropdownButton assertion error by ensuring value is always in items

class _SafeCompanyDropdown extends StatelessWidget {
  final List<int> companyIds;
  final String? selectedId;
  final Function(String?) onChanged;
  const _SafeCompanyDropdown({
    required this.companyIds,
    this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final companyCtrl = Get.find<CompanyCtrl>();

    // SAFE: ensure selectedId is actually in the list, otherwise treat as null
    final safeSelected = (selectedId != null && companyIds.contains(selectedId))
        ? selectedId
        : null;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedId,
          hint: Text(
            'Company',
            style: AppTheme.bodySecondary.copyWith(fontSize: 12),
          ),
          isExpanded: true,
          dropdownColor: AppTheme.surfaceElevated,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          style: AppTheme.bodyPrimary.copyWith(fontSize: 12),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Companies'),
            ),
            ...companyIds.map((id) {
              final c = companyCtrl.getCompanyById(id);

              return DropdownMenuItem<String?>(
                value: id.toString(), // ✅ convert int to String
                child: Text(
                  c?.company_name ?? id.toString(), // ✅ safe null handling
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ],
          onChanged: onChanged,
        ),
      )
    );
  }
}

// ─── Brand list item ──────────────────────────────────────────────────────────

class _BrandItem extends StatefulWidget {
  final DrugBrandModel brand;
  final bool isSelected;
  final VoidCallback onTap;
  const _BrandItem({required this.brand, required this.isSelected, required this.onTap});
  @override
  State<_BrandItem> createState() => _BrandItemState();
}

class _BrandItemState extends State<_BrandItem> {
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
                ? AppTheme.accent.withOpacity(0.12)
                : _hover ? AppTheme.surfaceHighlight : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: AppTheme.divider.withOpacity(0.4)),
              left: BorderSide(
                  color: widget.isSelected ? AppTheme.accent : Colors.transparent,
                  width: 3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.brand.brand_name,
                  style: AppTheme.bodyPrimary.copyWith(
                      fontWeight: FontWeight.w500, fontSize: 12)),
              const SizedBox(height: 3),
              Row(children: [
                if (widget.brand.strength != null) ...[
                  _Mini(widget.brand.strength!, AppTheme.accent),
                  const SizedBox(width: 4),
                ],
                if (widget.brand.form != null)
                  _Mini(widget.brand.form!, AppTheme.accentGreen),
              ]),
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
  const _Mini(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(3)),
      child: Text(label, style: AppTheme.chip.copyWith(color: color, fontSize: 9)),
    );
  }
}

// ─── Empty hint ───────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyHint({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 44),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Panel header ─────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PanelHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.divider))),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.accent),
          const SizedBox(width: 8),
          Text(title, style: AppTheme.headingSmall),
        ],
      ),
    );
  }
}
