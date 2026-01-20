// Widget tests for Employee Leave App

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:emp_leave_app/features/auth/login_screen.dart';

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Verify login screen elements
    expect(find.text('Employee Leave System'), findsOneWidget);
    expect(find.text('Employee ID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Verify quick login buttons
    expect(find.text('Employee'), findsOneWidget);
    expect(find.text('Manager'), findsOneWidget);
    expect(find.text('HR'), findsOneWidget);
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    await tester.pumpAndSettle();

    // Try to submit without filling form
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Should show validation error
    expect(find.textContaining('กรุณา'), findsWidgets);
  });
}
