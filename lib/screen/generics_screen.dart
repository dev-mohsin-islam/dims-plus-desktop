import 'package:dims_desktop/screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/generic_ctrl.dart';
import '../../models/generic/generic_details_model.dart';
import 'app_theme.dart';
import 'brand_detail_screen.dart';
import 'brands_screen.dart';

class GenericsScreen extends StatefulWidget {
  const GenericsScreen({Key? key}) : super(key: key);
  @override
  State<GenericsScreen> createState() => _GenericsScreenState();
}

class _GenericsScreenState extends State<GenericsScreen> {
  final GenericCtrl _ctrl = Get.find<GenericCtrl>();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: List
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border(right: BorderSide(color: AppTheme.divider)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelHeader(title: 'Generics', icon: Icons.science_outlined),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SearchInput(
                  controller: _searchCtrl,
                  hint: 'Search generics...',
                  onChanged: _ctrl.searchGenerics,
                ),
              ),
              Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text('${_ctrl.filteredGenericList.length} results', style: AppTheme.label),
              )),
              Expanded(
                child: Obx(() => ListView.builder(
                  itemCount: _ctrl.filteredGenericList.length,
                  itemBuilder: (_, i) {
                    final g = _ctrl.filteredGenericList[i];
                    return _GenericListItem(
                      generic: g,
                      onTap: () => _ctrl.currentSearchQuery = '',
                    );
                  },
                )),
              ),
            ],
          ),
        ),
        // Right: Hint
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.science_outlined, color: AppTheme.textMuted, size: 48),
                const SizedBox(height: 12),
                Text('Select a generic to view details', style: AppTheme.bodySecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GenericListItem extends StatefulWidget {
  final GenericDetailsModel generic;
  final VoidCallback onTap;
  const _GenericListItem({required this.generic, required this.onTap});
  @override
  State<_GenericListItem> createState() => _GenericListItemState();
}

class _GenericListItemState extends State<_GenericListItem> {
  bool _hover = false;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hover ? AppTheme.surfaceHighlight : Colors.transparent,
          border: Border(bottom: BorderSide(color: AppTheme.divider.withOpacity(0.4))),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.science_outlined, size: 14, color: AppTheme.accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(widget.generic.generic_name, style: AppTheme.bodyPrimary.copyWith(fontWeight: FontWeight.w500)),
                    ),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 16, color: AppTheme.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded)
              GenericDetailPanel(generic: widget.generic, compact: true),
          ],
        ),
      ),
    );
  }
}

// ─── GENERIC DETAIL PANEL (reusable) ─────────────────────────────────────────

class GenericDetailPanel extends StatelessWidget {
  final GenericDetailsModel generic;
  final bool compact;
  const GenericDetailPanel({Key? key, required this.generic, this.compact = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: compact ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) : EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(compact ? 10 : 0),
        border: compact ? Border.all(color: AppTheme.divider) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Text(generic.generic_name, style: AppTheme.headingMedium),
            const SizedBox(height: 4),
            _PregnancyBadge(categoryId: generic.pregnancy_category_id),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 12),
          ],
          if (generic.indication != null) _InfoRow('Indication', generic.indication!),
          if (generic.dose != null) _InfoRow('Dose', generic.dose!),
          if (generic.adult_dose != null) _InfoRow('Adult Dose', generic.adult_dose!),
          if (generic.child_dose != null) _InfoRow('Child Dose', generic.child_dose!),
          if (generic.renal_dose != null) _InfoRow('Renal Dose', generic.renal_dose!),
          if (generic.administration != null) _InfoRow('Administration', generic.administration!),
          if (generic.side_effect != null) _InfoRow('Side Effects', generic.side_effect!),
          if (generic.contra_indication != null) _InfoRow('Contraindications', generic.contra_indication!),
          if (generic.precaution != null) _InfoRow('Precautions', generic.precaution!),
          if (generic.mode_of_action != null) _InfoRow('Mode of Action', generic.mode_of_action!),
          if (generic.interaction != null) _InfoRow('Interactions', generic.interaction!),
          if (generic.pregnancy_category_note != null) _InfoRow('Pregnancy Note', generic.pregnancy_category_note!),
          if (!compact) ...[
            const SizedBox(height: 16),
            _BrandListForGeneric(genericId: generic.generic_id),
          ],
        ],
      ),
    );
  }
}

class _PregnancyBadge extends StatelessWidget {
  final int? categoryId;
  const _PregnancyBadge({this.categoryId});
  @override
  Widget build(BuildContext context) {
    if (categoryId == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accentAmber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.accentAmber.withOpacity(0.4)),
      ),
      child: Text('Pregnancy Cat: $categoryId', style: AppTheme.chip.copyWith(color: AppTheme.accentAmber)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppTheme.label.copyWith(color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: AppTheme.bodyPrimary),
          ),
        ],
      ),
    );
  }
}

class _BrandListForGeneric extends StatelessWidget {
  final int genericId;
  const _BrandListForGeneric({required this.genericId});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BRANDS', style: AppTheme.label),
        const SizedBox(height: 8),
        // Navigate to brands for this generic
        TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: AppTheme.accent.withOpacity(0.1),
            foregroundColor: AppTheme.accent,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.local_pharmacy_outlined, size: 16),
          label: const Text('View All Brands', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          onPressed: () {
            // This would be handled by the parent screen navigating
          },
        ),
      ],
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
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
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
