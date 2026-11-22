import 'package:flutter/material.dart';

enum BeverageCategory {
  water,
  tea,
  coffee,
  juice,
  electrolyte,
  dairy,
  wellness,
}

/// Rich domain model representing a beverage type, its hydration science metrics,
/// density and viscosity for fluid dynamics, and visual theme tokens.
class BeverageType {
  final String id;
  final String name;
  final BeverageCategory category;
  final double hydrationIndex; // Bioavailability factor (1.0 = baseline pure water)
  final double caffeineMgPer100ml;
  final double electrolytesMgPer100ml;
  final double sugarGramsPer100ml;
  final double density; // Relative fluid density for stratification (g/cm³)
  final double viscosity; // Viscosity factor damping fluid wave oscillations
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> gradientColors;
  final List<int> presetVolumesMl;
  final String description;

  const BeverageType({
    required this.id,
    required this.name,
    required this.category,
    required this.hydrationIndex,
    required this.caffeineMgPer100ml,
    required this.electrolytesMgPer100ml,
    required this.sugarGramsPer100ml,
    required this.density,
    required this.viscosity,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gradientColors,
    required this.presetVolumesMl,
    required this.description,
  });

  /// Computes net physiological hydration considering bioavailability and diuretic offset
  double calculateNetHydration(double volumeMl) {
    if (volumeMl <= 0) return 0.0;
    final totalCaffeineMg = (volumeMl / 100.0) * caffeineMgPer100ml;
    
    // Caffeine diuretic offset: ~1.0ml water loss per mg of caffeine above 100mg threshold
    final caffeineOffsetMl = totalCaffeineMg > 100 ? (totalCaffeineMg - 100) * 1.0 : 0.0;
    
    final grossHydration = volumeMl * hydrationIndex;
    final net = grossHydration - caffeineOffsetMl;
    return net > 0 ? net : 0.0;
  }

  // --- Comprehensive 16-Beverage Global Catalog ---

  static const BeverageType pureWater = BeverageType(
    id: 'pure_water',
    name: 'Pure Spring Water',
    category: BeverageCategory.water,
    hydrationIndex: 1.0,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 5.0,
    sugarGramsPer100ml: 0.0,
    density: 1.00,
    viscosity: 0.02,
    primaryColor: Color(0xFF00E5FF),
    secondaryColor: Color(0xFF00B0FF),
    gradientColors: [Color(0xFF29B6F6), Color(0xFF00E5FF)],
    presetVolumesMl: [250, 350, 500, 750],
    description: 'Crisp mountain spring water with essential trace minerals.',
  );

  static const BeverageType sparklingWater = BeverageType(
    id: 'sparkling_water',
    name: 'Sparkling Mineral Water',
    category: BeverageCategory.water,
    hydrationIndex: 0.99,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 18.0,
    sugarGramsPer100ml: 0.0,
    density: 0.99,
    viscosity: 0.022,
    primaryColor: Color(0xFF80DEEA),
    secondaryColor: Color(0xFF4DD0E1),
    gradientColors: [Color(0xFF80DEEA), Color(0xFF26C6DA)],
    presetVolumesMl: [250, 330, 500],
    description: 'Naturally carbonated water with rich alkaline bicarbonate.',
  );

  static const BeverageType coconutWater = BeverageType(
    id: 'coconut_water',
    name: 'Young Coconut Water',
    category: BeverageCategory.wellness,
    hydrationIndex: 1.06,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 65.0,
    sugarGramsPer100ml: 2.6,
    density: 1.015,
    viscosity: 0.028,
    primaryColor: Color(0xFFE0F7FA),
    secondaryColor: Color(0xFF80CBC4),
    gradientColors: [Color(0xFFE0F2F1), Color(0xFF80CBC4)],
    presetVolumesMl: [250, 330, 500],
    description: "Nature's isotonic beverage packed with potassium & magnesium.",
  );

  static const BeverageType electrolyteDrink = BeverageType(
    id: 'electrolyte_drink',
    name: 'Electrolyte Hydration Fluid',
    category: BeverageCategory.electrolyte,
    hydrationIndex: 1.12,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 120.0,
    sugarGramsPer100ml: 1.5,
    density: 1.02,
    viscosity: 0.025,
    primaryColor: Color(0xFF00E676),
    secondaryColor: Color(0xFF1DE9B6),
    gradientColors: [Color(0xFF00E676), Color(0xFF00B0FF)],
    presetVolumesMl: [250, 500, 750],
    description: 'Optimal sodium-potassium glucose transporter electrolyte matrix.',
  );

  static const BeverageType greenTea = BeverageType(
    id: 'green_tea',
    name: 'Sencha Green Tea',
    category: BeverageCategory.tea,
    hydrationIndex: 0.96,
    caffeineMgPer100ml: 12.0,
    electrolytesMgPer100ml: 8.0,
    sugarGramsPer100ml: 0.0,
    density: 0.995,
    viscosity: 0.021,
    primaryColor: Color(0xFF81C784),
    secondaryColor: Color(0xFF4CAF50),
    gradientColors: [Color(0xFFA5D6A7), Color(0xFF4CAF50)],
    presetVolumesMl: [200, 300, 400],
    description: 'Steeped green tea leaves loaded with antioxidant EGCG catechins.',
  );

  static const BeverageType blackTea = BeverageType(
    id: 'black_tea',
    name: 'Earl Grey Black Tea',
    category: BeverageCategory.tea,
    hydrationIndex: 0.93,
    caffeineMgPer100ml: 22.0,
    electrolytesMgPer100ml: 6.0,
    sugarGramsPer100ml: 0.0,
    density: 0.996,
    viscosity: 0.022,
    primaryColor: Color(0xFFA1887F),
    secondaryColor: Color(0xFF795548),
    gradientColors: [Color(0xFFBCAAA4), Color(0xFF6D4C41)],
    presetVolumesMl: [200, 300, 400],
    description: 'Full-bodied black tea infused with bergamot citrus oils.',
  );

  static const BeverageType herbalTea = BeverageType(
    id: 'herbal_tea',
    name: 'Chamomile & Mint Herbal Infusion',
    category: BeverageCategory.tea,
    hydrationIndex: 0.99,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 4.0,
    sugarGramsPer100ml: 0.0,
    density: 0.992,
    viscosity: 0.02,
    primaryColor: Color(0xFFCE93D8),
    secondaryColor: Color(0xFFBA68C8),
    gradientColors: [Color(0xFFE1BEE7), Color(0xFFAB47BC)],
    presetVolumesMl: [200, 300, 450],
    description: 'Caffeine-free botanical infusion promoting calm hydration.',
  );

  static const BeverageType espresso = BeverageType(
    id: 'espresso',
    name: 'Artisan Espresso',
    category: BeverageCategory.coffee,
    hydrationIndex: 0.68,
    caffeineMgPer100ml: 210.0,
    electrolytesMgPer100ml: 15.0,
    sugarGramsPer100ml: 0.0,
    density: 1.04,
    viscosity: 0.045,
    primaryColor: Color(0xFF4E342E),
    secondaryColor: Color(0xFF3E2723),
    gradientColors: [Color(0xFF5D4037), Color(0xFF271C19)],
    presetVolumesMl: [30, 60, 90],
    description: 'Dense, aromatic double-shot espresso crema extraction.',
  );

  static const BeverageType americano = BeverageType(
    id: 'americano',
    name: 'Caffè Americano',
    category: BeverageCategory.coffee,
    hydrationIndex: 0.85,
    caffeineMgPer100ml: 40.0,
    electrolytesMgPer100ml: 6.0,
    sugarGramsPer100ml: 0.0,
    density: 1.002,
    viscosity: 0.024,
    primaryColor: Color(0xFF6D4C41),
    secondaryColor: Color(0xFF4E342E),
    gradientColors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
    presetVolumesMl: [250, 350, 450],
    description: 'Espresso diluted with hot micro-filtered water.',
  );

  static const BeverageType latte = BeverageType(
    id: 'latte',
    name: 'Oat Milk Caffè Latte',
    category: BeverageCategory.coffee,
    hydrationIndex: 0.92,
    caffeineMgPer100ml: 30.0,
    electrolytesMgPer100ml: 35.0,
    sugarGramsPer100ml: 3.5,
    density: 1.028,
    viscosity: 0.055,
    primaryColor: Color(0xFFD7CCC8),
    secondaryColor: Color(0xFFA1887F),
    gradientColors: [Color(0xFFEFEBE9), Color(0xFFA1887F)],
    presetVolumesMl: [250, 350, 450],
    description: 'Smooth espresso folded into velvety steamed oat milk microfoam.',
  );

  static const BeverageType orangeJuice = BeverageType(
    id: 'orange_juice',
    name: 'Freshly Squeezed Orange Juice',
    category: BeverageCategory.juice,
    hydrationIndex: 0.89,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 45.0,
    sugarGramsPer100ml: 8.8,
    density: 1.035,
    viscosity: 0.042,
    primaryColor: Color(0xFFFF9800),
    secondaryColor: Color(0xFFF57C00),
    gradientColors: [Color(0xFFFFB74D), Color(0xFFE65100)],
    presetVolumesMl: [200, 300, 400],
    description: 'Vitamin C rich raw cold-pressed citrus juice with light pulp.',
  );

  static const BeverageType milk = BeverageType(
    id: 'whole_milk',
    name: 'Organic Whole Milk',
    category: BeverageCategory.dairy,
    hydrationIndex: 1.15,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 110.0,
    sugarGramsPer100ml: 4.8,
    density: 1.032,
    viscosity: 0.05,
    primaryColor: Color(0xFFECEFF1),
    secondaryColor: Color(0xFFCFD8DC),
    gradientColors: [Color(0xFFFFFFFF), Color(0xFFCFD8DC)],
    presetVolumesMl: [200, 300, 400],
    description: 'Exceptional hydration index due to natural proteins and electrolytes.',
  );

  static const BeverageType proteinShake = BeverageType(
    id: 'protein_shake',
    name: 'Whey Isolate Recovery Shake',
    category: BeverageCategory.dairy,
    hydrationIndex: 0.94,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 85.0,
    sugarGramsPer100ml: 1.8,
    density: 1.045,
    viscosity: 0.075,
    primaryColor: Color(0xFFB0BEC5),
    secondaryColor: Color(0xFF78909C),
    gradientColors: [Color(0xFFCFD8DC), Color(0xFF546E7A)],
    presetVolumesMl: [300, 450, 600],
    description: 'Post-workout hydration paired with 25g clean protein synthesis.',
  );

  static const BeverageType kombucha = BeverageType(
    id: 'kombucha',
    name: 'Living Ginger Kombucha',
    category: BeverageCategory.wellness,
    hydrationIndex: 0.95,
    caffeineMgPer100ml: 4.0,
    electrolytesMgPer100ml: 20.0,
    sugarGramsPer100ml: 3.2,
    density: 1.018,
    viscosity: 0.03,
    primaryColor: Color(0xFFFFB300),
    secondaryColor: Color(0xFFFF8F00),
    gradientColors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
    presetVolumesMl: [250, 330, 400],
    description: 'Probiotic sparkling fermented tea beneficial for gut microbiome.',
  );

  static const BeverageType boneBroth = BeverageType(
    id: 'bone_broth',
    name: 'Simmered Collagen Bone Broth',
    category: BeverageCategory.wellness,
    hydrationIndex: 1.10,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 190.0,
    sugarGramsPer100ml: 0.2,
    density: 1.025,
    viscosity: 0.038,
    primaryColor: Color(0xFFFFCC80),
    secondaryColor: Color(0xFFFFA726),
    gradientColors: [Color(0xFFFFE0B2), Color(0xFFFB8C00)],
    presetVolumesMl: [200, 300, 450],
    description: 'Slow-simmered savory electrolyte infusion rich in amino acids.',
  );

  static const BeverageType greenSmoothie = BeverageType(
    id: 'green_smoothie',
    name: 'Supergreen Vitality Smoothie',
    category: BeverageCategory.wellness,
    hydrationIndex: 0.93,
    caffeineMgPer100ml: 0.0,
    electrolytesMgPer100ml: 75.0,
    sugarGramsPer100ml: 6.5,
    density: 1.055,
    viscosity: 0.095,
    primaryColor: Color(0xFF66BB6A),
    secondaryColor: Color(0xFF388E3C),
    gradientColors: [Color(0xFF81C784), Color(0xFF2E7D32)],
    presetVolumesMl: [300, 450, 600],
    description: 'Spinach, cucumber, green apple, and celery blended cellular hydration.',
  );

  static const List<BeverageType> allBeverages = [
    pureWater,
    sparklingWater,
    coconutWater,
    electrolyteDrink,
    greenTea,
    blackTea,
    herbalTea,
    espresso,
    americano,
    latte,
    orangeJuice,
    milk,
    proteinShake,
    kombucha,
    boneBroth,
    greenSmoothie,
  ];

  static BeverageType findById(String id) {
    return allBeverages.firstWhere(
      (b) => b.id == id,
      orElse: () => pureWater,
    );
  }
}
