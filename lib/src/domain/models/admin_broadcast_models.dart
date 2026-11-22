import 'package:flutter/foundation.dart';

/// Contextual category for broadcast push announcements.
enum BroadcastCategory {
  announcement,
  challenge,
  community,
  urgent,
  promotion;

  String get displayName {
    switch (this) {
      case announcement:
        return 'Feature Announcement';
      case challenge:
        return 'Hydration Challenge';
      case community:
        return 'Sanctuary Community';
      case urgent:
        return 'Urgent Alert';
      case promotion:
        return 'Special Promotion';
    }
  }

  static BroadcastCategory fromString(String? value) {
    return BroadcastCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => BroadcastCategory.announcement,
    );
  }
}

/// Target recipient segment for administrative notifications.
enum BroadcastTargetAudience {
  allUsers,
  freeUsersOnly,
  proUsersOnly,
  dormantUsers,
  highStreakUsers;

  String get displayName {
    switch (this) {
      case allUsers:
        return 'All Registered Users';
      case freeUsersOnly:
        return 'Free Tier Users';
      case proUsersOnly:
        return 'AquaWild Pro Members';
      case dormantUsers:
        return 'Dormant Users (Inactive > 7 Days)';
      case highStreakUsers:
        return 'Habit Masters (Streak >= 7 Days)';
    }
  }

  static BroadcastTargetAudience fromString(String? value) {
    return BroadcastTargetAudience.values.firstWhere(
      (e) => e.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => BroadcastTargetAudience.allUsers,
    );
  }
}

/// Administrative push notification announcement.
@immutable
class AdminBroadcastMessage {
  final String id;
  final String title;
  final String body;
  final BroadcastCategory category;
  final BroadcastTargetAudience targetAudience;
  final String actionRoute;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final bool isSent;
  final int totalRecipients;
  final DateTime createdAt;

  const AdminBroadcastMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.targetAudience,
    this.actionRoute = '/home',
    this.scheduledAt,
    this.sentAt,
    this.isSent = false,
    this.totalRecipients = 0,
    required this.createdAt,
  });

  AdminBroadcastMessage copyWith({
    String? id,
    String? title,
    String? body,
    BroadcastCategory? category,
    BroadcastTargetAudience? targetAudience,
    String? actionRoute,
    DateTime? scheduledAt,
    DateTime? sentAt,
    bool? isSent,
    int? totalRecipients,
    DateTime? createdAt,
  }) {
    return AdminBroadcastMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      targetAudience: targetAudience ?? this.targetAudience,
      actionRoute: actionRoute ?? this.actionRoute,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      isSent: isSent ?? this.isSent,
      totalRecipients: totalRecipients ?? this.totalRecipients,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category.name,
      'targetAudience': targetAudience.name,
      'actionRoute': actionRoute,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'isSent': isSent,
      'totalRecipients': totalRecipients,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AdminBroadcastMessage.fromMap(Map<String, dynamic> map) {
    return AdminBroadcastMessage(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Notification',
      body: map['body'] as String? ?? '',
      category: BroadcastCategory.fromString(map['category'] as String?),
      targetAudience:
          BroadcastTargetAudience.fromString(map['targetAudience'] as String?),
      actionRoute: map['actionRoute'] as String? ?? '/home',
      scheduledAt: map['scheduledAt'] != null
          ? DateTime.tryParse(map['scheduledAt'] as String)
          : null,
      sentAt: map['sentAt'] != null
          ? DateTime.tryParse(map['sentAt'] as String)
          : null,
      isSent: map['isSent'] as bool? ?? false,
      totalRecipients: (map['totalRecipients'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Default mock broadcast history for initial administrative display.
  static List<AdminBroadcastMessage> get defaultHistory => [
        AdminBroadcastMessage(
          id: 'bc_001',
          title: '🌸 Spring Bloom Hydration Challenge is Live!',
          body:
              'Unlock exclusive cherry blossom water ripples and earn double XP all weekend with your active companion.',
          category: BroadcastCategory.challenge,
          targetAudience: BroadcastTargetAudience.allUsers,
          actionRoute: '/home',
          isSent: true,
          sentAt: DateTime.now().subtract(const Duration(days: 2)),
          totalRecipients: 12450,
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
        ),
        AdminBroadcastMessage(
          id: 'bc_002',
          title: '✨ Meet Barnaby the Capybara in Bamboo Springs!',
          body:
              'Our latest exotic animal companion has arrived with thermal hot spring relaxation animations.',
          category: BroadcastCategory.announcement,
          targetAudience: BroadcastTargetAudience.freeUsersOnly,
          actionRoute: '/companions',
          isSent: true,
          sentAt: DateTime.now().subtract(const Duration(days: 5)),
          totalRecipients: 8630,
          createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
        ),
        AdminBroadcastMessage(
          id: 'bc_003',
          title: '🌊 Weekend Habitat Rehydration Reminder',
          body:
              'Keep your sanctuary flourishing! Log a fresh pour today to protect your active streak.',
          category: BroadcastCategory.community,
          targetAudience: BroadcastTargetAudience.dormantUsers,
          actionRoute: '/home',
          isSent: false,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          totalRecipients: 1420,
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ];
}
