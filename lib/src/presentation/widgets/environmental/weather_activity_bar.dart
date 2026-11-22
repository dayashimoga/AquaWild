import 'package:aquawild/src/core/services/audio_haptics_service.dart';
import 'package:aquawild/src/core/services/weather_activity_service.dart';
import 'package:aquawild/src/presentation/controllers/ai_coach_controller.dart';
import 'package:aquawild/src/presentation/controllers/weather_activity_controller.dart';
import 'package:aquawild/src/presentation/widgets/ai/ai_coach_sheet.dart';
import 'package:aquawild/src/presentation/widgets/environmental/activity_logger_modal.dart';
import 'package:aquawild/src/presentation/widgets/reminders/smart_reminders_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modern glassmorphic status bar displaying current weather impact,
/// physical workout sessions, AI Coach trigger, and smart reminders.
class WeatherActivityBar extends ConsumerWidget {
  const WeatherActivityBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherActivityNotifierProvider);
    final coachState = ref.watch(aiCoachNotifierProvider);
    final weather = weatherState.currentWeather;
    final weatherOffset = weather.weatherHydrationOffsetMl;
    final hasActivities = weatherState.activities.isNotEmpty;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // 1. Weather Capsule
          _buildPill(
            icon: '🌡️',
            label: '${weather.temperatureCelsius.toStringAsFixed(0)}°C ${weather.cityName}',
            sublabel: weatherOffset > 0 ? '+$weatherOffset ml heat' : 'Optimal',
            pillColor: const Color(0xFF00B4D8),
            onTap: () {
              AudioHapticsService.playTap();
              _showWeatherPicker(context, ref);
            },
          ),
          const SizedBox(width: 8),

          // 2. Activity Capsule
          _buildPill(
            icon: hasActivities ? weatherState.activities.last.activityType.iconEmoji : '⚡',
            label: hasActivities
                ? '${weatherState.activities.last.activityType.label} (${weatherState.activities.last.durationMinutes}m)'
                : 'Log Workout',
            sublabel: hasActivities
                ? '+${weatherState.activities.fold<int>(0, (s, a) => s + a.recommendedReplenishmentMl)} ml'
                : 'Sweat Loss',
            pillColor: const Color(0xFFFFB703),
            onTap: () {
              AudioHapticsService.playTap();
              ActivityLoggerModal.show(context);
            },
          ),
          const SizedBox(width: 8),

          // 3. AI Coach Spark Capsule
          _buildPill(
            icon: '✨',
            label: 'AI Coach',
            sublabel: coachState.recommendation?.urgency.label ?? 'Ready',
            pillColor: const Color(0xFF00E5FF),
            onTap: () {
              AudioHapticsService.playTap();
              AiCoachSheet.show(context);
            },
          ),
          const SizedBox(width: 8),

          // 4. Smart Reminders Bell Capsule
          _buildPill(
            icon: '🔔',
            label: 'Circadian',
            sublabel: 'Reminders',
            pillColor: const Color(0xFF9D4EDD),
            onTap: () {
              AudioHapticsService.playTap();
              SmartRemindersSheet.show(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String icon,
    required String label,
    required String sublabel,
    required Color pillColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF162947).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: pillColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: pillColor.withValues(alpha: 0.12),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(
                      color: pillColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeatherPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E36).withValues(alpha: 0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: const Color(0xFF00B4D8).withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Simulate Environmental Biome',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ambient temperature, humidity, and altitude directly adjust perspiration rates.',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ...WeatherActivityService.environmentalPresets.map((preset) {
                final offset = preset.weatherHydrationOffsetMl;
                return ListTile(
                  title: Text(
                    '${preset.cityName} (${preset.temperatureCelsius.toStringAsFixed(0)}°C)',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${preset.description} • Offset: +${offset}ml',
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
                  ),
                  onTap: () {
                    AudioHapticsService.playTap();
                    ref.read(weatherActivityNotifierProvider.notifier).setWeather(preset);
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
