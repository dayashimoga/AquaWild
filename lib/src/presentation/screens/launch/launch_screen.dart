import 'package:aquawild/src/core/constants/app_constants.dart';
import 'package:aquawild/src/core/theme/app_colors.dart';
import 'package:aquawild/src/presentation/widgets/pool/interactive_pool_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Launch screen displaying the detailed animated SVG Red Panda relaxing
/// on a floating tube over top-view procedural pool water with realistic
/// floating physics, ripples, reflections, shadows, parallax, particles,
/// and seamless Hero transition to the hydration studio.
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAbyssal,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Interactive 60/120 FPS Procedural Pool Simulation & Red Panda Mascot
          const InteractivePoolView(),

          // Modern-Futuristic Glassmorphic Controls Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardGlassDark,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.cardGlassBorderDark,
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.waves_rounded,
                          size: 16,
                          color: AppColors.cyanPrimary,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Bamboo Misty Springs • Relax Mode',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom Modern-Futuristic Call-To-Action Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAbyssal.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppColors.cardGlassBorderDark,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyanPrimary.withValues(alpha: 0.15),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Track hydration, evolve exotic animal companions & restore living biomes.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => context.go('/home'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cyanPrimary,
                              foregroundColor: AppColors.surfaceAbyssal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 4,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Dive Into Habitat',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap pool surface or mascot anytime to create ripples',
                          style: TextStyle(fontSize: 11, color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
