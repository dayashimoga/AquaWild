/// Category grouping for achievements.
enum AchievementCategory {
  consistency(label: 'Consistency & Habits'),
  exploration(label: 'Animal & Biome Lore'),
  science(label: 'Beverage Science & Electrolytes'),
  mastery(label: 'Milestones & Challenges');

  final String label;
  const AchievementCategory({required this.label});
}

/// Tiered achievement badge awarded for milestones, habits, and exploration.
class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final String iconEmoji;
  final int xpReward;
  final double progressFraction; // 0.0 to 1.0
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconEmoji,
    required this.xpReward,
    this.progressFraction = 0.0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AchievementBadge copyWith({
    String? id,
    String? title,
    String? description,
    AchievementCategory? category,
    String? iconEmoji,
    int? xpReward,
    double? progressFraction,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementBadge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      xpReward: xpReward ?? this.xpReward,
      progressFraction: progressFraction ?? this.progressFraction,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  /// Initial catalog of 12 handcrafted achievements.
  static const List<AchievementBadge> defaultAchievements = [
    AchievementBadge(
      id: 'first_sip',
      title: 'First Droplet',
      description: 'Log your very first hydration entry in AquaWild.',
      category: AchievementCategory.consistency,
      iconEmoji: '💧',
      xpReward: 50,
    ),
    AchievementBadge(
      id: 'streak_3',
      title: 'Triduum Spark',
      description: 'Maintain a 3-day continuous hydration streak.',
      category: AchievementCategory.consistency,
      iconEmoji: '⚡',
      xpReward: 100,
    ),
    AchievementBadge(
      id: 'streak_7',
      title: 'Weekly Flow State',
      description: 'Conquer a full 7-day hydration streak without freezing.',
      category: AchievementCategory.consistency,
      iconEmoji: '🔥',
      xpReward: 250,
    ),
    AchievementBadge(
      id: 'streak_30',
      title: 'Centurion of Tides',
      description: 'Reach an extraordinary 30-day hydration habit streak.',
      category: AchievementCategory.consistency,
      iconEmoji: '👑',
      xpReward: 1000,
    ),
    AchievementBadge(
      id: 'morning_ritual',
      title: 'Dawn Awakening',
      description: 'Log 400ml or more before 09:00 AM for circadian kickstart.',
      category: AchievementCategory.consistency,
      iconEmoji: '🌅',
      xpReward: 75,
    ),
    AchievementBadge(
      id: 'electrolyte_alchemist',
      title: 'Electrolyte Alchemist',
      description: 'Log an electrolyte or coconut water drink following an intense workout.',
      category: AchievementCategory.science,
      iconEmoji: '⚡',
      xpReward: 150,
    ),
    AchievementBadge(
      id: 'botanical_infusion',
      title: 'Herbal Zen',
      description: 'Sip soothing green or herbal tea during an afternoon focus period.',
      category: AchievementCategory.science,
      iconEmoji: '🍵',
      xpReward: 100,
    ),
    AchievementBadge(
      id: 'ruby_guardian',
      title: 'Ruby’s True Bond',
      description: 'Evolve Ruby the Red Panda to Guardian stage (500 XP).',
      category: AchievementCategory.exploration,
      iconEmoji: '🦊',
      xpReward: 300,
    ),
    AchievementBadge(
      id: 'capy_zen',
      title: 'Onsen Master',
      description: 'Unlock Cappy the Capybara and bathe in the Thermal Yuzu Onsen.',
      category: AchievementCategory.exploration,
      iconEmoji: '🦫',
      xpReward: 350,
    ),
    AchievementBadge(
      id: 'biome_wanderer',
      title: 'Biome Cartographer',
      description: 'Explore 3 distinct living hydration biomes.',
      category: AchievementCategory.exploration,
      iconEmoji: '🗺️',
      xpReward: 400,
    ),
    AchievementBadge(
      id: 'heatwave_shield',
      title: 'Thermal Resilience',
      description: 'Hit 100% hydration during an ambient temperature above 30°C.',
      category: AchievementCategory.science,
      iconEmoji: '🌡️',
      xpReward: 200,
    ),
    AchievementBadge(
      id: 'mythic_transcendence',
      title: 'Mythic Spirit Ascendant',
      description: 'Evolve any companion to the legendary Mythic Spirit stage (1500 XP).',
      category: AchievementCategory.mastery,
      iconEmoji: '✨',
      xpReward: 1500,
    ),
    AchievementBadge(
      id: 'pro_pioneer',
      title: 'Apex Guardian',
      description: 'Ascend to AquaWild Pro and unlock the boundless companion sanctuary.',
      category: AchievementCategory.mastery,
      iconEmoji: '👑',
      xpReward: 500,
    ),
    AchievementBadge(
      id: 'summer_splash_champion',
      title: 'Summer Splash Legend',
      description: 'Master the Summer Splash Seasonal Expedition Pass and discover all aquatic secrets.',
      category: AchievementCategory.mastery,
      iconEmoji: '🏖️',
      xpReward: 750,
    ),
    AchievementBadge(
      id: 'master_of_ten',
      title: 'Wild Menagerie',
      description: 'Befriend and hydrate alongside all 10 companions in the sanctuary.',
      category: AchievementCategory.exploration,
      iconEmoji: '🐾',
      xpReward: 2000,
    ),
    AchievementBadge(
      id: 'bioluminescence_diver',
      title: 'Abyssal Glow',
      description: 'Immerse into the dark depths with the Neon Bioluminescence effect activated.',
      category: AchievementCategory.exploration,
      iconEmoji: '🪼',
      xpReward: 300,
    ),
  ];
}
