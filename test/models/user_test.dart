import 'package:flutter_test/flutter_test.dart';
import 'package:emp_leave_app/models/user.dart';

void main() {
  group('User Model', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'id': 'user-123',
        'username': 'john.doe',
        'roleId': 'role-1',
        'roleName': 'Employee',
        'createdAt': '2025-01-15T08:00:00Z',
        'updatedAt': '2025-06-01T10:30:00Z',
        'email': 'john@company.com',
        'phone': '0812345678',
        'annualLeaveQuota': 10,
        'firstName': 'John',
        'lastName': 'Doe',
        'departmentId': 'dept-1',
        'departmentName': 'IT',
        'position': 'Developer',
        'salary': 50000.0,
        'address': '123 Main St',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.username, 'john.doe');
      expect(user.roleId, 'role-1');
      expect(user.roleName, 'Employee');
      expect(user.email, 'john@company.com');
      expect(user.phone, '0812345678');
      expect(user.annualLeaveQuota, 10);
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.departmentId, 'dept-1');
      expect(user.departmentName, 'IT');
      expect(user.position, 'Developer');
      expect(user.salary, 50000.0);
      expect(user.address, '123 Main St');
      expect(user.createdAt, isA<DateTime>());
      expect(user.updatedAt, isA<DateTime>());
    });

    test('fromJson should handle null optional fields', () {
      final json = {
        'id': 'user-1',
        'username': 'minimal',
        'roleId': 'role-1',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user-1');
      expect(user.username, 'minimal');
      expect(user.roleId, 'role-1');
      expect(user.roleName, isNull);
      expect(user.email, isNull);
      expect(user.phone, isNull);
      expect(user.annualLeaveQuota, isNull);
      expect(user.firstName, isNull);
      expect(user.lastName, isNull);
      expect(user.departmentId, isNull);
      expect(user.departmentName, isNull);
      expect(user.position, isNull);
      expect(user.salary, isNull);
      expect(user.address, isNull);
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });

    test('fromJson should handle missing id with empty string default', () {
      final json = <String, dynamic>{
        'username': 'test',
        'roleId': 'role-1',
      };

      final user = User.fromJson(json);

      expect(user.id, '');
      expect(user.username, 'test');
    });

    test('fromJson should handle salary as int', () {
      final json = {
        'id': 'user-1',
        'username': 'test',
        'roleId': 'role-1',
        'salary': 35000, // int, not double
      };

      final user = User.fromJson(json);

      expect(user.salary, 35000.0);
      expect(user.salary, isA<double>());
    });

    test('toJson should serialize correctly', () {
      final user = User(
        id: 'user-1',
        username: 'john',
        roleId: 'role-1',
        roleName: 'Employee',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@test.com',
        phone: '0812345678',
        annualLeaveQuota: 10,
        departmentId: 'dept-1',
        departmentName: 'IT',
        position: 'Developer',
        salary: 50000.0,
        address: '123 St',
      );

      final json = user.toJson();

      expect(json['id'], 'user-1');
      expect(json['username'], 'john');
      expect(json['roleId'], 'role-1');
      expect(json['roleName'], 'Employee');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
      expect(json['email'], 'john@test.com');
      expect(json['salary'], 50000.0);
    });
  });

  group('LoginResponse Model', () {
    test('fromJson should parse all fields', () {
      final json = {
        'token': 'jwt-token-here',
        'userId': 'user-123',
        'username': 'john.doe',
        'roleId': 'role-1',
        'roleName': 'Employee',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.token, 'jwt-token-here');
      expect(response.userId, 'user-123');
      expect(response.username, 'john.doe');
      expect(response.roleId, 'role-1');
      expect(response.roleName, 'Employee');
    });

    test('fromJson should handle null token with empty string', () {
      final json = <String, dynamic>{
        'userId': 'user-1',
        'username': 'test',
        'roleId': 'role-1',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.token, '');
      expect(response.roleName, isNull);
    });

    test('fromJson should handle missing optional roleName', () {
      final json = {
        'token': 'abc',
        'userId': 'u1',
        'username': 'user',
        'roleId': 'r1',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.roleName, isNull);
    });
  });
}
