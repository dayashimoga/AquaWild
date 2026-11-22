import 'package:aquawild/src/presentation/widgets/ai/ai_coach_sheet.dart';
import 'package:aquawild/src/presentation/widgets/environmental/weather_activity_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AI Coach Sheet & Weather Activity Bar UI Tests', () {
    testWidgets('WeatherActivityBar renders weather, workout, AI coach, and reminder capsules', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WeatherActivityBar(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI Coach'), findsOneWidget);
      expect(find.text('Circadian'), findsOneWidget);
      expect(find.text('Log Workout'), findsOneWidget);
    });

    testWidgets('AiCoachSheet renders companion title and quick log button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AiCoachSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('AI Coach'), findsWidgets);
      expect(find.text('Refresh Analysis'), findsOneWidget);
    });
  });
}
