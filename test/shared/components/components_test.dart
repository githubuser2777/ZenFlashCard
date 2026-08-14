import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zen_flash_cards/shared/components/flip_card_3d.dart';
import 'package:zen_flash_cards/shared/components/zen_button.dart';
import 'package:zen_flash_cards/shared/components/progress_bar.dart';

void main() {
  group('Component Widget Tests', () {
    testWidgets('FlipCard3D renders front and flips on tap',
        (WidgetTester tester) async {
      bool flipped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipCard3D(
              front: const Text('Front Content'),
              back: const Text('Back Content'),
              onFlip: (isBack) => flipped = isBack,
            ),
          ),
        ),
      );

      expect(find.text('Front Content'), findsOneWidget);

      await tester.tap(find.byType(FlipCard3D));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(flipped, true);
    });

    testWidgets('ZenButton triggers onPressed callback and animates',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZenButton(
              label: 'Test Button',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      await tester.tap(find.byType(ZenButton));
      await tester.pumpAndSettle();

      expect(pressed, true);
    });

    testWidgets('ProgressBar renders with progress value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressBar(progress: 0.75),
          ),
        ),
      );

      expect(find.byType(ProgressBar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
    });
  });
}
