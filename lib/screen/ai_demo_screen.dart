import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/theme_ctrl.dart';
import 'app_theme.dart';

class AiDemoScreen extends StatefulWidget {
  const AiDemoScreen({Key? key}) : super(key: key);

  @override
  State<AiDemoScreen> createState() => _AiDemoScreenState();
}

class _AiDemoScreenState extends State<AiDemoScreen> {
  final _searchController = TextEditingController();
  bool _isAnalyzing = false;
  String _activeTab = 'Interaction'; // Interaction, Search, Guide

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeCtrl>();
    final theme = themeCtrl.currentTheme;
    final scale = themeCtrl.fontSizeScale;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: theme.accent, size: 20 * scale),
            const SizedBox(width: 10),
            Text(
              'AI Clinical Assistant (BETA)',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.divider),
        ),
      ),
      body: Row(
        children: [
          // Sidebar for AI Features
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(right: BorderSide(color: theme.divider)),
            ),
            child: Column(
              children: [
                _buildMenuTile('Interaction Checker', Icons.compare_arrows, 'Interaction', theme, scale),
                _buildMenuTile('Smart Clinical Search', Icons.psychology_rounded, 'Search', theme, scale),
                _buildMenuTile('Patient Guide Gen', Icons.description_rounded, 'Guide', theme, scale),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.accent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.accent.withOpacity(0.2)),
                    ),
                    child: Text(
                      'These features use LLM technology to analyze your Hive database.',
                      style: TextStyle(fontSize: 11 * scale, color: theme.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Demo Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(40),
              child: _buildActiveDemo(theme, scale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(String title, IconData icon, String tab, ThemeDefinition theme, double scale) {
    final isActive = _activeTab == tab;
    return InkWell(
      onTap: () => setState(() => _activeTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? theme.accent.withOpacity(0.1) : Colors.transparent,
          border: Border(left: BorderSide(color: isActive ? theme.accent : Colors.transparent, width: 4)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18 * scale, color: isActive ? theme.accent : theme.textSecondary),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13 * scale,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? theme.accent : theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDemo(ThemeDefinition theme, double scale) {
    switch (_activeTab) {
      case 'Interaction':
        return _buildInteractionDemo(theme, scale);
      case 'Search':
        return _buildSearchDemo(theme, scale);
      case 'Guide':
        return _buildGuideDemo(theme, scale);
      default:
        return const SizedBox();
    }
  }

  // 1. DRUG INTERACTION DEMO
  Widget _buildInteractionDemo(ThemeDefinition theme, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _demoHeader('Multi-Drug Interaction Checker', 'AI analyzes your selected drugs for potential clinical risks.', theme, scale),
        const SizedBox(height: 30),
        Row(
          children: [
            _drugChip('Atorvastatin', theme, scale),
            const SizedBox(width: 10),
            _drugChip('Clarithromycin', theme, scale),
            const SizedBox(width: 10),
            _drugChip('Amlodipine', theme, scale),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isAnalyzing = true);
                Future.delayed(const Duration(seconds: 2), () => setState(() => _isAnalyzing = false));
              },
              icon: const Icon(Icons.auto_awesome_rounded, size: 16),
              label: const Text('Analyze Interactions'),
              style: ElevatedButton.styleFrom(backgroundColor: theme.accent, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 40),
        if (_isAnalyzing)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24 * scale),
                      const SizedBox(width: 10),
                      Text('AI Clinical Risk Analysis', style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _interactionResult(
                    'Major Interaction: Atorvastatin + Clarithromycin',
                    'Clarithromycin significantly increases the plasma concentration of Atorvastatin by inhibiting CYP3A4 metabolism.',
                    'Risk of Myopathy/Rhabdomyolysis. Recommendation: Temporarily suspend Atorvastatin during antibiotic course.',
                    Colors.redAccent, theme, scale,
                  ),
                  const SizedBox(height: 20),
                  _interactionResult(
                    'Moderate Interaction: Amlodipine + Atorvastatin',
                    'Amlodipine may slightly increase Atorvastatin levels.',
                    'Monitor for increased statin side effects. No immediate change required.',
                    Colors.orangeAccent, theme, scale,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // 2. SMART SEARCH DEMO
  Widget _buildSearchDemo(ThemeDefinition theme, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _demoHeader('AI Smart Search', 'Ask clinical questions in plain English or Bangla.', theme, scale),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.accent.withOpacity(0.5)),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Try: "Safe blood pressure meds for 3rd-trimester pregnancy"',
              border: InputBorder.none,
              suffixIcon: Icon(Icons.auto_awesome_rounded, color: theme.accent),
            ),
            onSubmitted: (v) => setState(() {}),
          ),
        ),
        const SizedBox(height: 40),
        Text('AI Suggested Results:', style: TextStyle(fontWeight: FontWeight.w700, color: theme.textPrimary, fontSize: 14 * scale)),
        const SizedBox(height: 20),
        _searchResultCard('Methyldopa', 'Alpha-2 agonist. Gold standard for gestational hypertension.', 'Pregnancy Category: B', theme, scale),
        const SizedBox(height: 12),
        _searchResultCard('Labetalol', 'Beta/Alpha blocker. Highly effective for chronic hypertension in pregnancy.', 'Pregnancy Category: C (Widely used)', theme, scale),
        const SizedBox(height: 12),
        _searchResultCard('Nifedipine (ER)', 'Calcium channel blocker. Used when other agents are ineffective.', 'Pregnancy Category: C', theme, scale),
      ],
    );
  }

  // 3. PATIENT GUIDE DEMO
  Widget _buildGuideDemo(ThemeDefinition theme, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _demoHeader('AI Patient Education Generator', 'Translate complex drug data into simple, actionable steps.', theme, scale),
        const SizedBox(height: 30),
        Row(
          children: [
            Text('Active Drug:', style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            _drugChip('Metformin 500mg', theme, scale),
          ],
        ),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PATIENT GUIDE: METFORMIN', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue.shade800, letterSpacing: 1.5)),
              const SizedBox(height: 24),
              _guideStep('1', 'Why take this?', 'To help control your blood sugar levels and improve how your body uses insulin.', theme, scale),
              _guideStep('2', 'How to take?', 'Take with a meal to reduce stomach upset. Swallow whole with water.', theme, scale),
              _guideStep('3', 'Important!', 'If you have extreme nausea or a "metallic" taste in your mouth, notify your doctor.', theme, scale),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.print_rounded, size: 16),
                label: const Text('Print for Patient'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // HELPER WIDGETS
  Widget _demoHeader(String title, String sub, ThemeDefinition theme, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 22 * scale, fontWeight: FontWeight.w800, color: theme.textPrimary)),
        const SizedBox(height: 6),
        Text(sub, style: TextStyle(fontSize: 13 * scale, color: theme.textSecondary)),
      ],
    );
  }

  Widget _drugChip(String label, ThemeDefinition theme, double scale) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w600)),
      backgroundColor: theme.surfaceElevated,
      side: BorderSide(color: theme.divider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _interactionResult(String title, String desc, String reco, Color color, ThemeDefinition theme, double scale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13 * scale)),
          const SizedBox(height: 6),
          Text(desc, style: TextStyle(fontSize: 12 * scale, color: theme.textSecondary)),
          const SizedBox(height: 10),
          Text('💡 Recommendation:', style: TextStyle(fontWeight: FontWeight.w700, color: theme.textPrimary, fontSize: 12 * scale)),
          Text(reco, style: TextStyle(fontSize: 12 * scale, color: theme.textSecondary)),
        ],
      ),
    );
  }

  Widget _searchResultCard(String name, String desc, String meta, ThemeDefinition theme, double scale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: theme.accent.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.medication_rounded, color: theme.accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w700, color: theme.textPrimary)),
                Text(desc, style: TextStyle(fontSize: 12 * scale, color: theme.textSecondary)),
              ],
            ),
          ),
          Text(meta, style: TextStyle(fontSize: 11 * scale, color: theme.accent, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _guideStep(String num, String title, String desc, ThemeDefinition theme, double scale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 12, backgroundColor: Colors.blue, child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 12))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: theme.textPrimary, fontSize: 14 * scale)),
                Text(desc, style: TextStyle(fontSize: 13 * scale, color: theme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
