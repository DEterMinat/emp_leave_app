import 'package:flutter_test/flutter_test.dart';
import 'package:emp_leave_app/models/employee.dart';

void main() {
  group('Employee Model', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'id': 'emp-123',
        'userId': 'user-456',
        'departmentId': 'dept-1',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@company.com',
        'phone': '0812345678',
        'address': '123 Main Street',
        'departmentName': 'Information Technology',
        'username': 'john.doe',
        'position': 'Senior Developer',
        'salary': 65000.0,
      };

      final employee = Employee.fromJson(json);

      expect(employee.id, 'emp-123');
      expect(employee.userId, 'user-456');
      expect(employee.departmentId, 'dept-1');
      expect(employee.firstName, 'John');
      expect(employee.lastName, 'Doe');
      expect(employee.email, 'john@company.com');
      expect(employee.phone, '0812345678');
      expect(employee.address, '123 Main Street');
      expect(employee.departmentName, 'Information Technology');
      expect(employee.username, 'john.doe');
      expect(employee.position, 'Senior Developer');
      expect(employee.salary, 65000.0);
    });

    test('fromJson should handle null optional fields', () {
      final json = {
        'id': 'emp-1',
        'userId': 'user-1',
        'departmentId': 'dept-1',
        'firstName': 'Jane',
        'lastName': 'Smith',
        'email': 'jane@test.com',
      };

      final employee = Employee.fromJson(json);

      expect(employee.phone, isNull);
      expect(employee.address, isNull);
      expect(employee.departmentName, isNull);
      expect(employee.username, isNull);
      expect(employee.position, isNull);
      expect(employee.salary, isNull);
    });

    test('fromJson should handle missing required fields with empty strings', () {
      final json = <String, dynamic>{};

      final employee = Employee.fromJson(json);

      expect(employee.id, '');
      expect(employee.userId, '');
      expect(employee.departmentId, '');
      expect(employee.firstName, '');
      expect(employee.lastName, '');
      expect(employee.email, '');
    });

    test('fromJson should handle salary as int (type coercion)', () {
      final json = {
        'id': 'emp-1',
        'userId': 'user-1',
        'departmentId': 'dept-1',
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'test@test.com',
        'salary': 45000, // int, not double
      };

      final employee = Employee.fromJson(json);

      expect(employee.salary, 45000.0);
      expect(employee.salary, isA<double>());
    });

    test('fromJson should handle salary as double', () {
      final json = {
        'id': 'emp-1',
        'userId': 'user-1',
        'departmentId': 'dept-1',
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'test@test.com',
        'salary': 52500.50,
      };

      final employee = Employee.fromJson(json);

      expect(employee.salary, 52500.50);
    });

    test('toJson should serialize correctly', () {
      final employee = Employee(
        id: 'emp-1',
        userId: 'user-1',
        departmentId: 'dept-1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@test.com',
        phone: '0999999999',
        address: '456 Second Ave',
        position: 'Manager',
        salary: 80000.0,
      );

      final json = employee.toJson();

      expect(json['id'], 'emp-1');
      expect(json['userId'], 'user-1');
      expect(json['departmentId'], 'dept-1');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
      expect(json['email'], 'john@test.com');
      expect(json['phone'], '0999999999');
      expect(json['address'], '456 Second Ave');
      expect(json['position'], 'Manager');
      expect(json['salary'], 80000.0);
    });

    test('toJson should not include departmentName and username', () {
      final employee = Employee(
        id: 'emp-1',
        userId: 'user-1',
        departmentId: 'dept-1',
        firstName: 'Test',
        lastName: 'User',
        email: 'test@test.com',
        departmentName: 'IT',
        username: 'testuser',
      );

      final json = employee.toJson();

      // departmentName and username are not in toJson as they're read-only populated fields
      expect(json.containsKey('departmentName'), false);
      expect(json.containsKey('username'), false);
    });

    test('roundtrip fromJson -> toJson should preserve data', () {
      final originalJson = {
        'id': 'emp-round',
        'userId': 'user-round',
        'departmentId': 'dept-round',
        'firstName': 'Round',
        'lastName': 'Trip',
        'email': 'round@trip.com',
        'phone': '0811111111',
        'address': 'Roundtrip Lane',
        'position': 'Tester',
        'salary': 55000.0,
      };

      final employee = Employee.fromJson(originalJson);
      final outputJson = employee.toJson();

      expect(outputJson['id'], originalJson['id']);
      expect(outputJson['userId'], originalJson['userId']);
      expect(outputJson['firstName'], originalJson['firstName']);
      expect(outputJson['email'], originalJson['email']);
      expect(outputJson['salary'], originalJson['salary']);
    });
  });
}
