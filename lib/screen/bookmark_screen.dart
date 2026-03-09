import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../controller/favourite_ctrl.dart';
import '../controller/drug_brand_ctrl.dart';
import '../controller/generic_ctrl.dart';
import '../controller/theme_ctrl.dart';
import '../models/favourite/favourite_model.dart';
import '../models/brand/drug_brand_model.dart';
import 'app_theme.dart';
import 'brand_detail_screen.dart';
import 'generics_screen.dart';
import 'search_input.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  String _selectedFilter = 'All'; 
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  
  bool _isSelectionMode = false;
  final Set<String> _selectedFavKeys = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favCtrl = Get.find<FavouriteCtrl>();
    final themeCtrl = Get.find<ThemeCtrl>();
    final brandCtrl = Get.find<DrugBrandCtrl>();
    final genericCtrl = Get.find<GenericCtrl>();

    return Obx(() {
      final theme = themeCtrl.currentTheme;
      final scale = themeCtrl.fontSizeScale;
      
      var bookmarks = favCtrl.favourites;
      if (_selectedFilter != 'All') {
        bookmarks = bookmarks.where((f) => f.category == _selectedFilter.toLowerCase()).toList().obs;
      }

      if (_searchQuery.isNotEmpty) {
        bookmarks = bookmarks.where((f) {
          if (f.category == 'brand') {
            final b = brandCtrl.drugBrandList.firstWhereOrNull((brand) => brand.brand_id == f.targetId);
            return b?.brand_name.toLowerCase().contains(_searchQuery) ?? false;
          } else {
            final g = genericCtrl.genericList.firstWhereOrNull((gen) => gen.generic_id == f.targetId);
            return g?.generic_name.toLowerCase().contains(_searchQuery) ?? false;
          }
        }).toList().obs;
      }

      return Container(
        color: theme.bg,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(bottom: BorderSide(color: theme.divider)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.bookmark_rounded, color: AppTheme.accentAmber, size: 20 * scale),
                      const SizedBox(width: 12),
                      Text(
                        'Bookmarked Medicines',
                        style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w700, color: theme.textPrimary),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _isSelectionMode ? Icons.check_circle : Icons.ios_share_rounded,
                          color: _isSelectionMode ? AppTheme.accentGreen : theme.accent,
                          size: 20 * scale,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSelectionMode = !_isSelectionMode;
                            if (!_isSelectionMode) _selectedFavKeys.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SearchInput(
                          controller: _searchCtrl,
                          hint: 'Search in bookmarks...',
                          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase().trim()),
                          fontSizeScale: scale,
                          accentColor: theme.accent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _filterChip('All', theme, scale),
                      const SizedBox(width: 8),
                      _filterChip('Brand', theme, scale),
                      const SizedBox(width: 8),
                      _filterChip('Generic', theme, scale),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Stack(
                children: [
                  bookmarks.isEmpty
                      ? _buildEmptyState(theme, scale)
                      : ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: bookmarks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final fav = bookmarks[index];
                            final isSelected = _selectedFavKeys.contains(fav.uniqueKey);
                            return _buildBookmarkTile(context, fav, brandCtrl, genericCtrl, theme, scale, isSelected);
                          },
                        ),
                  
                  if (_isSelectionMode && _selectedFavKeys.isNotEmpty)
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: FloatingActionButton.extended(
                        backgroundColor: AppTheme.accentGreen,
                        onPressed: () => _openShareDialog(bookmarks, brandCtrl, genericCtrl, theme, scale),
                        label: Text('Share ${_selectedFavKeys.length} Items'),
                        icon: const Icon(Icons.share_rounded),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _filterChip(String label, ThemeDefinition theme, double scale) {
    final isSelected = _selectedFilter == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.accent : theme.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? theme.accent : theme.divider),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 12 * scale, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : theme.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkTile(
    BuildContext context,
    FavouriteModel fav,
    DrugBrandCtrl brandCtrl,
    GenericCtrl genericCtrl,
    ThemeDefinition theme,
    double scale,
    bool isSelected,
  ) {
    String name = "Unknown";
    String subtitle = "";
    IconData icon = Icons.medication_rounded;
    Color iconColor = theme.accent;
    dynamic targetData;

    if (fav.category == 'brand') {
      targetData = brandCtrl.drugBrandList.firstWhereOrNull((b) => b.brand_id == fav.targetId);
      if (targetData != null) {
        name = targetData.brand_name;
        subtitle = "Brand · ${targetData.strength ?? ''} ${targetData.form ?? ''}";
        icon = Icons.local_pharmacy_rounded;
      }
    } else if (fav.category == 'generic') {
      targetData = genericCtrl.genericList.firstWhereOrNull((g) => g.generic_id == fav.targetId);
      if (targetData != null) {
        name = targetData.generic_name;
        subtitle = "Generic Molecule";
        icon = Icons.science_rounded;
        iconColor = AppTheme.accentGreen;
      }
    }

    if (targetData == null) return const SizedBox.shrink();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (_isSelectionMode) {
            setState(() {
              if (isSelected) _selectedFavKeys.remove(fav.uniqueKey);
              else _selectedFavKeys.add(fav.uniqueKey);
            });
          } else {
            _showDetails(context, fav, targetData, theme, scale);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? theme.accent.withOpacity(0.05) : theme.surface,
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: isSelected ? theme.accent : theme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_isSelectionMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (v) => setState(() {
                        if (v == true) _selectedFavKeys.add(fav.uniqueKey);
                        else _selectedFavKeys.remove(fav.uniqueKey);
                      }),
                      activeColor: theme.accent,
                    ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 20 * scale),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                        Text(subtitle, style: TextStyle(fontSize: 12 * scale, color: theme.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_note_rounded, color: theme.accent, size: 20 * scale),
                    onPressed: () => _showEditNoteDialog(context, fav, theme, scale),
                    tooltip: 'Edit Note',
                  ),
                  if (!_isSelectionMode)
                    IconButton(
                      onPressed: () => Get.find<FavouriteCtrl>().toggleFavourite(fav.targetId, fav.category),
                      icon: const Icon(Icons.bookmark_rounded, color: AppTheme.accentAmber),
                    ),
                ],
              ),
              if (fav.notes != null && fav.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 56),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.divider),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notes_rounded, size: 14 * scale, color: theme.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fav.notes!,
                            style: TextStyle(fontSize: 12 * scale, color: theme.textSecondary, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, FavouriteModel fav, ThemeDefinition theme, double scale) {
    final noteCtrl = TextEditingController(text: fav.notes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surfaceElevated,
        title: const Text('Add/Edit Note'),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter dosage or patient specific instructions...', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.find<FavouriteCtrl>().updateNote(fav.targetId, fav.category, noteCtrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, FavouriteModel fav, dynamic data, ThemeDefinition theme, double scale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale), side: BorderSide(color: theme.divider)),
        title: Row(
          children: [
            Text(fav.category == 'brand' ? 'Brand Details' : 'Generic Details', style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.w600, color: theme.textPrimary)),
            const Spacer(),
            IconButton(icon: Icon(Icons.close, size: 20 * scale, color: theme.textSecondary), onPressed: () => Navigator.pop(context)),
          ],
        ),
        content: SizedBox(
          width: 900 * scale,
          height: 600 * scale,
          child: fav.category == 'brand' 
            ? BrandDetailView(brand: data, accentColor: theme.accent, fontSizeScale: scale)
            : _buildGenericDetailView(data, theme, scale),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeDefinition theme, double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline_rounded, size: 64 * scale, color: theme.textMuted),
          const SizedBox(height: 16),
          Text(_searchQuery.isEmpty ? 'No bookmarks yet' : 'No results found', style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.w600, color: theme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildGenericDetailView(dynamic generic, ThemeDefinition theme, double scale) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(14 * scale), border: Border.all(color: theme.divider)),
            child: Row(
              children: [
                Icon(Icons.science_outlined, color: AppTheme.accentGreen, size: 32 * scale),
                const SizedBox(width: 16),
                Text(generic.generic_name, style: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.w700, color: theme.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _infoItem('Indication', generic.indication, Icons.info_outline, theme, scale),
          _infoItem('Dose', generic.dose, Icons.medication_outlined, theme, scale),
        ],
      ),
    );
  }

  Widget _infoItem(String title, String? content, IconData icon, ThemeDefinition theme, double scale) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16 * scale, color: theme.accent),
              const SizedBox(width: 8),
              Text(title.toUpperCase(), style: TextStyle(fontSize: 11 * scale, fontWeight: FontWeight.w600, color: theme.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 13 * scale, color: theme.textPrimary, height: 1.5)),
        ],
      ),
    );
  }

  void _openShareDialog(List<FavouriteModel> bookmarks, DrugBrandCtrl brandCtrl, GenericCtrl genericCtrl, ThemeDefinition theme, double scale) {
    final selectedFavs = bookmarks.where((f) => _selectedFavKeys.contains(f.uniqueKey)).toList();
    showDialog(
      context: context,
      builder: (context) => _BookmarkShareDialog(
        selectedFavs: selectedFavs,
        brandCtrl: brandCtrl,
        genericCtrl: genericCtrl,
        theme: theme,
        scale: scale,
      ),
    );
  }
}

class _BookmarkShareDialog extends StatefulWidget {
  final List<FavouriteModel> selectedFavs;
  final DrugBrandCtrl brandCtrl;
  final GenericCtrl genericCtrl;
  final ThemeDefinition theme;
  final double scale;

  const _BookmarkShareDialog({
    required this.selectedFavs,
    required this.brandCtrl,
    required this.genericCtrl,
    required this.theme,
    required this.scale,
  });

  @override
  State<_BookmarkShareDialog> createState() => _BookmarkShareDialogState();
}

class _BookmarkShareDialogState extends State<_BookmarkShareDialog> {
  final TextEditingController _globalNoteCtrl = TextEditingController();

  void _shareAsText() {
    String text = "📋 DIMS Plus - Medicine Information\n";
    text += "──────────────────────────────\n\n";
    
    for (var fav in widget.selectedFavs) {
      if (fav.category == 'brand') {
        final b = widget.brandCtrl.drugBrandList.firstWhereOrNull((brand) => brand.brand_id == fav.targetId);
        if (b != null) {
          text += "💊 ${b.brand_name} (${b.form ?? ''}) - ${b.strength ?? ''}\n";
          if (fav.notes != null) text += "   Note: ${fav.notes}\n";
        }
      } else {
        final g = widget.genericCtrl.genericList.firstWhereOrNull((gen) => gen.generic_id == fav.targetId);
        if (g != null) {
          text += "🧪 ${g.generic_name}\n";
          if (fav.notes != null) text += "   Note: ${fav.notes}\n";
        }
      }
      text += "\n";
    }

    if (_globalNoteCtrl.text.isNotEmpty) {
      text += "📝 ADDITIONAL NOTES:\n${_globalNoteCtrl.text}\n";
    }
    
    text += "──────────────────────────────\n";
    text += "Sent via DIMS Plus Desktop";
    
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar('Copied', 'Information copied for sharing (WhatsApp/FB)');
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
                pw.Header(level: 0, text: "DIMS Plus Medicine Information"),
                pw.SizedBox(height: 20),
                ...widget.selectedFavs.map((fav) {
                  String name = "";
                  String details = "";
                  if (fav.category == 'brand') {
                    final b = widget.brandCtrl.drugBrandList.firstWhereOrNull((br) => br.brand_id == fav.targetId);
                    name = b?.brand_name ?? "Brand";
                    details = "${b?.form ?? ''} ${b?.strength ?? ''}";
                  } else {
                    final g = widget.genericCtrl.genericList.firstWhereOrNull((ge) => ge.generic_id == fav.targetId);
                    name = g?.generic_name ?? "Generic";
                  }
                  
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        if (details.isNotEmpty) pw.Text(details, style: const pw.TextStyle(fontSize: 10)),
                        if (fav.notes != null) pw.Text("Note: ${fav.notes}", style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
                        pw.Divider(thickness: 0.5),
                      ],
                    ),
                  );
                }).toList(),
                if (_globalNoteCtrl.text.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  pw.Text("Additional Notes:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(_globalNoteCtrl.text),
                ],
                pw.Spacer(),
                pw.Text("Generated by DIMS Plus", style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.surfaceElevated,
      title: const Text('Share Bookmarks'),
      content: SizedBox(
        width: 450 * widget.scale,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _globalNoteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Add Global Note (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              Text('Sharing ${widget.selectedFavs.length} items with their individual notes.',
                   style: TextStyle(fontSize: 12 * widget.scale, color: widget.theme.textSecondary)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _shareAsText, child: const Text('Share Text')),
        ElevatedButton(onPressed: _exportPDF, child: const Text('Save PDF')),
      ],
    );
  }
}
