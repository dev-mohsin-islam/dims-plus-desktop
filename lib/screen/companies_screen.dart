import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/company_ctrl.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../models/company/company_model.dart';
import 'app_theme.dart';
import 'brands_screen.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({Key? key}) : super(key: key);
  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final CompanyCtrl _ctrl = Get.find<CompanyCtrl>();
  final DrugBrandCtrl _brandCtrl = Get.find<DrugBrandCtrl>();
  final TextEditingController _searchCtrl = TextEditingController();
  CompanyModel? _selectedCompany;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left list
        Container(
          width: 300,
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(right: BorderSide(color: AppTheme.divider)),
          ),
          child: Column(
            children: [
              _PanelHeader(title: 'Companies', icon: Icons.business_outlined),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SearchInput(
                  controller: _searchCtrl,
                  hint: 'Search companies...',
                  onChanged: _ctrl.searchCompanies,
                ),
              ),
              Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text('${_ctrl.filteredCompanyList.length} companies', style: AppTheme.label),
              )),
              Expanded(
                child: Obx(() => ListView.builder(
                  itemCount: _ctrl.filteredCompanyList.length,
                  itemBuilder: (_, i) {
                    final c = _ctrl.filteredCompanyList[i];
                    final brandCount = _brandCtrl.getBrandsByCompany(c.company_id).length;
                    return _CompanyListItem(
                      company: c,
                      brandCount: brandCount,
                      isSelected: _selectedCompany?.company_id == c.company_id,
                      onTap: () => setState(() => _selectedCompany = c),
                    );
                  },
                )),
              ),
            ],
          ),
        ),
        // Right
        Expanded(
          child: _selectedCompany != null
            ? _CompanyDetailView(company: _selectedCompany!)
            : const Center(
                child: Text('Select a company', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ),
        ),
      ],
    );
  }
}

class _CompanyListItem extends StatefulWidget {
  final CompanyModel company;
  final int brandCount;
  final bool isSelected;
  final VoidCallback onTap;
  const _CompanyListItem({required this.company, required this.brandCount, required this.isSelected, required this.onTap});
  @override
  State<_CompanyListItem> createState() => _CompanyListItemState();
}

class _CompanyListItemState extends State<_CompanyListItem> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final bg = widget.isSelected ? AppTheme.accent.withOpacity(0.12) : _hover ? AppTheme.surfaceHighlight : Colors.transparent;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: bg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(widget.company.company_name[0].toUpperCase(),
                    style: AppTheme.headingSmall.copyWith(color: AppTheme.accent, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(widget.company.company_name,
                style: AppTheme.bodyPrimary.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHighlight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${widget.brandCount}', style: AppTheme.label.copyWith(color: AppTheme.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyDetailView extends StatelessWidget {
  final CompanyModel company;
  const _CompanyDetailView({required this.company});

  @override
  Widget build(BuildContext context) {
    final brandCtrl = Get.find<DrugBrandCtrl>();
    final brands = brandCtrl.getBrandsByCompany(company.company_id);

    return Container(
      color: AppTheme.bgDark,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(company.company_name[0].toUpperCase(),
                    style: AppTheme.headingLarge.copyWith(color: AppTheme.accent)),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(company.company_name, style: AppTheme.headingLarge),
                  Text('${brands.length} brands available', style: AppTheme.bodySecondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(width: 3, height: 16, decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text('Brand Portfolio', style: AppTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: ListView.separated(
                itemCount: brands.length,
                separatorBuilder: (_, __) => const Divider(color: AppTheme.divider, height: 1),
                itemBuilder: (_, i) {
                  final b = brands[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(child: Text(b.brand_name,
                          style: AppTheme.bodyPrimary.copyWith(fontWeight: FontWeight.w500))),
                        if (b.strength != null) ...[
                          _Chip(b.strength!, AppTheme.accent),
                          const SizedBox(width: 8),
                        ],
                        if (b.form != null) ...[
                          _Chip(b.form!, AppTheme.accentGreen),
                          const SizedBox(width: 8),
                        ],
                        if (b.price != null)
                          Text('৳${b.price}', style: AppTheme.bodySecondary.copyWith(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label, style: AppTheme.chip.copyWith(color: color, fontSize: 11)),
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
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider))),
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
