import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Circadian category for hydration alerts.
enum ReminderCategory {
  morningKickstart(label: 'Morning Awakening', defaultIcon: '🌅'),
  midDayMaintenance(label: 'Midday Focus', defaultIcon: '☀️'),
  afternoonBoost(label: 'Afternoon Rejuvenation', defaultIcon: '🍃'),
  postActivity(label: 'Post-Workout Restoration', defaultIcon: '⚡'),
  eveningWindDown(label: 'Evening Taper', defaultIcon: '🌙');

  final String label;
  final String defaultIcon;

  const ReminderCategory({
    required this.label,
    required this.defaultIcon,
  });
}

/// A circadian smart reminder tailored to human metabolic cycles.
class SmartReminder {
  final String id;
  final TimeOfDay targetTime;
  final String title;
  final String body;
  final int recommendedVolumeMl;
  final String suggestedBeverageId;
  final ReminderCategory category;
  final bool isCompleted;

  SmartReminder({
    String? id,
    required this.targetTime,
    required this.title,
    required this.body,
    required this.recommendedVolumeMl,
    this.suggestedBeverageId = 'pure_water',
    required this.category,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  SmartReminder copyWith({
    String? id,
    TimeOfDay? targetTime,
    String? title,
    String? body,
    int? recommendedVolumeMl,
    String? suggestedBeverageId,
    ReminderCategory? category,
    bool? isCompleted,
  }) {
    return SmartReminder(
      id: id ?? this.id,
      targetTime: targetTime ?? this.targetTime,
      title: title ?? this.title,
      body: body ?? this.body,
      recommendedVolumeMl: recommendedVolumeMl ?? this.recommendedVolumeMl,
      suggestedBeverageId: suggestedBeverageId ?? this.suggestedBeverageId,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': targetTime.hour,
      'minute': targetTime.minute,
      'title': title,
      'body': body,
      'recommendedVolumeMl': recommendedVolumeMl,
      'suggestedBeverageId': suggestedBeverageId,
      'category': category.name,
      'isCompleted': isCompleted,
    };
  }

  factory SmartReminder.fromJson(Map<String, dynamic> json) {
    return SmartReminder(
      id: json['id'] as String,
      targetTime: TimeOfDay(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      recommendedVolumeMl: json['recommendedVolumeMl'] as int,
      suggestedBeverageId: json['suggestedBeverageId'] as String? ?? 'pure_water',
      category: ReminderCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ReminderCategory.midDayMaintenance,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
