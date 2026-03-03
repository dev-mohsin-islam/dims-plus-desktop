import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../controller/company_ctrl.dart';
import '../../controller/generic_ctrl.dart';
import '../../models/brand/drug_brand_model.dart';
import 'app_theme.dart';
import 'brand_detail_screen.dart';

class BrandsScreen extends StatefulWidget {
  final String? initialGenericId;
  const BrandsScreen({Key? key, this.initialGenericId}) : super(key: key);
  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  final DrugBrandCtrl _ctrl = Get.find<DrugBrandCtrl>();
  final CompanyCtrl _companyCtrl = Get.find<CompanyCtrl>();
  final TextEditingController _searchCtrl = TextEditingController();
  DrugBrandModel? _selectedBrand;
  // KEY FIX: keep company filter as nullable String, never set a value not in list
  String? _selectedCompanyId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ctrl.clearFilters();
    if (widget.initialGenericId != null) {
      // Filter by genericId — convert to int if model uses int
      final id = int.tryParse(widget.initialGenericId!);
      if (id != null) {
        _ctrl.filterByGeneric(id);
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DrugBrandModel> _applyLocalFilters(List<DrugBrandModel> source) {
    var result = source;
    if (_searchQuery.isNotEmpty) {
      result = result.where((b) =>
        b.brand_name.toLowerCase().contains(_searchQuery) ||
        (b.strength?.toLowerCase().contains(_searchQuery) ?? false) ||
        (b.form?.toLowerCase().contains(_searchQuery) ?? false)
      ).toList();
    }
    if (_selectedCompanyId != null) {
      result = result.where((b) => b.company_id == _selectedCompanyId).toList();
    }
    return result;
  }

  void _clearAll() {
    setState(() {
      _selectedCompanyId = null;
      _searchQuery = '';
    });
    _searchCtrl.clear();
    _ctrl.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final source = _ctrl.filteredBrandList;
      final displayed = _applyLocalFilters(source);

      // Safe: collect all company IDs actually present in the source list
      final companyIds = source.map((b) => b.company_id).toSet().toList();

      // If current filter is no longer in the list, reset it
      if (_selectedCompanyId != null && !companyIds.contains(_selectedCompanyId)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedCompanyId = null);
        });
      }

      return Row(
        children: [
          // ── Left panel ──────────────────────────────────────────────────
          Container(
            width: 340,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(right: BorderSide(color: AppTheme.divider)),
            ),
            child: Column(
              children: [
                _PanelHeader(title: 'Drug Brands', icon: Icons.local_pharmacy_outlined),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      SearchInput(
                        controller: _searchCtrl,
                        hint: 'Search by brand, strength, form...',
                        onChanged: (q) => setState(() => _searchQuery = q.toLowerCase().trim()),
                      ),
                      const SizedBox(height: 8),
                      _SafeCompanyDropdown(
                        companyIds: companyIds,
                        selectedId: _selectedCompanyId,
                        onChanged: (id) => setState(() => _selectedCompanyId = id),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text('${displayed.length} brands', style: AppTheme.label),
                      const Spacer(),
                      if (_selectedCompanyId != null || _searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: _clearAll,
                          child: Text('Clear filters',
                              style: AppTheme.label.copyWith(color: AppTheme.accent)),
                        ),
                    ],
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
                            return _BrandListItem(
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

          // ── Right panel ─────────────────────────────────────────────────
          Expanded(
            child: _selectedBrand != null
                ? BrandDetailView(brand: _selectedBrand!)
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_pharmacy_outlined,
                            color: AppTheme.textMuted, size: 48),
                        SizedBox(height: 12),
                        Text('Select a brand to view details',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
          ),
        ],
      );
    });
  }
}

// ─── Brand list item ──────────────────────────────────────────────────────────

class _BrandListItem extends StatefulWidget {
  final DrugBrandModel brand;
  final bool isSelected;
  final VoidCallback onTap;
  const _BrandListItem(
      {required this.brand, required this.isSelected, required this.onTap});
  @override
  State<_BrandListItem> createState() => _BrandListItemState();
}

class _BrandListItemState extends State<_BrandListItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isSelected
        ? AppTheme.accent.withOpacity(0.12)
        : _hover
            ? AppTheme.surfaceHighlight
            : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              bottom: BorderSide(color: AppTheme.divider.withOpacity(0.4)),
              left: BorderSide(
                  color: widget.isSelected ? AppTheme.accent : Colors.transparent,
                  width: 3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.brand.brand_name,
                        style: AppTheme.bodyPrimary
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (widget.brand.strength != null) ...[
                          _MiniChip(widget.brand.strength!, AppTheme.accent),
                          const SizedBox(width: 6),
                        ],
                        if (widget.brand.form != null)
                          _MiniChip(widget.brand.form!, AppTheme.accentGreen),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.brand.price != null)
                Text('৳${widget.brand.price}',
                    style: AppTheme.bodySecondary.copyWith(fontSize: 12)),
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
// Fixes the DropdownButton assertion: value must always be in items or null

class _SafeCompanyDropdown extends StatelessWidget {
  final List<int> companyIds;
  final String? selectedId;
  final Function(String?) onChanged;
  const _SafeCompanyDropdown(
      {required this.companyIds, this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final companyCtrl = Get.find<CompanyCtrl>();

    // Guarantee value is in items
    final safeSelected =
        (selectedId != null && companyIds.contains(selectedId)) ? selectedId : null;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
