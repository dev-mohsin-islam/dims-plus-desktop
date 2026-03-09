import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../controller/company_ctrl.dart';
import '../../controller/generic_ctrl.dart';
import '../../controller/pregnancy_cat_ctrl.dart';
import '../../controller/theme_ctrl.dart';
import '../../controller/favourite_ctrl.dart';
import '../../models/brand/drug_brand_model.dart';
import '../../models/generic/generic_details_model.dart';
import 'app_theme.dart';

class BrandDetailView extends StatefulWidget {
  final DrugBrandModel brand;
  final Function(DrugBrandModel)? onBrandSwitch;
  final Color? accentColor;
  final double? fontSizeScale;

  const BrandDetailView({
    Key? key,
    required this.brand,
    this.onBrandSwitch,
    this.accentColor,
    this.fontSizeScale,
  }) : super(key: key);

  @override
  State<BrandDetailView> createState() => _BrandDetailViewState();
}

class _BrandDetailViewState extends State<BrandDetailView> {
  late DrugBrandModel _current;
  final ScrollController _scrollController = ScrollController();
  final ThemeCtrl _themeCtrl = Get.put(ThemeCtrl());

  late final String _instanceId;
  late final Map<String, GlobalKey> _sectionKeys;

  // Get current theme
  ThemeDefinition get _theme => _themeCtrl.currentTheme;
  Color get _accentColor => widget.accentColor ?? _theme.accent;
  double get _fontSizeScale => widget.fontSizeScale ?? _themeCtrl.fontSizeScale;
  bool get _expandByDefault => _themeCtrl.expandGenericByDefault.value;

  @override
  void initState() {
    super.initState();
    _current = widget.brand;

    _instanceId = '${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().hashCode}';

    _sectionKeys = {
      'Indication': GlobalKey(debugLabel: 'Indication_$_instanceId'),
      'Dose': GlobalKey(debugLabel: 'Dose_$_instanceId'),
      'Adult Dose': GlobalKey(debugLabel: 'AdultDose_$_instanceId'),
      'Child Dose': GlobalKey(debugLabel: 'ChildDose_$_instanceId'),
      'Renal Dose': GlobalKey(debugLabel: 'RenalDose_$_instanceId'),
      'Administration': GlobalKey(debugLabel: 'Administration_$_instanceId'),
      'Side Effects': GlobalKey(debugLabel: 'SideEffects_$_instanceId'),
      'Contraindications': GlobalKey(debugLabel: 'Contraindications_$_instanceId'),
      'Precautions': GlobalKey(debugLabel: 'Precautions_$_instanceId'),
      'Mode of Action': GlobalKey(debugLabel: 'ModeOfAction_$_instanceId'),
      'Interactions': GlobalKey(debugLabel: 'Interactions_$_instanceId'),
      'Pregnancy Note': GlobalKey(debugLabel: 'PregnancyNote_$_instanceId'),
    };
  }

  @override
  void didUpdateWidget(BrandDetailView old) {
    super.didUpdateWidget(old);
    if (old.brand.brand_id != widget.brand.brand_id) {
      setState(() => _current = widget.brand);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _switchTo(DrugBrandModel b) {
    setState(() => _current = b);
    widget.onBrandSwitch?.call(b);
  }

  void _scrollToSection(String section) {
    final key = _sectionKeys[section];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final genericCtrl = Get.put(GenericCtrl());
    final companyCtrl = Get.put(CompanyCtrl());
    final pregnancyCtrl = Get.put(PregnancyCatCtrl());
    final brandCtrl = Get.put(DrugBrandCtrl());

    final generic = genericCtrl.getGenericById(_current.generic_id);
    final company = companyCtrl.getCompanyById(_current.company_id);

    final allForGeneric = brandCtrl.drugBrandList
        .where((b) =>
    b.generic_id.toString() == _current.generic_id.toString() &&
        b.company_id.toString() == _current.company_id.toString())
        .toList();

    return Container(
      color: _theme.bg,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(24 * _fontSizeScale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand header card
            Container(
              padding: EdgeInsets.all(20 * _fontSizeScale),
              decoration: BoxDecoration(
                color: _theme.surface,
                borderRadius: BorderRadius.circular(14 * _fontSizeScale),
                border: Border.all(color: _theme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52 * _fontSizeScale,
                        height: 52 * _fontSizeScale,
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14 * _fontSizeScale),
                          border: Border.all(color: _accentColor.withOpacity(0.3)),
                        ),
                        child: Icon(
                          Icons.local_pharmacy_rounded,
                          color: _accentColor,
                          size: 28 * _fontSizeScale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _current.brand_name,
                                    style: TextStyle(
                                      fontSize: 24 * _fontSizeScale,
                                      fontWeight: FontWeight.w700,
                                      color: _theme.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                // Bookmark Button
                                GetBuilder<FavouriteCtrl>(
                                  init: Get.put(FavouriteCtrl()),
                                  builder: (favCtrl) {
                                    final isFav = favCtrl.isFavourite(_current.brand_id, 'brand');
                                    return IconButton(
                                      onPressed: () => favCtrl.toggleFavourite(_current.brand_id, 'brand'),
                                      icon: Icon(
                                        isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                        color: isFav ? AppTheme.accentAmber : _theme.textMuted,
                                        size: 24 * _fontSizeScale,
                                      ),
                                      tooltip: isFav ? 'Remove from Bookmarks' : 'Add to Bookmarks',
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8 * _fontSizeScale),
                            Wrap(spacing: 8, runSpacing: 6, children: [
                              if (_current.strength != null)
                                _InfoChip(
                                  _current.strength!,
                                  _accentColor,
                                  Icons.science_outlined,
                                  theme: _theme,
                                  fontSizeScale: _fontSizeScale,
                                ),
                              if (_current.form != null)
                                _InfoChip(
                                  _current.form!,
                                  AppTheme.accentGreen,
                                  Icons.medication_outlined,
                                  theme: _theme,
                                  fontSizeScale: _fontSizeScale,
                                ),
                              if (_current.packsize != null)
                                _InfoChip(
                                  'Pack: ${_current.packsize}',
                                  _theme.textSecondary,
                                  Icons.inventory_2_outlined,
                                  theme: _theme,
                                  fontSizeScale: _fontSizeScale,
                                ),
                            ]),
                          ],
                        ),
                      ),
                      if (_current.price != null && _themeCtrl.showPriceInList.value)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 18 * _fontSizeScale,
                              vertical: 10 * _fontSizeScale),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12 * _fontSizeScale),
                            border: Border.all(
                                color: AppTheme.accentGreen.withOpacity(0.4)),
                          ),
                          child: Column(children: [
                            Text(
                              'MRP',
                              style: TextStyle(
                                fontSize: 11 * _fontSizeScale,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentGreen,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2 * _fontSizeScale),
                            Text(
                              '৳${_current.price}',
                              style: TextStyle(
                                fontSize: 22 * _fontSizeScale,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                          ]),
                        ),
                    ],
                  ),
                  SizedBox(height: 14 * _fontSizeScale),
                  Divider(color: _theme.divider, height: 1),
                  SizedBox(height: 10 * _fontSizeScale),
                  Row(children: [
                    Icon(
                      Icons.business_outlined,
                      size: 14 * _fontSizeScale,
                      color: _theme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Manufacturer: ',
                      style: TextStyle(
                        fontSize: 11 * _fontSizeScale,
                        fontWeight: FontWeight.w600,
                        color: _theme.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (company != null)
                      Text(
                        company.company_name,
                        style: TextStyle(
                          fontSize: 13 * _fontSizeScale,
                          fontWeight: FontWeight.w500,
                          color: _theme.textPrimary,
                        ),
                      )
                    else
                      Text(
                        _current.company_id.toString(),
                        style: TextStyle(
                          fontSize: 13 * _fontSizeScale,
                          color: _theme.textSecondary,
                        ),
                      ),
                  ]),
                ],
              ),
            ),

            // Strength / Form switcher
            if (allForGeneric.length > 1) ...[
              SizedBox(height: 14 * _fontSizeScale),
              _StrengthSwitcher(
                allBrands: allForGeneric,
                currentBrand: _current,
                onSelect: _switchTo,
                accentColor: _accentColor,
                theme: _theme,
                fontSizeScale: _fontSizeScale,
              ),
            ],

            SizedBox(height: 16 * _fontSizeScale),

            // Generic Information header with dropdown and other brands button
            if (generic != null) ...[
              Row(
                children: [
                  _SectionTitle(
                    'Generic Information',
                    accentColor: _accentColor,
                    fontSizeScale: _fontSizeScale,
                  ),
                  const SizedBox(width: 16),
                  // Dropdown to jump to sections
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _theme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _theme.divider),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text(
                          'Jump to section...',
                          style: TextStyle(
                            fontSize: 12 * _fontSizeScale,
                            color: _theme.textSecondary,
                          ),
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          size: 18 * _fontSizeScale,
                          color: _theme.textSecondary,
                        ),
                        dropdownColor: _theme.surfaceElevated,
                        items: [
                          'Indication',
                          'Dose',
                          'Adult Dose',
                          'Child Dose',
                          'Renal Dose',
                          'Administration',
                          'Side Effects',
                          'Contraindications',
                          'Precautions',
                          'Mode of Action',
                          'Interactions',
                          'Pregnancy Note',
                        ].map((section) {
                          return DropdownMenuItem(
                            value: section,
                            child: Text(
                              section,
                              style: TextStyle(
                                fontSize: 12 * _fontSizeScale,
                                color: _theme.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _scrollToSection(value);
                          }
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Other brands button
                  _OtherBrandsSection(
                    genericId: _current.generic_id,
                    currentBrandId: _current.brand_id,
                    accentColor: _accentColor,
                    theme: _theme,
                    fontSizeScale: _fontSizeScale,
                    onBrandSelected: _switchTo,
                  ),
                ],
              ),
              SizedBox(height: 12 * _fontSizeScale),
              _GenericFullDetail(
                generic: generic,
                pregnancyCtrl: pregnancyCtrl,
                sectionKeys: _sectionKeys,
                accentColor: _accentColor,
                theme: _theme,
                fontSizeScale: _fontSizeScale,
                expandByDefault: _expandByDefault,
              ),
            ],

            SizedBox(height: 24 * _fontSizeScale),
          ],
        ),
      ),
    );
  }
}

class _GenericFullDetail extends StatelessWidget {
  final GenericDetailsModel generic;
  final PregnancyCatCtrl pregnancyCtrl;
  final Map<String, GlobalKey> sectionKeys;
  final Color accentColor;
  final ThemeDefinition theme;
  final double fontSizeScale;
  final bool expandByDefault;

  const _GenericFullDetail({
    required this.generic,
    required this.pregnancyCtrl,
    required this.sectionKeys,
    required this.accentColor,
    required this.theme,
    required this.fontSizeScale,
    required this.expandByDefault,
  });

  @override
  Widget build(BuildContext context) {
    String? pregnancyName;
    if (generic.pregnancy_category_id != null) {
      final cat = pregnancyCtrl.pregnancyCategoryList
          .firstWhereOrNull((p) => p.id.toString() == generic.pregnancy_category_id);
      pregnancyName = cat?.name;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12 * fontSizeScale),
        border: Border.all(color: theme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Generic name header
          Container(
            padding: EdgeInsets.all(16 * fontSizeScale),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.divider)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 16 * fontSizeScale,
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    generic.generic_name,
                    style: TextStyle(
                      fontSize: 14 * fontSizeScale,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                if (pregnancyName != null)
                  Container(
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
                      'Pregnancy: $pregnancyName',
                      style: TextStyle(
                        fontSize: 11 * fontSizeScale,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.accentAmber,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Details grid
          Padding(
            padding: EdgeInsets.all(16 * fontSizeScale),
            child: Column(
              children: [
                if (generic.indication != null)
                  _DetailSection(
                    'Indication',
                    generic.indication!,
                    Icons.info_outline,
                    sectionKey: sectionKeys['Indication'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
                if (generic.dose != null)
                  _DetailSection(
                    'Dose',
                    generic.dose!,
                    Icons.medication_outlined,
                    sectionKey: sectionKeys['Dose'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
                if (generic.adult_dose != null)
                  _DetailSection(
                    'Adult Dose',
                    generic.adult_dose!,
                    Icons.person_outline,
                    sectionKey: sectionKeys['Adult Dose'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
                if (generic.child_dose != null)
                  _DetailSection(
                    'Child Dose',
                    generic.child_dose!,
                    Icons.child_care_outlined,
                    sectionKey: sectionKeys['Child Dose'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
                if (generic.renal_dose != null)
                  _DetailSection(
                    'Renal Dose',
                    generic.renal_dose!,
                    Icons.water_drop_outlined,
                    sectionKey: sectionKeys['Renal Dose'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
                if (generic.administration != null)
                  _DetailSection(
                    'Administration',
                    generic.administration!,
                    Icons.route_outlined,
                    sectionKey: sectionKeys['Administration'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
                if (generic.side_effect != null)
                  _DetailSection(
                    'Side Effects',
                    generic.side_effect!,
                    Icons.warning_amber_outlined,
                    color: AppTheme.accentAmber,
                    sectionKey: sectionKeys['Side Effects'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
                if (generic.contra_indication != null)
                  _DetailSection(
                    'Contraindications',
                    generic.contra_indication!,
                    Icons.block_outlined,
                    color: AppTheme.accentRed,
                    sectionKey: sectionKeys['Contraindications'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
                if (generic.precaution != null)
                  _DetailSection(
                    'Precautions',
                    generic.precaution!,
                    Icons.shield_outlined,
                    color: AppTheme.accentAmber,
                    sectionKey: sectionKeys['Precautions'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
                if (generic.mode_of_action != null)
                  _DetailSection(
                    'Mode of Action',
                    generic.mode_of_action!,
                    Icons.biotech_outlined,
                    sectionKey: sectionKeys['Mode of Action'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
                if (generic.interaction != null)
                  _DetailSection(
                    'Interactions',
                    generic.interaction!,
                    Icons.compare_arrows_outlined,
                    color: AppTheme.accentRed,
                    sectionKey: sectionKeys['Interactions'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
                if (generic.pregnancy_category_note != null)
                  _DetailSection(
                    'Pregnancy Note',
                    generic.pregnancy_category_note!,
                    Icons.pregnant_woman_outlined,
                    color: AppTheme.accentAmber,
                    sectionKey: sectionKeys['Pregnancy Note'],
                    theme: theme,
                    fontSizeScale: fontSizeScale,
                    initialExpanded: expandByDefault,
                  ),
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
  final double fontSizeScale;
  final bool initialExpanded;
  final GlobalKey? sectionKey;
  final ThemeDefinition theme;

  const _DetailSection(
      this.title,
      this.content,
      this.icon, {
        this.color,
        this.sectionKey,
        required this.theme,
        required this.fontSizeScale,
        required this.initialExpanded,
      }) : super(key: sectionKey);

  @override
  State<_DetailSection> createState() => _DetailSectionState();
}

class _DetailSectionState extends State<_DetailSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8 * widget.fontSizeScale),
      decoration: BoxDecoration(
        color: widget.theme.bg,
        borderRadius: BorderRadius.circular(8 * widget.fontSizeScale),
        border: Border.all(color: widget.theme.divider.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * widget.fontSizeScale,
                vertical: 10 * widget.fontSizeScale,
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 14 * widget.fontSizeScale,
                    color: widget.color ?? widget.theme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11 * widget.fontSizeScale,
                      fontWeight: FontWeight.w600,
                      color: widget.color ?? widget.theme.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 14 * widget.fontSizeScale,
                    color: widget.theme.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: EdgeInsets.only(
                left: 12 * widget.fontSizeScale,
                right: 12 * widget.fontSizeScale,
                bottom: 12 * widget.fontSizeScale,
              ),
              child: Text(
                widget.content,
                style: TextStyle(
                  fontSize: 13 * widget.fontSizeScale,
                  color: widget.theme.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OtherBrandsSection extends StatefulWidget {
  final int genericId;
  final int currentBrandId;
  final Color accentColor;
  final ThemeDefinition theme;
  final double fontSizeScale;
  final Function(DrugBrandModel) onBrandSelected;

  const _OtherBrandsSection({
    required this.genericId,
    required this.currentBrandId,
    required this.accentColor,
    required this.theme,
    required this.fontSizeScale,
    required this.onBrandSelected,
  });

  @override
  State<_OtherBrandsSection> createState() => _OtherBrandsSectionState();
}

class _OtherBrandsSectionState extends State<_OtherBrandsSection> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int? _filterCompanyId;
  String? _filterForm;
  String? _priceSort;

  List<String> _availableForms = [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showOtherBrandsDialog() {
    final brandCtrl = Get.put(DrugBrandCtrl());
    final companyCtrl = Get.put(CompanyCtrl());

    final allBrands = brandCtrl.getBrandsByGeneric(widget.genericId)
        .where((b) => b.brand_id != widget.currentBrandId)
        .toList();

    final companyIds = allBrands.map((b) => b.company_id).toSet().toList();

    _availableForms = allBrands
        .where((b) => b.form != null && b.form!.isNotEmpty)
        .map((b) => b.form!)
        .toSet()
        .toList()
      ..sort();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            var displayed = allBrands.where((b) {
              final matchSearch = _searchQuery.isEmpty ||
                  b.brand_name.toLowerCase().contains(_searchQuery) ||
                  (b.strength?.toLowerCase().contains(_searchQuery) ?? false) ||
                  (b.form?.toLowerCase().contains(_searchQuery) ?? false);

              final matchCompany = _filterCompanyId == null || b.company_id == _filterCompanyId;
              final matchForm = _filterForm == null || b.form == _filterForm;

              return matchSearch && matchCompany && matchForm;
            }).toList();

            if (_priceSort == 'low-to-high') {
              displayed.sort((a, b) {
                final priceA = double.tryParse(a.price?.toString() ?? '0') ?? 0;
                final priceB = double.tryParse(b.price?.toString() ?? '0') ?? 0;
                return priceA.compareTo(priceB);
              });
            } else if (_priceSort == 'high-to-low') {
              displayed.sort((a, b) {
                final priceA = double.tryParse(a.price?.toString() ?? '0') ?? 0;
                final priceB = double.tryParse(b.price?.toString() ?? '0') ?? 0;
                return priceB.compareTo(priceA);
              });
            }

            return AlertDialog(
              backgroundColor: widget.theme.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16 * widget.fontSizeScale),
                side: BorderSide(color: widget.theme.divider),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Other Brands (${allBrands.length})',
                    style: TextStyle(
                      fontSize: 16 * widget.fontSizeScale,
                      fontWeight: FontWeight.w600,
                      color: widget.theme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20 * widget.fontSizeScale,
                      color: widget.theme.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: Container(
                width: 900 * widget.fontSizeScale,
                height: 600 * widget.fontSizeScale,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SearchInput(
                            controller: _searchCtrl,
                            hint: 'Search by brand, strength or form...',
                            onChanged: (q) {
                              setDialogState(() {
                                _searchQuery = q.toLowerCase().trim();
                              });
                            },
                            fontSizeScale: widget.fontSizeScale,
                            accentColor: widget.accentColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _CompanyDropdown(
                            companyIds: companyIds,
                            selectedId: _filterCompanyId,
                            onChanged: (id) {
                              setDialogState(() {
                                _filterCompanyId = id;
                              });
                            },
                            theme: widget.theme,
                            fontSizeScale: widget.fontSizeScale,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10 * widget.fontSizeScale),

                    Row(
                      children: [
                        Expanded(
                          child: _FormDropdown(
                            forms: _availableForms,
                            selectedForm: _filterForm,
                            onChanged: (form) {
                              setDialogState(() {
                                _filterForm = form;
                              });
                            },
                            theme: widget.theme,
                            fontSizeScale: widget.fontSizeScale,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _PriceSortDropdown(
                            selectedSort: _priceSort,
                            onChanged: (sort) {
                              setDialogState(() {
                                _priceSort = sort;
                              });
                            },
                            theme: widget.theme,
                            fontSizeScale: widget.fontSizeScale,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12 * widget.fontSizeScale),

                    Row(
                      children: [
                        Text(
                          '${displayed.length} brands found',
                          style: TextStyle(
                            fontSize: 11 * widget.fontSizeScale,
                            fontWeight: FontWeight.w600,
                            color: widget.theme.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (_searchQuery.isNotEmpty || _filterCompanyId != null || _filterForm != null || _priceSort != null)
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  _searchQuery = '';
                                  _filterCompanyId = null;
                                  _filterForm = null;
                                  _priceSort = null;
                                  _searchCtrl.clear();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8 * widget.fontSizeScale,
                                  vertical: 4 * widget.fontSizeScale,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4 * widget.fontSizeScale),
                                ),
                                child: Text(
                                  'Clear all filters',
                                  style: TextStyle(
                                    fontSize: 11 * widget.fontSizeScale,
                                    fontWeight: FontWeight.w500,
                                    color: widget.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8 * widget.fontSizeScale),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.theme.surface,
                          borderRadius: BorderRadius.circular(10 * widget.fontSizeScale),
                          border: Border.all(color: widget.theme.divider),
                        ),
                        child: displayed.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_pharmacy_outlined,
                                size: 48 * widget.fontSizeScale,
                                color: widget.theme.textMuted,
                              ),
                              SizedBox(height: 12 * widget.fontSizeScale),
                              Text(
                                'No brands found',
                                style: TextStyle(
                                  fontSize: 13 * widget.fontSizeScale,
                                  color: widget.theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                            : ListView.builder(
                          itemCount: displayed.length,
                          itemBuilder: (_, i) {
                            final b = displayed[i];
                            final co = companyCtrl.getCompanyById(b.company_id);
                            return _OtherBrandRow(
                              brand: b,
                              companyName: co?.company_name,
                              onTap: () {
                                Navigator.pop(dialogContext);
                                widget.onBrandSelected(b);
                              },
                              theme: widget.theme,
                              accentColor: widget.accentColor,
                              fontSizeScale: widget.fontSizeScale,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _showOtherBrandsDialog,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * widget.fontSizeScale,
            vertical: 6 * widget.fontSizeScale,
          ),
          decoration: BoxDecoration(
            color: widget.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8 * widget.fontSizeScale),
            border: Border.all(color: widget.accentColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.list_alt_rounded,
                size: 14 * widget.fontSizeScale,
                color: widget.accentColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Other Brands',
                style: TextStyle(
                  fontSize: 11 * widget.fontSizeScale,
                  fontWeight: FontWeight.w500,
                  color: widget.accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormDropdown extends StatelessWidget {
  final List<String> forms;
  final String? selectedForm;
  final Function(String?) onChanged;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _FormDropdown({
    required this.forms,
    this.selectedForm,
    required this.onChanged,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
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
          value: selectedForm,
          hint: Text(
            'Filter by form',
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
                'All Forms',
                style: TextStyle(
                  fontSize: 12 * fontSizeScale,
                  color: theme.textPrimary,
                ),
              ),
            ),
            ...forms.map((form) {
              return DropdownMenuItem<String?>(
                value: form,
                child: Text(
                  form,
                  style: TextStyle(
                    fontSize: 12 * fontSizeScale,
                    color: theme.textPrimary,
                  ),
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

class _PriceSortDropdown extends StatelessWidget {
  final String? selectedSort;
  final Function(String?) onChanged;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _PriceSortDropdown({
    this.selectedSort,
    required this.onChanged,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
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
          value: selectedSort,
          hint: Text(
            'Sort by price',
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
                'No sorting',
                style: TextStyle(
                  fontSize: 12 * fontSizeScale,
                  color: theme.textPrimary,
                ),
              ),
            ),
            DropdownMenuItem<String?>(
              value: 'low-to-high',
              child: Text(
                'Price: Low to High',
                style: TextStyle(
                  fontSize: 12 * fontSizeScale,
                  color: theme.textPrimary,
                ),
              ),
            ),
            DropdownMenuItem<String?>(
              value: 'high-to-low',
              child: Text(
                'Price: High to Low',
                style: TextStyle(
                  fontSize: 12 * fontSizeScale,
                  color: theme.textPrimary,
                ),
              ),
            ),
          ],
          onChanged: onChanged,
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

  const _CompanyDropdown({
    required this.companyIds,
    this.selectedId,
    required this.onChanged,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    final companyCtrl = Get.put(CompanyCtrl());

    return Container(
      height: 38 * fontSizeScale,
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
              final c = companyCtrl.getCompanyById(id);
              return DropdownMenuItem<int?>(
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
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _OtherBrandRow extends StatefulWidget {
  final DrugBrandModel brand;
  final String? companyName;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final Color accentColor;
  final double fontSizeScale;

  const _OtherBrandRow({
    required this.brand,
    this.companyName,
    required this.onTap,
    required this.theme,
    required this.accentColor,
    required this.fontSizeScale,
  });

  @override
  State<_OtherBrandRow> createState() => _OtherBrandRowState();
}

class _OtherBrandRowState extends State<_OtherBrandRow> {
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
          duration: const Duration(milliseconds: 100),
          color: _hover ? widget.theme.surfaceHighlight : Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * widget.fontSizeScale,
            vertical: 12 * widget.fontSizeScale,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.brand.brand_name,
                      style: TextStyle(
                        fontSize: 13 * widget.fontSizeScale,
                        fontWeight: FontWeight.w600,
                        color: _hover ? widget.accentColor : widget.theme.textPrimary,
                      ),
                    ),
                    if (widget.companyName != null)
                      Text(
                        widget.companyName!,
                        style: TextStyle(
                          fontSize: 11 * widget.fontSizeScale,
                          color: widget.theme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  if (widget.brand.strength != null)
                    _MiniChip(
                      widget.brand.strength!,
                      widget.accentColor,
                      theme: widget.theme,
                      fontSizeScale: widget.fontSizeScale,
                    ),
                  if (widget.brand.form != null)
                    _MiniChip(
                      widget.brand.form!,
                      AppTheme.accentGreen,
                      theme: widget.theme,
                      fontSizeScale: widget.fontSizeScale,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              if (widget.brand.price != null)
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
                    '৳${widget.brand.price}',
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
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _MiniChip(this.label, this.color, {required this.theme, required this.fontSizeScale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6 * fontSizeScale,
        vertical: 2 * fontSizeScale,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
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

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _InfoChip(
      this.label,
      this.color,
      this.icon, {
        required this.theme,
        required this.fontSizeScale,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * fontSizeScale,
        vertical: 5 * fontSizeScale,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8 * fontSizeScale),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12 * fontSizeScale, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 13 * fontSizeScale,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ]),
    );
  }
}

class _StrengthSwitcher extends StatelessWidget {
  final List<DrugBrandModel> allBrands;
  final DrugBrandModel currentBrand;
  final Function(DrugBrandModel) onSelect;
  final Color accentColor;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _StrengthSwitcher({
    required this.allBrands,
    required this.currentBrand,
    required this.onSelect,
    required this.accentColor,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14 * fontSizeScale),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12 * fontSizeScale),
        border: Border.all(color: theme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(
              Icons.tune_rounded,
              size: 14 * fontSizeScale,
              color: theme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'AVAILABLE STRENGTHS & FORMS',
              style: TextStyle(
                fontSize: 11 * fontSizeScale,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ]),
          SizedBox(height: 10 * fontSizeScale),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allBrands.map((b) {
              final isCurrent = b.brand_id == currentBrand.brand_id;
              final parts = <String>[
                if (b.strength != null) b.strength!,
                if (b.form != null) b.form!,
              ];
              final label = parts.isNotEmpty ? parts.join(' · ') : b.brand_name;
              return MouseRegion(
                cursor: isCurrent
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: isCurrent ? null : () => onSelect(b),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 130),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * fontSizeScale,
                      vertical: 7 * fontSizeScale,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? accentColor
                          : theme.surfaceHighlight,
                      borderRadius: BorderRadius.circular(8 * fontSizeScale),
                      border: Border.all(
                        color: isCurrent
                            ? accentColor
                            : theme.divider,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12 * fontSizeScale,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isCurrent ? Colors.white : theme.textPrimary,
                          ),
                        ),
                        if (b.price != null)
                          Text(
                            '৳${b.price}',
                            style: TextStyle(
                              fontSize: 11 * fontSizeScale,
                              fontWeight: FontWeight.w500,
                              color: isCurrent ? Colors.white70 : AppTheme.accentGreen,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14 * fontSizeScale),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10 * fontSizeScale),
        border: Border.all(color: theme.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16 * fontSizeScale, color: theme.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 11 * fontSizeScale,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 6),
          child,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color accentColor;
  final double fontSizeScale;

  const _SectionTitle(
      this.title, {
        required this.accentColor,
        required this.fontSizeScale,
      });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3 * fontSizeScale,
          height: 16 * fontSizeScale,
          decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2 * fontSizeScale)
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14 * fontSizeScale,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
      ],
    );
  }
}