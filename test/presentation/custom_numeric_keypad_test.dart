import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/custom_numeric_keypad_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomNumericKeypadModal Tests', () {
    testWidgets('Enters numbers, handles backspace and logs confirmed amount',
        (tester) async {
      double loggedAmount = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomNumericKeypadModal(
              beverage: BeverageType.pureWater,
              onAmountConfirmed: (amount) {
                loggedAmount = amount;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial digits is '300'
      expect(find.text('300'), findsOneWidget);

      // Tap Clear 'C'
      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsWidgets);

      // Tap 7, then 5, then 0
      await tester.tap(find.text('7'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      expect(find.text('750'), findsOneWidget);

      // Tap Log button
      final logButton = find.text('Log 750.0 ml');
      expect(logButton, findsOneWidget);
      await tester.tap(logButton);
      await tester.pumpAndSettle();

      expect(loggedAmount, equals(750.0));
    });
  });
}
