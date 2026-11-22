/// Represents user streak progress, consistency records, and streak freeze protection.
class HydrationStreak {
  final int currentStreakDays;
  final int longestStreakDays;
  final int streakFreezesAvailable;
  final DateTime? lastCompletedDate;
  final DateTime? lastFreezeUsedDate;

  const HydrationStreak({
    this.currentStreakDays = 0,
    this.longestStreakDays = 0,
    this.streakFreezesAvailable = 2,
    this.lastCompletedDate,
    this.lastFreezeUsedDate,
  });

  /// Whether a streak freeze was deployed today to preserve momentum.
  bool get isFrozenToday {
    if (lastFreezeUsedDate == null) return false;
    final now = DateTime.now();
    return lastFreezeUsedDate!.year == now.year &&
        lastFreezeUsedDate!.month == now.month &&
        lastFreezeUsedDate!.day == now.day;
  }

  /// Whether today's daily goal has already been recorded for the streak.
  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    return lastCompletedDate!.year == now.year &&
        lastCompletedDate!.month == now.month &&
        lastCompletedDate!.day == now.day;
  }

  /// Visual fire badge emoji tier based on streak longevity.
  String get fireEmoji {
    if (currentStreakDays >= 30) return '🔥✨';
    if (currentStreakDays >= 14) return '🔥⚡';
    if (currentStreakDays >= 7) return '🔥';
    if (currentStreakDays >= 3) return '⚡';
    return '💧';
  }

  HydrationStreak copyWith({
    int? currentStreakDays,
    int? longestStreakDays,
    int? streakFreezesAvailable,
    DateTime? lastCompletedDate,
    DateTime? lastFreezeUsedDate,
  }) {
    return HydrationStreak(
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      streakFreezesAvailable: streakFreezesAvailable ?? this.streakFreezesAvailable,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      lastFreezeUsedDate: lastFreezeUsedDate ?? this.lastFreezeUsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreakDays': currentStreakDays,
      'longestStreakDays': longestStreakDays,
      'streakFreezesAvailable': streakFreezesAvailable,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'lastFreezeUsedDate': lastFreezeUsedDate?.toIso8601String(),
    };
  }

  factory HydrationStreak.fromJson(Map<String, dynamic> json) {
    return HydrationStreak(
      currentStreakDays: json['currentStreakDays'] as int? ?? 0,
      longestStreakDays: json['longestStreakDays'] as int? ?? 0,
      streakFreezesAvailable: json['streakFreezesAvailable'] as int? ?? 2,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
      lastFreezeUsedDate: json['lastFreezeUsedDate'] != null
          ? DateTime.parse(json['lastFreezeUsedDate'] as String)
          : null,
    );
  }
}
