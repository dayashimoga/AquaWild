import 'package:aquawild/src/core/services/audio_haptics_service.dart';
import 'package:aquawild/src/presentation/controllers/sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Status pill displaying live Supabase cloud sync state (Synced, Syncing, Offline Pending).
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    String label;
    IconData icon;
    Color color;

    switch (syncState.status) {
      case CloudSyncStatus.synced:
        label = 'Cloud Synced';
        icon = Icons.cloud_done_rounded;
        color = const Color(0xFF26A69A);
        break;
      case CloudSyncStatus.syncing:
        label = 'Syncing...';
        icon = Icons.sync_rounded;
        color = const Color(0xFF00E5FF);
        break;
      case CloudSyncStatus.offlinePending:
        label = '${syncState.pendingCount} Pending';
        icon = Icons.cloud_queue_rounded;
        color = const Color(0xFFFFB703);
        break;
      case CloudSyncStatus.error:
        label = 'Sync Error';
        icon = Icons.sync_problem_rounded;
        color = const Color(0xFFFF5252);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AudioHapticsService.playTap();
          ref.read(syncProvider.notifier).triggerSync();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF0F2647),
              content: Text(
                syncState.pendingCount > 0
                    ? 'Flushing ${syncState.pendingCount} queued entries to Supabase PostgreSQL...'
                    : 'All records fully synchronized with cloud.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
