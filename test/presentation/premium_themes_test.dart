import 'dart:ui' as ui;
import 'package:aquawild/src/core/plugins/content_plugin_registry.dart';
import 'package:aquawild/src/core/theme/app_theme.dart';
import 'package:aquawild/src/core/theme/theme_mode_notifier.dart';
import 'package:aquawild/src/domain/models/achievement_badge.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/hydration_biome.dart';
import 'package:aquawild/src/domain/models/monetization_models.dart';
import 'package:aquawild/src/presentation/controllers/monetization_controller.dart';
import 'package:aquawild/src/presentation/widgets/pool/pool_particles_painter.dart';
import 'package:aquawild/src/presentation/widgets/theme/theme_switcher_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Premium Themes & Visual Tokens Tests', () {
    test('AppThemeMode contains all 8 themes with proper premium metadata', () {
      expect(AppThemeMode.values.length, equals(8));
      expect(AppThemeMode.values, contains(AppThemeMode.neonBioluminescence));
      expect(AppThemeMode.values, contains(AppThemeMode.minimalZen));
      expect(AppThemeMode.values, contains(AppThemeMode.cyberOcean));

      expect(AppThemeMode.hydroGlass.isPremium, isFalse);
      expect(AppThemeMode.dark.isPremium, isFalse);
      expect(AppThemeMode.light.isPremium, isFalse);
      expect(AppThemeMode.highContrast.isPremium, isFalse);
      expect(AppThemeMode.system.isPremium, isFalse);

      expect(AppThemeMode.neonBioluminescence.isPremium, isTrue);
      expect(AppThemeMode.minimalZen.isPremium, isTrue);
      expect(AppThemeMode.cyberOcean.isPremium, isTrue);

      expect(AppThemeMode.neonBioluminescence.themeId, equals('neon_bioluminescence'));
      expect(AppThemeMode.minimalZen.themeId, equals('minimal_zen'));
      expect(AppThemeMode.cyberOcean.themeId, equals('cyber_ocean'));
      expect(AppThemeMode.hydroGlass.themeId, isNull);
    });

    test('ThemeModeNotifier resolves all premium and standard themes correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(themeModeProvider.notifier);

      notifier.setTheme(AppThemeMode.hydroGlass);
      expect(notifier.resolveThemeData(Brightness.dark), equals(AppTheme.hydroGlassTheme));

      notifier.setTheme(AppThemeMode.neonBioluminescence);
      final neonTheme = notifier.resolveThemeData(Brightness.dark);
      expect(neonTheme.brightness, equals(Brightness.dark));
      expect(neonTheme.colorScheme.primary, equals(const Color(0xFF00F0FF)));
      expect(neonTheme.colorScheme.secondary, equals(const Color(0xFFFF007F)));
      expect(neonTheme.scaffoldBackgroundColor, equals(const Color(0xFF050814)));

      notifier.setTheme(AppThemeMode.minimalZen);
      final zenTheme = notifier.resolveThemeData(Brightness.light);
      expect(zenTheme.brightness, equals(Brightness.light));
      expect(zenTheme.colorScheme.primary, equals(const Color(0xFF4A6B53)));
      expect(zenTheme.colorScheme.secondary, equals(const Color(0xFFC48B54)));
      expect(zenTheme.scaffoldBackgroundColor, equals(const Color(0xFFF9F7F1)));

      notifier.setTheme(AppThemeMode.cyberOcean);
      final cyberTheme = notifier.resolveThemeData(Brightness.dark);
      expect(cyberTheme.brightness, equals(Brightness.dark));
      expect(cyberTheme.colorScheme.primary, equals(const Color(0xFF00E5FF)));
      expect(cyberTheme.colorScheme.secondary, equals(const Color(0xFF9D4EDD)));
      expect(cyberTheme.scaffoldBackgroundColor, equals(const Color(0xFF040B1A)));
    });

    testWidgets('ThemeSwitcherButton displays lock icons for premium themes when Free',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationProvider.overrideWith(() => _FakeMonetizationNotifier(isPro: false)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ThemeSwitcherButton(),
            ),
          ),
        ),
      );

      // Tap popup menu button
      await tester.tap(find.byType(ThemeSwitcherButton));
      await tester.pumpAndSettle();

      // Verify all theme options are shown
      expect(find.text('Hydro-Glass (Futuristic)'), findsOneWidget);
      expect(find.text('Neon Bioluminescence (PRO)'), findsOneWidget);
      expect(find.text('Minimal Zen (PRO)'), findsOneWidget);
      expect(find.text('Cyber Ocean (PRO)'), findsOneWidget);

      // Verify lock icons exist for the 3 premium themes
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(3));

      // Attempt to select locked Neon Bioluminescence
      await tester.tap(find.text('Neon Bioluminescence (PRO)'));
      await tester.pumpAndSettle();

      // Verify snackbar is displayed
      expect(find.textContaining('is a Pro theme'), findsOneWidget);
    });

    testWidgets('ThemeSwitcherButton allows selecting premium themes when Pro',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationProvider.overrideWith(() => _FakeMonetizationNotifier(isPro: true)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ThemeSwitcherButton(),
            ),
          ),
        ),
      );

      // Tap popup menu button
      await tester.tap(find.byType(ThemeSwitcherButton));
      await tester.pumpAndSettle();

      // When Pro, zero lock icons should appear
      expect(find.byIcon(Icons.lock_rounded), findsNothing);

      // Select Neon Bioluminescence
      await tester.tap(find.text('Neon Bioluminescence (PRO)'));
      await tester.pumpAndSettle();

      // No snackbar should be displayed
      expect(find.textContaining('is a Pro theme'), findsNothing);
    });
  });

  group('Particle Visual Effects Tests', () {
    test('PoolParticlesPainter generates and paints all 4 particle effect types', () {
      const types = [
        ParticleEffectType.standardBubbles,
        ParticleEffectType.bioluminescentPlankton,
        ParticleEffectType.auroraDust,
        ParticleEffectType.onsenSteamBubbles,
      ];

      for (final type in types) {
        final particles = PoolParticlesPainter.generateDefaultParticles(count: 20, type: type);
        expect(particles.length, equals(20));

        final painter = PoolParticlesPainter(
          time: 2.5,
          particles: particles,
          effectType: type,
        );

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        const size = Size(400, 600);

        // Rendering should execute without throwing
        expect(() => painter.paint(canvas, size), returnsNormally);

        final repainted = PoolParticlesPainter(
          time: 2.8,
          particles: particles,
          effectType: type,
        );
        expect(painter.shouldRepaint(repainted), isTrue);

        final same = PoolParticlesPainter(
          time: 2.5,
          particles: particles,
          effectType: type,
        );
        expect(painter.shouldRepaint(same), isFalse);
      }
    });
  });

  group('Exclusive Achievement Badges Tests', () {
    test('Default achievements contain the 4 new exclusive badges', () {
      const badges = AchievementBadge.defaultAchievements;
      expect(badges.length, equals(16));

      final proPioneer = badges.firstWhere((b) => b.id == 'pro_pioneer');
      expect(proPioneer.title, equals('Apex Guardian'));
      expect(proPioneer.xpReward, equals(500));
      expect(proPioneer.iconEmoji, equals('👑'));

      final summerSplash = badges.firstWhere((b) => b.id == 'summer_splash_champion');
      expect(summerSplash.title, equals('Summer Splash Legend'));
      expect(summerSplash.xpReward, equals(750));
      expect(summerSplash.iconEmoji, equals('🏖️'));

      final masterOfTen = badges.firstWhere((b) => b.id == 'master_of_ten');
      expect(masterOfTen.title, equals('Wild Menagerie'));
      expect(masterOfTen.xpReward, equals(2000));
      expect(masterOfTen.iconEmoji, equals('🐾'));

      final bioDiver = badges.firstWhere((b) => b.id == 'bioluminescence_diver');
      expect(bioDiver.title, equals('Abyssal Glow'));
      expect(bioDiver.xpReward, equals(300));
      expect(bioDiver.iconEmoji, equals('🪼'));
    });
  });

  group('Content Expansion Plugin Architecture Tests', () {
    test('ContentPluginRegistry loads standard AquaWild core catalog', () {
      final registry = ContentPluginRegistry.standard();

      expect(registry.plugins.length, equals(1));
      expect(registry.hasPlugin('aquawild.core'), isTrue);

      final core = registry.getPlugin('aquawild.core')!;
      expect(core.name, equals('AquaWild Core Sanctuary'));
      expect(core.version, equals('2.0.0'));

      expect(registry.allCompanions.length, equals(10));
      expect(registry.allBiomes.length, equals(6));
      expect(registry.allBeverages.length, equals(BeverageType.allBeverages.length));
      expect(registry.allProducts.length, greaterThanOrEqualTo(4));

      expect(registry.findCompanion('red_panda'), isNotNull);
      expect(registry.findBiome('bamboo_misty_springs'), isNotNull);
      expect(registry.findBiome('aurora_glacier'), isNotNull);
      expect(registry.findBeverage('pure_water'), isNotNull);
      expect(registry.findProduct('pack_deep_sea'), isNotNull);
    });

    test('ContentPluginRegistry registers and unregisters dynamic expansion packs', () {
      final registry = ContentPluginRegistry.standard();

      bool installed = false;
      bool uninstalled = false;

      final testPlugin = ContentPlugin(
        id: 'expansion.abyssal_trench',
        name: 'Abyssal Trench Expansion',
        version: '1.0.0',
        author: 'Oceanic Research Lab',
        description: 'New deep sea companion and hydrothermal vent biome.',
        companions: const [
          ExoticAnimal(
            id: 'giant_squid',
            name: 'Archie the Giant Squid',
            scientificName: 'Architeuthis dux',
            lore: 'Glides silently in pitch-black waters.',
            habitatBiomeId: 'hydrothermal_vents',
            unlockXp: 12000,
            accentColor: Color(0xFF673AB7),
            defaultCapacityMl: 700,
            evolutionStages: [],
            nativeHabitat: 'Abyssal Hydrothermal Vent',
          ),
        ],
        biomes: const [
          HydrationBiome(
            id: 'hydrothermal_vents',
            name: 'Hydrothermal Vent Chasm',
            subtitle: 'Volcanic Deep Sea',
            description: 'Volcanic thermal waters rich in minerals.',
            ambientColor: Color(0xFF220033),
            waterCausticColor: Color(0xFFFF4500),
            skyGradient: [Color(0xFF0D001A), Color(0xFF1A0033)],
            soundscapeName: 'Deep Submarine Vent Drone',
            unlockXp: 10000,
            nativeAnimalIds: ['giant_squid'],
          ),
        ],
        onInstall: (_) => installed = true,
        onUninstall: (_) => uninstalled = true,
      );

      // Register plugin
      registry.registerPlugin(testPlugin);
      expect(installed, isTrue);
      expect(registry.plugins.length, equals(2));
      expect(registry.hasPlugin('expansion.abyssal_trench'), isTrue);

      // Verify aggregated catalog contains new expansion assets
      expect(registry.allCompanions.length, equals(11));
      expect(registry.findCompanion('giant_squid'), isNotNull);
      expect(registry.findBiome('hydrothermal_vents'), isNotNull);

      // Duplicate registration throws ArgumentError
      expect(() => registry.registerPlugin(testPlugin), throwsArgumentError);

      // Unregister plugin
      final removed = registry.unregisterPlugin('expansion.abyssal_trench');
      expect(removed, isTrue);
      expect(uninstalled, isTrue);
      expect(registry.plugins.length, equals(1));
      expect(registry.findCompanion('giant_squid'), isNull);
    });
  });
}

class _FakeMonetizationNotifier extends MonetizationNotifier {
  final bool isPro;

  _FakeMonetizationNotifier({required this.isPro});

  @override
  MonetizationState build() {
    return MonetizationState(
      subscription: UserSubscription(
        userId: 'test_user',
        tier: isPro ? SubscriptionTier.proAnnual : SubscriptionTier.free,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
      ),
      entitlements: isPro
          ? [
              UserEntitlement(
                sku: 'pack_neon_bioluminescence',
                kind: EntitlementKind.animationPack,
                grantedAt: DateTime.now(),
              ),
              UserEntitlement(
                sku: 'pack_minimal_zen',
                kind: EntitlementKind.themePack,
                grantedAt: DateTime.now(),
              ),
              UserEntitlement(
                sku: 'pack_cyber_ocean',
                kind: EntitlementKind.themePack,
                grantedAt: DateTime.now(),
              ),
            ]
          : const [],
    );
  }
}
