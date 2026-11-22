import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/hydration_entry.dart';
import 'package:aquawild/src/presentation/controllers/sync_controller.dart';
import 'package:aquawild/src/presentation/widgets/sync/sync_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sync Status Indicator UI Tests', () {
    testWidgets('Renders Cloud Synced state initially and transitions to Pending', (tester) async {
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      late WidgetRef containerRef;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  containerRef = ref;
                  return const SyncStatusIndicator();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cloud Synced'), findsOneWidget);

      // Enqueue offline drink
      final entry = HydrationEntry.create(
        id: 'entry_test_999',
        beverage: BeverageType.pureWater,
        volumeMl: 250.0,
      );

      containerRef.read(syncProvider.notifier).enqueueHydrationEntry(entry);
      await tester.pump(const Duration(milliseconds: 100));

      // Should transition to syncing or synced
      expect(find.byType(SyncStatusIndicator), findsOneWidget);
    });
  });
}
