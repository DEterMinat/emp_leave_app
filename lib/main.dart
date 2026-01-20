import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/api/api_client.dart';
import 'providers/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client
  await ApiClient().init();

  runApp(const ProviderScope(child: EmployeeLeaveApp()));
}

class EmployeeLeaveApp extends ConsumerStatefulWidget {
  const EmployeeLeaveApp({super.key});

  @override
  ConsumerState<EmployeeLeaveApp> createState() => _EmployeeLeaveAppState();
}

class _EmployeeLeaveAppState extends ConsumerState<EmployeeLeaveApp> {
  @override
  void initState() {
    super.initState();
    // Check for existing auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Employee Leave',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: authState.isAuthenticated
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}
