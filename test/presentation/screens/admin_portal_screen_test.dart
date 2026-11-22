import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquawild/src/presentation/screens/admin/admin_portal_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableAdminPortal({
    Size screenSize = const Size(1200, 900),
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: const AdminPortalScreen(),
        ),
      ),
    );
  }

  group('AdminPortalScreen Desktop & Tablet Interface Tests', () {
    testWidgets('mounts cleanly and displays Mission Control brand & sidebar tabs',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestableAdminPortal());
      await tester.pumpAndSettle();

      // Mission Control title and Admin badge
      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.text('AquaWild Mission Control'), findsOneWidget);

      // Environment chip
      expect(find.text('DEVELOPMENT'), findsOneWidget);

      // Desktop sidebar tabs
      expect(find.text('KPI Overview'), findsOneWidget);
      expect(find.text('God Mode'), findsOneWidget);
      expect(find.text('User Directory'), findsOneWidget);
      expect(find.text('Content Catalog'), findsOneWidget);
      expect(find.text('Feature Flags'), findsOneWidget);
      expect(find.text('Environment'), findsOneWidget);
      expect(find.text('Audit Trail'), findsOneWidget);
      expect(find.text('Broadcasts'), findsOneWidget);

      // Default view is KPI overview
      expect(find.text('Financial & Monetization Telemetry'), findsOneWidget);
      expect(find.text('Monthly Recurring Revenue (MRR)'), findsOneWidget);
    });

    testWidgets('switches to God Mode tab and toggles Master God Mode',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestableAdminPortal());
      await tester.pumpAndSettle();

      // Tap God Mode tab in sidebar
      await tester.tap(find.text('God Mode'));
      await tester.pumpAndSettle();

      expect(find.text('Master God Mode Override'), findsOneWidget);
      expect(find.text('Individual Subsystem Overrides'), findsOneWidget);

      // Initially god mode indicator is not in app bar
      expect(find.text('GOD MODE'), findsNothing);

      // Find the first switch (Master God Mode) and toggle it
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // App bar should now display GOD MODE indicator badge
      expect(find.text('GOD MODE'), findsOneWidget);
    });

    testWidgets('switches to User Directory tab, filters users, and opens edit dialog',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestableAdminPortal());
      await tester.pumpAndSettle();

      // Tap User Directory tab
      await tester.tap(find.text('User Directory'));
      await tester.pumpAndSettle();

      expect(find.text('Search users by name, email, or user ID...'), findsOneWidget);
      expect(find.text('Daya (System Architect)'), findsOneWidget);
      expect(find.text('Alex Rivera'), findsOneWidget);

      // Type in search filter
      await tester.enterText(find.byType(TextField).first, 'Daya');
      await tester.pumpAndSettle();

      expect(find.text('Daya (System Architect)'), findsOneWidget);
      expect(find.text('Alex Rivera'), findsNothing);

      // Clear search
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(find.text('Alex Rivera'), findsOneWidget);
    });

    testWidgets('switches to Content Catalog and toggles between Beverages and Animals',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestableAdminPortal());
      await tester.pumpAndSettle();

      // Tap Content Catalog tab
      await tester.tap(find.text('Content Catalog'));
      await tester.pumpAndSettle();

      expect(find.text('Beverages Catalog'), findsOneWidget);
      expect(find.text('Animal Companions'), findsOneWidget);

      // Default sub-tab is Beverages
      expect(find.text('Pure Spring Water'), findsOneWidget);

      // Tap Animal Companions sub-tab
      await tester.tap(find.text('Animal Companions'));
      await tester.pumpAndSettle();

      expect(find.text('Ruby the Red Panda'), findsOneWidget);
    });

    testWidgets('switches to Feature Flags tab and toggles flag switch',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestableAdminPortal());
      await tester.pumpAndSettle();

      // Tap Feature Flags tab
      await tester.tap(find.text('Feature Flags'));
      await tester.pumpAndSettle();

      expect(find.text('High-Precision Wave Physics'), findsOneWidget);
      expect(find.text('Key: enable_high_precision_waves'), findsOneWidget);

      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
    });

    testWidgets('switches to Environment tab and changes active target',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestableAdminPortal());
      await tester.pumpAndSettle();

      // Tap Environment tab
      await tester.tap(find.text('Environment'));
      await tester.pumpAndSettle();

      expect(find.text('Target Backend Environment Configuration'), findsOneWidget);
      expect(find.text('DEVELOPMENT'), findsWidgets);
      expect(find.text('STAGING'), findsOneWidget);
      expect(find.text('PRODUCTION'), findsOneWidget);

      // Tap Staging environment card
      await tester.tap(find.text('STAGING'));
      await tester.pumpAndSettle();

      // App bar should now reflect STAGING
      expect(find.text('STAGING'), findsWidgets);
    });

    testWidgets('switches to Audit Trail tab and runs cryptographic verification',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestableAdminPortal());
      await tester.pumpAndSettle();

      // Tap Audit Trail tab
      await tester.tap(find.text('Audit Trail'));
      await tester.pumpAndSettle();

      expect(find.text('Audit Chain Intact & Cryptographically Verified'), findsOneWidget);
      expect(find.text('Verify Chain'), findsOneWidget);

      // Tap Verify Chain button
      await tester.tap(find.text('Verify Chain'));
      await tester.pumpAndSettle();

      // SnackBar verification confirmation
      expect(find.textContaining('✅ Verified'), findsOneWidget);
    });

    testWidgets('switches to Broadcasts tab, fills message, and sends immediately',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestableAdminPortal());
      await tester.pumpAndSettle();

      // Tap Broadcasts tab
      await tester.tap(find.text('Broadcasts'));
      await tester.pumpAndSettle();

      expect(find.text('Compose Notification Broadcast'), findsOneWidget);
      expect(find.text('Broadcast Dispatches & History'), findsOneWidget);

      // Enter Title & Body
      await tester.enterText(find.byType(TextField).first, 'Spring Challenge');
      await tester.enterText(find.byType(TextField).at(1), 'Stay hydrated and unlock bonuses!');
      await tester.pumpAndSettle();

      // Tap Send Immediately
      await tester.tap(find.text('Send Immediately'));
      await tester.pumpAndSettle();

      // Broadcast history should contain new broadcast
      expect(find.text('Spring Challenge'), findsOneWidget);
    });
  });

  group('AdminPortalScreen Mobile Responsive Layout Tests', () {
    testWidgets('renders horizontal choice chips tab bar on mobile viewport',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestableAdminPortal(
        screenSize: const Size(400, 800),
      ));
      await tester.pumpAndSettle();

      // Mobile should show ChoiceChip tabs in horizontal bar
      expect(find.byType(ChoiceChip), findsWidgets);
      expect(find.text('KPI Overview'), findsOneWidget);

      // Tap God Mode ChoiceChip
      await tester.tap(find.text('God Mode'));
      await tester.pumpAndSettle();

      expect(find.text('Master God Mode Override'), findsOneWidget);
    });
  });
}
