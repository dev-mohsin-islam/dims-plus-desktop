import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../controller/generic_ctrl.dart';
import '../../controller/company_ctrl.dart';
import '../../controller/theme_ctrl.dart';
import '../../models/brand/drug_brand_model.dart';
import 'app_theme.dart';
import 'brand_detail_screen.dart';

class GlobalSearchBar extends StatefulWidget {
  final Function(Widget, String) onNavigate;
  final Color? accentColor;
  final double? fontSizeScale;

  const GlobalSearchBar({
    Key? key,
    required this.onNavigate,
    this.accentColor,
    this.fontSizeScale,
  }) : super(key: key);

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  final TextEditingController _ctrl = TextEditingController();
  final DrugBrandCtrl _brandCtrl = Get.put(DrugBrandCtrl());
  final GenericCtrl _genericCtrl = Get.put(GenericCtrl());
  final CompanyCtrl _companyCtrl = Get.put(CompanyCtrl());
  final ThemeCtrl _themeCtrl = Get.put(ThemeCtrl());
  final FocusNode _focusNode = FocusNode();
  List<DrugBrandModel> _results = [];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // Get theme
  ThemeDefinition get _theme => _themeCtrl.currentTheme;
  Color get _accentColor => widget.accentColor ?? _theme.accent;
  double get _fontSizeScale => widget.fontSizeScale ?? _themeCtrl.fontSizeScale;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
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

    // Create BrandDetailView directly with the brand and theme props
    final brandDetailView = BrandDetailView(
      brand: brand,
      accentColor: _accentColor,
      fontSizeScale: _fontSizeScale,
    );

    // Navigate using the provided callback
    widget.onNavigate(brandDetailView, 'Brand: ${brand.brand_name}');
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
              constraints: BoxConstraints(maxHeight: 420 * _fontSizeScale),
              decoration: BoxDecoration(
                color: _theme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _theme.divider),
                boxShadow: [
                  BoxShadow(
                    color: _theme.isDark
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(0.1),
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
                      Text(
                        '${_results.length} results',
                        style: TextStyle(
                          fontSize: 11 * _fontSizeScale,
                          fontWeight: FontWeight.w600,
                          color: _theme.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Press Enter or click to open',
                        style: TextStyle(
                          fontSize: 11 * _fontSizeScale,
                          fontWeight: FontWeight.w600,
                          color: _theme.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ]),
                  ),
                  Divider(color: _theme.divider, height: 1),
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
                          theme: _theme,
                          accentColor: _accentColor,
                          fontSizeScale: _fontSizeScale,
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
        height: 42 * _fontSizeScale,
        decoration: BoxDecoration(
          color: _theme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _focusNode.hasFocus
                ? _accentColor.withOpacity(0.5)
                : _theme.divider,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 12 * _fontSizeScale),
            Icon(
              Icons.search_rounded,
              size: 18 * _fontSizeScale,
              color: _theme.textMuted,
            ),
            SizedBox(width: 10 * _fontSizeScale),
            Expanded(
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                style: TextStyle(
                  fontSize: 13 * _fontSizeScale,
                  fontWeight: FontWeight.w400,
                  color: _theme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by brand name or generic name...',
                  hintStyle: TextStyle(
                    color: _theme.textMuted,
                    fontSize: 13 * _fontSizeScale,
                  ),
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
                child: Padding(
                  padding: EdgeInsets.only(right: 10 * _fontSizeScale),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16 * _fontSizeScale,
                    color: _theme.textMuted,
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8 * _fontSizeScale,
                vertical: 4 * _fontSizeScale,
              ),
              margin: EdgeInsets.only(right: 8 * _fontSizeScale),
              decoration: BoxDecoration(
                color: _theme.surfaceHighlight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '⌘K',
                style: TextStyle(
                  fontSize: 10 * _fontSizeScale,
                  color: _theme.textMuted,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search result item ───────────────────────────────────────────────────────
class _SearchResultItem extends StatefulWidget {
  final DrugBrandModel brand;
  final String? genericName;
  final String? companyName;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final Color accentColor;
  final double fontSizeScale;

  const _SearchResultItem({
    required this.brand,
    this.genericName,
    this.companyName,
    required this.onTap,
    required this.theme,
    required this.accentColor,
    required this.fontSizeScale,
  });

  @override
  State<_SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<_SearchResultItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.put(ThemeCtrl());
    final showStrength = themeCtrl.showStrengthInSearch.value;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: _hover ? widget.theme.surfaceHighlight : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34 * widget.fontSizeScale,
                height: 34 * widget.fontSizeScale,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_pharmacy_outlined,
                  size: 16 * widget.fontSizeScale,
                  color: widget.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.brand.brand_name,
                      style: TextStyle(
                        fontSize: 13 * widget.fontSizeScale,
                        fontWeight: FontWeight.w600,
                        color: widget.theme.textPrimary,
                      ),
                    ),
                    if (widget.genericName != null)
                      Text(
                        widget.genericName!,
                        style: TextStyle(
                          fontSize: 11 * widget.fontSizeScale,
                          color: widget.theme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showStrength) ...[
                    Row(children: [
                      if (widget.brand.strength != null) ...[
                        _Chip(
                          widget.brand.strength!,
                          widget.accentColor,
                          widget.fontSizeScale,
                          widget.theme,
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (widget.brand.form != null)
                        _Chip(
                          widget.brand.form!,
                          AppTheme.accentGreen,
                          widget.fontSizeScale,
                          widget.theme,
                        ),
                    ]),
                  ],
                  if (widget.companyName != null)
                    Text(
                      widget.companyName!,
                      style: TextStyle(
                        fontSize: 10 * widget.fontSizeScale,
                        color: widget.theme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
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

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSizeScale;
  final ThemeDefinition theme;

  const _Chip(this.label, this.color, this.fontSizeScale, this.theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
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