import 'package:flutter/foundation.dart';

/// Interactive action button attached to a system notification
@immutable
class NotificationAction {
  final String id;
  final String title;
  final String? icon;
  final bool isDestructive;
  final bool isForeground;

  const NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.isDestructive = false,
    this.isForeground = false,
  });

  // Standard predefined notification action IDs and instances
  static const String idLog250Ml = 'action_log_250_ml';
  static const String idLog500Ml = 'action_log_500_ml';
  static const String idSnooze30Min = 'action_snooze_30_min';
  static const String idViewSanctuary = 'action_view_sanctuary';

  static const NotificationAction actionLog250Ml = NotificationAction(
    id: idLog250Ml,
    title: '+250ml Water 💧',
    icon: 'water_drop',
    isForeground: false,
  );

  static const NotificationAction actionLog500Ml = NotificationAction(
    id: idLog500Ml,
    title: '+500ml Water ⚡',
    icon: 'local_drink',
    isForeground: false,
  );

  static const NotificationAction actionSnooze30Min = NotificationAction(
    id: idSnooze30Min,
    title: 'Snooze 30m ⏰',
    icon: 'snooze',
    isForeground: false,
  );

  static const NotificationAction actionViewSanctuary = NotificationAction(
    id: idViewSanctuary,
    title: 'Sanctuary 🐾',
    icon: 'pets',
    isForeground: true,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'icon': icon,
        'isDestructive': isDestructive,
        'isForeground': isForeground,
      };

  factory NotificationAction.fromJson(Map<String, dynamic> json) =>
      NotificationAction(
        id: json['id'] as String,
        title: json['title'] as String,
        icon: json['icon'] as String?,
        isDestructive: json['isDestructive'] as bool? ?? false,
        isForeground: json['isForeground'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationAction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}

/// Rich, interactive notification payload tailored for out-of-app engagement
@immutable
class RichNotificationPayload {
  final String id;
  final String channelId;
  final String title;
  final String subtitle;
  final String body;
  final String companionQuote;
  final String companionEmoji;
  final String companionName;
  final int badgeNumber;
  final List<NotificationAction> actions;
  final Map<String, dynamic> data;
  final String category;
  final DateTime? scheduledTime;
  final bool isGoalCompleted;

  const RichNotificationPayload({
    required this.id,
    this.channelId = 'aquawild_hydration_channel',
    required this.title,
    required this.subtitle,
    required this.body,
    required this.companionQuote,
    required this.companionEmoji,
    required this.companionName,
    this.badgeNumber = 1,
    required this.actions,
    required this.data,
    this.category = 'hydration_reminder',
    this.scheduledTime,
    this.isGoalCompleted = false,
  });

  RichNotificationPayload copyWith({
    String? id,
    String? channelId,
    String? title,
    String? subtitle,
    String? body,
    String? companionQuote,
    String? companionEmoji,
    String? companionName,
    int? badgeNumber,
    List<NotificationAction>? actions,
    Map<String, dynamic>? data,
    String? category,
    DateTime? scheduledTime,
    bool? isGoalCompleted,
  }) {
    return RichNotificationPayload(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      body: body ?? this.body,
      companionQuote: companionQuote ?? this.companionQuote,
      companionEmoji: companionEmoji ?? this.companionEmoji,
      companionName: companionName ?? this.companionName,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      actions: actions ?? this.actions,
      data: data ?? this.data,
      category: category ?? this.category,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isGoalCompleted: isGoalCompleted ?? this.isGoalCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'channelId': channelId,
        'title': title,
        'subtitle': subtitle,
        'body': body,
        'companionQuote': companionQuote,
        'companionEmoji': companionEmoji,
        'companionName': companionName,
        'badgeNumber': badgeNumber,
        'actions': actions.map((a) => a.toJson()).toList(),
        'data': data,
        'category': category,
        'scheduledTime': scheduledTime?.toIso8601String(),
        'isGoalCompleted': isGoalCompleted,
      };

  factory RichNotificationPayload.fromJson(Map<String, dynamic> json) =>
      RichNotificationPayload(
        id: json['id'] as String,
        channelId: json['channelId'] as String? ?? 'aquawild_hydration_channel',
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        body: json['body'] as String,
        companionQuote: json['companionQuote'] as String,
        companionEmoji: json['companionEmoji'] as String? ?? '🐾',
        companionName: json['companionName'] as String,
        badgeNumber: json['badgeNumber'] as int? ?? 1,
        actions: (json['actions'] as List<dynamic>?)
                ?.map((a) => NotificationAction.fromJson(a as Map<String, dynamic>))
                .toList() ??
            const [],
        data: (json['data'] as Map<String, dynamic>?) ?? const {},
        category: json['category'] as String? ?? 'hydration_reminder',
        scheduledTime: json['scheduledTime'] != null
            ? DateTime.parse(json['scheduledTime'] as String)
            : null,
        isGoalCompleted: json['isGoalCompleted'] as bool? ?? false,
      );
}

/// Execution status of an actionable notification callback
enum NotificationActionStatus {
  logged,
  snoozed,
  navigated,
  ignored,
  failed,
}

/// Result returned after executing an actionable notification event
@immutable
class NotificationActionResult {
  final String actionId;
  final NotificationActionStatus status;
  final String message;
  final double? volumeLoggedMl;
  final DateTime? snoozedUntil;
  final String? targetRoute;
  final Map<String, dynamic>? extraData;

  const NotificationActionResult({
    required this.actionId,
    required this.status,
    required this.message,
    this.volumeLoggedMl,
    this.snoozedUntil,
    this.targetRoute,
    this.extraData,
  });

  bool get isSuccess =>
      status == NotificationActionStatus.logged ||
      status == NotificationActionStatus.snoozed ||
      status == NotificationActionStatus.navigated;

  Map<String, dynamic> toJson() => {
        'actionId': actionId,
        'status': status.name,
        'message': message,
        'volumeLoggedMl': volumeLoggedMl,
        'snoozedUntil': snoozedUntil?.toIso8601String(),
        'targetRoute': targetRoute,
        'extraData': extraData,
      };

  factory NotificationActionResult.fromJson(Map<String, dynamic> json) =>
      NotificationActionResult(
        actionId: json['actionId'] as String,
        status: NotificationActionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => NotificationActionStatus.ignored,
        ),
        message: json['message'] as String,
        volumeLoggedMl: (json['volumeLoggedMl'] as num?)?.toDouble(),
        snoozedUntil: json['snoozedUntil'] != null
            ? DateTime.parse(json['snoozedUntil'] as String)
            : null,
        targetRoute: json['targetRoute'] as String?,
        extraData: json['extraData'] as Map<String, dynamic>?,
      );
}
