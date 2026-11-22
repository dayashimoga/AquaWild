import 'package:flutter/material.dart';
import '../../../domain/models/out_of_app_telemetry.dart';

/// Interactive high-fidelity Medium (4x2) Home Screen Widget
class MediumWidgetView extends StatelessWidget {
  final OutOfAppTelemetrySnapshot snapshot;
  final ValueChanged<int>? onQuickLog;

  const MediumWidgetView({
    super.key,
    required this.snapshot,
    this.onQuickLog,
  });

  @override
  Widget build(BuildContext context) {
    final budget = snapshot.budget;
    final progress = budget.progressFraction.clamp(0.0, 1.0);
    final percent = budget.progressPercent;
    final pace = snapshot.circadianContext.paceStatus;

    return Semantics(
      label:
          'AquaWild 4x2 Widget. ${snapshot.activeCompanionName}, $percent percent hydrated, ${budget.netConsumedMl.round()} of ${budget.targetMl.round()} milliliters. Status: ${pace.label}.',
      container: true,
      child: Container(
        width: 328,
        height: 156,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF132238).withValues(alpha: 0.94),
              const Color(0xFF0A1322).withValues(alpha: 0.98),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Section: Left Meter + Right Telemetry Cards
            Expanded(
              child: Row(
                children: [
                  // Left Meter Card
                  SizedBox(
                    width: 90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 5,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF00E5FF),
                                ),
                              ),
                              Text(
                                snapshot.companionEmoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$percent% Goal',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${budget.netConsumedMl.round()} / ${budget.targetMl.round()}ml',
                          style: TextStyle(
                            fontSize: 8.5,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Right Telemetry Deck
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: Companion + Pace + Streak
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                snapshot.activeCompanionName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🔥',
                                      style: TextStyle(fontSize: 9)),
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

                        // Circadian Phase pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${pace.label} • Next: ${snapshot.circadianContext.anchorTimeFormatted}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF00E5FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Multi-Nutrient Chips
                        Row(
                          children: [
                            _buildNutrientBadge(
                              label: '☕ ${budget.caffeineConsumedMg.round()}mg',
                              color: budget.caffeineSafetyStatus ==
                                      CaffeineSafetyStatus.exceeded
                                  ? Colors.redAccent
                                  : (budget.caffeineSafetyStatus ==
                                          CaffeineSafetyStatus.caution
                                      ? Colors.amberAccent
                                      : Colors.white70),
                            ),
                            const SizedBox(width: 4),
                            _buildNutrientBadge(
                              label: '⚡ ${budget.electrolyteScorePercent}%',
                              color: budget.electrolyteStatus ==
                                      ElectrolyteBalanceStatus.depleted
                                  ? Colors.redAccent
                                  : Colors.tealAccent,
                            ),
                            const SizedBox(width: 4),
                            _buildNutrientBadge(
                              label:
                                  '🍯 ${budget.sugarConsumedG.toStringAsFixed(0)}g',
                              color: budget.hasExceededSugarBudget
                                  ? Colors.redAccent
                                  : Colors.white70,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 2),

            // Bottom Multi-Log Quick Dock
            Row(
              children: [
                _buildQuickLogButton(150, '150ml'),
                const SizedBox(width: 6),
                _buildQuickLogButton(250, '250ml 💧'),
                const SizedBox(width: 6),
                _buildQuickLogButton(330, '330ml'),
                const SizedBox(width: 6),
                _buildQuickLogButton(500, '500ml ⚡'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildQuickLogButton(int volumeMl, String label) {
    return Expanded(
      child: SizedBox(
        height: 26,
        child: ElevatedButton(
          key: Key('widget_quick_log_${volumeMl}_btn'),
          onPressed: () => onQuickLog?.call(volumeMl),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
            foregroundColor: const Color(0xFF00E5FF),
            padding: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
