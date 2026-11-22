import 'package:aquawild/src/data/repositories/local_hydration_repository.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/hydration_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalHydrationRepository Tests', () {
    late LocalHydrationRepository repository;

    setUp(() {
      repository = LocalHydrationRepository();
    });

    test('Initial repository starts empty with default goal', () async {
      final entries = await repository.getTodayEntries();
      expect(entries, isEmpty);

      final goal = await repository.getDailyBaseGoal();
      expect(goal, equals(2500));
    });

    test('Saving and retrieving entries works correctly', () async {
      final entry = HydrationEntry.create(
        id: 'entry-1',
        beverage: BeverageType.pureWater,
        volumeMl: 350.0,
      );

      await repository.saveEntry(entry);
      final entries = await repository.getTodayEntries();

      expect(entries.length, equals(1));
      expect(entries.first.id, equals('entry-1'));
      expect(entries.first.volumeMl, equals(350.0));
      expect(entries.first.netHydrationMl, equals(350.0));
    });

    test('Deleting entry removes it from repository', () async {
      final entry = HydrationEntry.create(
        id: 'entry-2',
        beverage: BeverageType.greenTea,
        volumeMl: 250.0,
      );

      await repository.saveEntry(entry);
      expect((await repository.getTodayEntries()).length, equals(1));

      await repository.deleteEntry('entry-2');
      expect((await repository.getTodayEntries()).length, equals(0));
    });

    test('XP management records additions', () async {
      expect(await repository.getUserXp(), equals(0));
      await repository.addXp(50);
      expect(await repository.getUserXp(), equals(50));
      await repository.addXp(120);
      expect(await repository.getUserXp(), equals(170));
    });
  });
}
