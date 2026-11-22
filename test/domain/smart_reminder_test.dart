import 'package:aquawild/src/core/services/smart_reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Smart Reminder Circadian Scheduler Tests', () {
    test('generateCircadianSchedule produces 5 circadian anchors', () {
      final service = SmartReminderService();
      final schedule = service.generateCircadianSchedule(
        dailyTargetMl: 2600.0,
        currentIntakeMl: 600.0,
      );

      expect(schedule.length, equals(5));
      expect(schedule[0].title, contains('Morning'));
      expect(schedule[1].title, contains('Mid-Morning'));
      expect(schedule[2].title, contains('Post-Lunch'));
      expect(schedule[3].title, contains('Afternoon'));
      expect(schedule[4].title, contains('Evening'));

      // Recommended volumes should sum approximately to daily target
      final totalVolume = schedule.fold<int>(0, (sum, r) => sum + r.recommendedVolumeMl);
      expect(totalVolume, greaterThan(2000));
      expect(totalVolume, lessThan(3000));
    });
  });
}
