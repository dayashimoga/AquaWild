import 'package:aquawild/src/core/plugins/content_plugin_registry.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/plugins/serengeti_oasis_plugin.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_silhouette_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Serengeti Savanna Oasis Expansion Plugin Tests', () {
    test('SerengetiOasisPlugin metadata and content definitions are valid', () {
      final plugin = SerengetiOasisPlugin();
      expect(plugin.id, equals('aquawild.serengeti_oasis'));
      expect(plugin.name, equals('Serengeti Savanna Oasis Expansion'));
      expect(plugin.version, equals('2.2.0'));
      expect(plugin.companions.length, equals(1));
      expect(plugin.biomes.length, equals(1));
      expect(plugin.beverages.length, equals(1));
      expect(plugin.products.length, equals(1));
    });

    test('Zara the Reticulated Giraffe companion properties and evolution stages are valid', () {
      const companion = SerengetiOasisPlugin.reticulatedGiraffe;
      expect(companion.id, equals('reticulated_giraffe'));
      expect(companion.scientificName, equals('Giraffa camelopardalis'));
      expect(companion.habitatBiomeId, equals('sunset_acacia_oasis'));
      expect(companion.avatarEmoji, equals('🦒'));
      expect(companion.defaultCapacityMl, equals(3000));
      expect(companion.evolutionStages.length, equals(4));

      expect(companion.evolutionStages[0].title, equals('Savanna Calf'));
      expect(companion.evolutionStages[1].title, equals('Acacia Browser'));
      expect(companion.evolutionStages[2].title, equals('Horizon Sentinel'));
      expect(companion.evolutionStages[3].title, equals('Serengeti Sun Deity'));
    });

    test('AnimalSilhouettePaths generates non-empty vector path for reticulated_giraffe', () {
      const size = Size(320, 368);
      final path = AnimalSilhouettePaths.getSilhouettePath('reticulated_giraffe', size);
      expect(path, isNotNull);
      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(100.0));
      expect(bounds.height, greaterThan(100.0));
      expect(bounds.right, lessThanOrEqualTo(size.width));
      expect(bounds.bottom, lessThanOrEqualTo(size.height));
    });

    test('Sunset Acacia Oasis biome properties are valid', () {
      const biome = SerengetiOasisPlugin.sunsetAcaciaOasisBiome;
      expect(biome.id, equals('sunset_acacia_oasis'));
      expect(biome.name, equals('Sunset Acacia Oasis'));
      expect(biome.nativeAnimalIds, contains('reticulated_giraffe'));
      expect(biome.unlockXp, equals(1200));
      expect(biome.skyGradient.length, equals(2));
    });

    test('Organic Rooibos & Hibiscus Infusion hydration bioavailability is valid', () {
      const tea = SerengetiOasisPlugin.rooibosHibiscusTea;
      expect(tea.id, equals('rooibos_hibiscus_tea'));
      expect(tea.category, equals(BeverageCategory.tea));
      expect(tea.hydrationIndex, equals(1.04));
      expect(tea.caffeineMgPer100ml, equals(0.0));
      expect(tea.electrolytesMgPer100ml, equals(28.0));

      final netHydration = tea.calculateNetHydration(250.0);
      expect(netHydration, equals(260.0)); // 250 * 1.04
    });

    test('Serengeti Oasis Expansion Pack SKU is valid', () {
      const sku = SerengetiOasisPlugin.packSerengetiOasis;
      expect(sku.id, equals('pack_serengeti_oasis'));
      expect(sku.priceFormatted, equals('\$7.99'));
      expect(sku.priceCents, equals(799));
      expect(sku.unlockedAnimalIds, contains('reticulated_giraffe'));
    });

    test('ContentPluginRegistry registers, aggregates, and unregisters SerengetiOasisPlugin cleanly', () {
      final registry = ContentPluginRegistry.standard();
      expect(registry.hasPlugin(SerengetiOasisPlugin.pluginId), isFalse);

      final initialCompanionCount = registry.allCompanions.length;
      final initialBiomeCount = registry.allBiomes.length;
      final initialBeverageCount = registry.allBeverages.length;
      final initialProductCount = registry.allProducts.length;

      // Register expansion
      final plugin = SerengetiOasisPlugin();
      registry.registerPlugin(plugin);

      expect(registry.hasPlugin(SerengetiOasisPlugin.pluginId), isTrue);
      expect(registry.getPlugin(SerengetiOasisPlugin.pluginId), equals(plugin));

      // Assert catalog aggregates expanded
      expect(registry.allCompanions.length, equals(initialCompanionCount + 1));
      expect(registry.allBiomes.length, equals(initialBiomeCount + 1));
      expect(registry.allBeverages.length, equals(initialBeverageCount + 1));
      expect(registry.allProducts.length, equals(initialProductCount + 1));

      // Clean unregister
      final unregistered = registry.unregisterPlugin(SerengetiOasisPlugin.pluginId);
      expect(unregistered, isTrue);
      expect(registry.hasPlugin(SerengetiOasisPlugin.pluginId), isFalse);
      expect(registry.allCompanions.length, equals(initialCompanionCount));
    });
  });
}
