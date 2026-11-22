import 'package:aquawild/src/presentation/widgets/analytics/predictive_analytics_sheet.dart';
import 'package:aquawild/src/presentation/widgets/biomes/biome_companion_selector_sheet.dart';
import 'package:aquawild/src/presentation/widgets/gamification/achievements_gallery_sheet.dart';
import 'package:aquawild/src/presentation/widgets/gamification/streak_badge_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gamification, Biomes & Analytics UI Tests', () {
    testWidgets('StreakBadgeChip renders streak days and freeze badge', (tester) async {
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StreakBadgeChip(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Streak'), findsOneWidget);
    });

    testWidgets('AchievementsGallerySheet renders streak card, seasonal challenge, and badges', (tester) async {
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AchievementsGallerySheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Badges & Habit Quests'), findsOneWidget);
      expect(find.textContaining('Achievement Badges'), findsOneWidget);
    });

    testWidgets('BiomeCompanionSelectorSheet renders companions and biomes tabs', (tester) async {
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BiomeCompanionSelectorSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Companions'), findsWidgets);
      expect(find.textContaining('Living Biomes'), findsWidgets);
    });

    testWidgets('PredictiveAnalyticsSheet renders risk meter and rolling charts', (tester) async {
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PredictiveAnalyticsSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Predictive Hydration Analytics'), findsOneWidget);
      expect(find.textContaining('7-Day Rolling'), findsOneWidget);
    });
  });
}
