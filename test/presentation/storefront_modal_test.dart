import 'package:aquawild/src/data/repositories/local_monetization_repository.dart';
import 'package:aquawild/src/data/repositories/monetization_repository.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/monetization_models.dart';
import 'package:aquawild/src/presentation/widgets/biomes/biome_companion_selector_sheet.dart';
import 'package:aquawild/src/presentation/widgets/monetization/premium_storefront_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late MonetizationRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    repo = LocalMonetizationRepository(prefs);
  });

  group('PremiumStorefrontModal Widget Tests', () {
    testWidgets('mounts cleanly and displays subscription plans and comparison table',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PremiumStorefrontModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header & title
      expect(find.text('AquaWild Store'), findsOneWidget);
      expect(find.text('UNLIMITED SANCTUARY ACCESS'), findsOneWidget);

      // Verify subscription plans
      expect(find.text('Annual Pass'), findsOneWidget);
      expect(find.text('Monthly Pass'), findsOneWidget);
      expect(find.text('Lifetime Sanctuary Access'), findsOneWidget);
      expect(find.text('Unlock AquaWild Pro Now'), findsOneWidget);

      // Verify comparison table
      expect(find.text('AquaWild Free vs Pro Comparison'), findsOneWidget);
      expect(find.text('10 Exotic Companions'), findsOneWidget);
      expect(find.text('Living Biomes (6)'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
    });

    testWidgets('allows selecting plans and subscribing to AquaWild Pro',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PremiumStorefrontModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Monthly Pass radio card
      await tester.tap(find.text('Monthly Pass'));
      await tester.pumpAndSettle();

      // Tap Subscribe
      final btnFinder = find.widgetWithText(ElevatedButton, 'Unlock AquaWild Pro Now');
      await tester.tap(btnFinder);
      await tester.pumpAndSettle();

      // Verify Pro is now active
      expect(find.text('PRO ACTIVE'), findsOneWidget);
      expect(find.text('CURRENT'), findsOneWidget);
    });

    testWidgets('displays packs & passes tab with one-time IAP products',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PremiumStorefrontModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Packs & Passes tab
      await tester.tap(find.text('Packs & Passes'));
      await tester.pumpAndSettle();

      // Verify one-time packs
      expect(find.text('Deep Sea Legends Pack'), findsOneWidget);
      expect(find.text('Alpine Glacier Expedition Pack'), findsOneWidget);
      expect(find.text('Neon Bioluminescence FX Pack'), findsOneWidget);
      expect(find.text('Minimal Zen Theme Pack'), findsOneWidget);
      expect(find.text('Cyber Ocean Synthwave Pack'), findsOneWidget);
      expect(find.text('Summer Splash Expedition Pass'), findsOneWidget);

      // Purchase Deep Sea Legends Pack
      final purchaseButtons = find.widgetWithText(ElevatedButton, 'Purchase');
      expect(purchaseButtons, findsWidgets);

      await tester.tap(purchaseButtons.first);
      await tester.pumpAndSettle();

      // First pack should now show OWNED
      expect(find.text('OWNED'), findsWidgets);
    });

    testWidgets('triggers restore purchases flow cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PremiumStorefrontModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Restore Purchases
      await tester.tap(find.text('Restore Purchases'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Purchases successfully restored.'), findsOneWidget);
    });
  });

  group('BiomeCompanionSelectorSheet Dual-Path Unlock Tests', () {
    testWidgets('shows Pro upgrade banner and dual-path unlock dialog for locked companions',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: BiomeCompanionSelectorSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Pro promotional banner at top of companions tab
      expect(find.text('Unlock All 10 Companions with Pro'), findsOneWidget);
      expect(find.text('UPGRADE'), findsOneWidget);

      // Verify locked companion (Ollie the Sea Otter) has lock button
      final seaOtter = ExoticAnimal.findById('sea_otter');
      final lockButtonFinder = find.text('🔒 ${seaOtter.unlockXp} XP');
      expect(lockButtonFinder, findsOneWidget);

      // Tap locked sea otter button
      await tester.tap(lockButtonFinder);
      await tester.pumpAndSettle();

      // Verify Dual-Path Unlock Dialog mounts
      expect(find.text('Path A: Earn with Hydration'), findsOneWidget);
      expect(find.text('Path B: Instant Unlock'), findsOneWidget);
      expect(find.text('Open Store'), findsOneWidget);

      // Verify matching pack option (Deep Sea Legends pack)
      expect(find.textContaining('Deep Sea Legends Pack'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping UPGRADE banner opens PremiumStorefrontModal',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: BiomeCompanionSelectorSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap UPGRADE banner
      await tester.tap(find.text('UPGRADE'));
      await tester.pumpAndSettle();

      // Verify PremiumStorefrontModal is opened
      expect(find.byType(PremiumStorefrontModal), findsOneWidget);
      expect(find.text('AquaWild Store'), findsOneWidget);
    });

    testWidgets('when user becomes Pro, all companions immediately show Select button',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Grant Pro subscription in repo
      await repo.saveSubscription(
        UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.proAnnual,
          status: SubscriptionStatus.active,
          startedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: BiomeCompanionSelectorSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // With Pro active, UPGRADE banner should not be present
      expect(find.text('Unlock All 10 Companions with Pro'), findsNothing);

      // Zero locked companions: all unlocked companions display 'Select'
      expect(find.textContaining('🔒'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Select'), findsWidgets);
    });
  });
}
