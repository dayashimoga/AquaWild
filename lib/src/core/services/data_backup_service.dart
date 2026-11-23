import 'dart:convert';
import '../security/security_sanitization_service.dart';
import '../../domain/models/beverage_type.dart';
import '../../domain/models/hydration_entry.dart';

/// Clean privacy-first data backup and export engine.
/// Generates lossless JSON archives and RFC 4180 CSV spreadsheets
/// for cross-platform data portability and clinical health reviews.
class DataBackupService {
  const DataBackupService._();

  /// Exports full hydration, streak, XP, and achievement telemetry to JSON
  static String exportToJson({
    required List<HydrationEntry> entries,
    required double dailyGoalMl,
    required int userXp,
    required String activeAnimalId,
    required String activeBiomeId,
    required int streakDays,
    required int longestStreakDays,
    required int streakFreezes,
    required List<String> unlockedBadgeIds,
  }) {
    final Map<String, dynamic> payload = {
      'app': 'AquaWild',
      'version': '1.2.0',
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'profile': {
        'daily_goal_ml': dailyGoalMl,
        'user_xp': userXp,
        'active_animal_id': activeAnimalId,
        'active_biome_id': activeBiomeId,
      },
      'streaks': {
        'current_streak_days': streakDays,
        'longest_streak_days': longestStreakDays,
        'streak_freezes': streakFreezes,
      },
      'unlocked_badge_ids': unlockedBadgeIds,
      'entries': entries.map((e) {
        return {
          'id': e.id,
          'timestamp': e.timestamp.toIso8601String(),
          'beverage_id': e.beverage.id,
          'beverage_name': e.beverage.name,
          'volume_ml': e.volumeMl,
          'net_hydration_ml': e.volumeMl * e.beverage.hydrationIndex,
          'caffeine_mg': e.beverage.caffeineMgPer100ml * (e.volumeMl / 100),
          'electrolytes_mg':
              e.beverage.electrolytesMgPer100ml * (e.volumeMl / 100),
        };
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Exports hydration log history to spreadsheet-compatible RFC 4180 CSV
  static String exportToCsv(List<HydrationEntry> entries) {
    final StringBuffer csv = StringBuffer();
    // CSV Header row
    csv.writeln(
      'Entry ID,Timestamp (ISO),Date,Time,Beverage ID,Beverage Name,Volume (ml),Hydration Index,Net Hydration (ml),Caffeine (mg),Electrolytes (mg)',
    );

    for (final e in entries) {
      final dateStr =
          '${e.timestamp.year.toString().padLeft(4, '0')}-${e.timestamp.month.toString().padLeft(2, '0')}-${e.timestamp.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${e.timestamp.hour.toString().padLeft(2, '0')}:${e.timestamp.minute.toString().padLeft(2, '0')}';
      final netMl = (e.volumeMl * e.beverage.hydrationIndex).toStringAsFixed(1);
      final caffeine = (e.beverage.caffeineMgPer100ml * (e.volumeMl / 100))
          .toStringAsFixed(1);
      final electrolytes =
          (e.beverage.electrolytesMgPer100ml * (e.volumeMl / 100))
              .toStringAsFixed(1);

      // Quote string fields that may contain spaces or commas
      csv.writeln(
        '"${e.id}","${e.timestamp.toIso8601String()}","$dateStr","$timeStr","${e.beverage.id}","${e.beverage.name}",${e.volumeMl},${e.beverage.hydrationIndex},$netMl,$caffeine,$electrolytes',
      );
    }

    return csv.toString();
  }

  /// Parses and validates a JSON backup snapshot with OWASP MASVS payload verification
  static Map<String, dynamic>? validateAndParseBackup(String rawJson) {
    try {
      if (!SecuritySanitizationService.validateBackupPayload(rawJson)) {
        return null;
      }
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) return null;
      return decoded;
    } catch (_) {
      return null;
    }
  }

  /// Reconstructs a list of `HydrationEntry` instances from validated backup payload
  static List<HydrationEntry> parseEntriesFromBackup(
    Map<String, dynamic> backupData,
  ) {
    final rawEntries = backupData['entries'] as List<dynamic>? ?? [];
    final List<HydrationEntry> result = [];

    for (final item in rawEntries) {
      if (item is Map<String, dynamic>) {
        final id = SecuritySanitizationService.sanitizeText(
          item['id']?.toString(),
          maxLength: 64,
          fallback: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        final timestampStr = item['timestamp']?.toString();
        final timestamp = timestampStr != null
            ? DateTime.tryParse(timestampStr) ?? DateTime.now()
            : DateTime.now();
        final bevId = SecuritySanitizationService.sanitizeText(
          item['beverage_id']?.toString(),
          maxLength: 64,
          fallback: 'pure_water',
        );
        final volume = SecuritySanitizationService.sanitizeVolume(
          item['volume_ml'],
          min: 1.0,
          max: 10000.0,
          fallback: 250.0,
        );
        final beverage = BeverageType.findById(bevId);

        result.add(
          HydrationEntry.create(
            id: id,
            beverage: beverage,
            volumeMl: volume,
            timestamp: timestamp,
          ),
        );
      }
    }

    return result;
  }
}
