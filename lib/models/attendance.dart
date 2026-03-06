class Attendance {
  final String attendanceID;
  final String employeeID;
  final String? employeeName;
  final DateTime attendanceDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Attendance({
    required this.attendanceID,
    required this.employeeID,
    this.employeeName,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceID: json['attendanceID'] ?? '',
      employeeID: json['employeeID'] ?? '',
      employeeName: json['employeeName'],
      attendanceDate: DateTime.parse(json['attendanceDate']),
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime']).toLocal()
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime']).toLocal()
          : null,
      status: json['status'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceID': attendanceID,
      'employeeID': employeeID,
      'employeeName': employeeName,
      'attendanceDate': attendanceDate.toIso8601String(),
      'checkInTime': checkInTime?.toUtc().toIso8601String(),
      'checkOutTime': checkOutTime?.toUtc().toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }
}
