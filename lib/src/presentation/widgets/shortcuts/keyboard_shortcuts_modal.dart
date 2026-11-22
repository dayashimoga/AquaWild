import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Modal dialog displaying full keyboard shortcut accelerators for desktop and power users
class KeyboardShortcutsModal extends StatelessWidget {
  const KeyboardShortcutsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const KeyboardShortcutsModal(),
    );
  }

  static const List<(String, String, String)> _shortcuts = [
    ('1 - 9', 'Quick Log Beverage', 'Instantly logs default volume for beverages 1 through 9'),
    ('Space', 'Pour Pure Water', 'Quick logs 250ml of fresh pure water'),
    ('A', 'AI Hydration Coach', 'Opens AI advisor with personalized hydration recommendations'),
    ('R', 'Smart Reminders', 'Opens circadian schedule timeline & interval timers'),
    ('B', 'Biomes & Companions', 'Opens exotic companion evolution & habitat biome switcher'),
    ('P', 'Predictive Analytics', 'Opens dehydration risk report, hourly curve & 7-day intake'),
    ('G', 'Achievements & Streaks', 'Opens XP progress, streak freeze shield, and badges'),
    ('T', 'Cycle Theme Mode', 'Cycles between Hydro-Glass, Dark, Light, and High Contrast'),
    ('V', 'Voice Logger', 'Opens natural language speech input simulation modal'),
    ('X', 'Backup & Export', 'Exports telemetry to lossless JSON or spreadsheet CSV'),
    ('Ctrl+Shift+A', 'Admin Mission Control', 'Opens AquaWild Mission Control & Developer Portal'),
    ('? / F1', 'Shortcuts Guide', 'Displays this shortcuts reference dialog'),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.keyboard, color: primaryColor, size: 24),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Keyboard Accelerators & Shortcuts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'AquaWild is optimized for desktop, web, tablets, and keyboard navigation.',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 18),

            // Shortcuts Grid / List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _shortcuts.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.white12,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final (keycap, title, description) = _shortcuts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // Stylized Keycap Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.5),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            keycap,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Footer
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close Shortcuts Guide'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
