import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_ctrl.dart';
import '../../controller/occupation_ctrl.dart';
import '../../controller/speciality_ctrl.dart';
import '../../controller/theme_ctrl.dart';
import 'app_theme.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthCtrl _authCtrl = Get.put(AuthCtrl());
  final OccupationCtrl _occCtrl = Get.put(OccupationCtrl());
  final SpecialityCtrl _specCtrl = Get.put(SpecialityCtrl());
  final ThemeCtrl _themeCtrl = Get.put(ThemeCtrl());

  final _formKey = GlobalKey<FormState>();
  
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  final _bmdcCtrl = TextEditingController();
  final _qualCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();

  String? _selectedOccupation;
  String? _selectedSpecialty;
  int _bmdcType = 0; // 0 for Medical, 1 for Dental

  bool get _isDoctor => _selectedOccupation?.toLowerCase() == 'doctor';

  @override
  void initState() {
    super.initState();
    _occCtrl.getAllOccupationFromBox();
    _specCtrl.getAllSpecialityFromBox();
  }
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _orgCtrl.dispose();
    _bmdcCtrl.dispose();
    _qualCtrl.dispose();
    _designationCtrl.dispose();
    super.dispose();
  }

  void _handleRegistration() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'phone': _phoneCtrl.text,
        'occupation': _selectedOccupation ?? '',
        'specialty': _selectedSpecialty ?? '',
        'organization': _orgCtrl.text,
        'bmdc': _bmdcCtrl.text,
        'qualification': _qualCtrl.text,
        'designation': _designationCtrl.text,
        'bmdc_type': _bmdcType.toString(),
      };
      
      _authCtrl.register(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeCtrl.currentTheme;
    final scale = _themeCtrl.fontSizeScale;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        title: Text('Create Account', style: TextStyle(color: theme.textPrimary, fontSize: 18 * scale, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textPrimary, size: 20 * scale),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600 * scale),
          padding: EdgeInsets.all(24 * scale),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Personal Information', theme, scale),
                  _buildTextField(_nameCtrl, 'Full Name', Icons.person_outline, theme, scale, validator: (v) => v!.isEmpty ? 'Name is required' : null),
                  SizedBox(height: 16 * scale),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_emailCtrl, 'Email Address', Icons.email_outlined, theme, scale, validator: (v) => !GetUtils.isEmail(v!) ? 'Invalid email' : null)),
                      SizedBox(width: 16 * scale),
                      Expanded(child: _buildTextField(_phoneCtrl, 'Phone Number', Icons.phone_outlined, theme, scale, validator: (v) => v!.isEmpty ? 'Phone is required' : null)),
                    ],
                  ),
                  
                  SizedBox(height: 24 * scale),
                  _buildSectionTitle('Professional Details', theme, scale),
                  
                  // Occupation Dropdown
                  Obx(() => _buildDropdown<String>(
                    value: _selectedOccupation,
                    items: _occCtrl.occupationList.map((e) => DropdownMenuItem(value: e.name, child: Text(e.name))).toList(),
                    hint: 'Select Occupation',
                    icon: Icons.work_outline,
                    theme: theme,
                    scale: scale,
                    onChanged: (val) => setState(() {
                      _selectedOccupation = val;
                      if (!_isDoctor) {
                        _selectedSpecialty = null;
                        _bmdcCtrl.clear();
                      }
                    }),
                  )),
                  
                  if (_isDoctor) ...[
                    SizedBox(height: 16 * scale),
                    Obx(() => _buildDropdown<String>(
                      value: _selectedSpecialty,
                      items: _specCtrl.specialityList.map((e) => DropdownMenuItem(value: e.specialty, child: Text(e.specialty))).toList(),
                      hint: 'Select Speciality',
                      icon: Icons.medical_services_outlined,
                      theme: theme,
                      scale: scale,
                      onChanged: (val) => setState(() => _selectedSpecialty = val),
                    )),
                    SizedBox(height: 16 * scale),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_bmdcCtrl, 'BMDC Number', Icons.badge_outlined, theme, scale)),
                        SizedBox(width: 16 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BMDC Type', style: TextStyle(fontSize: 11 * scale, color: theme.textSecondary, fontWeight: FontWeight.w600)),
                              Row(
                                children: [
                                  Radio<int>(value: 0, groupValue: _bmdcType, onChanged: (v) => setState(() => _bmdcType = v!), activeColor: theme.accent),
                                  Text('Medical', style: TextStyle(fontSize: 12 * scale, color: theme.textPrimary)),
                                  Radio<int>(value: 1, groupValue: _bmdcType, onChanged: (v) => setState(() => _bmdcType = v!), activeColor: theme.accent),
                                  Text('Dental', style: TextStyle(fontSize: 12 * scale, color: theme.textPrimary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  SizedBox(height: 16 * scale),
                  _buildTextField(_orgCtrl, 'Organization/Hospital', Icons.account_balance_outlined, theme, scale),
                  SizedBox(height: 16 * scale),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_designationCtrl, 'Designation', Icons.assignment_ind_outlined, theme, scale)),
                      SizedBox(width: 16 * scale),
                      Expanded(child: _buildTextField(_qualCtrl, 'Qualifications', Icons.history_edu_outlined, theme, scale)),
                    ],
                  ),
                  
                  SizedBox(height: 40 * scale),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50 * scale,
                    child: ElevatedButton(
                      onPressed: _authCtrl.isLoading.value ? null : _handleRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                      ),
                      child: _authCtrl.isLoading.value
                          ? SizedBox(width: 20 * scale, height: 20 * scale, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Register Now', style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.bold)),
                    ),
                  )),
                  SizedBox(height: 20 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeDefinition theme, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * scale),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 11 * scale, fontWeight: FontWeight.w700, color: theme.accent, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, ThemeDefinition theme, double scale, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      style: TextStyle(fontSize: 14 * scale, color: theme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.textMuted),
        prefixIcon: Icon(icon, size: 18 * scale, color: theme.textMuted),
        filled: true,
        fillColor: theme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale), borderSide: BorderSide(color: theme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale), borderSide: BorderSide(color: theme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale), borderSide: BorderSide(color: theme.accent, width: 1.5)),
        contentPadding: EdgeInsets.symmetric(vertical: 16 * scale),
      ),
    );
  }

  Widget _buildDropdown<T>({T? value, required List<DropdownMenuItem<T>> items, required String hint, required IconData icon, required ThemeDefinition theme, required double scale, required Function(T?) onChanged}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: theme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          hint: Row(children: [Icon(icon, size: 18 * scale, color: theme.textMuted), SizedBox(width: 12 * scale), Text(hint, style: TextStyle(fontSize: 14 * scale, color: theme.textMuted))]),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.textMuted),
          dropdownColor: theme.surfaceElevated,
          style: TextStyle(fontSize: 14 * scale, color: theme.textPrimary),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
