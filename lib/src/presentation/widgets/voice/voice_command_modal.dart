import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_haptics_service.dart';
import '../../../core/services/voice_command_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/animal_habitat_controller.dart';
import '../../controllers/hydration_controller.dart';

/// Modal dialog simulating voice command speech recognition and natural language logging
class VoiceCommandModal extends ConsumerStatefulWidget {
  const VoiceCommandModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceCommandModal(),
    );
  }

  @override
  ConsumerState<VoiceCommandModal> createState() => _VoiceCommandModalState();
}

class _VoiceCommandModalState extends ConsumerState<VoiceCommandModal>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final AnimationController _pulseController;
  VoiceParseResult? _parsedResult;
  bool _isListening = false;

  final List<String> _presets = [
    'Drank 250ml pure water',
    'Had 300ml hot green tea',
    'Logged 60ml espresso',
    'Drank 500ml electrolytes after workout',
    '330ml cold coconut water',
    '16 oz ice water',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.trim().isNotEmpty) {
      setState(() {
        _parsedResult = VoiceCommandService.instance.parseUtterance(text);
      });
    } else {
      setState(() {
        _parsedResult = null;
      });
    }
  }

  void _selectPreset(String preset) {
    _controller.text = preset;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: preset.length),
    );
    AudioHapticsService.instance.onVolumeChanged();
  }

  void _confirmAndLog() {
    if (_parsedResult == null) return;
    final result = _parsedResult!;
    ref.read(hydrationProvider.notifier).logDrink(
          beverage: result.beverage,
          volumeMl: result.volumeMl,
        );
    ref.read(animalHabitatProvider.notifier).addXp(
          (result.volumeMl / 10).round(),
        );
    AudioHapticsService.instance.onDrinkLogged();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎙️ ${result.confirmationMessage}'),
        backgroundColor: result.beverage.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.mic, color: primaryColor, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        'Voice Hydration Logger',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Speak or type naturally. AI extracts beverage and milliliters automatically.',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 20),

            // Pulsing Mic Visualizer
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.15);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _isListening = !_isListening;
                        if (_isListening && _controller.text.isEmpty) {
                          _controller.text = 'Drank 300ml green tea';
                        }
                      });
                      AudioHapticsService.instance.onVolumeChanged();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80 * scale,
                          height: 80 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(
                              alpha: 0.15 * (1 - _pulseController.value * 0.5),
                            ),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening
                                ? primaryColor
                                : primaryColor.withValues(alpha: 0.25),
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.black : primaryColor,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Speech Text Field
            TextField(
              controller: _controller,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'e.g. "Drank 500ml ice water with electrolytes"',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.white38),
                filled: true,
                fillColor: AppColors.cardGlassDark,
                prefixIcon: const Icon(Icons.record_voice_over, size: 20),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _controller.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: primaryColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Presets chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _presets.map((preset) {
                return ActionChip(
                  label: Text(
                    preset,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: AppColors.cardGlassDark,
                  onPressed: () => _selectPreset(preset),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Parsed Result Card
            if (_parsedResult != null) ...[
              Card(
                color: _parsedResult!.beverage.primaryColor
                    .withValues(alpha: 0.15),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _parsedResult!.beverage.primaryColor,
                        radius: 20,
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_parsedResult!.volumeMl.toStringAsFixed(0)}ml ${_parsedResult!.beverage.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Net hydration: +${(_parsedResult!.volumeMl * _parsedResult!.beverage.hydrationCoefficient).toStringAsFixed(0)}ml • Confidence: ${(_parsedResult!.confidence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _confirmAndLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _parsedResult!.beverage.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  'Log ${_parsedResult!.volumeMl.toStringAsFixed(0)}ml ${_parsedResult!.beverage.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
  }
}
