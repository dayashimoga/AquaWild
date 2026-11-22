import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

/// Available theme modes in AquaWild
enum AppThemeMode {
  hydroGlass,
  dark,
  light,
  highContrast,
  system;

  String get displayName {
    switch (this) {
      case AppThemeMode.hydroGlass:
        return 'Hydro-Glass (Futuristic)';
      case AppThemeMode.dark:
        return 'Abyssal Dark';
      case AppThemeMode.light:
        return 'Crisp Light';
      case AppThemeMode.highContrast:
        return 'High Contrast (WCAG AAA)';
      case AppThemeMode.system:
        return 'System Default';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.hydroGlass:
        return Icons.water_drop_outlined;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.highContrast:
        return Icons.contrast_rounded;
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }
}

/// State notifier managing the active theme mode
class ThemeModeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    return AppThemeMode.hydroGlass;
  }

  /// Sets the explicit theme mode
  void setTheme(AppThemeMode mode) {
    state = mode;
  }

  /// Cycles to the next theme mode in sequence
  void cycleTheme() {
    const values = AppThemeMode.values;
    final nextIndex = (values.indexOf(state) + 1) % values.length;
    state = values[nextIndex];
  }

  /// Resolves the effective ThemeData based on the current mode and brightness
  ThemeData resolveThemeData(Brightness platformBrightness) {
    switch (state) {
      case AppThemeMode.hydroGlass:
        return AppTheme.hydroGlassTheme;
      case AppThemeMode.dark:
        return AppTheme.darkTheme;
      case AppThemeMode.light:
        return AppTheme.lightTheme;
      case AppThemeMode.highContrast:
        return AppTheme.highContrastTheme;
      case AppThemeMode.system:
        return platformBrightness == Brightness.dark
            ? AppTheme.hydroGlassTheme
            : AppTheme.lightTheme;
    }
  }
}

/// Riverpod provider for active application theme mode
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, AppThemeMode>(() {
  return ThemeModeNotifier();
});
