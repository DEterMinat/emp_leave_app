class ActivityLog {
  final String id;
  final String userId;
  final String? username;
  final String action;
  final String targetType;
  final String targetId;
  final String? details;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.userId,
    this.username,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.details,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String?,
      action: json['action'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      details: json['details'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'action': action,
      'targetType': targetType,
      'targetId': targetId,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
