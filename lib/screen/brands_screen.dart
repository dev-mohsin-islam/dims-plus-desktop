import 'package:dims_desktop/controller/generic_ctrl.dart';
import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
  final DrugBrandCtrl _brandCtrl = Get.find<DrugBrandCtrl>();
  final CompanyCtrl _companyCtrl = Get.find<CompanyCtrl>();
  final ThemeCtrl _themeCtrl = Get.find<ThemeCtrl>();
  final GenericCtrl _genericCtrl = Get.find<GenericCtrl>();

  int? _genericId;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int? _filterCompanyId;
  DrugBrandModel? _selectedBrand;

  bool _isSelectionMode = false;
  final Set<int> _selectedBrandIds = {};

  @override
  void initState() {
    super.initState();
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
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DrugBrandModel> _getAllBrands() {
    if (_genericId != null) {
      return _brandCtrl.getBrandsByGeneric(_genericId!);
    } else {
      return _brandCtrl.drugBrandList;
    }
  }

  List<DrugBrandModel> _getFilteredBrands(List<DrugBrandModel> brands) {
    var result = brands;

    if (_searchQuery.isNotEmpty) {
      result = result.where((b) =>
      b.brand_name.toLowerCase().contains(_searchQuery) ||
          (b.strength?.toLowerCase().contains(_searchQuery) ?? false) ||
          (b.form?.toLowerCase().contains(_searchQuery) ?? false)
      ).toList();
    }

    if (_filterCompanyId != null) {
      result = result.where((b) => b.company_id == _filterCompanyId).toList();
    }

    return result;
  }

  List<int> _getUniqueCompanyIds(List<DrugBrandModel> brands) {
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
    final theme = _themeCtrl.currentTheme;
    final fontSizeScale = _themeCtrl.fontSizeScale;
    final accentColor = theme.accent;

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
                        Obx(() => Text(
                          '${_brandCtrl.drugBrandList.length} total brands',
                          style: TextStyle(
                            fontSize: 11 * fontSizeScale,
                            color: theme.textSecondary,
                          ),
                        )),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isSelectionMode ? Icons.check_circle : Icons.ios_share_rounded,
                    size: 20 * fontSizeScale,
                    color: _isSelectionMode ? AppTheme.accentGreen : theme.accent,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = !_isSelectionMode;
                      if (!_isSelectionMode) _selectedBrandIds.clear();
                    });
                  },
                  tooltip: _isSelectionMode ? 'Done Selecting' : 'Select to Share',
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
                Obx(() {
                  final allBrands = _getAllBrands();
                  final companyIds = _getUniqueCompanyIds(allBrands);
                  if (companyIds.isEmpty) return const SizedBox.shrink();
                  
                  return _CompanyDropdown(
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
                  );
                }),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * fontSizeScale, vertical: 4 * fontSizeScale),
            child: Obx(() {
              final allBrands = _getAllBrands();
              final displayedBrands = _getFilteredBrands(allBrands);
              
              return Row(
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
              );
            }),
          ),

          // Brand list
          Expanded(
            child: Obx(() {
              final allBrands = _getAllBrands();
              final displayedBrands = _getFilteredBrands(allBrands);

              return Stack(
                children: [
                  displayedBrands.isEmpty
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
                            final isSelectedInMode = _selectedBrandIds.contains(brand.brand_id);

                            return _BrandListItem(
                              brand: brand,
                              companyName: company?.company_name,
                              isSelected: isSelected,
                              isSelectedInMode: isSelectedInMode,
                              isSelectionMode: _isSelectionMode,
                              onSelectChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedBrandIds.add(brand.brand_id);
                                  } else {
                                    _selectedBrandIds.remove(brand.brand_id);
                                  }
                                });
                              },
                              onTap: () {
                                setState(() {
                                  _selectedBrand = brand;
                                });
                                if (!widget.isInDialog) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
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
                  if (_isSelectionMode && _selectedBrandIds.isNotEmpty)
                    Positioned(
                      bottom: 20 * fontSizeScale,
                      right: 20 * fontSizeScale,
                      child: FloatingActionButton.extended(
                        backgroundColor: AppTheme.accentGreen,
                        onPressed: () => _openShareDialog(displayedBrands),
                        label: Text('Share ${_selectedBrandIds.length} Items'),
                        icon: const Icon(Icons.share_rounded),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  void _openShareDialog(List<DrugBrandModel> displayedBrands) {
    final selectedBrands = displayedBrands.where((b) => _selectedBrandIds.contains(b.brand_id)).toList();
    final theme = _themeCtrl.currentTheme;
    final scale = _themeCtrl.fontSizeScale;

    showDialog(
      context: context,
      builder: (context) => _SharePreviewDialog(
        brands: selectedBrands,
        theme: theme,
        scale: scale,
      ),
    );
  }
}

class _SharePreviewDialog extends StatefulWidget {
  final List<DrugBrandModel> brands;
  final ThemeDefinition theme;
  final double scale;

  const _SharePreviewDialog({
    required this.brands,
    required this.theme,
    required this.scale,
  });

  @override
  State<_SharePreviewDialog> createState() => _SharePreviewDialogState();
}

class _SharePreviewDialogState extends State<_SharePreviewDialog> {
  final TextEditingController _noteCtrl = TextEditingController();

  void _shareAsText() {
    String text = "📋 DIMS Plus - Medicine Information\n";
    text += "──────────────────────────────\n\n";
    for (var b in widget.brands) {
      text += "💊 ${b.brand_name.toUpperCase()}\n";
      text += "Form: ${b.form ?? 'N/A'}\n";
      text += "Strength: ${b.strength ?? 'N/A'}\n\n";
    }
    if (_noteCtrl.text.isNotEmpty) {
      text += "📝 DOCTOR NOTES:\n${_noteCtrl.text}\n";
    }
    text += "\n──────────────────────────────\n";
    text += "Sent via DIMS Plus Desktop";
    
    Clipboard.setData(ClipboardData(text: text));
    
    Get.snackbar(
      'Copied to Clipboard', 
      'You can now paste this into WhatsApp or Facebook',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.accentGreen,
      colorText: Colors.white,
    );
    Navigator.pop(context);
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text("DIMS Plus - Medicine Information", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                ...widget.brands.map((b) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(b.brand_name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Form: ${b.form ?? ''} | Strength: ${b.strength ?? ''}", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                )),
                if (_noteCtrl.text.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  pw.Text("Doctor Notes:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(),
                  pw.Text(_noteCtrl.text, style: const pw.TextStyle(fontSize: 12)),
                ],
                pw.Spacer(),
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Generated by DIMS Plus", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.surfaceElevated,
      title: Row(
        children: [
          Icon(Icons.ios_share_rounded, color: widget.theme.accent, size: 20 * widget.scale),
          const SizedBox(width: 10),
          const Text('Share Information'),
        ],
      ),
      content: SizedBox(
        width: 500 * widget.scale,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SELECTED BRANDS:',
                style: TextStyle(
                  fontSize: 11 * widget.scale,
                  fontWeight: FontWeight.w700,
                  color: widget.theme.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.brands.map((b) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.theme.bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: widget.theme.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.brand_name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${b.form ?? ''} · ${b.strength ?? ''}', style: TextStyle(fontSize: 12 * widget.scale, color: widget.theme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 20),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                style: TextStyle(fontSize: 13 * widget.scale, color: widget.theme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Add Note (Dosage instructions, etc.)',
                  labelStyle: TextStyle(fontSize: 12 * widget.scale),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: widget.theme.bg,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: widget.theme.textSecondary)),
        ),
        ElevatedButton.icon(
          onPressed: _shareAsText,
          icon: const Icon(Icons.copy_rounded, size: 16),
          label: const Text('Share Text'),
          style: ElevatedButton.styleFrom(backgroundColor: widget.theme.accent, foregroundColor: Colors.white),
        ),
        ElevatedButton.icon(
          onPressed: _exportPDF,
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
          label: const Text('Save PDF'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen, foregroundColor: Colors.white),
        ),
      ],
    );
  }
}

class _BrandListItem extends StatefulWidget {
  final DrugBrandModel brand;
  final String? companyName;
  final bool isSelected;
  final bool isSelectedInMode;
  final bool isSelectionMode;
  final Function(bool?)? onSelectChanged;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;
  final bool showPrice;

  const _BrandListItem({
    required this.brand,
    this.companyName,
    required this.isSelected,
    this.isSelectedInMode = false,
    this.isSelectionMode = false,
    this.onSelectChanged,
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
        onTap: widget.isSelectionMode ? () => widget.onSelectChanged!(!widget.isSelectedInMode) : widget.onTap,
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
              if (widget.isSelectionMode)
                Checkbox(
                  value: widget.isSelectedInMode,
                  onChanged: widget.onSelectChanged,
                  activeColor: widget.theme.accent,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.brand_name,
                      style: TextStyle(
                        fontSize: 13 * widget.fontSizeScale,
                        fontWeight: (widget.isSelected || widget.isSelectedInMode) ? FontWeight.w600 : FontWeight.w500,
                        color: (widget.isSelected || widget.isSelectedInMode) ? widget.theme.accent : widget.theme.textPrimary,
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
