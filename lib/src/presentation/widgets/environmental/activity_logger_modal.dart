import 'package:aquawild/src/core/services/audio_haptics_service.dart';
import 'package:aquawild/src/domain/models/activity_session.dart';
import 'package:aquawild/src/presentation/controllers/weather_activity_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal to record physical workouts and calculate sweat replenishment.
class ActivityLoggerModal extends ConsumerStatefulWidget {
  const ActivityLoggerModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ActivityLoggerModal(),
    );
  }

  @override
  ConsumerState<ActivityLoggerModal> createState() => _ActivityLoggerModalState();
}

class _ActivityLoggerModalState extends ConsumerState<ActivityLoggerModal> {
  ActivityType _selectedType = ActivityType.running;
  ActivityIntensity _selectedIntensity = ActivityIntensity.high;
  int _durationMinutes = 30;

  @override
  Widget build(BuildContext context) {
    final estimatedSweatLoss = (_durationMinutes * _selectedIntensity.sweatRateMlPerMinute).round();
    final recommendedReplenishment = (estimatedSweatLoss * 1.25).round();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFFFFB703).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB703).withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            const Row(
              children: [
                Text(
                  '⚡ Log Workout Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Dynamic hydration compensates for exercise sweat loss & active metabolic heat.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 18),

            // Activity Type Grid/Wrap
            const Text(
              'Select Activity',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ActivityType.values.map((type) {
                final isSelected = type == _selectedType;
                return ChoiceChip(
                  label: Text('${type.iconEmoji} ${type.label}'),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFFB703),
                  backgroundColor: const Color(0xFF162947),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      AudioHapticsService.playTap();
                      setState(() {
                        _selectedType = type;
                        _selectedIntensity = type.defaultIntensity;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Duration Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Duration',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$_durationMinutes min',
                  style: const TextStyle(
                    color: Color(0xFFFFB703),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _durationMinutes.toDouble(),
              min: 5,
              max: 150,
              divisions: 29,
              activeColor: const Color(0xFFFFB703),
              inactiveColor: Colors.white24,
              onChanged: (val) {
                setState(() => _durationMinutes = val.round());
              },
            ),
            const SizedBox(height: 14),

            // Intensity Selector
            const Text(
              'Workout Intensity',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SegmentedButton<ActivityIntensity>(
              segments: const [
                ButtonSegment(
                  value: ActivityIntensity.light,
                  label: Text('Light', style: TextStyle(fontSize: 11)),
                ),
                ButtonSegment(
                  value: ActivityIntensity.moderate,
                  label: Text('Moderate', style: TextStyle(fontSize: 11)),
                ),
                ButtonSegment(
                  value: ActivityIntensity.high,
                  label: Text('High', style: TextStyle(fontSize: 11)),
                ),
                ButtonSegment(
                  value: ActivityIntensity.extreme,
                  label: Text('Extreme', style: TextStyle(fontSize: 11)),
                ),
              ],
              selected: {_selectedIntensity},
              onSelectionChanged: (set) {
                AudioHapticsService.playTap();
                setState(() => _selectedIntensity = set.first);
              },
            ),
            const SizedBox(height: 22),

            // Sweat Loss Summary Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF162947),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFB703).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('💧', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Sweat Loss: ${estimatedSweatLoss}ml',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Target will automatically increase by +${recommendedReplenishment}ml to maintain optimal hydration.',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Confirm Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB703),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () {
                AudioHapticsService.playGoalCelebration();
                final session = ActivitySession(
                  activityType: _selectedType,
                  durationMinutes: _durationMinutes,
                  intensity: _selectedIntensity,
                );
                ref.read(weatherActivityNotifierProvider.notifier).logActivity(session);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF0F2647),
                    content: Text(
                      'Logged ${_selectedType.label} ($_durationMinutes min). Target updated by +${recommendedReplenishment}ml!',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              child: const Text(
                'Save Workout & Update Target',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
