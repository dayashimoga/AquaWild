import 'package:flutter/material.dart';
import '../../../domain/models/out_of_app_telemetry.dart';

/// Interactive high-fidelity Compact (2x2) Home Screen Widget
class CompactWidgetView extends StatelessWidget {
  final OutOfAppTelemetrySnapshot snapshot;
  final ValueChanged<int>? onQuickLog;

  const CompactWidgetView({
    super.key,
    required this.snapshot,
    this.onQuickLog,
  });

  @override
  Widget build(BuildContext context) {
    final budget = snapshot.budget;
    final progress = budget.progressFraction.clamp(0.0, 1.0);
    final percent = budget.progressPercent;

    return Semantics(
      label:
          'AquaWild 2x2 Widget. ${snapshot.activeCompanionName}, $percent percent hydrated, ${budget.netConsumedMl.round()} of ${budget.targetMl.round()} milliliters.',
      container: true,
      child: Container(
        width: 156,
        height: 156,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF132238).withValues(alpha: 0.92),
              const Color(0xFF09111E).withValues(alpha: 0.96),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Header: Companion + Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.companionEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      snapshot.activeCompanionName.split(' ').first,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 2),
                      Text(
                        '${budget.streakDays}d',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Center Circular Progress Meter
            SizedBox(
              width: 58,
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5.5,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00E5FF),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${budget.netConsumedMl.round()}ml',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Quick-Log Button
            SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                key: const Key('widget_quick_log_250_btn'),
                onPressed: () => onQuickLog?.call(250),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF00E5FF).withValues(alpha: 0.2),
                  foregroundColor: const Color(0xFF00E5FF),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 12),
                    SizedBox(width: 2),
                    Text(
                      '250ml 💧',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
