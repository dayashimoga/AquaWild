import 'package:aquawild/src/core/services/supabase_sync_service.dart';
import 'package:aquawild/src/domain/models/sync_queue_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Supabase Offline-First Sync Service Tests', () {
    late SupabaseSyncService syncService;

    setUp(() {
      syncService = SupabaseSyncService();
    });

    test('Initial sync queue starts empty and online', () {
      expect(syncService.pendingCount, equals(0));
      expect(syncService.isOnline, isTrue);
    });

    test('Enqueueing items increases pending count', () {
      final item = SyncQueueItem(
        entityType: SyncEntityType.hydrationEntry,
        action: SyncAction.create,
        payload: {
          'id': 'entry_123',
          'volumeMl': 350.0,
          'beverageId': 'pure_water',
        },
      );

      syncService.enqueue(item);
      expect(syncService.pendingCount, equals(1));
      expect(syncService.pendingItems.first.payload['volumeMl'], equals(350.0));
    });

    test('flushQueue processes and empties pending items when online', () async {
      final item1 = SyncQueueItem(
        entityType: SyncEntityType.hydrationEntry,
        action: SyncAction.create,
        payload: {'id': 'e1'},
      );
      final item2 = SyncQueueItem(
        entityType: SyncEntityType.userStreak,
        action: SyncAction.update,
        payload: {'currentStreak': 5},
      );

      syncService.enqueue(item1);
      syncService.enqueue(item2);
      expect(syncService.pendingCount, equals(2));

      final syncedCount = await syncService.flushQueue();
      expect(syncedCount, equals(2));
      expect(syncService.pendingCount, equals(0));
      expect(syncService.lastSyncTime, isNotNull);
    });

    test('Offline status pauses flushing until back online', () async {
      syncService.setOnlineStatus(false);
      expect(syncService.isOnline, isFalse);

      final item = SyncQueueItem(
        entityType: SyncEntityType.activitySession,
        action: SyncAction.create,
        payload: {'activityType': 'running'},
      );
      syncService.enqueue(item);

      final synced = await syncService.flushQueue();
      expect(synced, equals(0));
      expect(syncService.pendingCount, equals(1)); // Preserved locally!

      // Reconnect
      syncService.setOnlineStatus(true);
      final syncedAfterOnline = await syncService.flushQueue();
      expect(syncedAfterOnline, equals(1));
      expect(syncService.pendingCount, equals(0));
    });
  });
}
