import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/attendance.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> _resolveAttendanceIdentifier() async {
  final prefs = await SharedPreferences.getInstance();
  final employeeId = prefs.getString(StorageKeys.employeeId);
  if (employeeId != null && employeeId.isNotEmpty) {
    return employeeId;
  }

  final userId = prefs.getString(StorageKeys.userId);
  if (userId != null && userId.isNotEmpty) {
    return userId;
  }

  return null;
}

final employeeIdProvider = FutureProvider<String?>((ref) async {
  return _resolveAttendanceIdentifier();
});

// Provides today's attendance for the logged-in employee
final todayAttendanceProvider = FutureProvider<Attendance?>((ref) async {
  final employeeId = await _resolveAttendanceIdentifier();

  if (employeeId == null || employeeId.isEmpty) return null;

  try {
    final response = await ApiClient().get(
      ApiConstants.attendanceToday(employeeId),
    );
    return Attendance.fromJson(response.data);
  } catch (e) {
    // Usually means 404 No attendance today
    return null;
  }
});

// Provides attendance history
final attendanceHistoryProvider =
    FutureProvider.family<List<Attendance>, String>((ref, employeeId) async {
      try {
        final response = await ApiClient().get(
          ApiConstants.attendanceHistory(employeeId),
        );
        final List data = response.data as List;
        return data.map((json) => Attendance.fromJson(json)).toList();
      } catch (e) {
        return [];
      }
    });

final allAttendanceProvider = FutureProvider.family<List<Attendance>, DateTime?>(
  (ref, date) async {
    try {
      final response = await ApiClient().get(ApiConstants.attendanceAll(date));
      final List data = response.data as List;
      return data.map((json) => Attendance.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  },
);

class AttendanceState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  AttendanceState({this.isLoading = false, this.error, this.isSuccess = false});
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final Ref ref;

  AttendanceNotifier(this.ref) : super(AttendanceState());

  Future<bool> checkIn({String? notes}) async {
    state = AttendanceState(isLoading: true);
    try {
      final employeeId = await _resolveAttendanceIdentifier();

      if (employeeId == null) {
        state = AttendanceState(error: 'Employee ID not found. Please login again.');
        return false;
      }

      await ApiClient().post(
        ApiConstants.attendanceCheckIn,
        data: {'employeeID': employeeId, 'notes': notes},
      );

      // Refresh today's attendance
      ref.invalidate(todayAttendanceProvider);

      state = AttendanceState(isSuccess: true);
      return true;
    } catch (e) {
      state = AttendanceState(error: 'Failed to check in: $e');
      return false;
    }
  }

  Future<bool> checkOut({String? notes}) async {
    state = AttendanceState(isLoading: true);
    try {
      final employeeId = await _resolveAttendanceIdentifier();

      if (employeeId == null) {
        state = AttendanceState(error: 'Employee ID not found. Please login again.');
        return false;
      }

      await ApiClient().post(
        ApiConstants.attendanceCheckOut,
        data: {'employeeID': employeeId, 'notes': notes},
      );

      // Refresh today's attendance
      ref.invalidate(todayAttendanceProvider);

      state = AttendanceState(isSuccess: true);
      return true;
    } catch (e) {
      state = AttendanceState(error: 'Failed to check out: $e');
      return false;
    }
  }
}

final attendanceNotifierProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
      return AttendanceNotifier(ref);
    });
