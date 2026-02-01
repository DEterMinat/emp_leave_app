import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../admin/user_management_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authProvider.notifier)
          .login(_usernameController.text.trim(), _passwordController.text);

      if (success && mounted) {
        final authState = ref.read(authProvider);
        final roleName = authState.roleName?.toLowerCase();

        if (roleName == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      }
    }
  }

  void _quickLogin(String role) {
    // Demo quick login
    _usernameController.text = role;
    _passwordController.text = 'demo123';
    _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Title (matching frontend)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.logoGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Employee Leave System',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gray800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'ระบบจัดการลางานพนักงาน',
                    style: TextStyle(color: AppTheme.gray500, fontSize: 14),
                  ),

                  const SizedBox(height: 32),

                  // Login Card (matching frontend style)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24), // rounded-3xl
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gray200.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: AppTheme.gray100),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Employee ID
                          Text(
                            'Employee ID',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.gray700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              hintText: 'รหัสพนักงาน',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกรหัสพนักงาน';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Password
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.gray700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'รหัสผ่าน',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.gray400,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกรหัสผ่าน';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Remember me & Forgot password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.gray600,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Error message
                          if (authState.error != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppTheme.danger,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authState.error!,
                                      style: const TextStyle(
                                        color: AppTheme.danger,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Sign In Button (gradient like frontend)
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('Sign In'),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppTheme.gray200)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Quick Login (Demo)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.gray500,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: AppTheme.gray200)),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Quick login buttons (matching frontend)
                          Row(
                            children: [
                              Expanded(
                                child: _QuickLoginButton(
                                  label: 'Employee',
                                  color: AppTheme.success,
                                  onTap: () => _quickLogin('employee'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickLoginButton(
                                  label: 'Manager',
                                  color: AppTheme.purple,
                                  onTap: () => _quickLogin('manager'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickLoginButton(
                                  label: 'HR',
                                  color: AppTheme.warning,
                                  onTap: () => _quickLogin('hr'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    '© 2025 Employee Leave System',
                    style: TextStyle(fontSize: 14, color: AppTheme.gray400),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickLoginButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLoginButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
