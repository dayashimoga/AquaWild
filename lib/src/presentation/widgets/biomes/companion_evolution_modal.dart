import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/services/audio_haptics_service.dart';
import '../../../domain/models/animal_evolution_stage.dart';
import '../../../domain/models/exotic_animal.dart';

/// Interactive celebration modal displayed when an exotic animal evolves
/// to a new evolution stage (Hatchling -> Explorer -> Guardian -> Mythic Spirit).
class CompanionEvolutionModal extends StatefulWidget {
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
  State<CompanionEvolutionModal> createState() =>
      _CompanionEvolutionModalState();
}

class _CompanionEvolutionModalState extends State<CompanionEvolutionModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final accent = widget.animal.accentColor;

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
            // Rotating Sunburst Aura behind Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                if (!reducedMotion)
                  AnimatedBuilder(
                    animation: _spinController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _spinController.value * 2 * math.pi,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                accent.withValues(alpha: 0.0),
                                accent.withValues(alpha: 0.4),
                                Colors.white.withValues(alpha: 0.6),
                                accent.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF162947),
                    border: Border.all(color: accent, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.animal.avatarEmoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ],
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
              widget.stage.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Stage ${widget.stage.stageNumber} • ${widget.animal.name}',
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
                          widget.stage.cosmeticPerk,
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
