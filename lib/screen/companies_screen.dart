import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/company_ctrl.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../controller/generic_ctrl.dart';
import '../../controller/theme_ctrl.dart';
import '../../models/company/company_model.dart';
import '../../models/brand/drug_brand_model.dart';
import 'app_theme.dart';
import 'brand_detail_screen.dart';
import 'brands_screen.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({Key? key}) : super(key: key);
  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final CompanyCtrl _ctrl = Get.put(CompanyCtrl());
  final DrugBrandCtrl _brandCtrl = Get.put(DrugBrandCtrl());
  final GenericCtrl _genericCtrl = Get.put(GenericCtrl());
  final ThemeCtrl _themeCtrl = Get.put(ThemeCtrl());
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _brandSearchCtrl = TextEditingController();

  CompanyModel? _selectedCompany;
  String _brandSearchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _brandSearchCtrl.dispose();
    super.dispose();
  }

  void _onCompanyTap(CompanyModel company) {
    setState(() {
      _selectedCompany = company;
      _brandSearchQuery = '';
      _brandSearchCtrl.clear();
    });
  }

  List<DrugBrandModel> _getFilteredBrands() {
    if (_selectedCompany == null) return [];

    var brands = _brandCtrl.getBrandsByCompany(_selectedCompany!.company_id);

    if (_brandSearchQuery.isNotEmpty) {
      brands = brands.where((b) {
        final generic = _genericCtrl.getGenericById(b.generic_id);
        final matchesBrand = b.brand_name.toLowerCase().contains(_brandSearchQuery);
        final matchesGeneric = generic?.generic_name.toLowerCase().contains(_brandSearchQuery) ?? false;
        final matchesStrength = b.strength?.toLowerCase().contains(_brandSearchQuery) ?? false;
        final matchesForm = b.form?.toLowerCase().contains(_brandSearchQuery) ?? false;

        return matchesBrand || matchesGeneric || matchesStrength || matchesForm;
      }).toList();
    }

    return brands;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = _themeCtrl.currentTheme;
      final fontSizeScale = _themeCtrl.fontSizeScale;
      final accentColor = theme.accent;

      return Row(
        children: [
          // Left list - Companies
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(right: BorderSide(color: theme.divider)),
            ),
            child: Column(
              children: [
                _PanelHeader(
                  title: 'Companies',
                  icon: Icons.business_outlined,
                  theme: theme,
                  fontSizeScale: fontSizeScale,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SearchInput(
                    controller: _searchCtrl,
                    hint: 'Search companies...',
                    onChanged: _ctrl.searchCompanies,
                    fontSizeScale: fontSizeScale,
                    accentColor: accentColor,
                  ),
                ),
                Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    '${_ctrl.filteredCompanyList.length} companies',
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
                    itemCount: _ctrl.filteredCompanyList.length,
                    itemBuilder: (_, i) {
                      final c = _ctrl.filteredCompanyList[i];
                      final brandCount = _brandCtrl.getBrandsByCompany(c.company_id).length;
                      return _CompanyListItem(
                        company: c,
                        brandCount: brandCount,
                        isSelected: _selectedCompany?.company_id == c.company_id,
                        onTap: () => _onCompanyTap(c),
                        theme: theme,
                        fontSizeScale: fontSizeScale,
                      );
                    },
                  )),
                ),
              ],
            ),
          ),

          // Right - Company Details with Brands
          Expanded(
            child: _selectedCompany != null
                ? _CompanyBrandsView(
              company: _selectedCompany!,
              searchController: _brandSearchCtrl,
              onSearchChanged: (value) {
                setState(() {
                  _brandSearchQuery = value.toLowerCase().trim();
                });
              },
              filteredBrands: _getFilteredBrands(),
              theme: theme,
              fontSizeScale: fontSizeScale,
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    color: theme.textMuted,
                    size: 48 * fontSizeScale,
                  ),
                  SizedBox(height: 12 * fontSizeScale),
                  Text(
                    'Select a company to view brands',
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
}

class _CompanyListItem extends StatefulWidget {
  final CompanyModel company;
  final int brandCount;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _CompanyListItem({
    required this.company,
    required this.brandCount,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_CompanyListItem> createState() => _CompanyListItemState();
}

class _CompanyListItemState extends State<_CompanyListItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isSelected
        ? widget.theme.accent.withOpacity(0.12)
        : _hover ? widget.theme.surfaceHighlight : Colors.transparent;

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
                width: 36 * widget.fontSizeScale,
                height: 36 * widget.fontSizeScale,
                decoration: BoxDecoration(
                  color: widget.theme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8 * widget.fontSizeScale),
                ),
                child: Center(
                  child: Text(
                    widget.company.company_name.isNotEmpty
                        ? widget.company.company_name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 16 * widget.fontSizeScale,
                      fontWeight: FontWeight.w600,
                      color: widget.theme.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.company.company_name,
                      style: TextStyle(
                        fontSize: 13 * widget.fontSizeScale,
                        fontWeight: FontWeight.w500,
                        color: widget.isSelected ? widget.theme.accent : widget.theme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.theme.surfaceHighlight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.brandCount}',
                  style: TextStyle(
                    fontSize: 11 * widget.fontSizeScale,
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected ? widget.theme.accent : widget.theme.textSecondary,
                    letterSpacing: 0.8,
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

class _CompanyBrandsView extends StatelessWidget {
  final CompanyModel company;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final List<DrugBrandModel> filteredBrands;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _CompanyBrandsView({
    required this.company,
    required this.searchController,
    required this.onSearchChanged,
    required this.filteredBrands,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    final brandCtrl = Get.put(DrugBrandCtrl());
    final genericCtrl = Get.put(GenericCtrl());
    final themeCtrl = Get.put(ThemeCtrl());
    final totalBrands = brandCtrl.getBrandsByCompany(company.company_id).length;

    return Container(
      color: theme.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Header
          Container(
            padding: EdgeInsets.all(24 * fontSizeScale),
            color: theme.surface,
            child: Row(
              children: [
                Container(
                  width: 64 * fontSizeScale,
                  height: 64 * fontSizeScale,
                  decoration: BoxDecoration(
                    color: theme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16 * fontSizeScale),
                    border: Border.all(color: theme.accent.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      company.company_name.isNotEmpty
                          ? company.company_name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 28 * fontSizeScale,
                        fontWeight: FontWeight.w700,
                        color: theme.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.company_name,
                        style: TextStyle(
                          fontSize: 24 * fontSizeScale,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4 * fontSizeScale),
                      Text(
                        '$totalBrands brands available',
                        style: TextStyle(
                          fontSize: 14 * fontSizeScale,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: EdgeInsets.all(20 * fontSizeScale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEARCH BRANDS',
                  style: TextStyle(
                    fontSize: 11 * fontSizeScale,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8 * fontSizeScale),
                SearchInput(
                  controller: searchController,
                  hint: 'Search by brand name, generic, strength or form...',
                  onChanged: onSearchChanged,
                  fontSizeScale: fontSizeScale,
                  accentColor: theme.accent,
                ),
                SizedBox(height: 8 * fontSizeScale),
                Text(
                  '${filteredBrands.length} of $totalBrands brands',
                  style: TextStyle(
                    fontSize: 11 * fontSizeScale,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Brands List
          Expanded(
            child: filteredBrands.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_pharmacy_outlined,
                    size: 48 * fontSizeScale,
                    color: theme.textMuted,
                  ),
                  SizedBox(height: 12 * fontSizeScale),
                  Text(
                    'No brands found',
                    style: TextStyle(
                      fontSize: 13 * fontSizeScale,
                      color: theme.textSecondary,
                    ),
                  ),
                  if (searchController.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8 * fontSizeScale),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                          child: Text(
                            'Clear search',
                            style: TextStyle(
                              fontSize: 11 * fontSizeScale,
                              fontWeight: FontWeight.w500,
                              color: theme.accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20 * fontSizeScale),
              itemCount: filteredBrands.length,
              itemBuilder: (context, index) {
                final brand = filteredBrands[index];
                final generic = genericCtrl.getGenericById(brand.generic_id);

                return _BrandCard(
                  brand: brand,
                  genericName: generic?.generic_name ?? 'Unknown Generic',
                  onViewDetails: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: theme.surfaceElevated,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16 * fontSizeScale),
                            side: BorderSide(color: theme.divider),
                          ),
                          title: Row(
                            children: [
                              Text(
                                brand.brand_name,
                                style: TextStyle(
                                  fontSize: 16 * fontSizeScale,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          content: Container(
                            width: 800 * fontSizeScale,
                            height: 600 * fontSizeScale,
                            child: BrandDetailView(
                              brand: brand,
                              accentColor: theme.accent,
                              fontSizeScale: fontSizeScale,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  theme: theme,
                  fontSizeScale: fontSizeScale,
                  showPrice: themeCtrl.showPriceInList.value,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandCard extends StatefulWidget {
  final DrugBrandModel brand;
  final String genericName;
  final VoidCallback onViewDetails;
  final ThemeDefinition theme;
  final double fontSizeScale;
  final bool showPrice;

  const _BrandCard({
    required this.brand,
    required this.genericName,
    required this.onViewDetails,
    required this.theme,
    required this.fontSizeScale,
    required this.showPrice,
  });

  @override
  State<_BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<_BrandCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final brand = widget.brand;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12 * widget.fontSizeScale),
        decoration: BoxDecoration(
          color: _hover ? widget.theme.surfaceHighlight : widget.theme.surface,
          borderRadius: BorderRadius.circular(12 * widget.fontSizeScale),
          border: Border.all(
            color: _hover ? widget.theme.accent.withOpacity(0.3) : widget.theme.divider,
          ),
          boxShadow: _hover
              ? [
            BoxShadow(
              color: widget.theme.isDark
                  ? Colors.black.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(16 * widget.fontSizeScale),
          child: Row(
            children: [
              // Brand Icon
              Container(
                width: 48 * widget.fontSizeScale,
                height: 48 * widget.fontSizeScale,
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10 * widget.fontSizeScale),
                ),
                child: Icon(
                  Icons.local_pharmacy_outlined,
                  color: AppTheme.accentAmber,
                  size: 24 * widget.fontSizeScale,
                ),
              ),
              const SizedBox(width: 16),

              // Brand Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.brand_name,
                      style: TextStyle(
                        fontSize: 15 * widget.fontSizeScale,
                        fontWeight: FontWeight.w600,
                        color: widget.theme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4 * widget.fontSizeScale),
                    Text(
                      widget.genericName,
                      style: TextStyle(
                        fontSize: 12 * widget.fontSizeScale,
                        color: widget.theme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8 * widget.fontSizeScale),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (brand.strength?.isNotEmpty ?? false)
                          _InfoChip(
                            brand.strength!,
                            widget.theme.accent,
                            widget.fontSizeScale,
                          ),
                        if (brand.form?.isNotEmpty ?? false)
                          _InfoChip(
                            brand.form!,
                            AppTheme.accentGreen,
                            widget.fontSizeScale,
                          ),
                        if (brand.packsize?.isNotEmpty ?? false)
                          _InfoChip(
                            brand.packsize!,
                            widget.theme.textSecondary,
                            widget.fontSizeScale,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price and Action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (brand.price != null && widget.showPrice)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * widget.fontSizeScale,
                        vertical: 4 * widget.fontSizeScale,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8 * widget.fontSizeScale),
                      ),
                      child: Text(
                        '৳ ${brand.price}',
                        style: TextStyle(
                          fontSize: 13 * widget.fontSizeScale,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ),
                  SizedBox(height: 8 * widget.fontSizeScale),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: widget.onViewDetails,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * widget.fontSizeScale,
                          vertical: 6 * widget.fontSizeScale,
                        ),
                        decoration: BoxDecoration(
                          color: _hover
                              ? widget.theme.accent
                              : widget.theme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8 * widget.fontSizeScale),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 11 * widget.fontSizeScale,
                                fontWeight: FontWeight.w500,
                                color: _hover ? Colors.white : widget.theme.accent,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14 * widget.fontSizeScale,
                              color: _hover ? Colors.white : widget.theme.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSizeScale;

  const _InfoChip(this.label, this.color, this.fontSizeScale);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * fontSizeScale,
        vertical: 3 * fontSizeScale,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6 * fontSizeScale),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11 * fontSizeScale,
          fontWeight: FontWeight.w500,
          color: color,
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