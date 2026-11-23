import 'package:flutter/material.dart';
import '../core/plugins/content_plugin_registry.dart';
import '../domain/models/animal_evolution_stage.dart';
import '../domain/models/beverage_type.dart';
import '../domain/models/exotic_animal.dart';
import '../domain/models/hydration_biome.dart';
import '../domain/models/monetization_models.dart';

/// Content expansion plugin introducing Finneas the Arctic Narwhal,
/// the Glacial Fjord Sanctuary biome, and Nordic Lingonberry & Chaga Adaptogenic Elixir.
class NordicFjordPlugin extends ContentPlugin {
  static const String pluginId = 'aquawild.nordic_fjord';

  NordicFjordPlugin()
      : super(
          id: pluginId,
          name: 'Nordic Glacial Fjord Expansion',
          version: '2.3.0',
          author: 'AquaWild Wildlife Foundation',
          description:
              'Dive into crystalline polar depths with Finneas the Arctic Narwhal, marvel at towering Glacial Fjord ice walls, and revitalize with antioxidant-rich Nordic Lingonberry & Chaga brew.',
          companions: [arcticNarwhal],
          biomes: [glacialFjordSanctuaryBiome],
          beverages: [lingonberryChagaBrew],
          products: [packNordicFjord],
          metadata: const {
            'climate': 'Subpolar Glacial Marine',
            'conservation_status': 'Near Threatened (IUCN 3.1)',
            'partner': 'Arctic Cetacean Protection Initiative',
          },
        );

  /// Finneas the Arctic Narwhal (Monodon monoceros)
  static const ExoticAnimal arcticNarwhal = ExoticAnimal(
    id: 'arctic_narwhal',
    name: 'Finneas the Arctic Narwhal',
    scientificName: 'Monodon monoceros',
    lore:
        'The legendary Unicorn of the Arctic Sea, gliding silently beneath pack ice floes and piercing glacial swells with his spiraled ivory tusk.',
    habitatBiomeId: 'glacial_fjord_sanctuary',
    unlockXp: 1400,
    accentColor: Color(0xFF00E5FF), // Glacial Cyan
    defaultCapacityMl: 2800,
    nativeHabitat: 'Baffin Bay & Greenland Sea Ice Fjords',
    evolutionStages: [
      AnimalEvolutionStage(
        stageNumber: 1,
        title: 'Fjord Calf',
        requiredXp: 1400,
        auraColor: Color(0x3300E5FF),
        auraEffectDescription: 'Faint crystalline frost motes',
        cosmeticPerk: 'Gentle fluke wave dips',
      ),
      AnimalEvolutionStage(
        stageNumber: 2,
        title: 'Pack Ice Diver',
        requiredXp: 2800,
        auraColor: Color(0x6600E5FF),
        auraEffectDescription: 'Spiraling ivory tusk gleams',
        cosmeticPerk: 'Acoustic sonar click ripple trail',
      ),
      AnimalEvolutionStage(
        stageNumber: 3,
        title: 'Glacial Sovereign',
        requiredXp: 4800,
        auraColor: Color(0x9900B4D8),
        auraEffectDescription: 'Luminous polar ice refraction ring',
        cosmeticPerk: 'Prismatic tusk spray refraction',
      ),
      AnimalEvolutionStage(
        stageNumber: 4,
        title: 'Aurora Ocean Leviathan',
        requiredXp: 8000,
        auraColor: Color(0xFF00E5FF),
        auraEffectDescription: 'Radiant celestial aurora borealis crest',
        cosmeticPerk: 'Legendary polar tidal wave swell',
      ),
    ],
  );

  /// Glacial Fjord Sanctuary Biome
  static const HydrationBiome glacialFjordSanctuaryBiome = HydrationBiome(
    id: 'glacial_fjord_sanctuary',
    name: 'Glacial Fjord Sanctuary',
    subtitle: 'Sub-Zero Nordic Crystalline Waters',
    description:
        'Towering cobalt-blue glacial ice walls plunge into tranquil deep fjord waters, reflecting drifting sea ice and celestial northern lights.',
    ambientColor: Color(0xFF006064),
    waterCausticColor: Color(0xFF80DEEA),
    skyGradient: [Color(0xFF002244), Color(0xFF004D40)],
    soundscapeName: 'Echoing Fjord Waves & Distant Calving Ice',
    unlockXp: 1400,
    nativeAnimalIds: ['arctic_narwhal'],
  );

  /// Nordic Lingonberry & Chaga Adaptogenic Elixir
  static const BeverageType lingonberryChagaBrew = BeverageType(
    id: 'lingonberry_chaga_brew',
    name: 'Nordic Lingonberry & Chaga Adaptogenic Elixir',
    category: BeverageCategory.tea,
    hydrationIndex: 1.06,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 34.0,
    sugarGramsPer100ml: 0.0,
    density: 1.018,
    viscosity: 0.024,
    primaryColor: Color(0xFF880E4F), // Frosted Lingonberry Crimson
    secondaryColor: Color(0xFF4A148C),
    gradientColors: [Color(0xFFAD1457), Color(0xFF880E4F)],
    presetVolumesMl: [250, 350, 500],
    description:
        'Subarctic wild lingonberries steeped with birch chaga mushroom extracts and trace glacial minerals for potent cellular adaptogen hydration.',
  );

  /// Nordic Fjord Expansion Pack SKU
  static const ProductSKU packNordicFjord = ProductSKU(
    id: 'pack_nordic_fjord',
    title: 'Nordic Glacial Fjord Expansion Pack',
    description:
        'Unlock Finneas the Arctic Narwhal, the Glacial Fjord Sanctuary biome, and Nordic Lingonberry Chaga Elixir.',
    priceFormatted: '\$7.99',
    priceCents: 799,
    kind: EntitlementKind.animalPack,
    unlockedAnimalIds: ['arctic_narwhal'],
    unlockedThemeIds: ['glacial_fjord'],
    badgeText: 'New Expansion',
  );
}
