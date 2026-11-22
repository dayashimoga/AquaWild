import 'package:flutter/material.dart';
import '../../../core/services/audio_haptics_service.dart';
import '../../../domain/models/animal_evolution_stage.dart';
import '../../../domain/models/exotic_animal.dart';
import 'companion_avatar_renderer.dart';

/// Interactive celebration modal displayed when an exotic animal evolves
/// to a new evolution stage (Hatchling -> Explorer -> Guardian -> Mythic Spirit).
class CompanionEvolutionModal extends StatelessWidget {
  final ExoticAnimal animal;
  final AnimalEvolutionStage stage;
  final int totalXp;

  const CompanionEvolutionModal({
    super.key,
    required this.animal,
    required this.stage,
    required this.totalXp,
  });

  static Future<void> show(
    BuildContext context, {
    required ExoticAnimal animal,
    required AnimalEvolutionStage stage,
    required int totalXp,
  }) {
    AudioHapticsService.playGoalCelebration();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => CompanionEvolutionModal(
        animal: animal,
        stage: stage,
        totalXp: totalXp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = animal.accentColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: accent.withValues(alpha: 0.6),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.35),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // High-Detail Vector Avatar with Rotating Celestial Aura
            CompanionAvatarRenderer(
              animal: animal,
              stage: stage,
              size: 110,
              isUnlocked: true,
              isSelected: true,
              showAura: true,
              showBadge: true,
              fillFraction: 0.85,
              interactionPulse: 1.0,
              animate: true,
            ),
            const SizedBox(height: 20),

            // Header Banner
            Text(
              'EVOLUTION UNLOCKED!',
              style: TextStyle(
                color: accent,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stage.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Stage ${stage.stageNumber} • ${animal.name}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Cosmetic Perk Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF132238),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFFFD54F),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stage Mastery Perk',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stage.cosmeticPerk,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  AudioHapticsService.playTap();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Claim Evolution',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
