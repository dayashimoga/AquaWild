import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_mode_notifier.dart';
import '../../controllers/monetization_controller.dart';

/// One-tap theme cycle and dropdown selection button supporting Pro lock indicators
class ThemeSwitcherButton extends ConsumerWidget {
  const ThemeSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMode = ref.watch(themeModeProvider);
    final monetization = ref.watch(monetizationProvider);

    return PopupMenuButton<AppThemeMode>(
      tooltip: 'Change Theme (${activeMode.displayName})',
      icon: Icon(activeMode.icon, size: 20),
      initialValue: activeMode,
      onSelected: (mode) {
        final isUnlocked = !mode.isPremium ||
            (mode.themeId != null &&
                monetization.isThemeUnlocked(mode.themeId!));

        if (!isUnlocked) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.lock_rounded, color: Colors.amberAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${mode.displayName} is a Pro theme. Upgrade to AquaWild Pro to unlock!',
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        ref.read(themeModeProvider.notifier).setTheme(mode);
      },
      itemBuilder: (context) {
        return AppThemeMode.values.map((mode) {
          final isSelected = mode == activeMode;
          final isUnlocked = !mode.isPremium ||
              (mode.themeId != null &&
                  monetization.isThemeUnlocked(mode.themeId!));

          return PopupMenuItem<AppThemeMode>(
            value: mode,
            child: Row(
              children: [
                Icon(
                  mode.icon,
                  size: 18,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : (!isUnlocked ? Colors.white38 : null),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mode.displayName,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: !isUnlocked ? Colors.white54 : null,
                    ),
                  ),
                ),
                if (!isUnlocked) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: Colors.amberAccent,
                  ),
                ] else if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
