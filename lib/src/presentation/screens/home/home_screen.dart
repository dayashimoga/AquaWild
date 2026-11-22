import 'package:flutter/material.dart';
import '../../widgets/shortcuts/aqua_wild_shortcuts_wrapper.dart';
import 'responsive_home_shell.dart';

/// Main Hydration & Exotic Animal Habitat Dashboard
/// Wrapped with global keyboard accelerators and adaptive multi-breakpoint shell
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AquaWildShortcutsWrapper(
      child: ResponsiveHomeShell(),
    );
  }
}
