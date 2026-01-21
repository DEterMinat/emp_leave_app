// API Configuration
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Auto-detect platform for correct URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5082/api'; // Flutter Web
    } else {
      return 'http://10.0.2.2:5082/api'; // Android Emulator
    }
  }
  // For production: 'https://your-api.com/api'

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String users = '/users';
  static const String employees = '/employees';
  static const String leaveTypes = '/leavetypes';
  static const String leaveRequests = '/leaverequests';
  static const String leaveBalances = '/leavebalances';
  static const String departments = '/departments';
  static const String roles = '/roles';
}

// Storage Keys
class StorageKeys {
  static const String token = 'auth_token';
  static const String userId = 'user_id';
  static const String username = 'username';
  static const String roleId = 'role_id';
  static const String roleName = 'role_name';
  static const String employeeId = 'employee_id';
}
