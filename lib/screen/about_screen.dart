import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/theme_ctrl.dart';
import 'app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

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
        title: Text(
          'About DIMS',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w700,
          ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo & Version
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100 * scale,
                        height: 100 * scale,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.surfaceElevated,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/dims_plus_logo.png',
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.medical_services_rounded,
                            size: 50 * scale,
                            color: theme.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'DIMS Plus',
                        style: TextStyle(
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          color: theme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                _buildSectionTitle('Overview', theme, scale),
                _buildBodyText(
                  'DIMS (Drug Information Management System) is the premier offline drug index in Bangladesh. '
                  'It provides healthcare and pharmaceutical professionals with instant, reliable, and comprehensive '
                  'clinical drug information. Developed by ITmedicus, it serves as an essential tool for doctors, '
                  'pharmacists, and nurses to ensure safe medication management.',
                  theme, scale,
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('Mission & Vision', theme, scale),
                _buildBodyText(
                  'Our mission is to empower healthcare professionals with frequently updated, practical information '
                  'on over 28,000+ brand names and 2,200+ generic drugs. We envision a digital healthcare landscape '
                  'in Bangladesh where the gap between pharmaceutical data and clinical practice is seamlessly bridged, '
                  'ultimately improving patient safety and treatment outcomes.',
                  theme, scale,
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('Key Features', theme, scale),
                _buildFeatureItem(Icons.search_rounded, 'Advanced search by Brand, Generic, or Condition.', theme, scale),
                _buildFeatureItem(Icons.offline_bolt_rounded, 'Full offline access for reliable clinical use.', theme, scale),
                _buildFeatureItem(Icons.info_outline_rounded, 'Detailed indications, dosage, and side effects.', theme, scale),
                _buildFeatureItem(Icons.payments_outlined, 'Latest retail prices and pack size information.', theme, scale),
                _buildFeatureItem(Icons.pregnant_woman_rounded, 'FDA Pregnancy categories and safety data.', theme, scale),

                const SizedBox(height: 32),
                _buildSectionTitle('Developer', theme, scale),
                _buildBodyText(
                  'Developed and Maintained by ITmedicus.\n'
                  'Dhaka, Bangladesh.\n'
                  'Contact: dims@itmedicus.com\n'
                  'Website: www.dimsbd.com',
                  theme, scale,
                ),

                const SizedBox(height: 48),
                Center(
                  child: Text(
                    '© 2026 ITmedicus. All Rights Reserved.',
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: theme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeDefinition theme, double scale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18 * scale,
          fontWeight: FontWeight.w700,
          color: theme.accent,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text, ThemeDefinition theme, double scale) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14 * scale,
        color: theme.textSecondary,
        height: 1.6,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, ThemeDefinition theme, double scale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18 * scale, color: theme.accent.withOpacity(0.8)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14 * scale,
                color: theme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
