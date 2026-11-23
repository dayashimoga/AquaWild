import 'package:aquawild/src/core/plugins/content_plugin_registry.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/plugins/rainforest_canopy_plugin.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_silhouette_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Content Plugin Architecture & Rainforest Canopy Plugin Tests', () {
    test('RainforestCanopyPlugin metadata and content definitions are valid', () {
      final plugin = RainforestCanopyPlugin();
      expect(plugin.id, equals('aquawild.rainforest_canopy'));
      expect(plugin.name, equals('Amazonian Rainforest Canopy Expansion'));
      expect(plugin.version, equals('2.1.0'));
      expect(plugin.companions.length, equals(1));
      expect(plugin.biomes.length, equals(1));
      expect(plugin.beverages.length, equals(1));
      expect(plugin.products.length, equals(1));
    });

    test('Sol the Golden Lion Tamarin companion properties and evolution stages are valid', () {
      const companion = RainforestCanopyPlugin.goldenLionTamarin;
      expect(companion.id, equals('golden_lion_tamarin'));
      expect(companion.scientificName, equals('Leontopithecus rosalia'));
      expect(companion.habitatBiomeId, equals('bioluminescent_mangrove'));
      expect(companion.avatarEmoji, equals('🐒'));
      expect(companion.evolutionStages.length, equals(4));

      expect(companion.evolutionStages[0].title, equals('Sunlit Sapling'));
      expect(companion.evolutionStages[1].title, equals('Canopy Leaper'));
      expect(companion.evolutionStages[2].title, equals('Golden Mane Protector'));
      expect(companion.evolutionStages[3].title, equals('Solar Crown Monarch'));
    });

    test('AnimalSilhouettePaths generates non-empty vector path for golden_lion_tamarin', () {
      const size = Size(320, 368);
      final path = AnimalSilhouettePaths.getSilhouettePath('golden_lion_tamarin', size);
      expect(path, isNotNull);
      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(100.0));
      expect(bounds.height, greaterThan(100.0));
      expect(bounds.right, lessThanOrEqualTo(size.width));
      expect(bounds.bottom, lessThanOrEqualTo(size.height));
    });

    test('Bioluminescent Mangrove biome properties are valid', () {
      const biome = RainforestCanopyPlugin.bioluminescentMangroveBiome;
      expect(biome.id, equals('bioluminescent_mangrove'));
      expect(biome.name, equals('Bioluminescent Mangrove'));
      expect(biome.nativeAnimalIds, contains('golden_lion_tamarin'));
      expect(biome.unlockXp, equals(800));
      expect(biome.skyGradient.length, equals(2));
    });

    test('Golden Turmeric Botanical Elixir hydration bioavailability is valid', () {
      const elixir = RainforestCanopyPlugin.goldenTurmericElixir;
      expect(elixir.id, equals('golden_turmeric_latte'));
      expect(elixir.category, equals(BeverageCategory.wellness));
      expect(elixir.hydrationIndex, equals(1.08));
      expect(elixir.caffeineMgPer100ml, equals(0.0));
      expect(elixir.electrolytesMgPer100ml, equals(45.0));

      final netHydration = elixir.calculateNetHydration(250.0);
      expect(netHydration, equals(270.0)); // 250 * 1.08
    });

    test('Amazonian Canopy Expansion Pack SKU is valid', () {
      const sku = RainforestCanopyPlugin.packRainforestCanopy;
      expect(sku.id, equals('pack_rainforest_canopy'));
      expect(sku.priceFormatted, equals('\$7.99'));
      expect(sku.priceCents, equals(799));
      expect(sku.unlockedAnimalIds, contains('golden_lion_tamarin'));
    });

    test('ContentPluginRegistry registers, aggregates, and unregisters RainforestCanopyPlugin cleanly', () {
      final registry = ContentPluginRegistry.standard();
      expect(registry.plugins.length, equals(1));
      expect(registry.hasPlugin(RainforestCanopyPlugin.pluginId), isFalse);

      final initialCompanionCount = registry.allCompanions.length;
      final initialBiomeCount = registry.allBiomes.length;
      final initialBeverageCount = registry.allBeverages.length;
      final initialProductCount = registry.allProducts.length;

      // Register expansion
      final plugin = RainforestCanopyPlugin();
      registry.registerPlugin(plugin);

      expect(registry.hasPlugin(RainforestCanopyPlugin.pluginId), isTrue);
      expect(registry.getPlugin(RainforestCanopyPlugin.pluginId), equals(plugin));
      expect(registry.plugins.length, equals(2));

      // Assert aggregated catalog expanded
      expect(registry.allCompanions.length, equals(initialCompanionCount + 1));
      expect(registry.allBiomes.length, equals(initialBiomeCount + 1));
      expect(registry.allBeverages.length, equals(initialBeverageCount + 1));
      expect(registry.allProducts.length, equals(initialProductCount + 1));

      // Unregister
      final unregistered = registry.unregisterPlugin(RainforestCanopyPlugin.pluginId);
      expect(unregistered, isTrue);
      expect(registry.hasPlugin(RainforestCanopyPlugin.pluginId), isFalse);
      expect(registry.allCompanions.length, equals(initialCompanionCount));
    });
  });
}
