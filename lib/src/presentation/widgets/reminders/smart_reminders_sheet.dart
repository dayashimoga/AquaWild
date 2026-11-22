import 'package:aquawild/src/core/services/audio_haptics_service.dart';
import 'package:aquawild/src/core/services/smart_reminder_service.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/controllers/weather_activity_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Circadian smart hydration schedule bottom sheet.
class SmartRemindersSheet extends ConsumerWidget {
  const SmartRemindersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SmartRemindersSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydrationState = ref.watch(hydrationProvider);
    final weatherState = ref.watch(weatherActivityNotifierProvider);
    final reminderService = SmartReminderService();

    final reminders = reminderService.generateCircadianSchedule(
      dailyTargetMl: weatherState.dynamicTargetMl,
      currentIntakeMl: hydrationState.goal.netHydrationMl,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A2F).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFF9D4EDD).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D4EDD).withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Text(
                '🔔 Circadian Hydration Timeline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Smart rhythm synchronized with human metabolic cycles and sleep-wake hours.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 18),

          Expanded(
            child: ListView.separated(
              itemCount: reminders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = reminders[index];
                final bev = BeverageType.findById(r.suggestedBeverageId);
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162947).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: r.isCompleted
                          ? const Color(0xFF26A69A).withValues(alpha: 0.5)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: r.isCompleted
                              ? const Color(0xFF26A69A).withValues(alpha: 0.2)
                              : Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          r.isCompleted ? '✅' : r.category.defaultIcon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  r.title,
                                  style: TextStyle(
                                    color: r.isCompleted ? Colors.white60 : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    decoration: r.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                Text(
                                  r.targetTime.format(context),
                                  style: const TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r.body,
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(bev.iconEmoji, style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 4),
                                Text(
                                  'Target: ${r.recommendedVolumeMl}ml ${bev.name}',
                                  style: const TextStyle(
                                    color: Color(0xFFFFB703),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!r.isCompleted)
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00B4D8)),
                          tooltip: 'Log Target Volume',
                          onPressed: () {
                            AudioHapticsService.playPour();
                            ref.read(hydrationProvider.notifier).logDrink(
                                  beverage: bev,
                                  volumeMl: r.recommendedVolumeMl.toDouble(),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF0F2647),
                                content: Text(
                                  'Logged ${r.recommendedVolumeMl}ml ${bev.name}!',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
