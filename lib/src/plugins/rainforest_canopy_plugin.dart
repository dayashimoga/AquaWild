import 'package:flutter/material.dart';
import '../core/plugins/content_plugin_registry.dart';
import '../domain/models/animal_evolution_stage.dart';
import '../domain/models/beverage_type.dart';
import '../domain/models/exotic_animal.dart';
import '../domain/models/hydration_biome.dart';
import '../domain/models/monetization_models.dart';

/// Flagship content expansion plugin introducing Sol the Golden Lion Tamarin,
/// the Bioluminescent Mangrove biome, and the Golden Turmeric Botanical Elixir.
class RainforestCanopyPlugin extends ContentPlugin {
  static const String pluginId = 'aquawild.rainforest_canopy';

  RainforestCanopyPlugin()
      : super(
          id: pluginId,
          name: 'Amazonian Rainforest Canopy Expansion',
          version: '2.1.0',
          author: 'AquaWild Wildlife Foundation',
          description:
              'Venture into the emerald canopy with Sol the Golden Lion Tamarin, explore the Bioluminescent Mangrove biome, and revitalize with the Golden Turmeric Botanical Elixir.',
          companions: [goldenLionTamarin],
          biomes: [bioluminescentMangroveBiome],
          beverages: [goldenTurmericElixir],
          products: [packRainforestCanopy],
          metadata: const {
            'climate': 'Tropical Rainforest',
            'conservation_status': 'Endangered (IUCN 3.1)',
            'partner': 'Atlantic Forest Conservation Alliance',
          },
        );

  /// Sol the Golden Lion Tamarin (Leontopithecus rosalia)
  static const ExoticAnimal goldenLionTamarin = ExoticAnimal(
    id: 'golden_lion_tamarin',
    name: 'Sol the Golden Lion Tamarin',
    scientificName: 'Leontopithecus rosalia',
    lore:
        'An agile arboreal acrobat with a radiant sunburst mane, darting through sunlit bromeliads and guarding emerald streams.',
    habitatBiomeId: 'bioluminescent_mangrove',
    unlockXp: 800,
    accentColor: Color(0xFFFFB300), // Amber Sun Gold
    defaultCapacityMl: 2500,
    nativeHabitat: 'Atlantic Coastal Rainforest, Brazil',
    evolutionStages: [
      AnimalEvolutionStage(
        stageNumber: 1,
        title: 'Sunlit Sapling',
        requiredXp: 800,
        auraColor: Color(0x33FFB300),
        auraEffectDescription: 'Faint golden pollen particles',
        cosmeticPerk: 'Playful vine swings',
      ),
      AnimalEvolutionStage(
        stageNumber: 2,
        title: 'Canopy Leaper',
        requiredXp: 1800,
        auraColor: Color(0x66FFB300),
        auraEffectDescription: 'Radiant sunbeam glints',
        cosmeticPerk: 'Acrobatic leap wake ripples',
      ),
      AnimalEvolutionStage(
        stageNumber: 3,
        title: 'Golden Mane Protector',
        requiredXp: 3500,
        auraColor: Color(0x99FF8F00),
        auraEffectDescription: 'Solar flare corona pulses',
        cosmeticPerk: 'Luminous sunburst fur highlight',
      ),
      AnimalEvolutionStage(
        stageNumber: 4,
        title: 'Solar Crown Monarch',
        requiredXp: 6000,
        auraColor: Color(0xFFFFD54F),
        auraEffectDescription: 'Blazing mythical solar aura',
        cosmeticPerk: 'Celestial rainforest canopy sunburst',
      ),
    ],
  );

  /// Bioluminescent Mangrove Biome
  static const HydrationBiome bioluminescentMangroveBiome = HydrationBiome(
    id: 'bioluminescent_mangrove',
    name: 'Bioluminescent Mangrove',
    subtitle: 'Ancient Amazonian River Estuary',
    description:
        'Lush stilt roots rising from glowing emerald waters beneath canopies alive with iridescent orchids and twilight fireflies.',
    ambientColor: Color(0xFF00BFA5),
    waterCausticColor: Color(0xFF64FFDA),
    skyGradient: [Color(0xFF004D40), Color(0xFF00BFA5)],
    soundscapeName: 'Tropical Canopy Rainfall & Distant Songbirds',
    unlockXp: 800,
    nativeAnimalIds: ['golden_lion_tamarin'],
  );

  /// Golden Turmeric Botanical Elixir
  static const BeverageType goldenTurmericElixir = BeverageType(
    id: 'golden_turmeric_latte',
    name: 'Golden Turmeric Botanical Elixir',
    category: BeverageCategory.wellness,
    hydrationIndex: 1.08,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 45.0,
    sugarGramsPer100ml: 2.0,
    density: 1.025,
    viscosity: 0.035,
    primaryColor: Color(0xFFFFB300),
    secondaryColor: Color(0xFFFF8F00),
    gradientColors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
    presetVolumesMl: [250, 350, 500],
    description:
        'Cold-pressed golden turmeric, pressed ginger, piperine, and rich coconut water for deep vitality.',
  );

  /// Amazonian Canopy Expansion Pack SKU
  static const ProductSKU packRainforestCanopy = ProductSKU(
    id: 'pack_rainforest_canopy',
    title: 'Amazonian Canopy Expansion Pack',
    description:
        'Instantly unlock Sol the Golden Lion Tamarin, the Bioluminescent Mangrove biome, and Golden Turmeric Elixir.',
    priceFormatted: '\$7.99',
    priceCents: 799,
    kind: EntitlementKind.animalPack,
    unlockedAnimalIds: ['golden_lion_tamarin'],
    unlockedThemeIds: ['emerald_canopy'],
    badgeText: 'New Expansion',
  );
}
