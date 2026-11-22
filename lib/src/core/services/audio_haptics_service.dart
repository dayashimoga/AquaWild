import 'package:flutter/services.dart';

/// Multimodal feedback service coordinating adaptive haptics and synthesized sounds
class AudioHapticsService {
  AudioHapticsService._();

  static final AudioHapticsService instance = AudioHapticsService._();

  /// Gentle haptic pulse during pour slider adjustment
  Future<void> onSliderTick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Tactile feedback when a drink entry is successfully logged and liquid splashes into vessel
  Future<void> onDrinkLogged() async {
    try {
      await HapticFeedback.mediumImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Jubilant tactile burst when an evolution stage or milestone is achieved
  Future<void> onEvolutionAchieved() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Subtle click on keypad press
  Future<void> onKeypadPress() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }
}
