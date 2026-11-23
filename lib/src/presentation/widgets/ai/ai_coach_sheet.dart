import 'package:aquawild/src/core/services/audio_haptics_service.dart';
import 'package:aquawild/src/domain/models/ai_recommendation.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/presentation/controllers/ai_coach_controller.dart';
import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interactive AI Hydration Coach Bottom Sheet.
class AiCoachSheet extends ConsumerStatefulWidget {
  const AiCoachSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiCoachSheet(),
    );
  }

  @override
  ConsumerState<AiCoachSheet> createState() => _AiCoachSheetState();
}

class _AiCoachSheetState extends ConsumerState<AiCoachSheet> {
  bool _showSettings = false;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _endpointController;
  String _selectedModel = 'gpt-4o-mini';

  @override
  void initState() {
    super.initState();
    final state = ref.read(aiCoachNotifierProvider);
    _apiKeyController = TextEditingController(text: state.apiKey ?? '');
    _endpointController = TextEditingController(text: state.customEndpoint);
    _selectedModel = state.selectedModel;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _endpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coachState = ref.watch(aiCoachNotifierProvider);
    final companion = ref.watch(animalHabitatProvider).activeAnimal;
    final advice = coachState.recommendation;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36).withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4D8).withValues(alpha: 0.25),
            blurRadius: 40,
            spreadRadius: 4,
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
            // Handle bar
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

            // Header with Companion Badge & Settings Toggle
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(companion.primaryColorHex).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(companion.primaryColorHex).withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    companion.avatarEmoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${companion.name}’s AI Coach',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        advice?.isFromOfflineHeuristic == true
                            ? 'Clinical Heuristic Engine • Offline Mode'
                            : 'OpenAI-Compatible Engine • Active',
                        style: TextStyle(
                          color: advice?.isFromOfflineHeuristic == true
                              ? const Color(0xFFFFB703)
                              : const Color(0xFF00E5FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Configure AI Provider',
                  icon: Icon(
                    _showSettings ? Icons.close : Icons.tune_rounded,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() => _showSettings = !_showSettings);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Settings Tray (Toggleable)
            if (_showSettings) ...[
              _buildSettingsTray(context),
              const SizedBox(height: 16),
            ],

            // Loading Indicator or Advice Card
            if (coachState.isLoading) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF00E5FF),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Analyzing biometrics & atmospheric conditions...',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (advice != null) ...[
              _buildAdviceCard(advice),
              const SizedBox(height: 16),

              // Quick Action Button: Log Suggested Drink
              _buildQuickLogButton(advice),
              const SizedBox(height: 12),

              // Refresh Button
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white70),
                label: const Text(
                  'Refresh Analysis',
                  style: TextStyle(color: Colors.white70),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  AudioHapticsService.playTap();
                  ref.read(aiCoachNotifierProvider.notifier).refreshAdvice();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard(AiRecommendation advice) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF162947).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Color(advice.urgency.badgeColorHex).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Urgency & Tag Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(advice.urgency.badgeColorHex).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  advice.urgency.label.toUpperCase(),
                  style: TextStyle(
                    color: Color(advice.urgency.badgeColorHex),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (advice.electrolyteFocus)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB703).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚡ ELECTROLYTES',
                    style: TextStyle(
                      color: Color(0xFFFFB703),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Headline
          Text(
            advice.headline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Guidance Message
          Text(
            advice.message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          // Reasoning Tags Wrap
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: advice.reasoningTags.map<Widget>((String tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '# $tag',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLogButton(AiRecommendation advice) {
    final bev = BeverageType.findById(advice.suggestedBeverageId);
    return Semantics(
      button: true,
      label: 'Log suggested ${advice.recommendedIntakeMl} milliliters of ${bev.name} per AI advice',
      child: ElevatedButton.icon(
        icon: Text(bev.iconEmoji, style: const TextStyle(fontSize: 18)),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Log Suggested ${advice.recommendedIntakeMl}ml ${bev.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00B4D8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 6,
        shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
      ),
      onPressed: () {
        AudioHapticsService.playPour();
        ref.read(hydrationProvider.notifier).logDrink(
              beverage: bev,
              volumeMl: advice.recommendedIntakeMl.toDouble(),
            );
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0F2647),
            content: Text(
              'Logged ${advice.recommendedIntakeMl}ml ${bev.name} per AI advice!',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildSettingsTray(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162947),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OpenAI-Compatible Configuration',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _endpointController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Base URL (OpenAI / Groq / Ollama / LocalAI)',
              labelStyle: TextStyle(color: Colors.white60, fontSize: 12),
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'API Key (Leave empty for Offline Heuristic Engine)',
              labelStyle: TextStyle(color: Colors.white60, fontSize: 12),
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedModel,
            dropdownColor: const Color(0xFF1A3358),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Model Name',
              labelStyle: TextStyle(color: Colors.white60, fontSize: 12),
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'gpt-4o-mini', child: Text('gpt-4o-mini')),
              DropdownMenuItem(value: 'gpt-4o', child: Text('gpt-4o')),
              DropdownMenuItem(value: 'llama-3.1-8b-instant', child: Text('llama-3.1-8b (Groq)')),
              DropdownMenuItem(value: 'mistral-7b-instruct', child: Text('mistral-7b (Local)')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedModel = val);
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                ref.read(aiCoachNotifierProvider.notifier).updateConfig(
                      apiKey: _apiKeyController.text.trim().isEmpty ? null : _apiKeyController.text.trim(),
                      customEndpoint: _endpointController.text.trim().isEmpty ? 'https://api.openai.com/v1' : _endpointController.text.trim(),
                      selectedModel: _selectedModel,
                    );
                setState(() => _showSettings = false);
              },
              child: const Text('Save & Reconnect', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
