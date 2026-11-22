import 'package:aquawild/src/domain/models/admin_analytics_models.dart';
import 'package:aquawild/src/domain/models/admin_audit_models.dart';
import 'package:aquawild/src/domain/models/admin_broadcast_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin Audit, Analytics & Broadcast Domain Models Tests', () {
    test('AdminAuditEntry hash computation and cryptographic integrity', () {
      final now = DateTime(2026, 11, 22, 12, 0);
      const prevHash = AdminAuditEntry.genesisHash;
      const id = 'audit_test_101';

      final hash = AdminAuditEntry.computeHash(
        previousEntryHash: prevHash,
        id: id,
        timestamp: now,
        operatorId: 'operator_root',
        actionType: AdminActionType.godModeToggled,
        targetEntityId: 'god_mode',
        description: 'Activated God Mode for testing',
        previousValue: 'disabled',
        newValue: 'enabled',
      );

      expect(hash.length, equals(64)); // SHA-256 hex string

      final entry = AdminAuditEntry(
        id: id,
        timestamp: now,
        operatorId: 'operator_root',
        operatorEmail: 'daya@aquawild.internal',
        actionType: AdminActionType.godModeToggled,
        targetEntityId: 'god_mode',
        description: 'Activated God Mode for testing',
        previousValue: 'disabled',
        newValue: 'enabled',
        previousEntryHash: prevHash,
        entryHash: hash,
      );

      // Verify intact entry passes integrity
      expect(entry.verifyIntegrity(), isTrue);

      // If description or any field is tampered with, integrity check fails
      final tampered = entry.copyWith(description: 'Tampered description');
      expect(tampered.verifyIntegrity(), isFalse);
    });

    test('AdminAuditEntry JSON serialization round-trips cleanly', () {
      final now = DateTime(2026, 11, 22, 12, 0);
      final entry = AdminAuditEntry(
        id: 'audit_test_202',
        timestamp: now,
        operatorId: 'operator_daya',
        operatorEmail: 'daya@aquawild.internal',
        actionType: AdminActionType.userXpAdjusted,
        targetEntityId: 'usr_alex_02',
        description: 'Awarded 500 XP to Alex',
        previousValue: '4800 XP',
        newValue: '5300 XP',
        previousEntryHash: AdminAuditEntry.genesisHash,
        entryHash: 'mock_hash_123',
      );

      final map = entry.toMap();
      final restored = AdminAuditEntry.fromMap(map);

      expect(restored.id, equals(entry.id));
      expect(restored.actionType, equals(AdminActionType.userXpAdjusted));
      expect(restored.targetEntityId, equals('usr_alex_02'));
      expect(restored.previousValue, equals('4800 XP'));
      expect(restored.newValue, equals('5300 XP'));
      expect(restored.entryHash, equals('mock_hash_123'));
    });

    test('AuditVerificationResult constructors', () {
      final valid = AuditVerificationResult.valid(25);
      expect(valid.isValid, isTrue);
      expect(valid.totalEntriesChecked, equals(25));
      expect(valid.compromisedIndex, isNull);

      final compromised = AuditVerificationResult.compromised(
        index: 4,
        entryId: 'audit_corrupt_4',
        totalChecked: 4,
        reason: 'Payload mismatch',
      );
      expect(compromised.isValid, isFalse);
      expect(compromised.compromisedIndex, equals(4));
      expect(compromised.compromisedEntryId, equals('audit_corrupt_4'));
    });

    test('MonetizationKpiSummary formatting, ARPU and Pro penetration metrics', () {
      final kpis = MonetizationKpiSummary.defaultBaseline;

      expect(kpis.formattedMrr, equals('\$14890.00'));
      expect(kpis.formattedArr, equals('\$178680.00'));
      expect(kpis.formattedArpu, equals('\$7.59'));
      expect(kpis.formattedGross, equals('\$94520.00'));

      expect(kpis.proPenetrationPercent, closeTo(30.68, 0.1));
      expect(kpis.skuBreakdown.length, equals(5));

      final map = kpis.toMap();
      final restored = MonetizationKpiSummary.fromMap(map);
      expect(restored.totalUsersCount, equals(12450));
      expect(restored.monthlyRecurringRevenueUsd, equals(14890.0));
      expect(restored.skuBreakdown.length, equals(5));
    });

    test('AdminBroadcastMessage audience parsing, categories and serialization', () {
      expect(
        BroadcastCategory.fromString('challenge'),
        equals(BroadcastCategory.challenge),
      );
      expect(
        BroadcastCategory.fromString('unknown'),
        equals(BroadcastCategory.announcement),
      );

      expect(
        BroadcastTargetAudience.fromString('proUsersOnly'),
        equals(BroadcastTargetAudience.proUsersOnly),
      );
      expect(
        BroadcastTargetAudience.fromString('dormantUsers'),
        equals(BroadcastTargetAudience.dormantUsers),
      );
      expect(
        BroadcastTargetAudience.fromString(null),
        equals(BroadcastTargetAudience.allUsers),
      );

      final history = AdminBroadcastMessage.defaultHistory;
      expect(history.length, greaterThanOrEqualTo(2));

      final first = history.first;
      expect(first.isSent, isTrue);
      expect(first.totalRecipients, greaterThan(0));

      final map = first.toMap();
      final restored = AdminBroadcastMessage.fromMap(map);
      expect(restored.id, equals(first.id));
      expect(restored.title, equals(first.title));
      expect(restored.category, equals(first.category));
      expect(restored.targetAudience, equals(first.targetAudience));
    });
  });
}
