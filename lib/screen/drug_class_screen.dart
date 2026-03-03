import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/systemic_class_ctrl.dart';
import '../../controller/therapeutic_class_ctrl.dart';
import '../../controller/therapeutic_generic_index_ctrl.dart';
import '../../controller/generic_ctrl.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../controller/company_ctrl.dart';
import '../../models/systemic_class/systemic_class_model.dart';
import '../../models/therapeutic_class/therapeutic_class_model.dart';
import '../../models/generic/generic_details_model.dart';
import '../../models/brand/drug_brand_model.dart';
import 'app_theme.dart';
import 'brand_detail_screen.dart';

class DrugClassScreen extends StatefulWidget {
  const DrugClassScreen({Key? key}) : super(key: key);
  @override
  State<DrugClassScreen> createState() => _DrugClassScreenState();
}

class _DrugClassScreenState extends State<DrugClassScreen> {
  final SystemicClassCtrl _sysCtrl = Get.find<SystemicClassCtrl>();
  final TherapeuticClassCtrl _therapCtrl = Get.find<TherapeuticClassCtrl>();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  TherapeuticClassModel? _selectedTherapeutic;
  GenericDetailsModel? _selectedGeneric;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Left: Drug class tree ──────────────────────────────────────────
        Container(
          width: 280,
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(right: BorderSide(color: AppTheme.divider)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelHeader(title: 'Drug Classes', icon: Icons.category_outlined),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SearchInput(
                  controller: _searchCtrl,
                  hint: 'Search drug classes...',
                  onChanged: (q) => setState(() => _searchQuery = q.toLowerCase().trim()),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final therapeutics = _therapCtrl.therapeuticClassList;
                  final systemics = _sysCtrl.systemicClassList;

                  if (therapeutics.isEmpty && systemics.isEmpty) {
                    return const Center(
                      child: Text('No drug classes loaded',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    );
                  }

                  // Group therapeutics by systemic_class_id (int or String)
                  final Map<String, List<TherapeuticClassModel>> grouped = {};
                  for (final t in therapeutics) {
                    final key = t.systemic_class_id?.toString() ?? '0';
                    grouped.putIfAbsent(key, () => []).add(t);
                  }

                  // Root systemics: parent_id is null or 0
                  final roots = systemics
                      .where((s) =>
                          s.parent_id == null ||
                          s.parent_id == 0 ||
                          s.parent_id.toString() == '0')
                      .toList();

                  // If no systemic roots, show therapeutics directly
                  if (roots.isEmpty) {
                    final allTherapeutics = _searchQuery.isEmpty
                        ? therapeutics
                        : therapeutics
                            .where((t) =>
                                t.name.toLowerCase().contains(_searchQuery))
                            .toList();
                    return ListView.builder(
                      itemCount: allTherapeutics.length,
                      itemBuilder: (_, i) => _TherapeuticItem(
                        therapeutic: allTherapeutics[i],
                        isSelected: _selectedTherapeutic?.id == allTherapeutics[i].id,
                        onTap: () => setState(() {
                          _selectedTherapeutic = allTherapeutics[i];
                          _selectedGeneric = null;
                        }),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: roots.length,
                    itemBuilder: (_, i) => _SystemicClassNode(
                      systemic: roots[i],
                      allSystemic: systemics,
                      therapeuticsGrouped: grouped,
                      searchQuery: _searchQuery,
                      onTherapeuticTap: (t) => setState(() {
                        _selectedTherapeutic = t;
                        _selectedGeneric = null;
                      }),
                      selectedTherapeuticId: _selectedTherapeutic?.id?.toString(),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // ── Middle: Generics for selected therapeutic class ────────────────
        if (_selectedTherapeutic != null)
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(right: BorderSide(color: AppTheme.divider)),
            ),
            child: _GenericsForTherapeutic(
              therapeutic: _selectedTherapeutic!,
              onGenericTap: (g) => setState(() => _selectedGeneric = g),
              selectedGenericId: _selectedGeneric?.generic_id?.toString(),
            ),
          ),

        // ── Right: Brands for selected generic ────────────────────────────
        Expanded(
          child: _selectedGeneric != null
              ? _BrandsForGenericPanel(generic: _selectedGeneric!)
              : _selectedTherapeutic != null
                  ? const _EmptyHint(
                      icon: Icons.science_outlined,
                      message: 'Select a generic to view brands',
                    )
                  : const _EmptyHint(
                      icon: Icons.category_outlined,
                      message: 'Select a drug class from the list',
                    ),
        ),
      ],
    );
  }
}

// ─── Systemic class tree node (recursive) ────────────────────────────────────

class _SystemicClassNode extends StatefulWidget {
  final SystemicClassModel systemic;
  final List<SystemicClassModel> allSystemic;
  final Map<String, List<TherapeuticClassModel>> therapeuticsGrouped;
  final String searchQuery;
  final Function(TherapeuticClassModel) onTherapeuticTap;
  final String? selectedTherapeuticId;

  const _SystemicClassNode({
    required this.systemic,
    required this.allSystemic,
    required this.therapeuticsGrouped,
    required this.searchQuery,
    required this.onTherapeuticTap,
    this.selectedTherapeuticId,
  });

  @override
  State<_SystemicClassNode> createState() => _SystemicClassNodeState();
}

class _SystemicClassNodeState extends State<_SystemicClassNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // Child systemic classes
    final children = widget.allSystemic
        .where((s) =>
            s.parent_id != null &&
            s.parent_id.toString() == widget.systemic.id?.toString())
        .toList();

    // Therapeutic classes belonging to this systemic class
    final therapeutics =
        widget.therapeuticsGrouped[widget.systemic.id?.toString() ?? ''] ?? [];
    final filteredTherapeutics = widget.searchQuery.isEmpty
        ? therapeutics
        : therapeutics
            .where((t) => t.name.toLowerCase().contains(widget.searchQuery))
            .toList();

    final hasContent = children.isNotEmpty || filteredTherapeutics.isNotEmpty;
    if (!hasContent && widget.searchQuery.isNotEmpty) return const SizedBox.shrink();

    // Auto-expand when searching
    if (widget.searchQuery.isNotEmpty && !_expanded && filteredTherapeutics.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _expanded = true);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.divider.withOpacity(0.4))),
            ),
            child: Row(
              children: [
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  size: 16,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.systemic.name,
                    style: AppTheme.bodyPrimary.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (filteredTherapeutics.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${filteredTherapeutics.length}',
                        style: AppTheme.label.copyWith(color: AppTheme.accent)),
                  ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          // Recursive child systemic classes
          ...children.map((child) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _SystemicClassNode(
                  systemic: child,
                  allSystemic: widget.allSystemic,
                  therapeuticsGrouped: widget.therapeuticsGrouped,
                  searchQuery: widget.searchQuery,
                  onTherapeuticTap: widget.onTherapeuticTap,
                  selectedTherapeuticId: widget.selectedTherapeuticId,
                ),
              )),
          // Therapeutic class items
          ...filteredTherapeutics.map((t) => _TherapeuticItem(
                therapeutic: t,
                isSelected:
                    widget.selectedTherapeuticId == t.id?.toString(),
                onTap: () => widget.onTherapeuticTap(t),
              )),
        ],
      ],
    );
  }
}

class _TherapeuticItem extends StatefulWidget {
  final TherapeuticClassModel therapeutic;
  final bool isSelected;
  final VoidCallback onTap;
  const _TherapeuticItem(
      {required this.therapeutic, required this.isSelected, required this.onTap});
  @override
  State<_TherapeuticItem> createState() => _TherapeuticItemState();
}

class _TherapeuticItemState extends State<_TherapeuticItem> {
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
              ? AppTheme.accent.withOpacity(0.12)
              : _hover ? AppTheme.surfaceHighlight : Colors.transparent,
          padding: const EdgeInsets.only(left: 36, right: 14, top: 9, bottom: 9),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.isSelected ? AppTheme.accent : AppTheme.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.therapeutic.name,
                  style: AppTheme.bodySecondary.copyWith(
                    color: widget.isSelected
                        ? AppTheme.accent
                        : AppTheme.textSecondary,
                    fontWeight:
                        widget.isSelected ? FontWeight.w500 : FontWeight.w400,
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

// ─── Generics panel ───────────────────────────────────────────────────────────
// KEY FIX: therapeutic.id is int, generic_id is String or int — compare as String

class _GenericsForTherapeutic extends StatelessWidget {
  final TherapeuticClassModel therapeutic;
  final Function(GenericDetailsModel) onGenericTap;
  final String? selectedGenericId;
  const _GenericsForTherapeutic({
    required this.therapeutic,
    required this.onGenericTap,
    this.selectedGenericId,
  });

  @override
  Widget build(BuildContext context) {
    final tgiCtrl = Get.find<TherapeuticGenIndCtrl>();
    final genericCtrl = Get.find<GenericCtrl>();

    // therapeutic.id is int — pass directly
    final rawIds = tgiCtrl.getGenericIdsByTherapeuticClass(therapeutic.id);
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
              border: Border(bottom: BorderSide(color: AppTheme.divider))),
          child: Row(
            children: [
              const Icon(Icons.science_outlined, size: 14, color: AppTheme.accentGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(therapeutic.name,
                    style: AppTheme.headingSmall, overflow: TextOverflow.ellipsis),
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
              child: Text('No generics in this class',
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
  const _GenericRowItem(
      {required this.generic, required this.isSelected, required this.onTap});
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
              ? AppTheme.accentGreen.withOpacity(0.1)
              : _hover ? AppTheme.surfaceHighlight : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.isSelected ? AppTheme.accentGreen : AppTheme.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.generic.generic_name,
                  style: AppTheme.bodySecondary.copyWith(
                    color: widget.isSelected
                        ? AppTheme.accentGreen
                        : AppTheme.textSecondary,
                    fontWeight:
                        widget.isSelected ? FontWeight.w500 : FontWeight.w400,
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

class _BrandsForGenericPanel extends StatefulWidget {
  final GenericDetailsModel generic;
  const _BrandsForGenericPanel({required this.generic});
  @override
  State<_BrandsForGenericPanel> createState() => _BrandsForGenericPanelState();
}

class _BrandsForGenericPanelState extends State<_BrandsForGenericPanel> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _filterCompanyId;
  DrugBrandModel? _selectedBrand;

  @override
  void didUpdateWidget(_BrandsForGenericPanel old) {
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

  @override
  Widget build(BuildContext context) {
    final brandCtrl = Get.find<DrugBrandCtrl>();
    final companyCtrl = Get.find<CompanyCtrl>();

    // KEY FIX: compare as String to avoid type mismatch
    final allBrands = brandCtrl.drugBrandList
        .where((b) => b.generic_id.toString() == widget.generic.generic_id.toString())
        .toList();

    var displayed = allBrands;
    if (_searchQuery.isNotEmpty) {
      displayed = displayed
          .where((b) =>
              b.brand_name.toLowerCase().contains(_searchQuery) ||
              (b.strength?.toLowerCase().contains(_searchQuery) ?? false) ||
              (b.form?.toLowerCase().contains(_searchQuery) ?? false))
          .toList();
    }
    if (_filterCompanyId != null) {
      displayed = displayed.where((b) => b.company_id == _filterCompanyId).toList();
    }

    final companyIds = allBrands.map((b) => b.company_id).toSet().toList();

    // Safety reset
    if (_filterCompanyId != null && !companyIds.contains(_filterCompanyId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _filterCompanyId = null);
      });
    }

    return Container(
      color: AppTheme.bgDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(bottom: BorderSide(color: AppTheme.divider)),
            ),
            child: Row(
              children: [
                const Icon(Icons.science_outlined, size: 16, color: AppTheme.accentGreen),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(widget.generic.generic_name,
                        style: AppTheme.headingSmall)),
                Text('${displayed.length} brands', style: AppTheme.label),
              ],
            ),
          ),
          // Search + filter
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: SearchInput(
                    controller: _searchCtrl,
                    hint: 'Search brands...',
                    onChanged: (q) =>
                        setState(() => _searchQuery = q.toLowerCase().trim()),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 200,
                  child: _SafeCompanyDropdown(
                    companyIds: companyIds,
                    selectedId: _filterCompanyId,
                    onChanged: (id) => setState(() => _filterCompanyId = id),
                  ),
                ),
              ],
            ),
          ),
          // Brand cards + detail split view
          Expanded(
            child: Row(
              children: [
                // Brand list
                SizedBox(
                  width: 300,
                  child: displayed.isEmpty
                      ? const Center(
                          child: Text('No brands found',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 12)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: displayed.length,
                          itemBuilder: (_, i) {
                            final b = displayed[i];
                            final company = companyCtrl.getCompanyById(b.company_id);
                            return _BrandCard(
                              brand: b,
                              companyName: company?.company_name,
                              isSelected: _selectedBrand?.brand_id == b.brand_id,
                              onTap: () => setState(() => _selectedBrand = b),
                            );
                          },
                        ),
                ),
                // Detail view
                Expanded(
                  child: _selectedBrand != null
                      ? BrandDetailView(brand: _selectedBrand!)
                      : const _EmptyHint(
                          icon: Icons.local_pharmacy_outlined,
                          message: 'Select a brand to view details',
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandCard extends StatefulWidget {
  final DrugBrandModel brand;
  final String? companyName;
  final bool isSelected;
  final VoidCallback onTap;
  const _BrandCard(
      {required this.brand, this.companyName, required this.isSelected, required this.onTap});
  @override
  State<_BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<_BrandCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.accent.withOpacity(0.1)
                : _hover ? AppTheme.surfaceHighlight : AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.accent.withOpacity(0.5)
                  : AppTheme.divider,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.brand.brand_name,
                  style: AppTheme.bodyPrimary.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(children: [
                if (widget.brand.strength != null) ...[
                  _MiniChip(widget.brand.strength!, AppTheme.accent),
                  const SizedBox(width: 6),
                ],
                if (widget.brand.form != null)
                  _MiniChip(widget.brand.form!, AppTheme.accentGreen),
                const Spacer(),
                if (widget.brand.price != null)
                  Text('৳${widget.brand.price}',
                      style: AppTheme.bodySecondary.copyWith(fontSize: 11)),
              ]),
              if (widget.companyName != null) ...[
                const SizedBox(height: 3),
                Text(widget.companyName!,
                    style: AppTheme.bodySecondary.copyWith(fontSize: 10),
                    overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: AppTheme.chip.copyWith(color: color, fontSize: 10)),
    );
  }
}

// ─── Safe Company Dropdown ────────────────────────────────────────────────────

class _SafeCompanyDropdown extends StatelessWidget {
  final List<int> companyIds;
  final String? selectedId;
  final Function(String?) onChanged;
  const _SafeCompanyDropdown(
      {required this.companyIds, this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final companyCtrl = Get.find<CompanyCtrl>();
    final safeSelected =
        (selectedId != null && companyIds.contains(selectedId)) ? selectedId : null;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
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
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

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
