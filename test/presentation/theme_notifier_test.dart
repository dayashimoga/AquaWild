import 'package:aquawild/src/core/theme/app_theme.dart';
import 'package:aquawild/src/core/theme/theme_mode_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state defaults to hydroGlass mode', () {
      final mode = container.read(themeModeProvider);
      expect(mode, equals(AppThemeMode.hydroGlass));
    });

    test('setTheme updates state properly', () {
      container.read(themeModeProvider.notifier).setTheme(AppThemeMode.dark);
      expect(container.read(themeModeProvider), equals(AppThemeMode.dark));

      container.read(themeModeProvider.notifier).setTheme(AppThemeMode.highContrast);
      expect(container.read(themeModeProvider), equals(AppThemeMode.highContrast));
    });

    test('cycleTheme cycles through all theme modes sequentially', () {
      final notifier = container.read(themeModeProvider.notifier);
      expect(container.read(themeModeProvider), equals(AppThemeMode.hydroGlass));

      notifier.cycleTheme();
      expect(container.read(themeModeProvider), equals(AppThemeMode.dark));

      notifier.cycleTheme();
      expect(container.read(themeModeProvider), equals(AppThemeMode.light));

      notifier.cycleTheme();
      expect(container.read(themeModeProvider), equals(AppThemeMode.highContrast));

      notifier.cycleTheme();
      expect(container.read(themeModeProvider), equals(AppThemeMode.system));

      notifier.cycleTheme();
      expect(container.read(themeModeProvider), equals(AppThemeMode.hydroGlass));
    });

    test('resolveThemeData returns matching ThemeData for each mode', () {
      final notifier = container.read(themeModeProvider.notifier);

      notifier.setTheme(AppThemeMode.hydroGlass);
      expect(
        notifier.resolveThemeData(Brightness.dark).brightness,
        equals(AppTheme.hydroGlassTheme.brightness),
      );

      notifier.setTheme(AppThemeMode.light);
      expect(
        notifier.resolveThemeData(Brightness.light).brightness,
        equals(Brightness.light),
      );

      notifier.setTheme(AppThemeMode.highContrast);
      expect(
        notifier.resolveThemeData(Brightness.dark).scaffoldBackgroundColor,
        equals(AppTheme.highContrastTheme.scaffoldBackgroundColor),
      );

      notifier.setTheme(AppThemeMode.system);
      expect(
        notifier.resolveThemeData(Brightness.light).brightness,
        equals(Brightness.light),
      );
      expect(
        notifier.resolveThemeData(Brightness.dark).brightness,
        equals(Brightness.dark),
      );
    });
  });
}
