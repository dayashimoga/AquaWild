import 'package:aquawild/src/core/plugins/content_plugin_registry.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/plugins/nordic_fjord_plugin.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_silhouette_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nordic Glacial Fjord Expansion Plugin Tests', () {
    test('NordicFjordPlugin metadata and content definitions are valid', () {
      final plugin = NordicFjordPlugin();
      expect(plugin.id, equals('aquawild.nordic_fjord'));
      expect(plugin.name, equals('Nordic Glacial Fjord Expansion'));
      expect(plugin.version, equals('2.3.0'));
      expect(plugin.companions.length, equals(1));
      expect(plugin.biomes.length, equals(1));
      expect(plugin.beverages.length, equals(1));
      expect(plugin.products.length, equals(1));
    });

    test('Finneas the Arctic Narwhal companion properties and evolution stages are valid', () {
      const companion = NordicFjordPlugin.arcticNarwhal;
      expect(companion.id, equals('arctic_narwhal'));
      expect(companion.scientificName, equals('Monodon monoceros'));
      expect(companion.habitatBiomeId, equals('glacial_fjord_sanctuary'));
      expect(companion.avatarEmoji, equals('🐋'));
      expect(companion.defaultCapacityMl, equals(2800));
      expect(companion.evolutionStages.length, equals(4));

      expect(companion.evolutionStages[0].title, equals('Fjord Calf'));
      expect(companion.evolutionStages[1].title, equals('Pack Ice Diver'));
      expect(companion.evolutionStages[2].title, equals('Glacial Sovereign'));
      expect(companion.evolutionStages[3].title, equals('Aurora Ocean Leviathan'));
    });

    test('AnimalSilhouettePaths generates non-empty vector path for arctic_narwhal', () {
      const size = Size(320, 368);
      final path = AnimalSilhouettePaths.getSilhouettePath('arctic_narwhal', size);
      expect(path, isNotNull);
      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(100.0));
      expect(bounds.height, greaterThan(100.0));
      expect(bounds.right, lessThanOrEqualTo(size.width));
      expect(bounds.bottom, lessThanOrEqualTo(size.height));
    });

    test('Glacial Fjord Sanctuary biome properties are valid', () {
      const biome = NordicFjordPlugin.glacialFjordSanctuaryBiome;
      expect(biome.id, equals('glacial_fjord_sanctuary'));
      expect(biome.name, equals('Glacial Fjord Sanctuary'));
      expect(biome.nativeAnimalIds, contains('arctic_narwhal'));
      expect(biome.unlockXp, equals(1400));
      expect(biome.skyGradient.length, equals(2));
    });

    test('Nordic Lingonberry & Chaga Adaptogenic Elixir hydration bioavailability is valid', () {
      const brew = NordicFjordPlugin.lingonberryChagaBrew;
      expect(brew.id, equals('lingonberry_chaga_brew'));
      expect(brew.category, equals(BeverageCategory.tea));
      expect(brew.hydrationIndex, equals(1.06));
      expect(brew.caffeineMgPer100ml, equals(0.0));
      expect(brew.electrolytesMgPer100ml, equals(34.0));

      final netHydration = brew.calculateNetHydration(250.0);
      expect(netHydration, equals(265.0)); // 250 * 1.06
    });

    test('Nordic Glacial Fjord Expansion Pack SKU is valid', () {
      const sku = NordicFjordPlugin.packNordicFjord;
      expect(sku.id, equals('pack_nordic_fjord'));
      expect(sku.priceFormatted, equals('\$7.99'));
      expect(sku.priceCents, equals(799));
      expect(sku.unlockedAnimalIds, contains('arctic_narwhal'));
    });

    test('ContentPluginRegistry registers, aggregates, and unregisters NordicFjordPlugin cleanly', () {
      final registry = ContentPluginRegistry.standard();
      expect(registry.hasPlugin(NordicFjordPlugin.pluginId), isFalse);

      final initialCompanionCount = registry.allCompanions.length;
      final initialBiomeCount = registry.allBiomes.length;
      final initialBeverageCount = registry.allBeverages.length;
      final initialProductCount = registry.allProducts.length;

      // Register expansion
      final plugin = NordicFjordPlugin();
      registry.registerPlugin(plugin);

      expect(registry.hasPlugin(NordicFjordPlugin.pluginId), isTrue);
      expect(registry.getPlugin(NordicFjordPlugin.pluginId), equals(plugin));

      // Assert catalog aggregates expanded
      expect(registry.allCompanions.length, equals(initialCompanionCount + 1));
      expect(registry.allBiomes.length, equals(initialBiomeCount + 1));
      expect(registry.allBeverages.length, equals(initialBeverageCount + 1));
      expect(registry.allProducts.length, equals(initialProductCount + 1));

      // Clean unregister
      final unregistered = registry.unregisterPlugin(NordicFjordPlugin.pluginId);
      expect(unregistered, isTrue);
      expect(registry.hasPlugin(NordicFjordPlugin.pluginId), isFalse);
      expect(registry.allCompanions.length, equals(initialCompanionCount));
    });
  });
}
