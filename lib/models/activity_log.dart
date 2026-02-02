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
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'],
      action: json['action'] ?? '',
      targetType: json['targetType'] ?? '',
      targetId: json['targetId'] ?? '',
      details: json['details'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
