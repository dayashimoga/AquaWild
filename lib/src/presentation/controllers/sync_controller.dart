import 'package:aquawild/src/core/services/supabase_sync_service.dart';
import 'package:aquawild/src/domain/models/hydration_entry.dart';
import 'package:aquawild/src/domain/models/sync_queue_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CloudSyncStatus {
  synced,
  syncing,
  offlinePending,
  error,
}

class SyncState {
  final CloudSyncStatus status;
  final int pendingCount;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  const SyncState({
    this.status = CloudSyncStatus.synced,
    this.pendingCount = 0,
    this.lastSyncedAt,
    this.errorMessage,
  });

  SyncState copyWith({
    CloudSyncStatus? status,
    int? pendingCount,
    DateTime? lastSyncedAt,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage,
    );
  }
}

/// Riverpod 3 Notifier coordinating background offline-first queue and Supabase cloud replication.
class SyncNotifier extends Notifier<SyncState> {
  late final SupabaseSyncService _service;

  @override
  SyncState build() {
    _service = SupabaseSyncService();
    return SyncState(lastSyncedAt: DateTime.now());
  }

  /// Enqueues a hydration entry for cloud synchronization.
  void enqueueHydrationEntry(HydrationEntry entry) {
    _service.enqueue(
      SyncQueueItem(
        entityType: SyncEntityType.hydrationEntry,
        action: SyncAction.create,
        payload: {
          'id': entry.id,
          'beverageId': entry.beverage.id,
          'volumeMl': entry.volumeMl,
          'netHydrationMl': entry.netHydrationMl,
          'loggedAt': entry.timestamp.toIso8601String(),
        },
      ),
    );

    state = state.copyWith(
      status: CloudSyncStatus.offlinePending,
      pendingCount: _service.pendingCount,
    );

    // Auto-flush in background if online
    triggerSync();
  }

  /// Flushes pending mutations to Supabase PostgreSQL.
  Future<void> triggerSync() async {
    if (_service.pendingCount == 0) {
      state = state.copyWith(status: CloudSyncStatus.synced);
      return;
    }

    state = state.copyWith(status: CloudSyncStatus.syncing);

    try {
      await _service.flushQueue();
      if (!ref.mounted) return;

      if (_service.pendingCount == 0) {
        state = state.copyWith(
          status: CloudSyncStatus.synced,
          pendingCount: 0,
          lastSyncedAt: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          status: CloudSyncStatus.offlinePending,
          pendingCount: _service.pendingCount,
        );
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: CloudSyncStatus.error,
        errorMessage: 'Network timeout: Changes preserved in local offline queue',
      );
    }
  }

  /// Toggle simulated connectivity for testing and demo modes.
  void toggleConnectivity(bool isOnline) {
    _service.setOnlineStatus(isOnline);
    state = state.copyWith(
      status: isOnline && _service.pendingCount == 0
          ? CloudSyncStatus.synced
          : CloudSyncStatus.offlinePending,
    );
    if (isOnline) {
      triggerSync();
    }
  }
}

/// Provider for Supabase Cloud Sync.
final syncProvider = NotifierProvider<SyncNotifier, SyncState>(() {
  return SyncNotifier();
});
