import 'package:aquawild/src/domain/models/smart_reminder.dart';
import 'package:flutter/material.dart';

/// Intelligent circadian reminder scheduler distributing hydration intervals across waking hours.
class SmartReminderService {
  /// Generates a personalized daily schedule based on daily hydration targets and metabolic rhythms.
  List<SmartReminder> generateCircadianSchedule({
    required double dailyTargetMl,
    required double currentIntakeMl,
    TimeOfDay wakeTime = const TimeOfDay(hour: 7, minute: 30),
    TimeOfDay sleepTime = const TimeOfDay(hour: 22, minute: 30),
  }) {
    // 5 circadian anchors:
    // 1. Awakening Kickstart (Wake + 30 min): 15% of daily goal
    // 2. Midday Focus (10:30): 25% of daily goal
    // 3. Post-Lunch Hydration (13:30): 20% of daily goal
    // 4. Afternoon Rejuvenation (16:30): 25% of daily goal
    // 5. Evening Taper (Sleep - 2 hours): 15% of daily goal

    final morningVol = (dailyTargetMl * 0.15).round().clamp(200, 500);
    final midDayVol = (dailyTargetMl * 0.25).round().clamp(250, 600);
    final postLunchVol = (dailyTargetMl * 0.20).round().clamp(200, 500);
    final afternoonVol = (dailyTargetMl * 0.25).round().clamp(250, 600);
    final eveningVol = (dailyTargetMl * 0.15).round().clamp(150, 350);

    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    bool isPast(int targetHour, int targetMin) {
      if (currentHour > targetHour) return true;
      if (currentHour == targetHour && currentMinute >= targetMin) return true;
      return false;
    }

    return [
      SmartReminder(
        targetTime: TimeOfDay(hour: wakeTime.hour, minute: (wakeTime.minute + 30) % 60),
        title: 'Morning Awakening Sip',
        body: 'Rehydrate post-sleep with crisp lemon water to stimulate metabolism.',
        recommendedVolumeMl: morningVol,
        suggestedBeverageId: 'lemon_water',
        category: ReminderCategory.morningKickstart,
        isCompleted: isPast(8, 0) && currentIntakeMl >= morningVol,
      ),
      SmartReminder(
        targetTime: const TimeOfDay(hour: 10, minute: 30),
        title: 'Mid-Morning Cognitive Flow',
        body: 'A cup of green tea or pure water maintains mental acuity.',
        recommendedVolumeMl: midDayVol,
        suggestedBeverageId: 'green_tea',
        category: ReminderCategory.midDayMaintenance,
        isCompleted: isPast(10, 30) && currentIntakeMl >= (morningVol + midDayVol),
      ),
      SmartReminder(
        targetTime: const TimeOfDay(hour: 13, minute: 30),
        title: 'Post-Lunch Digestion Boost',
        body: 'Keep cellular hydration balanced after meals.',
        recommendedVolumeMl: postLunchVol,
        suggestedBeverageId: 'pure_water',
        category: ReminderCategory.midDayMaintenance,
        isCompleted: isPast(13, 30) && currentIntakeMl >= (morningVol + midDayVol + postLunchVol),
      ),
      SmartReminder(
        targetTime: const TimeOfDay(hour: 16, minute: 30),
        title: 'Afternoon Slump Destroyer',
        body: 'Replenish electrolytes or enjoy a refreshing iced water.',
        recommendedVolumeMl: afternoonVol,
        suggestedBeverageId: 'coconut_water',
        category: ReminderCategory.afternoonBoost,
        isCompleted: isPast(16, 30) && currentIntakeMl >= (dailyTargetMl * 0.85),
      ),
      SmartReminder(
        targetTime: TimeOfDay(hour: (sleepTime.hour - 2).clamp(18, 23), minute: 0),
        title: 'Evening Relaxing Taper',
        body: 'A gentle chamomile infusion prepares your body for restorative sleep.',
        recommendedVolumeMl: eveningVol,
        suggestedBeverageId: 'herbal_tea',
        category: ReminderCategory.eveningWindDown,
        isCompleted: currentIntakeMl >= dailyTargetMl,
      ),
    ];
  }
}
