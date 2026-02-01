import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../auth/login_screen.dart';
import '../../providers/user_management_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fnameController;
  late TextEditingController _lnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _selectedDepartmentId;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fnameController = TextEditingController();
    _lnameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populateControllers() {
    final state = ref.read(profileProvider);
    if (state.employee != null) {
      _fnameController.text = state.employee!.firstName;
      _lnameController.text = state.employee!.lastName;
      _emailController.text = state.employee!.email;
      _phoneController.text = state.employee!.phone ?? '';
      _addressController.text = state.employee!.address ?? '';
      _selectedDepartmentId = state.employee!.departmentId;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(profileProvider.notifier)
        .updateProfile(
          _fnameController.text,
          _lnameController.text,
          _emailController.text,
          _phoneController.text,
          _addressController.text,
          _selectedDepartmentId ?? '',
        );

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('อัปเดตข้อมูลสำเร็จ'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    // Auto populate on first load if not editing
    if (!_isEditing &&
        profileState.employee != null &&
        _fnameController.text.isEmpty) {
      _populateControllers();
    }

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        actions: [
          if (profileState.employee != null)
            TextButton(
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    _populateControllers(); // Reset on cancel
                  }
                  _isEditing = !_isEditing;
                });
              },
              child: Text(_isEditing ? 'Cancel' : 'Edit'),
            ),
        ],
      ),
      body: profileState.isLoading && profileState.employee == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppTheme.logoGradient,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profileState.employee != null
                              ? '${profileState.employee!.firstName} ${profileState.employee!.lastName}'
                              : (ref.watch(authProvider).username ?? 'User'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gray800,
                          ),
                        ),
                        Text(
                          profileState.employee?.departmentName ??
                              (ref.watch(authProvider).roleName ?? 'Admin'),
                          style: TextStyle(color: AppTheme.gray500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (profileState.employee == null && !profileState.isLoading)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.warning,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Please complete your profile information to use all features.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.gray700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _isEditing = true),
                            child: const Text('Complete Now'),
                          ),
                        ],
                      ),
                    ),

                  // Profile Form
                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.gray200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ProfileField(
                                  label: 'First Name',
                                  controller: _fnameController,
                                  enabled: _isEditing,
                                  icon: Icons.person_outline,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _ProfileField(
                                  label: 'Last Name',
                                  controller: _lnameController,
                                  enabled: _isEditing,
                                  icon: Icons.person_outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _ProfileField(
                            label: 'Email',
                            controller: _emailController,
                            enabled:
                                _isEditing, // Allow email edit or make read-only? Assuming edit ok.
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _ProfileField(
                            label: 'Phone',
                            controller: _phoneController,
                            enabled: _isEditing,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _ProfileField(
                            label: 'Address',
                            controller: _addressController,
                            enabled: _isEditing,
                            icon: Icons.location_on_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          // Department Dropdown
                          ref
                              .watch(allDepartmentsProvider)
                              .when(
                                data: (depts) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Department',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.gray500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _selectedDepartmentId,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.business_outlined,
                                          size: 20,
                                          color: _isEditing
                                              ? AppTheme.primary
                                              : AppTheme.gray400,
                                        ),
                                        filled: true,
                                        fillColor: _isEditing
                                            ? Colors.white
                                            : AppTheme.gray50,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppTheme.gray200,
                                          ),
                                        ),
                                      ),
                                      items: depts.map((d) {
                                        return DropdownMenuItem<String>(
                                          value: d['id'],
                                          child: Text(d['departmentName']),
                                        );
                                      }).toList(),
                                      onChanged: _isEditing
                                          ? (val) {
                                              setState(() {
                                                _selectedDepartmentId = val;
                                              });
                                            }
                                          : null,
                                      validator: (value) => value == null
                                          ? 'Please select department'
                                          : null,
                                    ),
                                  ],
                                ),
                                loading: () => const SizedBox(
                                  height: 2,
                                  child: LinearProgressIndicator(),
                                ),
                                error: (e, _) => Text('Error: $e'),
                              ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save Button (only when editing)
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: profileState.isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: profileState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.danger,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.danger,
                        side: BorderSide(
                          color: AppTheme.danger.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.gray500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20,
              color: enabled ? AppTheme.primary : AppTheme.gray400,
            ),
            filled: true,
            fillColor: enabled ? Colors.white : AppTheme.gray50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.gray200),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            return null;
          },
        ),
      ],
    );
  }
}
