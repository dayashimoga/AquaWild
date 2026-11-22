import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/admin_broadcast_models.dart';
import '../../domain/models/admin_portal_models.dart';

/// Service managing administrative notification broadcasts and campaigns.
class AdminNotificationBroadcastService {
  final SharedPreferences? _prefs;
  static const String _storageKey = 'aquawild_admin_broadcasts_v1';

  final List<AdminBroadcastMessage> _broadcasts = [];

  AdminNotificationBroadcastService({SharedPreferences? prefs})
      : _prefs = prefs {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    if (_prefs == null) {
      _broadcasts.addAll(AdminBroadcastMessage.defaultHistory);
      return;
    }
    final jsonList = _prefs.getStringList(_storageKey);
    if (jsonList != null && jsonList.isNotEmpty) {
      for (final raw in jsonList) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          _broadcasts.add(AdminBroadcastMessage.fromMap(map));
        } catch (_) {
          // Ignore corrupted entries
        }
      }
    } else {
      _broadcasts.addAll(AdminBroadcastMessage.defaultHistory);
    }
  }

  Future<void> _persistToStorage() async {
    if (_prefs == null) return;
    final serialized =
        _broadcasts.map((b) => jsonEncode(b.toMap())).toList();
    await _prefs.setStringList(_storageKey, serialized);
  }

  /// Composes and immediately dispatches a push notification to the target audience.
  Future<AdminBroadcastMessage> dispatchImmediate({
    required String title,
    required String body,
    required BroadcastCategory category,
    required BroadcastTargetAudience targetAudience,
    String actionRoute = '/home',
    required List<AdminUserProfile> userDirectory,
  }) async {
    final now = DateTime.now();
    final id = 'bc_${now.millisecondsSinceEpoch}';

    // Calculate audience recipients
    final recipients = _calculateRecipients(targetAudience, userDirectory);

    final broadcast = AdminBroadcastMessage(
      id: id,
      title: title,
      body: body,
      category: category,
      targetAudience: targetAudience,
      actionRoute: actionRoute,
      sentAt: now,
      isSent: true,
      totalRecipients: recipients,
      createdAt: now,
    );

    _broadcasts.insert(0, broadcast);
    await _persistToStorage();
    return broadcast;
  }

  /// Schedules a future broadcast campaign.
  Future<AdminBroadcastMessage> scheduleBroadcast({
    required String title,
    required String body,
    required BroadcastCategory category,
    required BroadcastTargetAudience targetAudience,
    required DateTime scheduledAt,
    String actionRoute = '/home',
    required List<AdminUserProfile> userDirectory,
  }) async {
    final now = DateTime.now();
    final id = 'bc_sched_${now.millisecondsSinceEpoch}';
    final recipients = _calculateRecipients(targetAudience, userDirectory);

    final broadcast = AdminBroadcastMessage(
      id: id,
      title: title,
      body: body,
      category: category,
      targetAudience: targetAudience,
      actionRoute: actionRoute,
      scheduledAt: scheduledAt,
      isSent: false,
      totalRecipients: recipients,
      createdAt: now,
    );

    _broadcasts.insert(0, broadcast);
    await _persistToStorage();
    return broadcast;
  }

  /// Cancels a scheduled broadcast before its trigger time.
  Future<bool> cancelScheduled(String broadcastId) async {
    final index = _broadcasts.indexWhere((b) => b.id == broadcastId);
    if (index >= 0 && !_broadcasts[index].isSent) {
      _broadcasts.removeAt(index);
      await _persistToStorage();
      return true;
    }
    return false;
  }

  /// Returns list of broadcast messages with optional category filter.
  List<AdminBroadcastMessage> getBroadcasts({
    BroadcastCategory? category,
    bool? isSent,
  }) {
    Iterable<AdminBroadcastMessage> list = _broadcasts;
    if (category != null) {
      list = list.where((b) => b.category == category);
    }
    if (isSent != null) {
      list = list.where((b) => b.isSent == isSent);
    }
    return list.toList();
  }

  int _calculateRecipients(
    BroadcastTargetAudience audience,
    List<AdminUserProfile> users,
  ) {
    if (users.isEmpty) return 1000;
    switch (audience) {
      case BroadcastTargetAudience.allUsers:
        return users.length;
      case BroadcastTargetAudience.freeUsersOnly:
        return users.where((u) => !u.isPro).length;
      case BroadcastTargetAudience.proUsersOnly:
        return users.where((u) => u.isPro).length;
      case BroadcastTargetAudience.dormantUsers:
        final cutoff = DateTime.now().subtract(const Duration(days: 7));
        return users.where((u) => u.lastActiveAt.isBefore(cutoff)).length;
      case BroadcastTargetAudience.highStreakUsers:
        return users.where((u) => u.streakCount >= 7).length;
    }
  }

  /// Total count of broadcasts.
  int get totalCount => _broadcasts.length;
}

/// Riverpod provider for the Admin Notification Broadcast Service.
final adminNotificationBroadcastServiceProvider =
    Provider<AdminNotificationBroadcastService>((ref) {
  return AdminNotificationBroadcastService();
});
