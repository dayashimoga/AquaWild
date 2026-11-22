import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_mode_notifier.dart';

/// One-tap theme cycle and dropdown selection button
class ThemeSwitcherButton extends ConsumerWidget {
  const ThemeSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMode = ref.watch(themeModeProvider);

    return PopupMenuButton<AppThemeMode>(
      tooltip: 'Change Theme (${activeMode.displayName})',
      icon: Icon(activeMode.icon, size: 20),
      initialValue: activeMode,
      onSelected: (mode) {
        ref.read(themeModeProvider.notifier).setTheme(mode);
      },
      itemBuilder: (context) {
        return AppThemeMode.values.map((mode) {
          final isSelected = mode == activeMode;
          return PopupMenuItem<AppThemeMode>(
            value: mode,
            child: Row(
              children: [
                Icon(
                  mode.icon,
                  size: 18,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mode.displayName,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
