/// Remote Configuration Flag for dynamic feature toggling and tuning
class RemoteConfigFlag {
  final String key;
  final Map<String, dynamic> value;
  final String description;
  final String environment; // 'all', 'dev', 'staging', 'prod'
  final bool isActive;
  final String? updatedBy;
  final DateTime updatedAt;

  const RemoteConfigFlag({
    required this.key,
    required this.value,
    this.description = '',
    this.environment = 'all',
    this.isActive = true,
    this.updatedBy,
    required this.updatedAt,
  });

  RemoteConfigFlag copyWith({
    String? key,
    Map<String, dynamic>? value,
    String? description,
    String? environment,
    bool? isActive,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return RemoteConfigFlag(
      key: key ?? this.key,
      value: value ?? this.value,
      description: description ?? this.description,
      environment: environment ?? this.environment,
      isActive: isActive ?? this.isActive,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
        'description': description,
        'environment': environment,
        'is_active': isActive,
        'updated_by': updatedBy,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory RemoteConfigFlag.fromJson(Map<String, dynamic> json) {
    return RemoteConfigFlag(
      key: json['key'] as String? ?? '',
      value: (json['value'] as Map<String, dynamic>?) ?? {},
      description: json['description'] as String? ?? '',
      environment: json['environment'] as String? ?? 'all',
      isActive: json['is_active'] as bool? ?? true,
      updatedBy: json['updated_by'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Immutable Audit Log Record tracking administrative mutations
class AdminAuditEntry {
  final String id;
  final String? actorId;
  final String actorEmail;
  final String action;
  final String targetResource;
  final Map<String, dynamic> details;
  final String environment;
  final String? ipAddress;
  final DateTime timestamp;

  const AdminAuditEntry({
    required this.id,
    this.actorId,
    required this.actorEmail,
    required this.action,
    required this.targetResource,
    this.details = const {},
    this.environment = 'prod',
    this.ipAddress,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'actor_id': actorId,
        'actor_email': actorEmail,
        'action': action,
        'target_resource': targetResource,
        'details': details,
        'environment': environment,
        'ip_address': ipAddress,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AdminAuditEntry.fromJson(Map<String, dynamic> json) {
    return AdminAuditEntry(
      id: json['id'] as String? ?? '',
      actorId: json['actor_id'] as String?,
      actorEmail: json['actor_email'] as String? ?? 'system@aquawild.internal',
      action: json['action'] as String? ?? 'UNKNOWN_ACTION',
      targetResource: json['target_resource'] as String? ?? 'SYSTEM',
      details: (json['details'] as Map<String, dynamic>?) ?? {},
      environment: json['environment'] as String? ?? 'prod',
      ipAddress: json['ip_address'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
    );
  }
}

/// Environment mode for Admin Portal runtime operations
enum AdminEnvironment {
  development,
  staging,
  production;

  String get label {
    switch (this) {
      case AdminEnvironment.development:
        return 'DEV';
      case AdminEnvironment.staging:
        return 'STAGING';
      case AdminEnvironment.production:
        return 'PROD';
    }
  }

  static AdminEnvironment fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'dev':
      case 'development':
        return AdminEnvironment.development;
      case 'staging':
        return AdminEnvironment.staging;
      default:
        return AdminEnvironment.production;
    }
  }
}
