import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_ctrl.dart';
import '../controller/occupation_ctrl.dart';
import '../controller/speciality_ctrl.dart';
import '../controller/theme_ctrl.dart';
import 'app_theme.dart';
import 'registration_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeCtrl>();
    final authCtrl = Get.put(AuthCtrl());
    final theme = themeCtrl.currentTheme;
    final _ctrlOccupation = Get.put(OccupationCtrl());
    final _ctrlSpeciality = Get.put(SpecialityCtrl());
    _ctrlOccupation.getOccupationApi();
    _ctrlSpeciality.getSpecialityApi();
    return Scaffold(
      backgroundColor: theme.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.divider.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(theme.isDark ? 0.3 : 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/dims_plus_logo.png',
                    height: 80,
                    width: 80,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.medical_services_rounded,
                      size: 60,
                      color: theme.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Product Name
                Text(
                  'DIMS',
                  style: TextStyle(
                    fontSize: 32 * themeCtrl.fontSizeScale,
                    fontWeight: FontWeight.w900,
                    color: theme.accent,
                    letterSpacing: 4,
                  ),
                ),
                Text(
                  'Drug Information Management System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14 * themeCtrl.fontSizeScale,
                    fontWeight: FontWeight.w500,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Phone Number Input
                _buildInputField(
                  controller: authCtrl.phoneController,
                  label: 'PHONE NUMBER',
                  hint: 'Enter your phone number',
                  icon: Icons.phone_android_rounded,
                  theme: theme,
                  themeCtrl: themeCtrl,
                ),
                
                const SizedBox(height: 32),
                
                // Login Button
                Obx(() => authCtrl.isLoading.value
                    ? CircularProgressIndicator(color: theme.accent)
                    : ElevatedButton(
                        onPressed: authCtrl.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.accent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16 * themeCtrl.fontSizeScale,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      )),
                
                const SizedBox(height: 24),
                
                // Registration Button
                OutlinedButton(
                  onPressed: authCtrl.goToRegistration,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: BorderSide(color: theme.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'CREATE AN ACCOUNT',
                    style: TextStyle(
                      fontSize: 14 * themeCtrl.fontSizeScale,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeDefinition theme,
    required ThemeCtrl themeCtrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11 * themeCtrl.fontSizeScale,
            fontWeight: FontWeight.w700,
            color: theme.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: theme.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.divider),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              fontSize: 15 * themeCtrl.fontSizeScale,
              color: theme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              icon: Icon(icon, size: 20, color: theme.accent.withOpacity(0.7)),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14 * themeCtrl.fontSizeScale,
                color: theme.textMuted,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
