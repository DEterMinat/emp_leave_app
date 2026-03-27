import 'package:flutter_test/flutter_test.dart';
import 'package:emp_leave_app/models/leave.dart';

void main() {
  group('LeaveType Model', () {
    test('fromJson should parse all fields', () {
      final json = {
        'id': 'lt-1',
        'typeName': 'Annual Leave',
        'description': 'Yearly vacation leave',
      };

      final type = LeaveType.fromJson(json);

      expect(type.id, 'lt-1');
      expect(type.typeName, 'Annual Leave');
      expect(type.description, 'Yearly vacation leave');
    });

    test('fromJson should handle null description', () {
      final json = {
        'id': 'lt-2',
        'typeName': 'Sick Leave',
      };

      final type = LeaveType.fromJson(json);

      expect(type.id, 'lt-2');
      expect(type.typeName, 'Sick Leave');
      expect(type.description, isNull);
    });

    test('fromJson should handle missing id with empty string', () {
      final json = <String, dynamic>{
        'typeName': 'Personal Leave',
      };

      final type = LeaveType.fromJson(json);

      expect(type.id, '');
    });
  });

  group('LeaveBalance Model', () {
    test('fromJson should parse all fields', () {
      final json = {
        'id': 'bal-1',
        'employeeId': 'emp-1',
        'leaveTypeId': 'lt-1',
        'year': 2026,
        'totalDays': 10,
        'usedDays': 3,
        'remainingDays': 7,
        'leaveTypeName': 'Annual Leave',
      };

      final balance = LeaveBalance.fromJson(json);

      expect(balance.id, 'bal-1');
      expect(balance.employeeId, 'emp-1');
      expect(balance.leaveTypeId, 'lt-1');
      expect(balance.year, 2026);
      expect(balance.totalDays, 10);
      expect(balance.usedDays, 3);
      expect(balance.remainingDays, 7);
      expect(balance.leaveTypeName, 'Annual Leave');
    });

    test('fromJson should use default values for missing fields', () {
      final json = <String, dynamic>{};

      final balance = LeaveBalance.fromJson(json);

      expect(balance.id, '');
      expect(balance.employeeId, '');
      expect(balance.leaveTypeId, '');
      expect(balance.year, DateTime.now().year);
      expect(balance.totalDays, 0);
      expect(balance.usedDays, 0);
      expect(balance.remainingDays, 0);
      expect(balance.leaveTypeName, isNull);
    });
  });

  group('LeaveRequest Model', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'id': 'req-1',
        'employeeId': 'emp-1',
        'leaveTypeId': 'lt-1',
        'startDate': '2026-04-01T00:00:00Z',
        'endDate': '2026-04-03T00:00:00Z',
        'totalDays': 3,
        'reason': 'Family trip',
        'status': 'Pending',
        'comment': null,
        'requestedDate': '2026-03-25T10:00:00Z',
        'approverId': null,
        'approvedDate': null,
        'employeeName': 'John Doe',
        'username': 'john.doe',
        'leaveTypeName': 'Annual Leave',
        'hasAttachments': true,
      };

      final request = LeaveRequest.fromJson(json);

      expect(request.id, 'req-1');
      expect(request.employeeId, 'emp-1');
      expect(request.leaveTypeId, 'lt-1');
      expect(request.startDate, isA<DateTime>());
      expect(request.endDate, isA<DateTime>());
      expect(request.totalDays, 3);
      expect(request.reason, 'Family trip');
      expect(request.status, 'Pending');
      expect(request.comment, isNull);
      expect(request.requestedDate, isA<DateTime>());
      expect(request.approverId, isNull);
      expect(request.approvedDate, isNull);
      expect(request.employeeName, 'John Doe');
      expect(request.username, 'john.doe');
      expect(request.leaveTypeName, 'Annual Leave');
      expect(request.hasAttachments, true);
    });

    test('fromJson should handle approved request', () {
      final json = {
        'id': 'req-2',
        'employeeId': 'emp-1',
        'leaveTypeId': 'lt-1',
        'startDate': '2026-04-01T00:00:00Z',
        'endDate': '2026-04-02T00:00:00Z',
        'totalDays': 2,
        'reason': 'Medical',
        'status': 'Approved',
        'comment': 'Approved by manager',
        'approverId': 'mgr-1',
        'approvedDate': '2026-03-27T14:00:00Z',
      };

      final request = LeaveRequest.fromJson(json);

      expect(request.status, 'Approved');
      expect(request.comment, 'Approved by manager');
      expect(request.approverId, 'mgr-1');
      expect(request.approvedDate, isA<DateTime>());
    });

    test('statusColor should return green for approved', () {
      final request = LeaveRequest(
        id: '1',
        employeeId: 'e1',
        leaveTypeId: 'lt1',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        totalDays: 1,
        reason: 'test',
        status: 'Approved',
      );

      expect(request.statusColor, 'green');
    });

    test('statusColor should return red for rejected', () {
      final request = LeaveRequest(
        id: '1',
        employeeId: 'e1',
        leaveTypeId: 'lt1',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        totalDays: 1,
        reason: 'test',
        status: 'Rejected',
      );

      expect(request.statusColor, 'red');
    });

    test('statusColor should return orange for pending', () {
      final request = LeaveRequest(
        id: '1',
        employeeId: 'e1',
        leaveTypeId: 'lt1',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        totalDays: 1,
        reason: 'test',
        status: 'Pending',
      );

      expect(request.statusColor, 'orange');
    });

    test('toCreateJson should serialize correctly for API', () {
      final now = DateTime(2026, 4, 1);
      final end = DateTime(2026, 4, 3);

      final request = LeaveRequest(
        id: '1',
        employeeId: 'emp-1',
        leaveTypeId: 'lt-1',
        startDate: now,
        endDate: end,
        totalDays: 3,
        reason: 'Vacation',
        status: 'Pending',
      );

      final json = request.toCreateJson();

      expect(json['employeeId'], 'emp-1');
      expect(json['leaveTypeId'], 'lt-1');
      expect(json['reason'], 'Vacation');
      expect(json.containsKey('startDate'), true);
      expect(json.containsKey('endDate'), true);
      // Should NOT include id, status, etc.
      expect(json.containsKey('id'), false);
      expect(json.containsKey('status'), false);
    });

    test('fromJson should default hasAttachments to false', () {
      final json = {
        'id': 'req-1',
        'employeeId': 'emp-1',
        'leaveTypeId': 'lt-1',
        'startDate': '2026-04-01T00:00:00Z',
        'endDate': '2026-04-02T00:00:00Z',
        'reason': 'test',
        'status': 'Pending',
      };

      final request = LeaveRequest.fromJson(json);

      expect(request.hasAttachments, false);
    });
  });

  group('LeaveAttachment Model', () {
    test('fromJson should parse all fields', () {
      final json = {
        'id': 'att-1',
        'requestId': 'req-1',
        'fileName': 'medical_cert.pdf',
        'filePath': '/uploads/abc_medical_cert.pdf',
        'uploadedDate': '2026-03-27T10:00:00Z',
      };

      final attachment = LeaveAttachment.fromJson(json);

      expect(attachment.id, 'att-1');
      expect(attachment.requestId, 'req-1');
      expect(attachment.fileName, 'medical_cert.pdf');
      expect(attachment.filePath, '/uploads/abc_medical_cert.pdf');
      expect(attachment.uploadedDate, isA<DateTime>());
    });

    test('fromJson should handle null uploadedDate with DateTime.now()', () {
      final json = {
        'id': 'att-2',
        'requestId': 'req-2',
        'fileName': 'doc.pdf',
        'filePath': '/uploads/doc.pdf',
      };

      final attachment = LeaveAttachment.fromJson(json);

      expect(attachment.uploadedDate, isA<DateTime>());
      // Should be approximately now
      expect(
        attachment.uploadedDate.difference(DateTime.now()).inSeconds.abs(),
        lessThan(5),
      );
    });
  });
}
