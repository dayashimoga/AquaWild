import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/interactive_pour_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InteractivePourSheet Tests', () {
    testWidgets('Renders beverage name, initial volume and confirms pour',
        (tester) async {
      double confirmedVolume = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractivePourSheet(
              initialBeverage: BeverageType.greenTea,
              onPourConfirmed: (vol) {
                confirmedVolume = vol;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(BeverageType.greenTea.name), findsOneWidget);
      expect(find.text('ml'), findsOneWidget);

      // Tap preset 350ml button
      final presetButton = find.text('350ml');
      expect(presetButton, findsOneWidget);
      await tester.tap(presetButton);
      await tester.pumpAndSettle();

      // Tap Log button
      final logButton = find.byType(ElevatedButton);
      expect(logButton, findsOneWidget);
      await tester.tap(logButton);
      await tester.pumpAndSettle();

      expect(confirmedVolume, equals(350.0));
    });
  });
}
