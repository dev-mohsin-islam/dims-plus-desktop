import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../controller/generic_ctrl.dart';
import '../../controller/company_ctrl.dart';
import '../../models/brand/drug_brand_model.dart';
import 'app_theme.dart';
import 'brand_detail_screen.dart';

class GlobalSearchBar extends StatefulWidget {
  final Function(Widget, String) onNavigate;
  const GlobalSearchBar({Key? key, required this.onNavigate}) : super(key: key);
  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  final TextEditingController _ctrl = TextEditingController();
  final DrugBrandCtrl _brandCtrl = Get.find<DrugBrandCtrl>();
  final GenericCtrl _genericCtrl = Get.find<GenericCtrl>();
  final CompanyCtrl _companyCtrl = Get.find<CompanyCtrl>();
  final FocusNode _focusNode = FocusNode();
  List<DrugBrandModel> _results = [];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Small delay to allow tap on overlay item first
        Future.delayed(const Duration(milliseconds: 200), _hideOverlay);
      }
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      _hideOverlay();
      return;
    }

    final term = query.toLowerCase();
    final matchingGenericIds = _genericCtrl.genericList
        .where((g) => g.generic_name.toLowerCase().contains(term))
        .map((g) => g.generic_id.toString())
        .toSet();

    final results = _brandCtrl.drugBrandList.where((b) {
      return b.brand_name.toLowerCase().contains(term) ||
          matchingGenericIds.contains(b.generic_id.toString()) ||
          (b.strength?.toLowerCase().contains(term) ?? false) ||
          (b.form?.toLowerCase().contains(term) ?? false);
    }).take(25).toList();

    setState(() => _results = results);
    if (results.isNotEmpty) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    _hideOverlay();
    _overlayEntry = _buildOverlay();
    if (mounted && Overlay.of(context) != null) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectBrand(DrugBrandModel brand) {
    _hideOverlay();
    _ctrl.clear();
    setState(() => _results = []);
    // Navigate to a dedicated brand detail page wrapper
    widget.onNavigate(
      _BrandDetailPage(brand: brand),
      'Search: ${brand.brand_name}',
    );
  }

  OverlayEntry _buildOverlay() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return OverlayEntry(builder: (_) => const SizedBox.shrink());
    final size = box.size;

    return OverlayEntry(
      builder: (_) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 420),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(children: [
                      Text('${_results.length} results', style: AppTheme.label),
                      const Spacer(),
                      Text('Press Enter or click to open',
                          style: AppTheme.label.copyWith(color: AppTheme.textMuted)),
                    ]),
                  ),
                  const Divider(color: AppTheme.divider, height: 1),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final b = _results[i];
                        final generic = _genericCtrl.genericList
                            .firstWhereOrNull(
                                (g) => g.generic_id.toString() == b.generic_id.toString());
                        final company = _companyCtrl.getCompanyById(b.company_id);
                        return _SearchResultItem(
                          brand: b,
                          genericName: generic?.generic_name,
                          companyName: company?.company_name,
                          onTap: () => _selectBrand(b),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _focusNode.hasFocus
                ? AppTheme.accent.withOpacity(0.5)
                : AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search_rounded, size: 18, color: AppTheme.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                style: AppTheme.bodyPrimary,
                decoration: const InputDecoration(
                  hintText: 'Search by brand name or generic name...',
                  hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: _search,
                onSubmitted: (q) {
                  if (_results.isNotEmpty) _selectBrand(_results.first);
                },
              ),
            ),
            if (_ctrl.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  _hideOverlay();
                  setState(() => _results = []);
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceHighlight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('⌘K',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      fontFamily: 'monospace')),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Full-page brand detail wrapper ──────────────────────────────────────────
// Shown when user clicks a search result — includes back breadcrumb

class _BrandDetailPage extends StatelessWidget {
  final DrugBrandModel brand;
  const _BrandDetailPage({required this.brand});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(bottom: BorderSide(color: AppTheme.divider)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text('Search Result', style: AppTheme.label),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Text(brand.brand_name, style: AppTheme.label.copyWith(color: AppTheme.accent)),
            ],
          ),
        ),
        Expanded(child: BrandDetailView(brand: brand)),
      ],
    );
  }
}

// ─── Search result item ───────────────────────────────────────────────────────

class _SearchResultItem extends StatefulWidget {
  final DrugBrandModel brand;
  final String? genericName;
  final String? companyName;
  final VoidCallback onTap;
  const _SearchResultItem({
    required this.brand,
    this.genericName,
    this.companyName,
    required this.onTap,
  });
  @override
  State<_SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<_SearchResultItem> {
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
          color: _hover ? AppTheme.surfaceHighlight : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_pharmacy_outlined,
                    size: 16, color: AppTheme.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.brand.brand_name,
                        style: AppTheme.bodyPrimary
                            .copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                    if (widget.genericName != null)
                      Text(widget.genericName!,
                          style: AppTheme.bodySecondary.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(children: [
                    if (widget.brand.strength != null) ...[
                      _Chip(widget.brand.strength!, AppTheme.accent),
                      const SizedBox(width: 4),
                    ],
                    if (widget.brand.form != null)
                      _Chip(widget.brand.form!, AppTheme.accentGreen),
                  ]),
                  if (widget.companyName != null)
                    Text(widget.companyName!,
                        style: AppTheme.bodySecondary.copyWith(fontSize: 10),
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: AppTheme.chip.copyWith(color: color, fontSize: 10)),
    );
  }
}
