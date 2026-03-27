import 'package:flutter_test/flutter_test.dart';
import 'package:emp_leave_app/models/attendance.dart';

void main() {
  group('Attendance Model', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'attendanceID': 'att-123',
        'employeeID': 'emp-456',
        'employeeName': 'John Doe',
        'attendanceDate': '2026-03-27T00:00:00Z',
        'checkInTime': '2026-03-27T08:30:00Z',
        'checkOutTime': '2026-03-27T17:15:00Z',
        'status': 'Present',
        'notes': 'Normal working day',
        'createdAt': '2026-03-27T08:30:05Z',
        'updatedAt': '2026-03-27T17:15:05Z',
      };

      final attendance = Attendance.fromJson(json);

      expect(attendance.attendanceID, 'att-123');
      expect(attendance.employeeID, 'emp-456');
      expect(attendance.employeeName, 'John Doe');
      expect(attendance.attendanceDate, isA<DateTime>());
      expect(attendance.checkInTime, isA<DateTime>());
      expect(attendance.checkOutTime, isA<DateTime>());
      expect(attendance.status, 'Present');
      expect(attendance.notes, 'Normal working day');
      expect(attendance.createdAt, isA<DateTime>());
      expect(attendance.updatedAt, isA<DateTime>());
    });

    test('fromJson should handle Late status', () {
      final json = {
        'attendanceID': 'att-2',
        'employeeID': 'emp-1',
        'attendanceDate': '2026-03-27T00:00:00Z',
        'checkInTime': '2026-03-27T09:30:00Z', // After 9 AM
        'status': 'Late',
      };

      final attendance = Attendance.fromJson(json);

      expect(attendance.status, 'Late');
      expect(attendance.checkInTime, isA<DateTime>());
    });

    test('fromJson should handle null optional fields', () {
      final json = {
        'attendanceID': 'att-3',
        'employeeID': 'emp-1',
        'attendanceDate': '2026-03-27T00:00:00Z',
      };

      final attendance = Attendance.fromJson(json);

      expect(attendance.attendanceID, 'att-3');
      expect(attendance.employeeName, isNull);
      expect(attendance.checkInTime, isNull);
      expect(attendance.checkOutTime, isNull);
      expect(attendance.status, isNull);
      expect(attendance.notes, isNull);
      expect(attendance.createdAt, isNull);
      expect(attendance.updatedAt, isNull);
    });

    test('fromJson should handle missing attendanceID with empty string', () {
      final json = {
        'employeeID': 'emp-1',
        'attendanceDate': '2026-03-27T00:00:00Z',
      };

      final attendance = Attendance.fromJson(json);

      expect(attendance.attendanceID, '');
    });

    test('fromJson should convert times to local timezone', () {
      final json = {
        'attendanceID': 'att-5',
        'employeeID': 'emp-1',
        'attendanceDate': '2026-03-27T00:00:00Z',
        'checkInTime': '2026-03-27T02:00:00Z', // 2 AM UTC
        'checkOutTime': '2026-03-27T10:00:00Z', // 10 AM UTC
        'createdAt': '2026-03-27T02:00:00Z',
      };

      final attendance = Attendance.fromJson(json);

      // checkInTime and checkOutTime should be converted to local
      expect(attendance.checkInTime!.isUtc, false);
      expect(attendance.checkOutTime!.isUtc, false);
      expect(attendance.createdAt!.isUtc, false);
    });

    test('toJson should serialize correctly', () {
      final attendance = Attendance(
        attendanceID: 'att-1',
        employeeID: 'emp-1',
        employeeName: 'John',
        attendanceDate: DateTime(2026, 3, 27),
        checkInTime: DateTime(2026, 3, 27, 8, 30),
        checkOutTime: DateTime(2026, 3, 27, 17, 0),
        status: 'Present',
        notes: 'Office',
      );

      final json = attendance.toJson();

      expect(json['attendanceID'], 'att-1');
      expect(json['employeeID'], 'emp-1');
      expect(json['employeeName'], 'John');
      expect(json['status'], 'Present');
      expect(json['notes'], 'Office');
      expect(json.containsKey('attendanceDate'), true);
      expect(json.containsKey('checkInTime'), true);
      expect(json.containsKey('checkOutTime'), true);
    });

    test('toJson should handle null checkOutTime', () {
      final attendance = Attendance(
        attendanceID: 'att-2',
        employeeID: 'emp-1',
        attendanceDate: DateTime(2026, 3, 27),
        checkInTime: DateTime(2026, 3, 27, 8, 30),
        status: 'Present',
      );

      final json = attendance.toJson();

      expect(json['checkOutTime'], isNull);
    });
  });
}
