import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Database entity types managed in the offline synchronization queue.
enum SyncEntityType {
  hydrationEntry,
  userStreak,
  userAchievement,
  activitySession,
}

/// Operation mutation types.
enum SyncAction {
  create,
  update,
  delete,
}

/// A queued database mutation persisted locally during offline operation.
class SyncQueueItem {
  final String id;
  final SyncEntityType entityType;
  final SyncAction action;
  final Map<String, dynamic> payload;
  final int retryCount;
  final DateTime createdAt;

  SyncQueueItem({
    String? id,
    required this.entityType,
    required this.action,
    required this.payload,
    this.retryCount = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  SyncQueueItem copyWith({
    String? id,
    SyncEntityType? entityType,
    SyncAction? action,
    Map<String, dynamic>? payload,
    int? retryCount,
    DateTime? createdAt,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType.name,
      'action': action.name,
      'payload': payload,
      'retryCount': retryCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      entityType: SyncEntityType.values.firstWhere(
        (e) => e.name == json['entityType'],
        orElse: () => SyncEntityType.hydrationEntry,
      ),
      action: SyncAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => SyncAction.create,
      ),
      payload: json['payload'] is String
          ? jsonDecode(json['payload'] as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(json['payload'] as Map),
      retryCount: json['retryCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
