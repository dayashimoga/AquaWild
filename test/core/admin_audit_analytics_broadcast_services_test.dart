import 'package:aquawild/src/core/services/admin_audit_log_service.dart';
import 'package:aquawild/src/core/services/admin_broadcast_service.dart';
import 'package:aquawild/src/core/services/admin_monetization_analytics_service.dart';
import 'package:aquawild/src/domain/models/admin_audit_models.dart';
import 'package:aquawild/src/domain/models/admin_broadcast_models.dart';
import 'package:aquawild/src/domain/models/admin_portal_models.dart';
import 'package:aquawild/src/domain/models/monetization_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin Services Unit Tests', () {
    test('AdminAuditLogService appends hash-chained entries and verifies cryptographic integrity', () async {
      final service = AdminAuditLogService();
      service.clearMemoryForTest();

      expect(service.totalEntriesCount, equals(0));

      // 1. Record first entry (linked to genesis)
      final e1 = await service.recordAction(
        operatorId: 'operator_1',
        operatorEmail: 'daya@aquawild.internal',
        actionType: AdminActionType.godModeToggled,
        targetEntityId: 'god_mode',
        description: 'First action',
      );

      expect(e1.previousEntryHash, equals(AdminAuditEntry.genesisHash));
      expect(service.totalEntriesCount, equals(1));

      // 2. Record second entry (linked to e1)
      final e2 = await service.recordAction(
        operatorId: 'operator_1',
        operatorEmail: 'daya@aquawild.internal',
        actionType: AdminActionType.beverageCreated,
        targetEntityId: 'matcha_smoothie',
        description: 'Second action',
      );

      expect(e2.previousEntryHash, equals(e1.entryHash));
      expect(service.totalEntriesCount, equals(2));

      // 3. Record third entry (linked to e2)
      final e3 = await service.recordAction(
        operatorId: 'operator_2',
        operatorEmail: 'alex@aquawild.internal',
        actionType: AdminActionType.userXpAdjusted,
        targetEntityId: 'usr_sam_03',
        description: 'Third action',
      );

      expect(e3.previousEntryHash, equals(e2.entryHash));
      expect(service.totalEntriesCount, equals(3));

      // 4. Verify unbroken chain passes integrity
      final verification = service.verifyTrailIntegrity();
      expect(verification.isValid, isTrue);
      expect(verification.totalEntriesChecked, equals(3));

      // 5. Test filtering
      final byAction = service.getEntries(filterAction: AdminActionType.beverageCreated);
      expect(byAction.length, equals(1));
      expect(byAction.first.targetEntityId, equals('matcha_smoothie'));

      final byOperator = service.getEntries(operatorFilter: 'alex');
      expect(byOperator.length, equals(1));
      expect(byOperator.first.operatorId, equals('operator_2'));
    });

    test('AdminMonetizationTelemetryService computes ARR, MRR, ARPU and SKU breakdowns', () {
      const service = AdminMonetizationTelemetryService();
      final users = AdminUserProfile.defaultSeedUsers;

      final sub = UserSubscription(
        userId: 'local_user',
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
      );

      final kpis = service.calculateKpis(
        users: users,
        products: ProductSKU.catalog,
        activeLocalSubscription: sub,
      );

      expect(kpis.totalUsersCount, equals(users.length));
      expect(kpis.activeProUsersCount, greaterThan(0));
      expect(kpis.monthlyRecurringRevenueUsd, greaterThan(0.0));
      expect(kpis.annualRecurringRevenueUsd, equals(kpis.monthlyRecurringRevenueUsd * 12.0));
      expect(kpis.skuBreakdown.length, equals(ProductSKU.catalog.length));
    });

    test('AdminNotificationBroadcastService dispatches immediate, schedules and cancels broadcasts', () async {
      final service = AdminNotificationBroadcastService();
      final initialCount = service.totalCount;

      final users = AdminUserProfile.defaultSeedUsers;

      // 1. Dispatch immediate broadcast
      final dispatched = await service.dispatchImmediate(
        title: 'Immediate Hydro Alert',
        body: 'Hydrate now for active habitat health!',
        category: BroadcastCategory.urgent,
        targetAudience: BroadcastTargetAudience.allUsers,
        actionRoute: '/home',
        userDirectory: users,
      );

      expect(dispatched.isSent, isTrue);
      expect(dispatched.totalRecipients, equals(users.length));
      expect(service.totalCount, equals(initialCount + 1));

      // 2. Schedule future broadcast
      final futureTime = DateTime.now().add(const Duration(days: 3));
      final scheduled = await service.scheduleBroadcast(
        title: 'Scheduled Weekend Splash',
        body: 'Weekend double XP starting soon!',
        category: BroadcastCategory.challenge,
        targetAudience: BroadcastTargetAudience.freeUsersOnly,
        scheduledAt: futureTime,
        userDirectory: users,
      );

      expect(scheduled.isSent, isFalse);
      expect(scheduled.scheduledAt, equals(futureTime));
      expect(service.totalCount, equals(initialCount + 2));

      // 3. Cancel scheduled broadcast
      final cancelled = await service.cancelScheduled(scheduled.id);
      expect(cancelled, isTrue);
      expect(service.totalCount, equals(initialCount + 1));

      // Cannot cancel already sent broadcast
      final cancelSent = await service.cancelScheduled(dispatched.id);
      expect(cancelSent, isFalse);
    });
  });
}
