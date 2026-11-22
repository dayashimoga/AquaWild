import 'package:aquawild/src/core/services/audio_haptics_service.dart';
import 'package:aquawild/src/domain/models/achievement_badge.dart';
import 'package:aquawild/src/domain/models/hydration_streak.dart';
import 'package:aquawild/src/domain/models/seasonal_challenge.dart';
import 'package:aquawild/src/presentation/controllers/gamification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal sheet showcasing streak statistics, seasonal challenges, and achievements.
class AchievementsGallerySheet extends ConsumerWidget {
  const AchievementsGallerySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AchievementsGallerySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationProvider);
    final streak = state.streak;
    final challenge = state.activeChallenge;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0C192E).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFFFFB703).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB703).withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  '🏆 Badges & Habit Quests',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Streak Stats Card
                _buildStreakCard(context, ref, streak),
                const SizedBox(height: 16),

                // 2. Active Seasonal Challenge Card
                _buildSeasonalCard(context, ref, challenge),
                const SizedBox(height: 20),

                // 3. Achievements Catalog Header
                const Text(
                  'Achievement Badges (12)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Badges List
                ...state.badges.map((b) => _buildBadgeTile(b)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, WidgetRef ref, HydrationStreak streak) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF162947).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB703).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB703).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(streak.fireEmoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${streak.currentStreakDays} Day Streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Personal Best: ${streak.longestStreakDays} Days • Freezes: ${streak.streakFreezesAvailable}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (streak.streakFreezesAvailable > 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                foregroundColor: const Color(0xFF00E5FF),
                elevation: 0,
                side: const BorderSide(color: Color(0xFF00E5FF)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onPressed: () {
                AudioHapticsService.playTap();
                ref.read(gamificationProvider.notifier).deployStreakFreeze();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF0F2647),
                    content: Text(
                      '❄️ Streak Freeze deployed! Tomorrow’s streak is shielded.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              child: const Text('Equip ❄️', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildSeasonalCard(BuildContext context, WidgetRef ref, SeasonalChallenge challenge) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF26A69A).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${challenge.iconEmoji} ${challenge.title}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${challenge.daysRemaining}d Left',
                  style: const TextStyle(
                    color: Color(0xFF26A69A),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            challenge.description,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: challenge.progressFraction,
            backgroundColor: Colors.white12,
            color: const Color(0xFF26A69A),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge.currentXp} / ${challenge.targetXp} XP',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              if (challenge.isCompleted && !challenge.isClaimed)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: () {
                    AudioHapticsService.playGoalCelebration();
                    ref.read(gamificationProvider.notifier).claimChallengeReward();
                  },
                  child: const Text('Claim +250 XP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                )
              else if (challenge.isClaimed)
                const Text('✅ Claimed', style: TextStyle(color: Color(0xFF26A69A), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTile(AchievementBadge badge) {
    final unlocked = badge.isUnlocked;
    final progress = badge.progressFraction;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFF162947).withValues(alpha: 0.9)
            : const Color(0xFF111F36).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? const Color(0xFFFFB703).withValues(alpha: 0.4)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: unlocked
                  ? const Color(0xFFFFB703).withValues(alpha: 0.2)
                  : Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Text(
              unlocked ? badge.iconEmoji : '🔒',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      badge.title,
                      style: TextStyle(
                        color: unlocked ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '+${badge.xpReward} XP',
                      style: const TextStyle(
                        color: Color(0xFFFFB703),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  badge.description,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                if (!unlocked) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    color: const Color(0xFFFFB703),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
