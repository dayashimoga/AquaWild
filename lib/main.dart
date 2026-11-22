import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/constants/app_constants.dart';
import 'src/core/router/app_router.dart';
import 'src/core/theme/theme_mode_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AquaWildApp(),
    ),
  );
}

/// AquaWild Root Application Widget
class AquaWildApp extends ConsumerWidget {
  const AquaWildApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final appThemeMode = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final effectiveTheme = themeNotifier.resolveThemeData(platformBrightness);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: effectiveTheme,
      themeMode: appThemeMode == AppThemeMode.system
          ? ThemeMode.system
          : ThemeMode.dark,
      routerConfig: router,
    );
  }
}
