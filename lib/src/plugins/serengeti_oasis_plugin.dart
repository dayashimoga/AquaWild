import 'package:flutter/material.dart';
import '../core/plugins/content_plugin_registry.dart';
import '../domain/models/animal_evolution_stage.dart';
import '../domain/models/beverage_type.dart';
import '../domain/models/exotic_animal.dart';
import '../domain/models/hydration_biome.dart';
import '../domain/models/monetization_models.dart';

/// Content expansion plugin introducing Zara the Reticulated Giraffe,
/// the Sunset Acacia Oasis biome, and Organic Rooibos & Hibiscus Infusion.
class SerengetiOasisPlugin extends ContentPlugin {
  static const String pluginId = 'aquawild.serengeti_oasis';

  SerengetiOasisPlugin()
      : super(
          id: pluginId,
          name: 'Serengeti Savanna Oasis Expansion',
          version: '2.2.0',
          author: 'AquaWild Wildlife Foundation',
          description:
              'Traverse golden savanna horizons with Zara the Reticulated Giraffe, watch sunset caustics over the Acacia Oasis, and hydrate with organic Rooibos & Hibiscus tea.',
          companions: [reticulatedGiraffe],
          biomes: [sunsetAcaciaOasisBiome],
          beverages: [rooibosHibiscusTea],
          products: [packSerengetiOasis],
          metadata: const {
            'climate': 'Arid Savanna & Grassland',
            'conservation_status': 'Vulnerable (IUCN 3.1)',
            'partner': 'East African Wildlife Conservation Trust',
          },
        );

  /// Zara the Reticulated Giraffe (Giraffa camelopardalis)
  static const ExoticAnimal reticulatedGiraffe = ExoticAnimal(
    id: 'reticulated_giraffe',
    name: 'Zara the Reticulated Giraffe',
    scientificName: 'Giraffa camelopardalis',
    lore:
        'An elegant savanna sentry with geometric polygonal markings and a towering vantage, sipping gracefully from desert watering holes.',
    habitatBiomeId: 'sunset_acacia_oasis',
    unlockXp: 1200,
    accentColor: Color(0xFFFF8F00), // Sunset Amber Gold
    defaultCapacityMl: 3000,
    nativeHabitat: 'Serengeti National Park, Tanzania & Kenya',
    evolutionStages: [
      AnimalEvolutionStage(
        stageNumber: 1,
        title: 'Savanna Calf',
        requiredXp: 1200,
        auraColor: Color(0x33FF8F00),
        auraEffectDescription: 'Faint golden savanna dust motes',
        cosmeticPerk: 'Playful ear wiggles',
      ),
      AnimalEvolutionStage(
        stageNumber: 2,
        title: 'Acacia Browser',
        requiredXp: 2500,
        auraColor: Color(0x66FF8F00),
        auraEffectDescription: 'Sunset acacia leaf glints',
        cosmeticPerk: 'High-reach leaf browsing wake ripples',
      ),
      AnimalEvolutionStage(
        stageNumber: 3,
        title: 'Horizon Sentinel',
        requiredXp: 4500,
        auraColor: Color(0x99E65100),
        auraEffectDescription: 'Radiant amber sunset corona pulses',
        cosmeticPerk: 'Luminous polygonal rosette highlights',
      ),
      AnimalEvolutionStage(
        stageNumber: 4,
        title: 'Serengeti Sun Deity',
        requiredXp: 7500,
        auraColor: Color(0xFFFFAB00),
        auraEffectDescription: 'Blazing mythical solar desert aura',
        cosmeticPerk: 'Golden mirage water caustics',
      ),
    ],
  );

  /// Sunset Acacia Oasis Biome
  static const HydrationBiome sunsetAcaciaOasisBiome = HydrationBiome(
    id: 'sunset_acacia_oasis',
    name: 'Sunset Acacia Oasis',
    subtitle: 'Golden Hour African Savanna Waterhole',
    description:
        'Silhouetted umbrella acacia trees against a fiery crimson-orange sky, with tranquil waterhole ripples reflecting migratory flocks.',
    ambientColor: Color(0xFFE65100),
    waterCausticColor: Color(0xFFFFD54F),
    skyGradient: [Color(0xFFBF360C), Color(0xFFFF6F00)],
    soundscapeName: 'Savanna Dusk Breeze & Distant Cicadas',
    unlockXp: 1200,
    nativeAnimalIds: ['reticulated_giraffe'],
  );

  /// Organic Rooibos & Hibiscus Infusion
  static const BeverageType rooibosHibiscusTea = BeverageType(
    id: 'rooibos_hibiscus_tea',
    name: 'Organic Rooibos & Hibiscus Infusion',
    category: BeverageCategory.tea,
    hydrationIndex: 1.04,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 28.0,
    sugarGramsPer100ml: 0.0,
    density: 1.008,
    viscosity: 0.022,
    primaryColor: Color(0xFFC62828), // Crimson Hibiscus
    secondaryColor: Color(0xFF8E0000),
    gradientColors: [Color(0xFFEF5350), Color(0xFFC62828)],
    presetVolumesMl: [250, 350, 500],
    description:
        'Naturally caffeine-free South African red bush steeped with tart ruby hibiscus petals and cellular electrolytes.',
  );

  /// Serengeti Oasis Expansion Pack SKU
  static const ProductSKU packSerengetiOasis = ProductSKU(
    id: 'pack_serengeti_oasis',
    title: 'Serengeti Oasis Expansion Pack',
    description:
        'Unlock Zara the Reticulated Giraffe, the Sunset Acacia Oasis biome, and Rooibos Hibiscus Tea.',
    priceFormatted: '\$7.99',
    priceCents: 799,
    kind: EntitlementKind.animalPack,
    unlockedAnimalIds: ['reticulated_giraffe'],
    unlockedThemeIds: ['sunset_savanna'],
    badgeText: 'New Expansion',
  );
}
