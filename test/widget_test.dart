// Widget tests for Employee Leave App

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emp_leave_app/features/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    // Mock Environment Variables
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost:5082/api');
  });

  testWidgets('Login screen builds and shows title', (WidgetTester tester) async {
    // Set larger viewport for testing
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify main title and form labels
    expect(find.text('Employee Leave System'), findsOneWidget);
    expect(find.text('Employee ID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pump();

    // Find and tap Sign In button
    final signInButton = find.text('Sign In');
    expect(signInButton, findsOneWidget);
    
    await tester.tap(signInButton);
    await tester.pump();

    // Should show validation errors in Thai
    expect(find.text('กรุณากรอกรหัสพนักงาน'), findsOneWidget);
    expect(find.text('กรุณากรอกรหัสผ่าน'), findsOneWidget);
  });
}
