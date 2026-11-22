import 'package:flutter/material.dart';
import '../../../domain/models/out_of_app_telemetry.dart';

/// Interactive high-contrast Lock Screen Live Activity & Dynamic Island Simulator
class LockScreenLiveActivityView extends StatelessWidget {
  final OutOfAppTelemetrySnapshot snapshot;
  final ValueChanged<int>? onQuickLog;
  final VoidCallback? onSnooze;

  const LockScreenLiveActivityView({
    super.key,
    required this.snapshot,
    this.onQuickLog,
    this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final budget = snapshot.budget;
    final progress = budget.progressFraction.clamp(0.0, 1.0);
    final percent = budget.progressPercent;

    return Semantics(
      label:
          'AquaWild Lock Screen Live Activity. ${snapshot.activeCompanionName}, $percent percent hydrated, ${budget.netConsumedMl.round()} of ${budget.targetMl.round()} milliliters.',
      container: true,
      child: Container(
        width: 340,
        height: 140,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: const Color(0xFF060B14).withValues(alpha: 0.96),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.28),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Bar: Companion Info + Live Capsule
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        snapshot.companionEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.activeCompanionName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              snapshot.companionStageTitle,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E5FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'LIVE ACTIVITY',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00E5FF),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Middle: Progress Bar & Volume Metrics
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${budget.netConsumedMl.round()} / ${budget.targetMl.round()} ml ($percent%)',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Next: ${snapshot.circadianContext.anchorTimeFormatted}',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00E5FF),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Actions: Quick-Log & Snooze
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      key: const Key('live_activity_log_250_btn'),
                      onPressed: () => onQuickLog?.call(250),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF00E5FF).withValues(alpha: 0.2),
                        foregroundColor: const Color(0xFF00E5FF),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color:
                                const Color(0xFF00E5FF).withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 12),
                          SizedBox(width: 3),
                          Text(
                            '+250ml Water 💧',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 28,
                    child: OutlinedButton(
                      key: const Key('live_activity_snooze_btn'),
                      onPressed: onSnooze,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: EdgeInsets.zero,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Snooze 30m',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
