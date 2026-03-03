import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../controller/company_ctrl.dart';
import '../../controller/generic_ctrl.dart';
import '../../controller/pregnancy_cat_ctrl.dart';
import '../../models/brand/drug_brand_model.dart';
import '../../models/generic/generic_details_model.dart';
import 'app_theme.dart';

class BrandDetailView extends StatelessWidget {
  final DrugBrandModel brand;
  const BrandDetailView({Key? key, required this.brand}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final genericCtrl = Get.find<GenericCtrl>();
    final companyCtrl = Get.find<CompanyCtrl>();
    final pregnancyCtrl = Get.find<PregnancyCatCtrl>();

    final generic = genericCtrl.getGenericById(brand.generic_id);
    final company = companyCtrl.getCompanyById(brand.company_id);

    return Container(
      color: AppTheme.bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.local_pharmacy_rounded, color: AppTheme.accent, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(brand.brand_name, style: AppTheme.headingLarge),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (brand.strength != null) _Chip(brand.strength!, AppTheme.accent),
                          if (brand.form != null) _Chip(brand.form!, AppTheme.accentGreen),
                          if (brand.packsize != null) _Chip('Pack: ${brand.packsize}', AppTheme.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price
                if (brand.price != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('PRICE', style: AppTheme.label.copyWith(color: AppTheme.accentGreen)),
                        Text('৳${brand.price}', style: AppTheme.headingMedium.copyWith(color: AppTheme.accentGreen)),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Company info
            if (company != null)
              _InfoCard(
                icon: Icons.business_outlined,
                title: 'Manufacturer',
                child: Text(company.company_name, style: AppTheme.bodyPrimary.copyWith(fontWeight: FontWeight.w500)),
              ),

            const SizedBox(height: 16),

            // Generic info section
            if (generic != null) ...[
              _SectionTitle('Generic Information'),
              const SizedBox(height: 12),
              _GenericFullDetail(generic: generic, pregnancyCtrl: pregnancyCtrl),
            ],

            const SizedBox(height: 24),

            // Other brands button
            _OtherBrandsSection(genericId: brand.generic_id, currentBrandId: brand.brand_id),
          ],
        ),
      ),
    );
  }
}

class _GenericFullDetail extends StatelessWidget {
  final GenericDetailsModel generic;
  final PregnancyCatCtrl pregnancyCtrl;
  const _GenericFullDetail({required this.generic, required this.pregnancyCtrl});

  @override
  Widget build(BuildContext context) {
    // Get pregnancy category
    String? pregnancyName;
    if (generic.pregnancy_category_id != null) {
      final cat = pregnancyCtrl.pregnancyCategoryList
          .firstWhereOrNull((p) => p.id.toString() == generic.pregnancy_category_id);
      pregnancyName = cat?.name;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Generic name header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.divider)),
            ),
            child: Row(
              children: [
                Icon(Icons.science_outlined, size: 16, color: AppTheme.accent),
                const SizedBox(width: 8),
                Expanded(child: Text(generic.generic_name, style: AppTheme.headingSmall)),
                if (pregnancyName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAmber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.accentAmber.withOpacity(0.4)),
                    ),
                    child: Text('Pregnancy: $pregnancyName',
                        style: AppTheme.chip.copyWith(color: AppTheme.accentAmber)),
                  ),
              ],
            ),
          ),
          // Details grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (generic.indication != null) _DetailSection('Indication', generic.indication!, Icons.info_outline),
                if (generic.dose != null) _DetailSection('Dose', generic.dose!, Icons.medication_outlined),
                if (generic.adult_dose != null) _DetailSection('Adult Dose', generic.adult_dose!, Icons.person_outline),
                if (generic.child_dose != null) _DetailSection('Child Dose', generic.child_dose!, Icons.child_care_outlined),
                if (generic.renal_dose != null) _DetailSection('Renal Dose', generic.renal_dose!, Icons.water_drop_outlined),
                if (generic.administration != null) _DetailSection('Administration', generic.administration!, Icons.route_outlined),
                if (generic.side_effect != null) _DetailSection('Side Effects', generic.side_effect!, Icons.warning_amber_outlined, color: AppTheme.accentAmber),
                if (generic.contra_indication != null) _DetailSection('Contraindications', generic.contra_indication!, Icons.block_outlined, color: AppTheme.accentRed),
                if (generic.precaution != null) _DetailSection('Precautions', generic.precaution!, Icons.shield_outlined, color: AppTheme.accentAmber),
                if (generic.mode_of_action != null) _DetailSection('Mode of Action', generic.mode_of_action!, Icons.biotech_outlined),
                if (generic.interaction != null) _DetailSection('Interactions', generic.interaction!, Icons.compare_arrows_outlined, color: AppTheme.accentRed),
                if (generic.pregnancy_category_note != null)
                  _DetailSection('Pregnancy Note', generic.pregnancy_category_note!, Icons.pregnant_woman_outlined, color: AppTheme.accentAmber),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color? color;
  const _DetailSection(this.title, this.content, this.icon, {this.color});
  @override
  State<_DetailSection> createState() => _DetailSectionState();
}

class _DetailSectionState extends State<_DetailSection> {
  bool _expanded = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(widget.icon, size: 14, color: widget.color ?? AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(widget.title.toUpperCase(),
                      style: AppTheme.label.copyWith(color: widget.color ?? AppTheme.textSecondary)),
                  const Spacer(),
                  Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 14, color: AppTheme.textMuted),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Text(widget.content, style: AppTheme.bodyPrimary.copyWith(height: 1.6)),
            ),
        ],
      ),
    );
  }
}

class _OtherBrandsSection extends StatefulWidget {
  final int genericId;
  final int currentBrandId;
  const _OtherBrandsSection({required this.genericId, required this.currentBrandId});
  @override
  State<_OtherBrandsSection> createState() => _OtherBrandsSectionState();
}

class _OtherBrandsSectionState extends State<_OtherBrandsSection> {
  bool _showOthers = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _filterCompanyId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandCtrl = Get.find<DrugBrandCtrl>();
    final companyCtrl = Get.find<CompanyCtrl>();

    final allBrands = brandCtrl.getBrandsByGeneric(widget.genericId)
        .where((b) => b.brand_id != widget.currentBrandId)
        .toList();

    // Apply search + company filter
    var displayed = allBrands.where((b) {
      final matchSearch = _searchQuery.isEmpty ||
          b.brand_name.toLowerCase().contains(_searchQuery) ||
          (b.strength?.toLowerCase().contains(_searchQuery) ?? false);
      final matchCompany = _filterCompanyId == null || b.company_id == _filterCompanyId;
      return matchSearch && matchCompany;
    }).toList();

    final companyIds = allBrands.map((b) => b.company_id).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionTitle('Other Brands (${allBrands.length})'),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _showOthers = !_showOthers),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_showOthers ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 16, color: AppTheme.accent),
                    const SizedBox(width: 4),
                    Text(_showOthers ? 'Hide' : 'Show All', style: AppTheme.chip.copyWith(color: AppTheme.accent)),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_showOthers) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SearchInput(
                  controller: _searchCtrl,
                  hint: 'Search other brands...',
                  onChanged: (q) => setState(() => _searchQuery = q.toLowerCase().trim()),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 200,
                child: _CompanyDropdown(
                  companyIds: companyIds,
                  selectedId: _filterCompanyId,
                  onChanged: (id) => setState(() => _filterCompanyId = id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              children: displayed.map((b) {
                final co = companyCtrl.getCompanyById(b.company_id);
                return _OtherBrandRow(brand: b, companyName: co?.company_name);
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _OtherBrandRow extends StatefulWidget {
  final DrugBrandModel brand;
  final String? companyName;
  const _OtherBrandRow({required this.brand, this.companyName});
  @override
  State<_OtherBrandRow> createState() => _OtherBrandRowState();
}

class _OtherBrandRowState extends State<_OtherBrandRow> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hover ? AppTheme.surfaceHighlight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(widget.brand.brand_name,
                style: AppTheme.bodyPrimary.copyWith(fontWeight: FontWeight.w500))),
            if (widget.brand.strength != null)
              _MiniChip(widget.brand.strength!, AppTheme.accent),
            const SizedBox(width: 8),
            if (widget.brand.form != null)
              _MiniChip(widget.brand.form!, AppTheme.accentGreen),
            const SizedBox(width: 12),
            if (widget.companyName != null)
              Expanded(child: Text(widget.companyName!, style: AppTheme.bodySecondary.copyWith(fontSize: 11), overflow: TextOverflow.ellipsis)),
            if (widget.brand.price != null)
              Text('৳${widget.brand.price}', style: AppTheme.bodySecondary.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label, style: AppTheme.chip.copyWith(color: color, fontSize: 12)),
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

class _CompanyDropdown extends StatelessWidget {
  final List<int> companyIds;
  final String? selectedId;
  final Function(String?) onChanged;
  const _CompanyDropdown({required this.companyIds, this.selectedId, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final companyCtrl = Get.find<CompanyCtrl>();
    return Container(
      height: 38,
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _InfoCard({required this.icon, required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Wrap(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Text('$title: ', style: AppTheme.label.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(width: 6),
          child,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: AppTheme.headingSmall),
      ],
    );
  }
}