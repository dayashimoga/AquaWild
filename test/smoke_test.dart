import 'package:aquawild/main.dart';
import 'package:aquawild/src/core/constants/app_constants.dart';
import 'package:aquawild/src/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AquaWild Smoke & Integration Tests', () {
    test('AppConstants definitions are validated', () {
      expect(AppConstants.appName, equals('AquaWild'));
      expect(AppConstants.defaultDailyGoalMl, equals(2500));
      expect(AppConstants.targetFps, equals(120.0));
      expect(AppConstants.maxFrameBudgetMs, lessThan(8.4));
    });

    test('AppColors signature tokens are defined', () {
      expect(AppColors.cyanPrimary.toARGB32(), equals(0xFF00E5FF));
      expect(AppColors.surfaceAbyssal.toARGB32(), equals(0xFF060B18));
      expect(AppColors.waterCyan.toARGB32(), equals(0xFF29B6F6));
      expect(AppColors.redPandaAuburn.toARGB32(), equals(0xFFD84315));
    });

    testWidgets('AquaWildApp mounts cleanly with ProviderScope and shows LaunchScreen with Red Panda Mascot',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquaWildApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text('Dive Into Habitat'), findsOneWidget);
      expect(find.text('Bamboo Misty Springs • Relax Mode'), findsOneWidget);

      // Verify Red Panda mascot semantics is accessible
      final mascot = find.bySemanticsLabel(
        RegExp(r'Ruby the Red Panda wearing aviator sunglasses'),
      );
      expect(mascot, findsOneWidget);
    });

    testWidgets('Navigating to HomeScreen displays active companion and quick dock',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquaWildApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final diveInButton = find.text('Dive Into Habitat');
      expect(diveInButton, findsOneWidget);

      await tester.tap(diveInButton);
      await tester.pumpAndSettle();

      expect(find.text('Ruby the Red Panda'), findsOneWidget);
      expect(find.text('Net Hydration'), findsOneWidget);
      expect(find.text('Quick Log Beverage'), findsOneWidget);

      // Tap quick log water button
      final quickLogButton = find.text('+250ml').first;
      await tester.tap(quickLogButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('250 / 2500 ml'), findsOneWidget);
    });
  });
}
