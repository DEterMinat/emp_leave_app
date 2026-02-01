import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_management_provider.dart';
import '../../models/user.dart';

class UserEditScreen extends ConsumerStatefulWidget {
  final User? user;

  const UserEditScreen({super.key, this.user});

  @override
  ConsumerState<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends ConsumerState<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _quotaController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  String? _selectedRoleId;
  String? _selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username);
    _passwordController = TextEditingController();
    _emailController = TextEditingController(text: widget.user?.email);
    _phoneController = TextEditingController(text: widget.user?.phone);
    _quotaController = TextEditingController(
      text: widget.user?.annualLeaveQuota?.toString() ?? '10',
    );
    _firstNameController = TextEditingController(text: widget.user?.firstName);
    _lastNameController = TextEditingController(text: widget.user?.lastName);
    _selectedRoleId = widget.user?.roleId;
    _selectedDepartmentId = widget.user?.departmentId;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _quotaController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(allRolesProvider);
    final deptsAsync = ref.watch(allDepartmentsProvider);
    final managementState = ref.watch(userManagementProvider);
    final isEditing = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit User' : 'Create User'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.gray800,
        elevation: 0,
      ),
      body: managementState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: isEditing
                            ? 'New Password (Optional)'
                            : 'Password',
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (!isEditing && (value == null || value.isEmpty)) {
                          return 'Required';
                        }
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Min 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    rolesAsync.when(
                      data: (roles) => DropdownButtonFormField<String>(
                        value: _selectedRoleId,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(Icons.admin_panel_settings),
                        ),
                        items: roles.map((r) {
                          return DropdownMenuItem(
                            value: r['id'] as String,
                            child: Text(r['roleName'] as String),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedRoleId = val),
                        validator: (val) => val == null ? 'Required' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) => Text('Error loading roles: $err'),
                    ),
                    const SizedBox(height: 16),
                    deptsAsync.when(
                      data: (depts) => DropdownButtonFormField<String>(
                        value: _selectedDepartmentId,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          prefixIcon: Icon(Icons.business),
                        ),
                        items: depts.map((d) {
                          return DropdownMenuItem(
                            value: d['id'] as String,
                            child: Text(d['departmentName'] as String),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDepartmentId = val),
                        validator: (val) => val == null ? 'Required' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) =>
                          Text('Error loading departments: $err'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quotaController,
                      decoration: const InputDecoration(
                        labelText: 'Annual Leave Quota',
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (int.tryParse(value) == null)
                          return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _save(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isEditing ? 'Update User' : 'Create User'),
                    ),
                    if (managementState.error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        managementState.error!,
                        style: const TextStyle(color: AppTheme.danger),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  void _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final userData = {
      'username': _usernameController.text,
      'password': _passwordController.text.isNotEmpty
          ? _passwordController.text
          : null,
      'roleId': _selectedRoleId,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'annualLeaveQuota': int.parse(_quotaController.text),
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'departmentId': _selectedDepartmentId,
    };

    final notifier = ref.read(userManagementProvider.notifier);
    bool success;

    if (widget.user != null) {
      success = await notifier.updateUser(widget.user!.id, userData);
    } else {
      success = await notifier.createUser(userData);
    }

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.user != null ? 'User updated' : 'User created'),
        ),
      );
      ref.invalidate(allUsersProvider);
      Navigator.pop(context);
    }
  }
}
