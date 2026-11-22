import 'package:aquawild/src/core/services/data_backup_service.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/hydration_entry.dart';
import 'package:aquawild/src/presentation/widgets/backup/data_backup_modal.dart';
import 'package:aquawild/src/presentation/widgets/biomes/companion_evolution_modal.dart';
import 'package:aquawild/src/domain/models/animal_evolution_stage.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataBackupService Tests', () {
    final entries = [
      HydrationEntry.create(
        id: 'test-1',
        beverage: BeverageType.pureWater,
        volumeMl: 500,
        timestamp: DateTime(2026, 11, 22, 10, 30),
      ),
      HydrationEntry.create(
        id: 'test-2',
        beverage: BeverageType.espresso,
        volumeMl: 60,
        timestamp: DateTime(2026, 11, 22, 14, 0),
      ),
    ];

    test('exportToJson generates valid AquaWild schema', () {
      final jsonStr = DataBackupService.exportToJson(
        entries: entries,
        dailyGoalMl: 2500,
        userXp: 450,
        activeAnimalId: 'capybara',
        activeBiomeId: 'thermal_yuzu_onsen',
        streakDays: 5,
        longestStreakDays: 12,
        streakFreezes: 2,
        unlockedBadgeIds: ['first_sip', 'streak_3'],
      );

      expect(jsonStr, contains('"app": "AquaWild"'));
      expect(jsonStr, contains('"version": "1.2.0"'));
      expect(jsonStr, contains('"active_animal_id": "capybara"'));
      expect(jsonStr, contains('"test-1"'));
      expect(jsonStr, contains('"test-2"'));

      final parsed = DataBackupService.validateAndParseBackup(jsonStr);
      expect(parsed, isNotNull);
      expect(parsed!['app'], equals('AquaWild'));
      expect(parsed['profile']['user_xp'], equals(450));

      final restoredEntries = DataBackupService.parseEntriesFromBackup(parsed);
      expect(restoredEntries.length, equals(2));
      expect(restoredEntries.first.beverage.id, equals('pure_water'));
      expect(restoredEntries.first.volumeMl, equals(500));
    });

    test('exportToCsv generates RFC 4180 compliant CSV', () {
      final csvStr = DataBackupService.exportToCsv(entries);

      expect(csvStr, contains('Entry ID,Timestamp (ISO),Date,Time,Beverage ID,Beverage Name,Volume (ml)'));
      expect(csvStr, contains('"test-1"'));
      expect(csvStr, contains('pure_water'));
      expect(csvStr, contains('"test-2"'));
      expect(csvStr, contains('espresso'));
    });

    test('validateAndParseBackup rejects invalid JSON and non-AquaWild structures', () {
      expect(DataBackupService.validateAndParseBackup('not-json'), isNull);
      expect(DataBackupService.validateAndParseBackup('{"app": "OtherApp"}'), isNull);
      expect(DataBackupService.validateAndParseBackup('{"app": "AquaWild"}'), isNull); // missing entries
    });
  });

  group('DataBackupModal & CompanionEvolutionModal Widget Tests', () {
    testWidgets('DataBackupModal mounts and displays export buttons and metrics',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DataBackupModal(),
            ),
          ),
        ),
      );

      expect(find.text('Data Portability & Backup'), findsOneWidget);
      expect(find.text('Export JSON'), findsOneWidget);
      expect(find.text('Export CSV'), findsOneWidget);
      expect(find.text('Validate & Restore Backup'), findsOneWidget);

      // Tap Export JSON
      await tester.tap(find.text('Export JSON'));
      await tester.pump();

      expect(find.textContaining('copied to clipboard'), findsOneWidget);
    });

    testWidgets('CompanionEvolutionModal displays unlocked stage and perk',
        (tester) async {
      final capy = ExoticAnimal.findById('capybara');
      final stage = AnimalEvolutionStage.defaultStages[2]; // Guardian

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompanionEvolutionModal(
              animal: capy,
              stage: stage,
              totalXp: 800,
            ),
          ),
        ),
      );

      expect(find.text('EVOLUTION UNLOCKED!'), findsOneWidget);
      expect(find.text(stage.title), findsOneWidget);
      expect(find.text(stage.cosmeticPerk), findsOneWidget);
      expect(find.text('Claim Evolution'), findsOneWidget);

      // Tap Claim Evolution to close modal
      await tester.tap(find.text('Claim Evolution'));
      await tester.pump();
    });
  });
}
