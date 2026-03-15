import 'package:dims_desktop/controller/therapeutic_generic_index_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/systemic_class_ctrl.dart';
import '../../controller/therapeutic_class_ctrl.dart';
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
import 'search_input.dart';

class DrugClassScreen extends StatefulWidget {
  const DrugClassScreen({Key? key}) : super(key: key);

  @override
  State<DrugClassScreen> createState() => _DrugClassScreenState();
}

class _DrugClassScreenState extends State<DrugClassScreen> {
  final ThemeCtrl _themeCtrl = Get.find<ThemeCtrl>();
  final SystemicClassCtrl _systemicCtrl = Get.find<SystemicClassCtrl>();
  final TherapeuticClassCtrl _therapeuticCtrl = Get.find<TherapeuticClassCtrl>();
  final TherapeuticGenIndCtrl _tgiCtrl = Get.find<TherapeuticGenIndCtrl>();
  final GenericCtrl _genericCtrl = Get.find<GenericCtrl>();
  final DrugBrandCtrl _brandCtrl = Get.find<DrugBrandCtrl>();

  final List<SystemicClassModel> _breadcrumb = [];
  SystemicClassModel? _selectedSystemic;
  final TextEditingController _systemicSearch = TextEditingController();
  String _systemicQuery = '';

  @override
  void dispose() {
    _systemicSearch.dispose();
    super.dispose();
  }

  int get _currentParentId => _breadcrumb.isEmpty ? 0 : _breadcrumb.last.id;

  List<SystemicClassModel> _childrenOf(int parentId) =>
      _systemicCtrl.systemicClassList.where((s) => (s.parent_id ?? 0) == parentId).toList();

  bool _hasChildren(SystemicClassModel s) =>
      _systemicCtrl.systemicClassList.any((c) => (c.parent_id ?? 0) == s.id);

  List<TherapeuticClassModel> _therapeuticsFor(int systemicId) =>
      _therapeuticCtrl.therapeuticClassList.where((t) => t.systemic_class_id == systemicId).toList();

  List<GenericDetailsModel> _genericsFor(int therapeuticId) {
    final ids = _tgiCtrl.therapeuticGenIndList
        .where((x) => x.therapitic_id == therapeuticId)
        .map((x) => x.generic_id)
        .toSet();
    return _genericCtrl.genericList.where((g) => ids.contains(g.generic_id)).toList();
  }

  void _onSystemicTap(SystemicClassModel s) {
    if (_hasChildren(s)) {
      setState(() {
        _breadcrumb.add(s);
        _selectedSystemic = null;
        _systemicQuery = '';
        _systemicSearch.clear();
      });
    } else {
      setState(() => _selectedSystemic = s);
    }
  }

  void _breadcrumbJump(int index) {
    setState(() {
      if (index < 0) {
        _breadcrumb.clear();
      } else {
        _breadcrumb.removeRange(index + 1, _breadcrumb.length);
      }
      _selectedSystemic = null;
      _systemicQuery = '';
      _systemicSearch.clear();
    });
  }

  void _openGenericsModal(TherapeuticClassModel t, ThemeDefinition theme, double fss) {
    showDialog(
      context: context,
      builder: (_) => _GenericsModal(
        therapeutic: t,
        generics: _genericsFor(t.id),
        brandCtrl: _brandCtrl,
        companyCtrl: Get.find<CompanyCtrl>(),
        themeCtrl: _themeCtrl,
        theme: theme,
        fss: fss,
      ),
    );
  }

  void _openBrandDetail(DrugBrandModel brand, ThemeDefinition theme, double fss) {
    showDialog(
      context: context,
      builder: (_) => BrandDetailModal(brand: brand, theme: theme, fss: fss),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeCtrl.currentTheme;
    final fss = _themeCtrl.fontSizeScale;
    RxBool loading = false.obs;
    return Row(
      children: [
        Container(
          width: 280 * fss,
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border(right: BorderSide(color: theme.divider)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(16 * fss, 14 * fss, 16 * fss, 14 * fss),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.divider)),
                ),
                child: Row(children: [
                  Icon(Icons.category_outlined, size: 15 * fss, color: theme.accent),
                  SizedBox(width: 8 * fss),
                  Text(
                    'Drug Classes',
                    style: TextStyle(fontSize: 13 * fss, fontWeight: FontWeight.w600, color: theme.textPrimary),
                  ),
                ]),
              ),
              if (_breadcrumb.isNotEmpty)
                _BreadcrumbBar(breadcrumb: _breadcrumb, onJump: _breadcrumbJump, theme: theme, fss: fss),
              Padding(
                padding: EdgeInsets.all(10 * fss),
                child: SearchInput(
                  controller: _systemicSearch,
                  hint: 'Search classes...',
                  onChanged: (q) => setState(() => _systemicQuery = q.toLowerCase()),
                  fontSizeScale: fss,
                  accentColor: theme.accent,
                ),
              ),
              Obx(() {
                final allTherapeutics = _therapeuticCtrl.therapeuticClassList;
                final visibleChildren = _childrenOf(_currentParentId)
                    .where((s) => _systemicQuery.isEmpty || s.name.toLowerCase().contains(_systemicQuery))
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16 * fss, 0, 16 * fss, 6 * fss),
                      child: Text(
                        '${visibleChildren.length} classes',
                        style: TextStyle(fontSize: 10 * fss, fontWeight: FontWeight.w600, color: theme.textMuted, letterSpacing: 0.8),
                      ),
                    ),
                  ],
                );
              }),
              Expanded(
                child: Obx(() {
                  final allTherapeutics = _therapeuticCtrl.therapeuticClassList;
                  final visibleChildren = _childrenOf(_currentParentId)
                      .where((s) => _systemicQuery.isEmpty || s.name.toLowerCase().contains(_systemicQuery))
                      .toList();
                  if (visibleChildren.isEmpty) {
                    return Center(child: Text('No classes found', style: TextStyle(fontSize: 12 * fss, color: theme.textMuted)));
                  }
                  return ListView.builder(
                    itemCount: visibleChildren.length,
                    itemBuilder: (_, i) {
                      final s = visibleChildren[i];
                      return _SystemicItem(
                        item: s,
                        isSelected: _selectedSystemic?.id == s.id,
                        hasChildren: _hasChildren(s),
                        onTap: () => _onSystemicTap(s),
                        theme: theme,
                        fss: fss,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {

            // Touch the observable list to ensure Obx has something to listen to
            final allTherapeutics = _therapeuticCtrl.therapeuticClassList.toList();

            final therapeutics = _selectedSystemic != null
                ? allTherapeutics.where((t) => t.systemic_class_id == _selectedSystemic!.id).toList()
                : <TherapeuticClassModel>[];

            return _selectedSystemic == null
                ? _EmptyState(
                    icon: Icons.account_tree_outlined,
                    title: _breadcrumb.isEmpty ? 'Select a Drug Class' : 'Select a Sub-Class',
                    subtitle: _breadcrumb.isEmpty
                        ? 'Choose a class from the left panel to explore therapeutic classes'
                        : 'Pick a sub-class to see its therapeutic classes',
                    theme: theme,
                    fss: fss,
                  )
                : _TherapeuticGrid(
                    systemic: _selectedSystemic!,
                    therapeutics: therapeutics,
                    onTherapeuticTap: (t) => _openGenericsModal(t, theme, fss),
                    theme: theme,
                    fss: fss,
                  );
          }),
        ),
      ],
    );
  }
}

class _BreadcrumbBar extends StatelessWidget {
  final List<SystemicClassModel> breadcrumb;
  final void Function(int) onJump;
  final ThemeDefinition theme;
  final double fss;

  const _BreadcrumbBar({required this.breadcrumb, required this.onJump, required this.theme, required this.fss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12 * fss, vertical: 8 * fss),
      decoration: BoxDecoration(color: theme.bg, border: Border(bottom: BorderSide(color: theme.divider.withOpacity(0.6)))),
      child: SingleChildScrollView(
        child: Wrap(
          children: [
            _CrumbChip(label: 'Root', icon: Icons.home_outlined, isLast: false, onTap: () => onJump(-1), theme: theme, fss: fss),
            ...breadcrumb.asMap().entries.map((e) {
              final isLast = e.key == breadcrumb.length - 1;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4 * fss, vertical: 2 * fss),
                    child: Icon(Icons.chevron_right_rounded, size: 13 * fss, color: theme.textMuted),
                  ),
                  _CrumbChip(label: e.value.name, isLast: isLast, onTap: isLast ? null : () => onJump(e.key), theme: theme, fss: fss),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CrumbChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLast;
  final VoidCallback? onTap;
  final ThemeDefinition theme;
  final double fss;

  const _CrumbChip({required this.label, this.icon, required this.isLast, this.onTap, required this.theme, required this.fss});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * fss, vertical: 3 * fss),
          decoration: BoxDecoration(
            color: isLast ? theme.accent.withOpacity(0.15) : theme.surfaceHighlight,
            borderRadius: BorderRadius.circular(5 * fss),
            border: Border.all(color: isLast ? theme.accent.withOpacity(0.4) : theme.divider.withOpacity(0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 11 * fss, color: isLast ? theme.accent : theme.textSecondary),
                SizedBox(width: 4 * fss),
              ],
              Text(label, style: TextStyle(fontSize: 11 * fss, fontWeight: isLast ? FontWeight.w600 : FontWeight.w400, color: isLast ? theme.accent : theme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemicItem extends StatefulWidget {
  final SystemicClassModel item;
  final bool isSelected;
  final bool hasChildren;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fss;

  const _SystemicItem({required this.item, required this.isSelected, required this.hasChildren, required this.onTap, required this.theme, required this.fss});

  @override
  State<_SystemicItem> createState() => _SystemicItemState();
}

class _SystemicItemState extends State<_SystemicItem> {
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
          duration: const Duration(milliseconds: 130),
          decoration: BoxDecoration(
            color: widget.isSelected ? widget.theme.accent.withOpacity(0.1) : _hover ? widget.theme.surfaceHighlight : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: widget.theme.divider.withOpacity(0.4)),
              left: BorderSide(color: widget.isSelected ? widget.theme.accent : Colors.transparent, width: 3),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16 * widget.fss, vertical: 11 * widget.fss),
          child: Row(
            children: [
              Container(
                width: 30 * widget.fss,
                height: 30 * widget.fss,
                decoration: BoxDecoration(
                  color: widget.isSelected ? widget.theme.accent.withOpacity(0.15) : widget.theme.surfaceElevated,
                  borderRadius: BorderRadius.circular(7 * widget.fss),
                ),
                child: Icon(widget.hasChildren ? Icons.folder_outlined : Icons.local_hospital_outlined, size: 15 * widget.fss, color: widget.isSelected ? widget.theme.accent : widget.theme.textSecondary),
              ),
              SizedBox(width: 10 * widget.fss),
              Expanded(
                child: Text(widget.item.name, style: TextStyle(fontSize: 13 * widget.fss, fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400, color: widget.isSelected ? widget.theme.accent : widget.theme.textPrimary)),
              ),
              Icon(widget.hasChildren ? Icons.arrow_forward_ios_rounded : Icons.chevron_right_rounded, size: widget.hasChildren ? 11 * widget.fss : 16 * widget.fss, color: (_hover || widget.isSelected) ? widget.theme.accent : widget.theme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

const _kCardAccents = [AppTheme.accentBlue, AppTheme.accentGreen, AppTheme.accentPurple, AppTheme.accentAmber, AppTheme.accentRose];

class _TherapeuticGrid extends StatelessWidget {
  final SystemicClassModel systemic;
  final List<TherapeuticClassModel> therapeutics;
  final void Function(TherapeuticClassModel) onTherapeuticTap;
  final ThemeDefinition theme;
  final double fss;

  const _TherapeuticGrid({required this.systemic, required this.therapeutics, required this.onTherapeuticTap, required this.theme, required this.fss});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(24 * fss, 14 * fss, 24 * fss, 12 * fss),
          decoration: BoxDecoration(color: theme.surface, border: Border(bottom: BorderSide(color: theme.divider))),
          child: Row(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10 * fss, vertical: 5 * fss),
              decoration: BoxDecoration(color: theme.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(6 * fss), border: Border.all(color: theme.accent.withOpacity(0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.local_hospital_outlined, size: 13 * fss, color: theme.accent),
                SizedBox(width: 6 * fss),
                Text(systemic.name, style: TextStyle(fontSize: 12 * fss, fontWeight: FontWeight.w600, color: theme.accent)),
              ]),
            ),
            SizedBox(width: 12 * fss),
            Text('${therapeutics.length} therapeutic classes', style: TextStyle(fontSize: 12 * fss, color: theme.textMuted)),
          ]),
        ),
        Expanded(
          child: therapeutics.isEmpty
              ? _EmptyState(icon: Icons.search_off_rounded, title: 'No Therapeutic Classes', subtitle: 'No therapeutic classes linked to "${systemic.name}"', theme: theme, fss: fss)
              : ListView.builder(
                  padding: EdgeInsets.all(20 * fss),
                  itemCount: therapeutics.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: _TherapeuticCard(therapeutic: therapeutics[i], color: _kCardAccents[i % _kCardAccents.length], onTap: () => onTherapeuticTap(therapeutics[i]), theme: theme, fss: fss),
                  ),
                ),
        ),
      ],
    );
  }
}

class _TherapeuticCard extends StatefulWidget {
  final TherapeuticClassModel therapeutic;
  final Color color;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fss;

  const _TherapeuticCard({required this.therapeutic, required this.color, required this.onTap, required this.theme, required this.fss});

  @override
  State<_TherapeuticCard> createState() => _TherapeuticCardState();
}

class _TherapeuticCardState extends State<_TherapeuticCard> {
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
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hover ? widget.color.withOpacity(0.1) : widget.theme.surface,
            borderRadius: BorderRadius.circular(12 * widget.fss),
            border: Border.all(color: _hover ? widget.color.withOpacity(0.5) : widget.theme.divider, width: _hover ? 1.5 : 1),
            boxShadow: _hover ? [BoxShadow(color: widget.color.withOpacity(0.14), blurRadius: 14, offset: const Offset(0, 5))] : [],
          ),
          padding: EdgeInsets.all(14 * widget.fss),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.therapeutic.name, style: TextStyle(fontSize: 12 * widget.fss, fontWeight: FontWeight.w600, color: _hover ? widget.color : widget.theme.textPrimary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 5 * widget.fss),
                  Row(children: [
                    Text('View generics', style: TextStyle(fontSize: 10 * widget.fss, color: _hover ? widget.color : widget.theme.textMuted)),
                    SizedBox(width: 2 * widget.fss),
                    Icon(Icons.arrow_forward_rounded, size: 10 * widget.fss, color: _hover ? widget.color : widget.theme.textMuted),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenericsModal extends StatefulWidget {
  final TherapeuticClassModel therapeutic;
  final List<GenericDetailsModel> generics;
  final DrugBrandCtrl brandCtrl;
  final CompanyCtrl companyCtrl;
  final ThemeCtrl themeCtrl;
  final ThemeDefinition theme;
  final double fss;

  const _GenericsModal({required this.therapeutic, required this.generics, required this.brandCtrl, required this.companyCtrl, required this.themeCtrl, required this.theme, required this.fss});

  @override
  State<_GenericsModal> createState() => _GenericsModalState();
}

class _GenericsModalState extends State<_GenericsModal> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openBrandsModal(GenericDetailsModel g) {
    showDialog(
      context: context,
      builder: (_) => _BrandsModal(generic: g, brands: widget.brandCtrl.getBrandsByGeneric(g.generic_id), companyCtrl: widget.companyCtrl, themeCtrl: widget.themeCtrl, theme: widget.theme, fss: widget.fss),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final fss = widget.fss;
    final displayed = _query.isEmpty ? widget.generics : widget.generics.where((g) => g.generic_name.toLowerCase().contains(_query)).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 80 * fss, vertical: 60 * fss),
      child: Container(
        constraints: BoxConstraints(maxWidth: 900 * fss),
        decoration: modalDecoration(theme, fss),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(title: widget.therapeutic.name, subtitle: '${displayed.length} generics', icon: Icons.science_outlined, iconColor: AppTheme.accentGreen, onClose: () => Navigator.pop(context), theme: theme, fss: fss),
            Padding(
              padding: EdgeInsets.fromLTRB(20 * fss, 12 * fss, 20 * fss, 8 * fss),
              child: SearchInput(controller: _search, hint: 'Search generics...', onChanged: (q) => setState(() => _query = q.toLowerCase()), fontSizeScale: fss, accentColor: AppTheme.accentGreen),
            ),
            Flexible(
              child: displayed.isEmpty
                  ? _ModalEmpty(icon: Icons.science_outlined, message: 'No generics found', theme: theme, fss: fss)
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(20 * fss, 4 * fss, 20 * fss, 20 * fss),
                      shrinkWrap: true,
                      itemCount: displayed.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: _GenericCard(generic: displayed[i], onTap: () => _openBrandsModal(displayed[i]), theme: theme, fss: fss),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenericCard extends StatefulWidget {
  final GenericDetailsModel generic;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fss;

  const _GenericCard({required this.generic, required this.onTap, required this.theme, required this.fss});

  @override
  State<_GenericCard> createState() => _GenericCardState();
}

class _GenericCardState extends State<_GenericCard> {
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
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(color: _hover ? AppTheme.accentGreen.withOpacity(0.1) : widget.theme.bg, borderRadius: BorderRadius.circular(10 * widget.fss), border: Border.all(color: _hover ? AppTheme.accentGreen.withOpacity(0.5) : widget.theme.divider)),
          padding: EdgeInsets.all(12 * widget.fss),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.science_outlined, size: 18 * widget.fss, color: _hover ? AppTheme.accentGreen : widget.theme.textMuted),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.generic.generic_name, style: TextStyle(fontSize: 12 * widget.fss, fontWeight: FontWeight.w600, color: _hover ? AppTheme.accentGreen : widget.theme.textPrimary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (widget.generic.pregnancy_category_id != null) ...[
                    SizedBox(height: 3 * widget.fss),
                    Container(padding: EdgeInsets.symmetric(horizontal: 5 * widget.fss, vertical: 1 * widget.fss), decoration: BoxDecoration(color: AppTheme.accentAmber.withOpacity(0.15), borderRadius: BorderRadius.circular(3 * widget.fss)), child: Text('Cat ${widget.generic.pregnancy_category_id}', style: TextStyle(fontSize: 9 * widget.fss, color: AppTheme.accentAmber, fontWeight: FontWeight.w500))),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandsModal extends StatefulWidget {
  final GenericDetailsModel generic;
  final List<DrugBrandModel> brands;
  final CompanyCtrl companyCtrl;
  final ThemeCtrl themeCtrl;
  final ThemeDefinition theme;
  final double fss;

  const _BrandsModal({required this.generic, required this.brands, required this.companyCtrl, required this.themeCtrl, required this.theme, required this.fss});

  @override
  State<_BrandsModal> createState() => _BrandsModalState();
}

class _BrandsModalState extends State<_BrandsModal> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  int? _filterCompanyId;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<DrugBrandModel> get _displayed {
    var list = widget.brands;
    if (_query.isNotEmpty) {
      list = list.where((b) => b.brand_name.toLowerCase().contains(_query) || (b.strength?.toLowerCase().contains(_query) ?? false) || (b.form?.toLowerCase().contains(_query) ?? false)).toList();
    }
    if (_filterCompanyId != null) {
      list = list.where((b) => b.company_id == _filterCompanyId).toList();
    }
    return list;
  }

  List<int> get _companyIds => widget.brands.map((b) => b.company_id).toSet().toList()..sort();

  void _openBrandDetail(DrugBrandModel brand) {
    showDialog(
      context: context,
      builder: (_) => BrandDetailModal(brand: brand, theme: widget.theme, fss: widget.fss),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final fss = widget.fss;
    final displayed = _displayed;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 60 * fss, vertical: 40 * fss),
      child: Container(
        constraints: BoxConstraints(maxWidth: 1000 * fss, maxHeight: 680 * fss),
        decoration: modalDecoration(theme, fss),
        child: Column(
          children: [
            _ModalHeader(title: widget.generic.generic_name, subtitle: '${displayed.length} of ${widget.brands.length} brands', icon: Icons.local_pharmacy_outlined, iconColor: AppTheme.accentPurple, onClose: () => Navigator.pop(context), theme: theme, fss: fss, trailing: widget.generic.pregnancy_category_id != null ? _PregnancyBadge(catId: widget.generic.pregnancy_category_id!, fss: fss) : null),
            Padding(
              padding: EdgeInsets.fromLTRB(20 * fss, 12 * fss, 20 * fss, 8 * fss),
              child: Row(children: [
                Expanded(flex: 2, child: SearchInput(controller: _search, hint: 'Search by name, strength or form...', onChanged: (q) => setState(() => _query = q.toLowerCase()), fontSizeScale: fss, accentColor: AppTheme.accentPurple)),
                SizedBox(width: 10 * fss),
                Expanded(child: _CompanyFilter(companyIds: _companyIds, selectedId: _filterCompanyId, onChanged: (id) => setState(() => _filterCompanyId = id), companyCtrl: widget.companyCtrl, theme: theme, fss: fss)),
              ]),
            ),
            Expanded(
              child: displayed.isEmpty
                  ? _ModalEmpty(icon: Icons.local_pharmacy_outlined, message: 'No brands found', theme: theme, fss: fss)
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(16 * fss, 4 * fss, 16 * fss, 16 * fss),
                      itemCount: displayed.length,
                      itemBuilder: (_, i) {
                        final b = displayed[i];
                        final company = widget.companyCtrl.getCompanyById(b.company_id);
                        return _BrandRow(brand: b, companyName: company?.company_name, onTap: () => _openBrandDetail(b), theme: theme, fss: fss, showPrice: widget.themeCtrl.showPriceInList.value);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandRow extends StatefulWidget {
  final DrugBrandModel brand;
  final String? companyName;
  final VoidCallback onTap;
  final ThemeDefinition theme;
  final double fss;
  final bool showPrice;

  const _BrandRow({required this.brand, this.companyName, required this.onTap, required this.theme, required this.fss, required this.showPrice});

  @override
  State<_BrandRow> createState() => _BrandRowState();
}

class _BrandRowState extends State<_BrandRow> {
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
          margin: EdgeInsets.only(bottom: 2 * widget.fss),
          decoration: BoxDecoration(color: _hover ? AppTheme.accentPurple.withOpacity(0.08) : Colors.transparent, borderRadius: BorderRadius.circular(8 * widget.fss), border: Border.all(color: _hover ? AppTheme.accentPurple.withOpacity(0.28) : Colors.transparent)),
          padding: EdgeInsets.symmetric(horizontal: 14 * widget.fss, vertical: 10 * widget.fss),
          child: Row(
            children: [
              Container(width: 36 * widget.fss, height: 36 * widget.fss, decoration: BoxDecoration(color: AppTheme.accentPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(8 * widget.fss)), child: Icon(Icons.local_pharmacy_outlined, size: 17 * widget.fss, color: AppTheme.accentPurple)),
              SizedBox(width: 12 * widget.fss),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.brand_name, style: TextStyle(fontSize: 13 * widget.fss, fontWeight: FontWeight.w600, color: _hover ? AppTheme.accentPurple : widget.theme.textPrimary)),
                    SizedBox(height: 3 * widget.fss),
                    Wrap(spacing: 5, runSpacing: 3, children: [
                      if (b.strength != null) _Chip(b.strength!, widget.theme.accent, widget.fss),
                      if (b.form != null) _Chip(b.form!, AppTheme.accentGreen, widget.fss),
                    ]),
                    if (widget.companyName != null) ...[
                      SizedBox(height: 2 * widget.fss),
                      Text(widget.companyName!, style: TextStyle(fontSize: 10 * widget.fss, color: widget.theme.textSecondary)),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (b.price != null && widget.showPrice) Container(padding: EdgeInsets.symmetric(horizontal: 8 * widget.fss, vertical: 4 * widget.fss), decoration: BoxDecoration(color: AppTheme.accentGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(6 * widget.fss)), child: Text('৳${b.price}', style: TextStyle(fontSize: 12 * widget.fss, fontWeight: FontWeight.w700, color: AppTheme.accentGreen))),
                  SizedBox(height: 5 * widget.fss),
                  Row(children: [
                    Text('Details', style: TextStyle(fontSize: 10 * widget.fss, color: _hover ? AppTheme.accentPurple : widget.theme.textMuted)),
                    SizedBox(width: 2 * widget.fss),
                    Icon(Icons.open_in_new_rounded, size: 10 * widget.fss, color: _hover ? AppTheme.accentPurple : widget.theme.textMuted),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeDefinition theme;
  final double fss;

  const _EmptyState({required this.icon, required this.title, required this.subtitle, required this.theme, required this.fss});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 64 * fss, height: 64 * fss, decoration: BoxDecoration(color: theme.surfaceElevated, borderRadius: BorderRadius.circular(16 * fss), border: Border.all(color: theme.divider)), child: Icon(icon, size: 28 * fss, color: theme.textMuted)), SizedBox(height: 16 * fss), Text(title, style: TextStyle(fontSize: 15 * fss, fontWeight: FontWeight.w600, color: theme.textPrimary)), SizedBox(height: 6 * fss), Text(subtitle, style: TextStyle(fontSize: 12 * fss, color: theme.textSecondary), textAlign: TextAlign.center)]));
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeDefinition theme;
  final double fontSizeScale;

  const _PanelHeader({required this.title, required this.icon, required this.theme, required this.fontSizeScale});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.divider))), child: Row(children: [Icon(icon, size: 16 * fontSizeScale, color: theme.accent), SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 14 * fontSizeScale, fontWeight: FontWeight.w600, color: theme.textPrimary))]));
  }
}

class _ModalHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onClose;
  final ThemeDefinition theme;
  final double fss;
  final Widget? trailing;

  const _ModalHeader({required this.title, required this.subtitle, required this.icon, required this.iconColor, required this.onClose, required this.theme, required this.fss, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20 * fss, 16 * fss, 16 * fss, 14 * fss),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.divider)), borderRadius: BorderRadius.vertical(top: Radius.circular(16 * fss))),
      child: Row(children: [Container(width: 38 * fss, height: 38 * fss, decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10 * fss)), child: Icon(icon, size: 18 * fss, color: iconColor)), SizedBox(width: 12 * fss), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 15 * fss, fontWeight: FontWeight.w700, color: theme.textPrimary)), Text(subtitle, style: TextStyle(fontSize: 11 * fss, color: theme.textSecondary))])), if (trailing != null) ...[trailing!, SizedBox(width: 10 * fss)], MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onClose, child: Container(width: 30 * fss, height: 30 * fss, decoration: BoxDecoration(color: theme.surfaceHighlight, borderRadius: BorderRadius.circular(7 * fss), border: Border.all(color: theme.divider)), child: Icon(Icons.close_rounded, size: 14 * fss, color: theme.textSecondary))))]),
    );
  }
}

class _ModalEmpty extends StatelessWidget {
  final IconData icon;
  final String message;
  final ThemeDefinition theme;
  final double fss;

  const _ModalEmpty({required this.icon, required this.message, required this.theme, required this.fss});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(40 * fss), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 40 * fss, color: theme.textMuted), SizedBox(height: 12 * fss), Text(message, style: TextStyle(fontSize: 13 * fss, color: theme.textSecondary))]));
  }
}

class _CompanyFilter extends StatelessWidget {
  final List<int> companyIds;
  final int? selectedId;
  final void Function(int?) onChanged;
  final CompanyCtrl companyCtrl;
  final ThemeDefinition theme;
  final double fss;

  const _CompanyFilter({required this.companyIds, this.selectedId, required this.onChanged, required this.companyCtrl, required this.theme, required this.fss});

  @override
  Widget build(BuildContext context) {
    return Container(height: 36 * fss, padding: EdgeInsets.symmetric(horizontal: 10 * fss), decoration: BoxDecoration(color: theme.bg, borderRadius: BorderRadius.circular(8 * fss), border: Border.all(color: theme.divider)), child: DropdownButtonHideUnderline(child: DropdownButton<int?>(value: selectedId, hint: Text('All Companies', style: TextStyle(fontSize: 12 * fss, color: theme.textSecondary)), isExpanded: true, dropdownColor: theme.surfaceElevated, icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16 * fss, color: theme.textSecondary), style: TextStyle(fontSize: 12 * fss, color: theme.textPrimary), items: [DropdownMenuItem<int?>(value: null, child: Text('All Companies', style: TextStyle(fontSize: 12 * fss, color: theme.textPrimary))), ...companyIds.map((id) { final c = companyCtrl.getCompanyById(id); return DropdownMenuItem<int?>(value: id, child: Text(c?.company_name ?? 'Company $id', style: TextStyle(fontSize: 12 * fss, color: theme.textPrimary), overflow: TextOverflow.ellipsis)); })], onChanged: onChanged)));
  }
}

class _PregnancyBadge extends StatelessWidget {
  final dynamic catId;
  final double fss;

  const _PregnancyBadge({required this.catId, required this.fss});

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.symmetric(horizontal: 8 * fss, vertical: 3 * fss), decoration: BoxDecoration(color: AppTheme.accentAmber.withOpacity(0.15), borderRadius: BorderRadius.circular(5 * fss), border: Border.all(color: AppTheme.accentAmber.withOpacity(0.4))), child: Text('Preg. Cat $catId', style: TextStyle(fontSize: 10 * fss, color: AppTheme.accentAmber, fontWeight: FontWeight.w500)));
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final double fss;

  const _Chip(this.label, this.color, this.fss);

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(3)), child: Text(label, style: TextStyle(fontSize: 9 * fss, fontWeight: FontWeight.w500, color: color)));
  }
}
