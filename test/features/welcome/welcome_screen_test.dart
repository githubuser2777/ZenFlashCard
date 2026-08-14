import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zen_flash_cards/features/welcome/welcome_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('WelcomeScreen renders Zen branding and action buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('ZenFlashCards'), findsOneWidget);
    expect(find.text('Dark · Calm · Focused'), findsOneWidget);
    expect(find.text('Begin Journey'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
