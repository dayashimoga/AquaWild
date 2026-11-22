import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Hydration & Habitat Controller Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Logging drinks recalculates totals and builds density stratification', () async {
      final notifier = container.read(hydrationProvider.notifier);

      // Log Water (density = 1.00)
      await notifier.logDrink(
        beverage: BeverageType.pureWater,
        volumeMl: 500.0,
      );

      // Log Espresso (density = 1.04)
      await notifier.logDrink(
        beverage: BeverageType.espresso,
        volumeMl: 60.0,
      );

      final state = container.read(hydrationProvider);
      expect(state.entries.length, equals(2));
      expect(state.goal.totalConsumedMl, equals(560.0));
      expect(state.stratifiedLayers.length, equals(2));

      // Heaviest liquid (Espresso, density 1.04) must be sorted first (at bottom)
      expect(state.stratifiedLayers.first.beverage.id, equals('espresso'));
      expect(state.stratifiedLayers.last.beverage.id, equals('pure_water'));
    });

    test('Adding XP unlocks evolution stages in AnimalHabitatNotifier', () async {
      final notifier = container.read(animalHabitatProvider.notifier);
      expect(container.read(animalHabitatProvider).currentStage.stageNumber, equals(1));

      // Stage 2 Explorer requires 400 XP
      await notifier.addXp(450);

      final state = container.read(animalHabitatProvider);
      expect(state.userXp, equals(450));
      expect(state.currentStage.stageNumber, equals(2));
      expect(state.currentStage.title, equals('Explorer'));
    });
  });
}
