import 'package:dims_desktop/controller/generic_ctrl.dart';
import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../controller/company_ctrl.dart';
import '../../controller/theme_ctrl.dart';
import '../../models/brand/drug_brand_model.dart';
import 'app_theme.dart';
import 'brand_detail_screen.dart';

class BrandsScreen extends StatefulWidget {
  final int? initialGenericId;
  final bool isInDialog;

  const BrandsScreen({
    Key? key,
    this.initialGenericId,
    this.isInDialog = false,
  }) : super(key: key);

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  late final DrugBrandCtrl _brandCtrl;
  late final CompanyCtrl _companyCtrl;
  late final ThemeCtrl _themeCtrl;
  late final GenericCtrl _genericCtrl;

  int? _genericId;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int? _filterCompanyId;
  DrugBrandModel? _selectedBrand;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with unique tags
    final tag = 'brands_screen_${widget.initialGenericId ?? 'all'}';
    _brandCtrl = Get.put(DrugBrandCtrl(), tag: tag);
    _companyCtrl = Get.put(CompanyCtrl(), tag: tag);
    _themeCtrl = Get.put(ThemeCtrl(), tag: tag);
    _genericCtrl = Get.put(GenericCtrl(), tag: tag);

    _genericId = widget.initialGenericId;
  }

  @override
  void didUpdateWidget(BrandsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialGenericId != widget.initialGenericId) {
      setState(() {
        _genericId = widget.initialGenericId;
        _searchQuery = '';
        _filterCompanyId = null;
        _selectedBrand = null;
        _searchCtrl.clear();
      });
    }
  }

  @override
  void dispose() {
    final tag = 'brands_screen_${widget.initialGenericId ?? 'all'}';
    Get.delete<DrugBrandCtrl>(tag: tag);
    Get.delete<CompanyCtrl>(tag: tag);
    Get.delete<ThemeCtrl>(tag: tag);

    _searchCtrl.dispose();
    super.dispose();
  }

  // Get all brands or filtered by generic
  List<DrugBrandModel> _getAllBrands() {
    if (_genericId != null) {
      return _brandCtrl.getBrandsByGeneric(_genericId!);
    } else {
      return _brandCtrl.drugBrandList;
    }
  }

  List<DrugBrandModel> _getFilteredBrands() {
    var brands = _getAllBrands();

    if (_searchQuery.isNotEmpty) {
      brands = brands.where((b) =>
      b.brand_name.toLowerCase().contains(_searchQuery) ||
          (b.strength?.toLowerCase().contains(_searchQuery) ?? false) ||
          (b.form?.toLowerCase().contains(_searchQuery) ?? false)
      ).toList();
    }

    if (_filterCompanyId != null) {
      brands = brands.where((b) => b.company_id == _filterCompanyId).toList();
    }

    return brands;
  }

  List<int> _getUniqueCompanyIds() {
    final brands = _getAllBrands();
    return brands.map((b) => b.company_id).toSet().toList()..sort();
  }

  String _getHeaderTitle() {
    if (_genericId != null) {
      final generic = _genericCtrl.getGenericById(_genericId!);
      return generic?.generic_name ?? 'Brands';
    } else {
      return 'All Brands';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = _themeCtrl.currentTheme;
      final fontSizeScale = _themeCtrl.fontSizeScale;
      final accentColor = theme.accent;

      final displayedBrands = _getFilteredBrands();
      final companyIds = _getUniqueCompanyIds();
      final totalBrands = _getAllBrands().length;

      if (_filterCompanyId != null && !companyIds.contains(_filterCompanyId)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _filterCompanyId = null);
        });
      }

      return Container(
        width: widget.isInDialog ? 600 * fontSizeScale : double.infinity,
        height: widget.isInDialog ? 500 * fontSizeScale : double.infinity,
        color: theme.surface,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16 * fontSizeScale),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.divider)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_pharmacy_outlined,
                    size: 18 * fontSizeScale,
                    color: AppTheme.accentAmber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getHeaderTitle(),
                          style: TextStyle(
                            fontSize: 14 * fontSizeScale,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                        ),
                        if (_genericId == null)
                          Text(
                            '$totalBrands total brands',
                            style: TextStyle(
                              fontSize: 11 * fontSizeScale,
                              color: theme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.isInDialog)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20 * fontSizeScale,
                        color: theme.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                ],
              ),
            ),

            // Search and filters
            Padding(
              padding: EdgeInsets.all(12 * fontSizeScale),
              child: Column(
                children: [
                  SearchInput(
                    controller: _searchCtrl,
                    hint: 'Search brands by name, strength or form...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase().trim();
                      });
                    },
                    fontSizeScale: fontSizeScale,
                    accentColor: accentColor,
                  ),
                  SizedBox(height: 8 * fontSizeScale),
                  if (companyIds.isNotEmpty)
                    _CompanyDropdown(
                      companyIds: companyIds,
                      selectedId: _filterCompanyId,
                      onChanged: (value) {
                        setState(() {
                          _filterCompanyId = value;
                        });
                      },
                      theme: theme,
                      fontSizeScale: fontSizeScale,
                      companyCtrl: _companyCtrl,
                    ),
                ],
              ),
            ),

            // Results count and clear button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * fontSizeScale, vertical: 4 * fontSizeScale),
              child: Row(
                children: [
                  Text(
                    '${displayedBrands.length} brands',
                    style: TextStyle(
                      fontSize: 11 * fontSizeScale,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  if (_filterCompanyId != null || _searchQuery.isNotEmpty)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _filterCompanyId = null;
                            _searchQuery = '';
                            _searchCtrl.clear();
                          });
                        },
                        child: Text(
                          'Clear filters',
                          style: TextStyle(
                            fontSize: 11 * fontSizeScale,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Brand list
            Expanded(
              child: displayedBrands.isEmpty
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
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: displayedBrands.length,
                itemBuilder: (context, index) {
                  final brand = displayedBrands[index];
                  final company = _companyCtrl.getCompanyById(brand.company_id);
                  final isSelected = _selectedBrand?.brand_id == brand.brand_id;

                  return _BrandListItem(
                    brand: brand,
                    companyName: company?.company_name,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedBrand = brand;
                      });
                      if (!widget.isInDialog) {
                        // Get.to(() => BrandDetailView(
                        //   brand: brand,
                        //   accentColor: accentColor,
                        //   fontSizeScale: fontSizeScale,
                        // ));
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title: Row(
                              children: [
                                Text(
                                  'Brand Details',
                                  style: TextStyle(
                                    fontSize: 14 * fontSizeScale,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textPrimary,
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 20 * fontSizeScale,
                                    color: theme.textSecondary,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  tooltip: 'Close',
                                ),
                              ],
                            ),
                            content: SizedBox(
                              width: 800,
                              child: BrandDetailView(
                                brand: brand,
                                accentColor: accentColor,
                                fontSizeScale: fontSizeScale,
                              ),
                            ),
                          );
                        });
                          } else {
                        Navigator.pop(context, brand);
                      }
                    },
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    showPrice: _themeCtrl.showPriceInList.value,
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _BrandListItem extends StatefulWidget {
  final DrugBrandModel brand;
  final String? companyName;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;
  final bool showPrice;

  const _BrandListItem({
    required this.brand,
    this.companyName,
    required this.isSelected,
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
    final brand = widget.brand;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * widget.fontSizeScale,
            vertical: 12 * widget.fontSizeScale,
          ),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.brand_name,
                      style: TextStyle(
                        fontSize: 13 * widget.fontSizeScale,
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: widget.isSelected ? widget.theme.accent : widget.theme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4 * widget.fontSizeScale),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (brand.strength?.isNotEmpty ?? false)
                          _buildChip(
                            brand.strength!,
                            widget.theme.accent,
                            widget.fontSizeScale,
                          ),
                        if (brand.form?.isNotEmpty ?? false)
                          _buildChip(
                            brand.form!,
                            AppTheme.accentGreen,
                            widget.fontSizeScale,
                          ),
                      ],
                    ),
                    if (widget.companyName?.isNotEmpty ?? false) ...[
                      SizedBox(height: 4 * widget.fontSizeScale),
                      Text(
                        widget.companyName!,
                        style: TextStyle(
                          fontSize: 11 * widget.fontSizeScale,
                          color: widget.theme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (brand.price != null && widget.showPrice)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * widget.fontSizeScale,
                    vertical: 4 * widget.fontSizeScale,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6 * widget.fontSizeScale),
                  ),
                  child: Text(
                    '৳${brand.price}',
                    style: TextStyle(
                      fontSize: 11 * widget.fontSizeScale,
                      fontWeight: FontWeight.w600,
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

  Widget _buildChip(String label, Color color, double fontSizeScale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6 * fontSizeScale,
        vertical: 2 * fontSizeScale,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4 * fontSizeScale),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10 * fontSizeScale,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _CompanyDropdown extends StatelessWidget {
  final List<int> companyIds;
  final int? selectedId;
  final Function(int?) onChanged;
  final ThemeDefinition theme;
  final double fontSizeScale;
  final CompanyCtrl companyCtrl;

  const _CompanyDropdown({
    required this.companyIds,
    this.selectedId,
    required this.onChanged,
    required this.theme,
    required this.fontSizeScale,
    required this.companyCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40 * fontSizeScale,
      padding: EdgeInsets.symmetric(horizontal: 12 * fontSizeScale),
      decoration: BoxDecoration(
        color: theme.bg,
        borderRadius: BorderRadius.circular(8 * fontSizeScale),
        border: Border.all(color: theme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedId,
          hint: Text(
            'Filter by company',
            style: TextStyle(
              fontSize: 12 * fontSizeScale,
              color: theme.textSecondary,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18 * fontSizeScale,
            color: theme.textSecondary,
          ),
          dropdownColor: theme.surfaceElevated,
          items: [
            DropdownMenuItem<int?>(
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
              final company = companyCtrl.getCompanyById(id);
              // Use company name if available, otherwise show a placeholder
              final companyName = company?.company_name;

              return DropdownMenuItem<int?>(
                value: id,
                child: Text(
                  companyName ?? 'Loading...',
                  style: TextStyle(
                    fontSize: 12 * fontSizeScale,
                    color: theme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}