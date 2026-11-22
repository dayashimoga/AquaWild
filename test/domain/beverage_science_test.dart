import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Beverage Science & Bioavailability Tests', () {
    test('Pure water has 1.0 hydration index and matches net volume', () {
      const water = BeverageType.pureWater;
      expect(water.hydrationIndex, equals(1.0));
      expect(water.calculateNetHydration(500.0), equals(500.0));
    });

    test('Coconut water has superior hydration index (> 1.0)', () {
      const coconut = BeverageType.coconutWater;
      expect(coconut.hydrationIndex, greaterThan(1.0));
      final net = coconut.calculateNetHydration(500.0);
      expect(net, greaterThan(500.0));
    });

    test('Espresso diuretic offset applies for high caffeine concentration', () {
      const espresso = BeverageType.espresso;
      // 100ml espresso has 210mg caffeine -> > 100mg threshold -> diuretic offset applies
      final net = espresso.calculateNetHydration(100.0);
      expect(net, lessThan(100.0 * espresso.hydrationIndex));
    });

    test('All 16 beverages in catalog have unique IDs and valid densities', () {
      expect(BeverageType.allBeverages.length, greaterThanOrEqualTo(16));
      final idSet = <String>{};
      for (final bev in BeverageType.allBeverages) {
        expect(idSet.contains(bev.id), isFalse, reason: 'Duplicate ID: ${bev.id}');
        idSet.add(bev.id);
        expect(bev.density, greaterThan(0.9));
        expect(bev.density, lessThan(1.2));
        expect(bev.viscosity, greaterThan(0.01));
      }
    });

    test('findById returns matching beverage or falls back to pureWater', () {
      final greenTea = BeverageType.findById('green_tea');
      expect(greenTea.id, equals('green_tea'));

      final unknown = BeverageType.findById('non_existent_drink');
      expect(unknown.id, equals('pure_water'));
    });
  });
}
