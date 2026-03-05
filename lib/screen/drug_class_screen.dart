import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/systemic_class_ctrl.dart';
import '../../controller/therapeutic_class_ctrl.dart';
import '../../controller/therapeutic_generic_index_ctrl.dart';
import '../../controller/generic_ctrl.dart';
import '../../controller/drug_brand_ctrl.dart';
import '../../controller/company_ctrl.dart';
import '../../controller/theme_ctrl.dart';
import '../../models/systemic_class/systemic_class_model.dart';
import '../../models/therapeutic_class/therapeutic_class_model.dart';
import '../../models/generic/generic_details_model.dart';
import '../../models/brand/drug_brand_model.dart';
import 'app_theme.dart';
import 'brand_detail_screen.dart';

// Extension for firstWhereOrNull
extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class DrugClassScreen extends StatefulWidget {
  const DrugClassScreen({Key? key}) : super(key: key);
  @override
  State<DrugClassScreen> createState() => _DrugClassScreenState();
}

class _DrugClassScreenState extends State<DrugClassScreen> {
  final SystemicClassCtrl _sysCtrl = Get.find<SystemicClassCtrl>();
  final TherapeuticClassCtrl _therapCtrl = Get.find<TherapeuticClassCtrl>();
  final ThemeCtrl _themeCtrl = Get.put(ThemeCtrl());
  final TextEditingController _treeSearch = TextEditingController();
  String _treeQuery = '';

  String? _selectedSystemicId;
  TherapeuticClassModel? _selectedTherapeutic;
  GenericDetailsModel? _selectedGeneric;

  @override
  void initState() {
    super.initState();
    print('🔍 DrugClassScreen initState - Checking controllers:');
    print('  - SystemicClassCtrl: ${_sysCtrl.runtimeType}');
    print('  - TherapeuticClassCtrl: ${_therapCtrl.runtimeType}');
    print('  - SystemicClassList length: ${_sysCtrl.systemicClassList.length}');
    print('  - TherapeuticClassList length: ${_therapCtrl.therapeuticClassList.length}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugCheckData();
    });
  }

  void _debugCheckData() {
    print('\n🔍 DEBUG DATA CHECK:');
    final genericCtrl = Get.put(GenericCtrl());
    print('GenericCtrl.genericList length: ${genericCtrl.genericList.length}');

    if (genericCtrl.genericList.isNotEmpty) {
      print('\nSample of first 10 generics:');
      for (int i = 0; i < genericCtrl.genericList.length && i < 10; i++) {
        final g = genericCtrl.genericList[i];
        print('  - ID: ${g.generic_id}, Name: ${g.generic_name}');
      }
    } else {
      print('⚠️ GenericCtrl.genericList is EMPTY!');
    }

    final tgiCtrl = Get.find<TherapeuticGenIndCtrl>();
    print('\nTherapeuticGenIndCtrl check:');
    if (_selectedTherapeutic != null) {
      final ids = tgiCtrl.getGenericIdsByTherapeuticClass(_selectedTherapeutic!.id);
      print('  - Generic IDs for selected therapeutic: $ids');
    }
  }

  @override
  void dispose() {
    _treeSearch.dispose();
    super.dispose();
  }

  void _onSystemicTap(SystemicClassModel s) {
    print('🔍 TAPPED Systemic Class: ${s.id} - ${s.name}');
    setState(() {
      _selectedSystemicId = s.id?.toString();
      _selectedTherapeutic = null;
      _selectedGeneric = null;
    });
    print('  → _selectedSystemicId set to: $_selectedSystemicId');
  }

  void _onTherapeuticTap(TherapeuticClassModel t) {
    print('🔍 TAPPED Therapeutic Class: ${t.id} - ${t.name}');
    setState(() {
      _selectedTherapeutic = t;
      _selectedGeneric = null;
    });
    print('  → _selectedTherapeutic set to: ${t.id} - ${t.name}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tgiCtrl = Get.find<TherapeuticGenIndCtrl>();
      final genericCtrl = Get.put(GenericCtrl());

      final ids = tgiCtrl.getGenericIdsByTherapeuticClass(t.id);
      print('  → Generic IDs from TGI: $ids');

      if (ids.isNotEmpty) {
        final stringIds = ids.map((id) => id.toString()).toList();
        final generics = genericCtrl.genericList
            .where((g) => stringIds.contains(g.generic_id.toString()))
            .toList();
        print('  → Found ${generics.length} generics in GenericCtrl');
      }
    });
  }

  void _onGenericTap(GenericDetailsModel g) {
    print('🔍 TAPPED Generic: ${g.generic_id} - ${g.generic_name}');
    setState(() => _selectedGeneric = g);
    print('  → _selectedGeneric set to: ${g.generic_id} - ${g.generic_name}');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = _themeCtrl.currentTheme;
      final fontSizeScale = _themeCtrl.fontSizeScale;
      final accentColor = theme.accent;

      print('🔍 REBUILD DrugClassScreen - Selected: Systemic: $_selectedSystemicId, Therapeutic: ${_selectedTherapeutic?.id}, Generic: ${_selectedGeneric?.generic_id}');

      return Row(
        children: [
          // ── Panel 1: Systemic Class tree ──────────────────────────────────
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(right: BorderSide(color: theme.divider)),
            ),
            child: Column(
              children: [
                _PanelHeader(
                  title: 'Drug Classes',
                  icon: Icons.category_outlined,
                  theme: theme,
                  fontSizeScale: fontSizeScale,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SearchInput(
                    controller: _treeSearch,
                    hint: 'Search drug classes...',
                    onChanged: (q) => setState(() => _treeQuery = q.toLowerCase().trim()),
                    fontSizeScale: fontSizeScale,
                    accentColor: accentColor,
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    print('🔍 PANEL 1 - Building with ${_sysCtrl.systemicClassList.length} systemics and ${_therapCtrl.therapeuticClassList.length} therapeutics');

                    final systemics = _sysCtrl.systemicClassList;
                    final therapeutics = _therapCtrl.therapeuticClassList;

                    if (systemics.isEmpty && therapeutics.isEmpty) {
                      print('⚠️ PANEL 1 - No data loaded');
                      return Center(
                        child: Text(
                          'No data loaded',
                          style: TextStyle(
                            fontSize: 13 * fontSizeScale,
                            color: theme.textMuted,
                          ),
                        ),
                      );
                    }

                    final Map<String, int> tCount = {};
                    for (final t in therapeutics) {
                      final k = t.systemic_class_id?.toString() ?? '';
                      if (k.isNotEmpty) {
                        tCount[k] = (tCount[k] ?? 0) + 1;
                      }
                    }

                    final roots = systemics
                        .where((s) =>
                    s.parent_id == null ||
                        s.parent_id == 0 ||
                        s.parent_id.toString() == '0')
                        .toList();

                    if (roots.isEmpty) {
                      print('⚠️ PANEL 1 - No root nodes, showing flat therapeutics');
                      final list = _treeQuery.isEmpty
                          ? therapeutics
                          : therapeutics
                          .where((t) => t.name.toLowerCase().contains(_treeQuery))
                          .toList();
                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, i) => _TherapeuticFlatItem(
                          therapeutic: list[i],
                          isSelected: _selectedTherapeutic?.id?.toString() == list[i].id?.toString(),
                          onTap: () => _onTherapeuticTap(list[i]),
                          theme: theme,
                          fontSizeScale: fontSizeScale,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: roots.length,
                      itemBuilder: (_, i) => _SystemicNode(
                        systemic: roots[i],
                        allSystemics: systemics,
                        therapeuticCount: tCount,
                        searchQuery: _treeQuery,
                        selectedId: _selectedSystemicId,
                        onTap: _onSystemicTap,
                        theme: theme,
                        fontSizeScale: fontSizeScale,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ── Panel 2: Therapeutic classes ──────────────────────────────────
          if (_selectedSystemicId != null)
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(right: BorderSide(color: theme.divider)),
              ),
              child: _TherapeuticPanel(
                systemicId: _selectedSystemicId!,
                selectedId: _selectedTherapeutic?.id?.toString(),
                onTap: _onTherapeuticTap,
                theme: theme,
                fontSizeScale: fontSizeScale,
              ),
            ),

          // ── Panel 3: Generics ─────────────────────────────────────────────
          if (_selectedTherapeutic != null)
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(right: BorderSide(color: theme.divider)),
              ),
              child: _GenericsPanel(
                therapeutic: _selectedTherapeutic!,
                selectedGenericId: _selectedGeneric?.generic_id?.toString(),
                onTap: _onGenericTap,
                theme: theme,
                fontSizeScale: fontSizeScale,
              ),
            ),

          // ── Panel 4: Brands + detail ──────────────────────────────────────
          Expanded(
            child: _selectedGeneric != null
                ? _BrandsPanel(
              generic: _selectedGeneric!,
              theme: theme,
              fontSizeScale: fontSizeScale,
            )
                : _selectedTherapeutic != null
                ? _EmptyHint(
              icon: Icons.science_outlined,
              message: 'Select a generic to view brands',
              theme: theme,
              fontSizeScale: fontSizeScale,
            )
                : _selectedSystemicId != null
                ? _EmptyHint(
              icon: Icons.device_hub_outlined,
              message: 'Select a therapeutic class',
              theme: theme,
              fontSizeScale: fontSizeScale,
            )
                : _EmptyHint(
              icon: Icons.category_outlined,
              message: 'Select a drug class to begin',
              theme: theme,
              fontSizeScale: fontSizeScale,
            ),
          ),
        ],
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Panel 1 — Recursive Systemic Node
// ══════════════════════════════════════════════════════════════════════════════

class _SystemicNode extends StatefulWidget {
  final SystemicClassModel systemic;
  final List<SystemicClassModel> allSystemics;
  final Map<String, int> therapeuticCount;
  final String searchQuery;
  final String? selectedId;
  final Function(SystemicClassModel) onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _SystemicNode({
    required this.systemic,
    required this.allSystemics,
    required this.therapeuticCount,
    required this.searchQuery,
    required this.onTap,
    this.selectedId,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_SystemicNode> createState() => _SystemicNodeState();
}

class _SystemicNodeState extends State<_SystemicNode> {
  bool _expanded = false;

  bool get _isSelected => widget.selectedId == widget.systemic.id?.toString();

  @override
  void initState() {
    super.initState();
    print('🔍 _SystemicNode init: ${widget.systemic.name} (ID: ${widget.systemic.id})');
  }

  @override
  Widget build(BuildContext context) {
    final myId = widget.systemic.id?.toString() ?? '';

    final children = widget.allSystemics
        .where((s) => s.parent_id != null && s.parent_id.toString() == myId)
        .toList();
    final hasChildren = children.isNotEmpty;
    final tCount = widget.therapeuticCount[myId] ?? 0;

    if (widget.searchQuery.isNotEmpty) {
      final nameMatch = widget.systemic.name.toLowerCase().contains(widget.searchQuery);
      final childMatch = children.any((c) => c.name.toLowerCase().contains(widget.searchQuery));
      if (!nameMatch && !childMatch) return const SizedBox.shrink();
      if (!_expanded && childMatch) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _expanded = true);
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              widget.onTap(widget.systemic);
              if (hasChildren) setState(() => _expanded = !_expanded);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: _isSelected ? widget.theme.accent.withOpacity(0.12) : Colors.transparent,
                border: Border(
                  bottom: BorderSide(color: widget.theme.divider.withOpacity(0.4)),
                  left: BorderSide(
                      color: _isSelected ? widget.theme.accent : Colors.transparent,
                      width: 3),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 12 * widget.fontSizeScale,
                vertical: 10 * widget.fontSizeScale,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 18 * widget.fontSizeScale,
                    child: hasChildren
                        ? Icon(
                      _expanded
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_right_rounded,
                      size: 16 * widget.fontSizeScale,
                      color: _isSelected ? widget.theme.accent : widget.theme.textMuted,
                    )
                        : Center(
                      child: Container(
                        width: 5 * widget.fontSizeScale,
                        height: 5 * widget.fontSizeScale,
                        decoration: BoxDecoration(
                          color: _isSelected ? widget.theme.accent : widget.theme.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.systemic.name,
                      style: TextStyle(
                        fontSize: 13 * widget.fontSizeScale,
                        fontWeight: _isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: _isSelected ? widget.theme.accent : widget.theme.textPrimary,
                      ),
                    ),
                  ),
                  if (tCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6 * widget.fontSizeScale,
                        vertical: 1 * widget.fontSizeScale,
                      ),
                      decoration: BoxDecoration(
                        color: widget.theme.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8 * widget.fontSizeScale),
                      ),
                      child: Text(
                        '$tCount',
                        style: TextStyle(
                          fontSize: 11 * widget.fontSizeScale,
                          fontWeight: FontWeight.w600,
                          color: widget.theme.accent,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded && hasChildren)
          Padding(
            padding: EdgeInsets.only(left: 14 * widget.fontSizeScale),
            child: Column(
              children: children.map((child) => _SystemicNode(
                systemic: child,
                allSystemics: widget.allSystemics,
                therapeuticCount: widget.therapeuticCount,
                searchQuery: widget.searchQuery,
                selectedId: widget.selectedId,
                onTap: widget.onTap,
                theme: widget.theme,
                fontSizeScale: widget.fontSizeScale,
              )).toList(),
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Therapeutic Flat Item (when no systemic hierarchy)
// ══════════════════════════════════════════════════════════════════════════════

class _TherapeuticFlatItem extends StatefulWidget {
  final TherapeuticClassModel therapeutic;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _TherapeuticFlatItem({
    required this.therapeutic,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_TherapeuticFlatItem> createState() => _TherapeuticFlatItemState();
}

class _TherapeuticFlatItemState extends State<_TherapeuticFlatItem> {
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    print('🔍 _TherapeuticFlatItem init: ${widget.therapeutic.name}');
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: widget.isSelected
              ? widget.theme.accent.withOpacity(0.12)
              : _hover ? widget.theme.surfaceHighlight : Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * widget.fontSizeScale,
            vertical: 10 * widget.fontSizeScale,
          ),
          child: Text(
            widget.therapeutic.name,
            style: TextStyle(
              fontSize: 13 * widget.fontSizeScale,
              color: widget.isSelected ? widget.theme.accent : widget.theme.textSecondary,
              fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Panel 2 — Therapeutic Classes
// ══════════════════════════════════════════════════════════════════════════════

class _TherapeuticPanel extends StatefulWidget {
  final String systemicId;
  final String? selectedId;
  final Function(TherapeuticClassModel) onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _TherapeuticPanel({
    required this.systemicId,
    required this.onTap,
    this.selectedId,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_TherapeuticPanel> createState() => _TherapeuticPanelState();
}

class _TherapeuticPanelState extends State<_TherapeuticPanel> {
  final TextEditingController _search = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    print('🔍 PANEL 2 init - systemicId: ${widget.systemicId}');
  }

  @override
  void didUpdateWidget(_TherapeuticPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.systemicId != widget.systemicId) {
      setState(() {
        _q = '';
        _search.clear();
      });
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final therapCtrl = Get.find<TherapeuticClassCtrl>();
    final sysCtrl = Get.find<SystemicClassCtrl>();

    return Obx(() {
      final systemic = sysCtrl.systemicClassList
          .firstWhereOrNull((s) => s.id?.toString() == widget.systemicId);

      final all = therapCtrl.therapeuticClassList
          .where((t) => t.systemic_class_id?.toString() == widget.systemicId)
          .toList();

      final displayed = _q.isEmpty
          ? all
          : all.where((t) => t.name.toLowerCase().contains(_q)).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14 * widget.fontSizeScale,
              vertical: 12 * widget.fontSizeScale,
            ),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: widget.theme.divider)),
            ),
            child: Row(children: [
              Icon(
                Icons.device_hub_outlined,
                size: 14 * widget.fontSizeScale,
                color: widget.theme.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  systemic?.name ?? 'Therapeutic Classes',
                  style: TextStyle(
                    fontSize: 14 * widget.fontSizeScale,
                    fontWeight: FontWeight.w600,
                    color: widget.theme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
          Padding(
            padding: EdgeInsets.all(10 * widget.fontSizeScale),
            child: SearchInput(
              controller: _search,
              hint: 'Search therapeutic...',
              onChanged: (q) => setState(() => _q = q.toLowerCase().trim()),
              fontSizeScale: widget.fontSizeScale,
              accentColor: widget.theme.accent,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14 * widget.fontSizeScale,
              vertical: 2 * widget.fontSizeScale,
            ),
            child: Text(
              '${displayed.length} classes',
              style: TextStyle(
                fontSize: 11 * widget.fontSizeScale,
                fontWeight: FontWeight.w600,
                color: widget.theme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: displayed.isEmpty
                ? Center(
              child: Text(
                'No therapeutic classes',
                style: TextStyle(
                  fontSize: 13 * widget.fontSizeScale,
                  color: widget.theme.textMuted,
                ),
              ),
            )
                : ListView.builder(
              itemCount: displayed.length,
              itemBuilder: (_, i) {
                final t = displayed[i];
                return _ListItem(
                  label: t.name,
                  isSelected: widget.selectedId == t.id?.toString(),
                  color: AppTheme.accentGreen,
                  onTap: () => widget.onTap(t),
                  theme: widget.theme,
                  fontSizeScale: widget.fontSizeScale,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Panel 3 — Generics
// ══════════════════════════════════════════════════════════════════════════════

class _GenericsPanel extends StatefulWidget {
  final TherapeuticClassModel therapeutic;
  final String? selectedGenericId;
  final Function(GenericDetailsModel) onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _GenericsPanel({
    required this.therapeutic,
    required this.onTap,
    this.selectedGenericId,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_GenericsPanel> createState() => _GenericsPanelState();
}

class _GenericsPanelState extends State<_GenericsPanel> {
  final TextEditingController _search = TextEditingController();
  String _q = '';
  List<GenericDetailsModel> _generics = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('🔍 PANEL 3 init - therapeutic: ${widget.therapeutic.id} - ${widget.therapeutic.name}');
    _loadGenerics();
  }

  @override
  void didUpdateWidget(_GenericsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.therapeutic.id != widget.therapeutic.id) {
      print('🔍 PANEL 3 - therapeutic changed from ${oldWidget.therapeutic.id} to ${widget.therapeutic.id}');
      setState(() {
        _q = '';
        _search.clear();
        _generics = [];
      });
      _loadGenerics();
    }
  }

  Future<void> _loadGenerics() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final tgiCtrl = Get.find<TherapeuticGenIndCtrl>();
      final genericCtrl = Get.put(GenericCtrl());

      print('\n🔍 PANEL 3 - Loading generics for therapeutic: ${widget.therapeutic.id}');
      print('  → GenericCtrl total items: ${genericCtrl.genericList.length}');

      final rawIds = tgiCtrl.getGenericIdsByTherapeuticClass(widget.therapeutic.id);
      print('  → getGenericIdsByTherapeuticClass returned: $rawIds');

      if (rawIds.isEmpty) {
        print('  ⚠️ No generic IDs found for this therapeutic');
        setState(() {
          _generics = [];
          _isLoading = false;
        });
        return;
      }

      final ids = rawIds.map((e) => e.toString()).toList();
      print('  → Looking for generics with IDs: $ids');

      List<GenericDetailsModel> foundGenerics = [];

      if (genericCtrl.filteredGenericList.isNotEmpty) {
        print('  → Using filteredGenericList (${genericCtrl.filteredGenericList.length} items)');
        foundGenerics = genericCtrl.filteredGenericList
            .where((g) => ids.contains(g.generic_id.toString()))
            .toList();
      } else if (genericCtrl.genericList.isNotEmpty) {
        print('  → Using genericList (${genericCtrl.genericList.length} items)');
        foundGenerics = genericCtrl.genericList
            .where((g) => ids.contains(g.generic_id.toString()))
            .toList();
      }

      print('  → Found ${foundGenerics.length} generics');

      if (foundGenerics.isEmpty) {
        print('  ⚠️ No generics found with the given IDs');
        print('  → Sample of available generic IDs:');
        for (int i = 0; i < genericCtrl.genericList.length && i < 5; i++) {
          final g = genericCtrl.genericList[i];
          print('      ID: ${g.generic_id}, Name: ${g.generic_name}');
        }
      } else {
        print('  → Generic names found:');
        for (var g in foundGenerics) {
          print('      - ${g.generic_name}');
        }
      }

      if (mounted) {
        setState(() {
          _generics = foundGenerics;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('  ❌ Error loading generics: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _q.isEmpty
        ? _generics
        : _generics
        .where((g) => g.generic_name.toLowerCase().contains(_q))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14 * widget.fontSizeScale,
            vertical: 12 * widget.fontSizeScale,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: widget.theme.divider)),
          ),
          child: Row(children: [
            Icon(
              Icons.science_outlined,
              size: 14 * widget.fontSizeScale,
              color: AppTheme.accentGreen,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.therapeutic.name,
                style: TextStyle(
                  fontSize: 14 * widget.fontSizeScale,
                  fontWeight: FontWeight.w600,
                  color: widget.theme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.bug_report,
                size: 16 * widget.fontSizeScale,
                color: widget.theme.textMuted,
              ),
              onPressed: _loadGenerics,
              tooltip: 'Reload generics',
            ),
          ]),
        ),
        Padding(
          padding: EdgeInsets.all(10 * widget.fontSizeScale),
          child: SearchInput(
            controller: _search,
            hint: 'Search generics...',
            onChanged: (q) => setState(() => _q = q.toLowerCase().trim()),
            fontSizeScale: widget.fontSizeScale,
            accentColor: widget.theme.accent,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14 * widget.fontSizeScale,
            vertical: 2 * widget.fontSizeScale,
          ),
          child: Text(
            '${displayed.length} generics',
            style: TextStyle(
              fontSize: 11 * widget.fontSizeScale,
              fontWeight: FontWeight.w600,
              color: widget.theme.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: widget.theme.accent))
              : displayed.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No generics found',
                  style: TextStyle(
                    fontSize: 13 * widget.fontSizeScale,
                    color: widget.theme.textMuted,
                  ),
                ),
                SizedBox(height: 8 * widget.fontSizeScale),
                TextButton.icon(
                  onPressed: _loadGenerics,
                  icon: Icon(
                    Icons.refresh,
                    size: 16 * widget.fontSizeScale,
                    color: widget.theme.accent,
                  ),
                  label: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 13 * widget.fontSizeScale,
                      color: widget.theme.accent,
                    ),
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: displayed.length,
            itemBuilder: (_, i) {
              final g = displayed[i];
              return _ListItem(
                label: g.generic_name,
                isSelected: widget.selectedGenericId == g.generic_id.toString(),
                color: AppTheme.accentAmber,
                onTap: () => widget.onTap(g),
                theme: widget.theme,
                fontSizeScale: widget.fontSizeScale,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Panel 4 — Brand list + Brand Detail
// ══════════════════════════════════════════════════════════════════════════════

class _BrandsPanel extends StatefulWidget {
  final GenericDetailsModel generic;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _BrandsPanel({
    required this.generic,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_BrandsPanel> createState() => _BrandsPanelState();
}

class _BrandsPanelState extends State<_BrandsPanel> {
  final TextEditingController _search = TextEditingController();
  String _q = '';
  String? _filterCompanyId;
  DrugBrandModel? _selectedBrand;

  @override
  void initState() {
    super.initState();
    print('🔍 PANEL 4 init - generic: ${widget.generic.generic_id} - ${widget.generic.generic_name}');
  }

  @override
  void didUpdateWidget(_BrandsPanel old) {
    super.didUpdateWidget(old);
    if (old.generic.generic_id?.toString() != widget.generic.generic_id?.toString()) {
      print('🔍 PANEL 4 - generic changed from ${old.generic.generic_id} to ${widget.generic.generic_id}');
      setState(() {
        _selectedBrand = null;
        _filterCompanyId = null;
        _q = '';
        _search.clear();
      });
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandCtrl = Get.put(DrugBrandCtrl());
    final companyCtrl = Get.put(CompanyCtrl());
    final themeCtrl = Get.put(ThemeCtrl());

    return Obx(() {
      print('🔍 PANEL 4 building for generic: ${widget.generic.generic_id} - ${widget.generic.generic_name}');

      final allBrands = brandCtrl.getBrandsByGeneric(widget.generic.generic_id);
      print('  → getBrandsByGeneric returned ${allBrands.length} brands');

      final companyIds = allBrands
          .map((b) => b.company_id.toString())
          .toSet()
          .toList()
        ..sort();

      if (_filterCompanyId != null && !companyIds.contains(_filterCompanyId)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _filterCompanyId = null);
        });
      }

      var displayed = allBrands;
      if (_q.isNotEmpty) {
        displayed = displayed
            .where((b) =>
        b.brand_name.toLowerCase().contains(_q) ||
            (b.strength?.toLowerCase().contains(_q) ?? false) ||
            (b.form?.toLowerCase().contains(_q) ?? false))
            .toList();
      }
      if (_filterCompanyId != null) {
        displayed = displayed
            .where((b) => b.company_id.toString() == _filterCompanyId)
            .toList();
      }

      return Container(
        color: widget.theme.bg,
        child: Row(
          children: [
            // Brand list sidebar
            Container(
              width: 300,
              color: widget.theme.surface,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14 * widget.fontSizeScale,
                      vertical: 12 * widget.fontSizeScale,
                    ),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: widget.theme.divider)),
                    ),
                    child: Row(children: [
                      Icon(
                        Icons.local_pharmacy_outlined,
                        size: 14 * widget.fontSizeScale,
                        color: AppTheme.accentAmber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.generic.generic_name,
                          style: TextStyle(
                            fontSize: 14 * widget.fontSizeScale,
                            fontWeight: FontWeight.w600,
                            color: widget.theme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10 * widget.fontSizeScale),
                    child: Column(children: [
                      SearchInput(
                        controller: _search,
                        hint: 'Search brands...',
                        onChanged: (q) => setState(() => _q = q.toLowerCase().trim()),
                        fontSizeScale: widget.fontSizeScale,
                        accentColor: widget.theme.accent,
                      ),
                      SizedBox(height: 8 * widget.fontSizeScale),
                      if (companyIds.isNotEmpty)
                        _CompanyDropdown(
                          companyIds: companyIds,
                          selectedId: _filterCompanyId,
                          onChanged: (id) => setState(() => _filterCompanyId = id),
                          theme: widget.theme,
                          fontSizeScale: widget.fontSizeScale,
                        ),
                    ]),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14 * widget.fontSizeScale,
                      vertical: 2 * widget.fontSizeScale,
                    ),
                    child: Row(children: [
                      Text(
                        '${displayed.length} / ${allBrands.length} brands',
                        style: TextStyle(
                          fontSize: 11 * widget.fontSizeScale,
                          fontWeight: FontWeight.w600,
                          color: widget.theme.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      if (_filterCompanyId != null || _q.isNotEmpty)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _filterCompanyId = null;
                                _q = '';
                                _search.clear();
                              });
                            },
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 11 * widget.fontSizeScale,
                                fontWeight: FontWeight.w600,
                                color: widget.theme.accent,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                    ]),
                  ),
                  Expanded(
                    child: displayed.isEmpty
                        ? Center(
                      child: Text(
                        'No brands found',
                        style: TextStyle(
                          fontSize: 13 * widget.fontSizeScale,
                          color: widget.theme.textMuted,
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: displayed.length,
                      itemBuilder: (_, i) {
                        final b = displayed[i];
                        final co = companyCtrl.getCompanyById(b.company_id);
                        return _BrandListItem(
                          brand: b,
                          companyName: co?.company_name,
                          isSelected: _selectedBrand?.brand_id == b.brand_id,
                          onTap: () => setState(() => _selectedBrand = b),
                          theme: widget.theme,
                          fontSizeScale: widget.fontSizeScale,
                          showPrice: themeCtrl.showPriceInList.value,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Brand detail
            Expanded(
              child: _selectedBrand != null
                  ? BrandDetailView(
                brand: _selectedBrand!,
                onBrandSwitch: (b) => setState(() => _selectedBrand = b),
                accentColor: widget.theme.accent,
                fontSizeScale: widget.fontSizeScale,
              )
                  : _EmptyHint(
                icon: Icons.local_pharmacy_outlined,
                message: 'Select a brand to view details',
                theme: widget.theme,
                fontSizeScale: widget.fontSizeScale,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Brand List Item
// ══════════════════════════════════════════════════════════════════════════════

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
    final b = widget.brand;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.theme.accent.withOpacity(0.12)
                : _hover ? widget.theme.surfaceHighlight : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: widget.theme.divider.withOpacity(0.4)),
              left: BorderSide(
                  color: widget.isSelected ? widget.theme.accent : Colors.transparent,
                  width: 3),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 14 * widget.fontSizeScale,
            vertical: 10 * widget.fontSizeScale,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.brand_name,
                      style: TextStyle(
                        fontSize: 13 * widget.fontSizeScale,
                        fontWeight: FontWeight.w600,
                        color: widget.theme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4 * widget.fontSizeScale),
                    Wrap(spacing: 5, runSpacing: 4, children: [
                      if (b.strength != null && b.strength!.isNotEmpty)
                        _MiniChip(
                          b.strength!,
                          widget.theme.accent,
                          fontSizeScale: widget.fontSizeScale,
                        ),
                      if (b.form != null && b.form!.isNotEmpty)
                        _MiniChip(
                          b.form!,
                          AppTheme.accentGreen,
                          fontSizeScale: widget.fontSizeScale,
                        ),
                    ]),
                    if (widget.companyName != null && widget.companyName!.isNotEmpty) ...[
                      SizedBox(height: 3 * widget.fontSizeScale),
                      Text(
                        widget.companyName!,
                        style: TextStyle(
                          fontSize: 11 * widget.fontSizeScale,
                          color: widget.theme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (b.price != null && widget.showPrice)
                Container(
                  margin: EdgeInsets.only(left: 8 * widget.fontSizeScale),
                  padding: EdgeInsets.symmetric(
                    horizontal: 7 * widget.fontSizeScale,
                    vertical: 3 * widget.fontSizeScale,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6 * widget.fontSizeScale),
                    border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    '৳${b.price}',
                    style: TextStyle(
                      fontSize: 11 * widget.fontSizeScale,
                      fontWeight: FontWeight.w700,
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

// ══════════════════════════════════════════════════════════════════════════════
// Company Dropdown
// ══════════════════════════════════════════════════════════════════════════════

class _CompanyDropdown extends StatelessWidget {
  final List<String> companyIds;
  final String? selectedId;
  final Function(String?) onChanged;
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
    final ctrl = Get.put(CompanyCtrl());
    final safe = (selectedId != null && companyIds.contains(selectedId)) ? selectedId : null;

    return Container(
      height: 36 * fontSizeScale,
      padding: EdgeInsets.symmetric(horizontal: 10 * fontSizeScale),
      decoration: BoxDecoration(
        color: theme.bg,
        borderRadius: BorderRadius.circular(8 * fontSizeScale),
        border: Border.all(color: theme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: safe,
          hint: Text(
            'All Companies',
            style: TextStyle(
              fontSize: 12 * fontSizeScale,
              color: theme.textSecondary,
            ),
          ),
          isExpanded: true,
          dropdownColor: theme.surfaceElevated,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 14 * fontSizeScale,
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
                'All Companies',
                style: TextStyle(
                  fontSize: 12 * fontSizeScale,
                  color: theme.textPrimary,
                ),
              ),
            ),
            ...companyIds.map((id) {
              final c = ctrl.getCompanyById(int.tryParse(id) ?? 0);
              final companyName = c?.company_name ?? 'Company $id';
              return DropdownMenuItem<String?>(
                value: id,
                child: Text(
                  companyName,
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

// ══════════════════════════════════════════════════════════════════════════════
// Shared List Item (for panels 2 & 3)
// ══════════════════════════════════════════════════════════════════════════════

class _ListItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _ListItem({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  State<_ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<_ListItem> {
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
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.color.withOpacity(0.1)
                : _hover ? widget.theme.surfaceHighlight : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: widget.theme.divider.withOpacity(0.4)),
              left: BorderSide(
                  color: widget.isSelected ? widget.color : Colors.transparent,
                  width: 3),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 14 * widget.fontSizeScale,
            vertical: 10 * widget.fontSizeScale,
          ),
          child: Row(children: [
            Container(
              width: 5 * widget.fontSizeScale,
              height: 5 * widget.fontSizeScale,
              decoration: BoxDecoration(
                color: widget.isSelected ? widget.color : widget.theme.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13 * widget.fontSizeScale,
                  color: widget.isSelected ? widget.color : widget.theme.textSecondary,
                  fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Mini Chip
// ══════════════════════════════════════════════════════════════════════════════

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSizeScale;

  const _MiniChip(this.label, this.color, {required this.fontSizeScale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7 * fontSizeScale,
        vertical: 2 * fontSizeScale,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5 * fontSizeScale),
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

// ══════════════════════════════════════════════════════════════════════════════
// Empty Hint
// ══════════════════════════════════════════════════════════════════════════════

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String message;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _EmptyHint({
    required this.icon,
    required this.message,
    required this.theme,
    required this.fontSizeScale,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: theme.textMuted,
            size: 48 * fontSizeScale,
          ),
          SizedBox(height: 14 * fontSizeScale),
          Text(
            message,
            style: TextStyle(
              fontSize: 14 * fontSizeScale,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Panel Header
// ══════════════════════════════════════════════════════════════════════════════

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
      padding: EdgeInsets.symmetric(
        horizontal: 16 * fontSizeScale,
        vertical: 14 * fontSizeScale,
      ),
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