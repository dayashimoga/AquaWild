import 'package:aquawild/src/core/services/widget_bridge_sync_service.dart';
import 'package:aquawild/src/core/services/widget_notification_telemetry_service.dart';
import 'package:aquawild/src/data/repositories/local_hydration_repository.dart';
import 'package:aquawild/src/domain/models/out_of_app_telemetry.dart';
import 'package:aquawild/src/domain/models/widget_models.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/controllers/telemetry_controller.dart';
import 'package:aquawild/src/presentation/widgets/widgets_preview/compact_widget_view.dart';
import 'package:aquawild/src/presentation/widgets/widgets_preview/lock_screen_widget_view.dart';
import 'package:aquawild/src/presentation/widgets/widgets_preview/medium_widget_view.dart';
import 'package:aquawild/src/presentation/widgets/widgets_preview/widget_preview_studio_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  OutOfAppTelemetrySnapshot createSampleSnapshot({
    double netConsumedMl = 1639.0,
    double targetMl = 2500.0,
    int streakDays = 7,
  }) {
    return OutOfAppTelemetrySnapshot(
      timestamp: DateTime(2026, 11, 22, 11, 30),
      budget: HydrationBudgetSummary(
        targetMl: targetMl,
        netConsumedMl: netConsumedMl,
        grossConsumedMl: netConsumedMl,
        caffeineConsumedMg: 120.0,
        electrolytesConsumedMg: 450.0,
        sugarConsumedG: 14.0,
        streakDays: streakDays,
      ),
      activeCompanionId: 'red_panda',
      activeCompanionName: 'Ruby the Red Panda',
      companionEmoji: '🦊',
      companionCapacityMl: 2500,
      companionStageTitle: 'Novice Puddle Cub',
      evolutionStageIndex: 0,
      userXp: 850,
      xpUntilNextStage: 150,
      activeBiomeId: 'bamboo_misty_springs',
      activeBiomeName: 'Bamboo Misty Springs',
      nextUnlock: const NextUnlockProgression(
        nextAnimalId: 'capybara',
        nextAnimalName: 'Barnaby the Capybara',
        nextAnimalEmoji: '🦫',
        unlockXp: 1000,
        currentXp: 850,
        xpNeeded: 150,
        progressFraction: 0.85,
        isAllUnlocked: false,
      ),
      circadianContext: const CircadianContext(
        phaseName: 'Mid-Morning Cognitive Flow',
        anchorTimeFormatted: '10:30',
        paceStatus: CircadianPaceStatus.onTrack,
        expectedProgressPercent: 50,
        suggestedNextSipMl: 250,
        suggestedBeverageName: 'Green Tea',
      ),
      unclaimedAchievementsCount: 1,
      quickLogPresetMl: const [150, 250, 330, 500],
    );
  }

  group('Widget Models & Bridge Sync Service Tests', () {
    test('WidgetFamily definitions have correct dimensions and labels', () {
      expect(WidgetFamily.systemSmall.width, equals(156.0));
      expect(WidgetFamily.systemSmall.height, equals(156.0));
      expect(WidgetFamily.systemMedium.width, equals(328.0));
      expect(WidgetFamily.systemMedium.height, equals(156.0));
      expect(WidgetFamily.lockScreenLiveActivity.width, equals(340.0));
      expect(WidgetFamily.lockScreenLiveActivity.height, equals(140.0));
    });

    test('WidgetSyncResult serializes cleanly to JSON', () {
      final syncResult = WidgetSyncResult(
        isSuccess: true,
        syncedAt: DateTime(2026, 11, 22, 12, 0),
        targetPlatforms: const ['local_storage', 'ios_widgetkit'],
        message: 'Synchronized telemetry',
      );

      final json = syncResult.toJson();
      expect(json['isSuccess'], isTrue);
      expect(json['targetPlatforms'], contains('ios_widgetkit'));
      expect(json['message'], equals('Synchronized telemetry'));
    });

    test('WidgetBridgeSyncService saves snapshot and records lastSyncTime', () async {
      final telemetryService = WidgetNotificationTelemetryService();
      final syncService = WidgetBridgeSyncService(telemetryService: telemetryService);

      final snapshot = createSampleSnapshot();
      final result = await syncService.syncSnapshot(snapshot);

      expect(result.isSuccess, isTrue);
      expect(syncService.lastSyncTime, isNotNull);
      expect(result.targetPlatforms, contains('local_storage'));
    });
  });

  group('Widget Component Views Unit & Interaction Tests', () {
    testWidgets('CompactWidgetView renders companion info and triggers quick-log', (tester) async {
      final snapshot = createSampleSnapshot();
      int? loggedVolume;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CompactWidgetView(
                snapshot: snapshot,
                onQuickLog: (vol) => loggedVolume = vol,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Ruby'), findsOneWidget);
      expect(find.text('66%'), findsOneWidget);
      expect(find.text('7d'), findsOneWidget);
      expect(find.text('250ml 💧'), findsOneWidget);

      await tester.tap(find.byKey(const Key('widget_quick_log_250_btn')));
      await tester.pump();

      expect(loggedVolume, equals(250));
    });

    testWidgets('MediumWidgetView renders nutrient chips and multi-log dock', (tester) async {
      final snapshot = createSampleSnapshot();
      int? loggedVolume;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MediumWidgetView(
                snapshot: snapshot,
                onQuickLog: (vol) => loggedVolume = vol,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Ruby the Red Panda'), findsOneWidget);
      expect(find.text('66% Goal'), findsOneWidget);
      expect(find.textContaining('1639 / 2500ml'), findsOneWidget);
      expect(find.textContaining('☕ 120mg'), findsOneWidget);
      expect(find.textContaining('⚡ 90%'), findsOneWidget);
      expect(find.textContaining('🍯 14g'), findsOneWidget);

      // Verify all 4 quick-log dock buttons exist
      expect(find.text('150ml'), findsOneWidget);
      expect(find.text('250ml 💧'), findsOneWidget);
      expect(find.text('330ml'), findsOneWidget);
      expect(find.text('500ml ⚡'), findsOneWidget);

      await tester.tap(find.byKey(const Key('widget_quick_log_500_btn')));
      await tester.pump();

      expect(loggedVolume, equals(500));
    });

    testWidgets('LockScreenLiveActivityView renders Live Activity indicator and snooze button', (tester) async {
      final snapshot = createSampleSnapshot();
      int? loggedVolume;
      bool snoozed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LockScreenLiveActivityView(
                snapshot: snapshot,
                onQuickLog: (vol) => loggedVolume = vol,
                onSnooze: () => snoozed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('LIVE ACTIVITY'), findsOneWidget);
      expect(find.text('Novice Puddle Cub'), findsOneWidget);
      expect(find.textContaining('1639 / 2500 ml (66%)'), findsOneWidget);
      expect(find.text('+250ml Water 💧'), findsOneWidget);
      expect(find.text('Snooze 30m'), findsOneWidget);

      await tester.tap(find.byKey(const Key('live_activity_log_250_btn')));
      await tester.pump();
      expect(loggedVolume, equals(250));

      await tester.tap(find.byKey(const Key('live_activity_snooze_btn')));
      await tester.pump();
      expect(snoozed, isTrue);
    });
  });

  group('WidgetPreviewStudioModal Studio Tests', () {
    testWidgets('Mounts studio modal, switches tabs and wallpapers, and syncs widgets', (tester) async {
      final testRepository = LocalHydrationRepository();
      final telemetryService = WidgetNotificationTelemetryService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hydrationRepositoryProvider.overrideWithValue(testRepository),
            widgetNotificationTelemetryServiceProvider
                .overrideWithValue(telemetryService),
            widgetBridgeSyncServiceProvider.overrideWithValue(
              WidgetBridgeSyncService(telemetryService: telemetryService),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WidgetPreviewStudioModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Header & Tab Selector
      expect(find.text('Widget Preview Studio'), findsOneWidget);
      expect(find.text('Compact 2x2'), findsOneWidget);
      expect(find.text('Medium 4x2'), findsOneWidget);
      expect(find.text('Lock Screen Live Activity'), findsOneWidget);

      // Default tab is Compact 2x2
      expect(find.byType(CompactWidgetView), findsOneWidget);

      // Switch to Medium 4x2 tab
      await tester.tap(find.byKey(const Key('widget_tab_systemMedium')));
      await tester.pumpAndSettle();
      expect(find.byType(MediumWidgetView), findsOneWidget);

      // Switch to Lock Screen Live Activity tab
      await tester.tap(find.byKey(const Key('widget_tab_lockScreenLiveActivity')));
      await tester.pumpAndSettle();
      expect(find.byType(LockScreenLiveActivityView), findsOneWidget);

      // Tap simulated quick-log button inside Lock Screen view
      await tester.tap(find.byKey(const Key('live_activity_log_250_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify SnackBar confirmation appeared
      expect(find.textContaining('Logged 250ml Pure Water in Simulator! 💧'), findsOneWidget);

      // Tap Sync to Device Widgets button
      await tester.tap(find.byKey(const Key('widget_sync_native_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Successfully synchronized'), findsOneWidget);
    });
  });
}
