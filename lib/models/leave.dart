class LeaveType {
  final String id;
  final String typeName;
  final String? description;

  LeaveType({required this.id, required this.typeName, this.description});

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'] ?? '',
      typeName: json['typeName'] ?? '',
      description: json['description'],
    );
  }
}

class LeaveBalance {
  final String id;
  final String employeeId;
  final String leaveTypeId;
  final int year;
  final int totalDays;
  final int usedDays;
  final int remainingDays;
  final String? leaveTypeName;

  LeaveBalance({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.year,
    required this.totalDays,
    required this.usedDays,
    required this.remainingDays,
    this.leaveTypeName,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      leaveTypeId: json['leaveTypeId'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      totalDays: json['totalDays'] ?? 0,
      usedDays: json['usedDays'] ?? 0,
      remainingDays: json['remainingDays'] ?? 0,
      leaveTypeName: json['leaveTypeName'],
    );
  }
}

class LeaveRequest {
  final String id;
  final String employeeId;
  final String leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String status;
  final String? comment;
  final DateTime? requestedDate;
  final String? approverId;
  final DateTime? approvedDate;
  final String? employeeName;
  final String? username;
  final String? leaveTypeName;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    this.comment,
    this.requestedDate,
    this.approverId,
    this.approvedDate,
    this.employeeName,
    this.username,
    this.leaveTypeName,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      leaveTypeId: json['leaveTypeId'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalDays: json['totalDays'] ?? 0,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
      comment: json['comment'],
      requestedDate: json['requestedDate'] != null
          ? DateTime.parse(json['requestedDate'])
          : null,
      approverId: json['approverId'],
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      employeeName: json['employeeName'],
      username: json['username'],
      leaveTypeName: json['leaveTypeName'],
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'employeeId': employeeId,
      'leaveTypeId': leaveTypeId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
    };
  }

  // Status color helper
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      case 'pending':
      default:
        return 'orange';
    }
  }
}

class LeaveAttachment {
  final String id;
  final String requestId;
  final String fileName;
  final String filePath;
  final DateTime uploadedDate;

  LeaveAttachment({
    required this.id,
    required this.requestId,
    required this.fileName,
    required this.filePath,
    required this.uploadedDate,
  });

  factory LeaveAttachment.fromJson(Map<String, dynamic> json) {
    return LeaveAttachment(
      id: json['id'] ?? '',
      requestId: json['requestId'] ?? '',
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      uploadedDate: json['uploadedDate'] != null
          ? DateTime.parse(json['uploadedDate'])
          : DateTime.now(),
    );
  }
}
