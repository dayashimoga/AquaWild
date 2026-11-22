/// A limited-time seasonal hydration event and community quest.
class SeasonalChallenge {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String themeColorHex;
  final String iconEmoji;
  final DateTime startDate;
  final DateTime endDate;
  final int targetXp;
  final int currentXp;
  final String badgeRewardId;
  final bool isClaimed;

  const SeasonalChallenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.themeColorHex,
    required this.iconEmoji,
    required this.startDate,
    required this.endDate,
    required this.targetXp,
    this.currentXp = 0,
    required this.badgeRewardId,
    this.isClaimed = false,
  });

  /// Fraction completed between 0.0 and 1.0.
  double get progressFraction {
    if (targetXp <= 0) return 1.0;
    return (currentXp / targetXp).clamp(0.0, 1.0);
  }

  /// Whether the quest target has been achieved.
  bool get isCompleted => currentXp >= targetXp;

  /// Remaining days until the seasonal event closes.
  int get daysRemaining {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  SeasonalChallenge copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? themeColorHex,
    String? iconEmoji,
    DateTime? startDate,
    DateTime? endDate,
    int? targetXp,
    int? currentXp,
    String? badgeRewardId,
    bool? isClaimed,
  }) {
    return SeasonalChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      themeColorHex: themeColorHex ?? this.themeColorHex,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetXp: targetXp ?? this.targetXp,
      currentXp: currentXp ?? this.currentXp,
      badgeRewardId: badgeRewardId ?? this.badgeRewardId,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  /// Current active global seasonal event.
  static SeasonalChallenge get currentSpringChallenge {
    final now = DateTime.now();
    return SeasonalChallenge(
      id: 'spring_rejuvenation_2026',
      title: 'Verdant Spring Rejuvenation',
      subtitle: 'Awaken the Cloud Forest Biome',
      description: 'Earn 600 XP by maintaining consistent hydration and trying diverse botanical teas.',
      themeColorHex: '0xFF26A69A',
      iconEmoji: '🌸',
      startDate: now.subtract(const Duration(days: 4)),
      endDate: now.add(const Duration(days: 26)),
      targetXp: 600,
      currentXp: 180,
      badgeRewardId: 'ruby_guardian',
    );
  }
}
