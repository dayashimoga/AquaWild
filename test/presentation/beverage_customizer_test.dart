import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/presentation/widgets/beverages/beverage_customizer_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BeverageCustomizer & Dynamic Beverage Registry Tests', () {
    test('Can register and lookup custom handcrafted beverages in BeverageType', () {
      const customBev = BeverageType(
        id: 'custom_boba_milk_tea',
        name: 'Boba Milk Tea',
        category: BeverageCategory.dairy,
        hydrationIndex: 0.88,
        caffeineMgPer100ml: 25.0,
        electrolytesMgPer100ml: 40.0,
        sugarGramsPer100ml: 12.0,
        density: 1.06,
        viscosity: 0.05,
        primaryColor: Color(0xFF8D6E63),
        secondaryColor: Color(0xFF6D4C41),
        gradientColors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
        presetVolumesMl: [450, 700],
        description: 'Chewy tapioca pearls in brown sugar black milk tea.',
      );

      BeverageType.registerCustom(customBev);

      expect(BeverageType.allBeverages.contains(customBev), isTrue);
      expect(BeverageType.findById('custom_boba_milk_tea'), equals(customBev));
      expect(customBev.calculateNetHydration(500), greaterThan(0));

      // Cleanup
      BeverageType.removeCustom('custom_boba_milk_tea');
    });

    testWidgets('BeverageCustomizerModal mounts and renders all parameter controls',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BeverageCustomizerModal(),
            ),
          ),
        ),
      );

      expect(find.text('Custom Beverage Studio'), findsOneWidget);
      expect(find.text('Beverage Name'), findsOneWidget);
      expect(find.text('Bioavailability Index'), findsOneWidget);
      expect(find.text('Caffeine per 100ml'), findsOneWidget);
      expect(find.text('Electrolytes per 100ml'), findsOneWidget);
      expect(find.text('Fluid Theme Color'), findsOneWidget);

      final craftBtn = find.textContaining('Craft & Log');
      await tester.ensureVisible(craftBtn);
      expect(craftBtn, findsOneWidget);

      // Tap craft button to craft and log
      await tester.tap(craftBtn);
      await tester.pump();
    });
  });
}
