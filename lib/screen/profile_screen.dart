import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_ctrl.dart';
import '../../controller/occupation_ctrl.dart';
import '../../controller/speciality_ctrl.dart';
import '../../controller/theme_ctrl.dart';
import 'app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthCtrl _authCtrl = Get.find<AuthCtrl>();
  final OccupationCtrl _occCtrl = Get.find<OccupationCtrl>();
  final SpecialityCtrl _specCtrl = Get.find<SpecialityCtrl>();
  final ThemeCtrl _themeCtrl = Get.find<ThemeCtrl>();

  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _orgCtrl;
  late final TextEditingController _bmdcCtrl;
  late final TextEditingController _qualCtrl;
  late final TextEditingController _designationCtrl;

  String? _selectedOccupation;
  String? _selectedSpecialty;
  int _bmdcType = 0; 

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _authCtrl.userName.value);
    _emailCtrl = TextEditingController(text: _authCtrl.userEmail.value);
    _phoneCtrl = TextEditingController(text: _authCtrl.userPhone.value);
    _orgCtrl = TextEditingController(text: _authCtrl.userOrganization.value);
    _bmdcCtrl = TextEditingController(text: _authCtrl.userBmdc.value);
    _qualCtrl = TextEditingController(text: _authCtrl.userQualification.value);
    _designationCtrl = TextEditingController(text: _authCtrl.userDesignation.value);
    
    _selectedOccupation = _authCtrl.userOccupation.value.isEmpty ? null : _authCtrl.userOccupation.value;
    _selectedSpecialty = _authCtrl.userSpecialty.value.isEmpty ? null : _authCtrl.userSpecialty.value;
    _bmdcType = int.tryParse(_authCtrl.userBmdcType.value) ?? 0;
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

  void _handleUpdate() {
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
        'dsignation': _designationCtrl.text,
        'bmdc_type': _bmdcType.toString(),
      };
      
      _authCtrl.updateProfile(data).then((_) {
        setState(() => _isEditing = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeCtrl.currentTheme;
    final scale = _themeCtrl.fontSizeScale;

    return Scaffold(
      backgroundColor: theme.bg,
      body: Row(
        children: [
          // Left Sidebar (Profile summary)
          Container(
            width: 300 * scale,
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(right: BorderSide(color: theme.divider)),
            ),
            child: Column(
              children: [
                SizedBox(height: 40 * scale),
                Container(
                  width: 100 * scale,
                  height: 100 * scale,
                  decoration: BoxDecoration(
                    color: theme.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.accent.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(Icons.person_rounded, size: 50 * scale, color: theme.accent),
                ),
                SizedBox(height: 20 * scale),
                Obx(() => Text(
                  _authCtrl.userName.value.isEmpty ? 'User Profile' : _authCtrl.userName.value,
                  style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold, color: theme.textPrimary),
                  textAlign: TextAlign.center,
                )),
                Obx(() => Text(
                  _authCtrl.userOccupation.value.isEmpty ? 'Member' : _authCtrl.userOccupation.value,
                  style: TextStyle(fontSize: 13 * scale, color: theme.textSecondary),
                )),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.all(20 * scale),
                  child: OutlinedButton.icon(
                    onPressed: _authCtrl.logout,
                    icon: Icon(Icons.logout_rounded, size: 18 * scale),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentRed,
                      side: BorderSide(color: AppTheme.accentRed.withOpacity(0.5)),
                      minimumSize: Size(double.infinity, 45 * scale),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Right Main Content (Edit form)
          Expanded(
            child: Container(
              padding: EdgeInsets.all(40 * scale),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profile Information', style: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                          if (!_isEditing)
                            ElevatedButton.icon(
                              onPressed: () => setState(() => _isEditing = true),
                              icon: Icon(Icons.edit_rounded, size: 18 * scale),
                              label: const Text('Edit Profile'),
                              style: ElevatedButton.styleFrom(backgroundColor: theme.accent, foregroundColor: Colors.white),
                            )
                          else
                            Row(
                              children: [
                                TextButton(onPressed: () => setState(() => _isEditing = false), child: const Text('Cancel')),
                                SizedBox(width: 12 * scale),
                                ElevatedButton(onPressed: _handleUpdate, child: const Text('Save Changes')),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 32 * scale),
                      
                      _buildInfoGrid(theme, scale),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(ThemeDefinition theme, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ACCOUNT BASICS', theme, scale),
        Row(
          children: [
            Expanded(child: _buildField(_nameCtrl, 'Full Name', Icons.person_outline, theme, scale)),
            SizedBox(width: 24 * scale),
            Expanded(child: _buildField(_emailCtrl, 'Email Address', Icons.email_outlined, theme, scale)),
          ],
        ),
        SizedBox(height: 20 * scale),
        Row(
          children: [
            Expanded(child: _buildField(_phoneCtrl, 'Phone Number', Icons.phone_outlined, theme, scale, enabled: false)),
            SizedBox(width: 24 * scale),
            const Spacer(),
          ],
        ),
        
        SizedBox(height: 40 * scale),
        _buildSectionHeader('PROFESSIONAL INFO', theme, scale),
        Row(
          children: [
            Expanded(
              child: _isEditing 
                ? _buildDropdown<String>(
                    value: _selectedOccupation,
                    items: _occCtrl.occupationList.map((e) => DropdownMenuItem(value: e.name, child: Text(e.name))).toList(),
                    hint: 'Occupation',
                    icon: Icons.work_outline,
                    theme: theme,
                    scale: scale,
                    onChanged: (val) => setState(() => _selectedOccupation = val),
                  )
                : _buildField(TextEditingController(text: _selectedOccupation), 'Occupation', Icons.work_outline, theme, scale, enabled: false),
            ),
            SizedBox(width: 24 * scale),
            Expanded(
              child: _isEditing && _selectedOccupation?.toLowerCase() == 'doctor'
                ? _buildDropdown<String>(
                    value: _selectedSpecialty,
                    items: _specCtrl.specialityList.map((e) => DropdownMenuItem(value: e.specialty, child: Text(e.specialty))).toList(),
                    hint: 'Speciality',
                    icon: Icons.medical_services_outlined,
                    theme: theme,
                    scale: scale,
                    onChanged: (val) => setState(() => _selectedSpecialty = val),
                  )
                : _buildField(TextEditingController(text: _selectedSpecialty), 'Speciality', Icons.medical_services_outlined, theme, scale, enabled: false),
            ),
          ],
        ),
        SizedBox(height: 20 * scale),
        Row(
          children: [
            Expanded(child: _buildField(_orgCtrl, 'Organization', Icons.business_outlined, theme, scale)),
            SizedBox(width: 24 * scale),
            Expanded(child: _buildField(_designationCtrl, 'Designation', Icons.assignment_ind_outlined, theme, scale)),
          ],
        ),
        
        if (_selectedOccupation?.toLowerCase() == 'doctor') ...[
          SizedBox(height: 40 * scale),
          _buildSectionHeader('MEDICAL REGISTRATION', theme, scale),
          Row(
            children: [
              Expanded(child: _buildField(_bmdcCtrl, 'BMDC Number', Icons.badge_outlined, theme, scale)),
              SizedBox(width: 24 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BMDC Type', style: TextStyle(fontSize: 11 * scale, color: theme.textSecondary, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Radio<int>(value: 0, groupValue: _bmdcType, onChanged: _isEditing ? (v) => setState(() => _bmdcType = v!) : null, activeColor: theme.accent),
                        Text('Medical', style: TextStyle(fontSize: 12 * scale, color: theme.textPrimary)),
                        Radio<int>(value: 1, groupValue: _bmdcType, onChanged: _isEditing ? (v) => setState(() => _bmdcType = v!) : null, activeColor: theme.accent),
                        Text('Dental', style: TextStyle(fontSize: 12 * scale, color: theme.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeDefinition theme, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * scale),
      child: Text(title, style: TextStyle(fontSize: 11 * scale, fontWeight: FontWeight.bold, color: theme.accent, letterSpacing: 1.1)),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, ThemeDefinition theme, double scale, {bool enabled = true}) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled && _isEditing,
      style: TextStyle(fontSize: 14 * scale, color: theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textSecondary),
        prefixIcon: Icon(icon, size: 18 * scale, color: theme.textMuted),
        filled: true,
        fillColor: _isEditing && enabled ? theme.bg : theme.surfaceHighlight.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10 * scale), borderSide: BorderSide(color: theme.divider)),
      ),
    );
  }

  Widget _buildDropdown<T>({T? value, required List<DropdownMenuItem<T>> items, required String hint, required IconData icon, required ThemeDefinition theme, required double scale, required Function(T?) onChanged}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: theme.bg,
        borderRadius: BorderRadius.circular(10 * scale),
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
