import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/api/api_client.dart';

import 'providers/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'providers/notification_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/notification/notification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  // Initialize API client
  await ApiClient().init();

  // Initialize Firebase (Requires google-services.json for Android/iOS)
  /*
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(FCMService.onBackgroundMessage);
    await FCMService().init();
  } catch (e) {
    debugPrint(
      '⚠️ Firebase not initialized: $e (This is expected if config files are missing)',
    );
  }
  */

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
          ? const _AuthenticatedApp()
          : const LoginScreen(),
    );
  }
}

class _AuthenticatedApp extends ConsumerStatefulWidget {
  const _AuthenticatedApp();

  @override
  ConsumerState<_AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends ConsumerState<_AuthenticatedApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).initSignalR();
      // Register FCM Token
      /*
      final userId = ref.read(authProvider).userId;
      if (userId != null) {
        FCMService().registerToken(userId);
      }
      */
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for new notifications to show SnackBar
    ref.listen<List<NotificationItem>>(notificationListProvider, (
      previous,
      next,
    ) {
      if (previous != null && next.length > previous.length) {
        final newNotification = next.first; // Assumes new items added to start
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  newNotification.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(newNotification.message),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.blueAccent,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
            ),
          ),
        );
      }
    });

    return const DashboardScreen();
  }
}
