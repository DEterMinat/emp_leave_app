import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/leave.dart';

// Leave Types Provider
final leaveTypesProvider = FutureProvider<List<LeaveType>>((ref) async {
  final response = await ApiClient().get(ApiConstants.leaveTypes);
  final List data = response.data as List;
  return data.map((json) => LeaveType.fromJson(json)).toList();
});

// Leave Balances Provider (by employee)
final leaveBalancesProvider = FutureProvider.family<List<LeaveBalance>, String>(
  (ref, employeeId) async {
    final response = await ApiClient().get(
      '${ApiConstants.leaveBalances}/employee/$employeeId',
    );
    final List data = response.data as List;
    return data.map((json) => LeaveBalance.fromJson(json)).toList();
  },
);

// Leave Requests Provider (by employee)
final leaveRequestsProvider = FutureProvider.family<List<LeaveRequest>, String>(
  (ref, employeeId) async {
    final response = await ApiClient().get(
      '${ApiConstants.leaveRequests}/employee/$employeeId',
    );
    final List data = response.data as List;
    return data.map((json) => LeaveRequest.fromJson(json)).toList();
  },
);

// Leave Request State for creating new requests
class LeaveRequestState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  LeaveRequestState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  LeaveRequestState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return LeaveRequestState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LeaveRequestNotifier extends StateNotifier<LeaveRequestState> {
  LeaveRequestNotifier() : super(LeaveRequestState());

  Future<bool> createRequest({
    required String employeeId,
    required String leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    state = LeaveRequestState(isLoading: true);

    try {
      await ApiClient().post(
        ApiConstants.leaveRequests,
        data: {
          'employeeId': employeeId,
          'leaveTypeId': leaveTypeId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'reason': reason,
        },
      );
      state = LeaveRequestState(isSuccess: true);
      return true;
    } catch (e) {
      state = LeaveRequestState(error: 'Failed to submit: $e');
      return false;
    }
  }

  void reset() {
    state = LeaveRequestState();
  }
}

final leaveRequestNotifierProvider =
    StateNotifierProvider<LeaveRequestNotifier, LeaveRequestState>((ref) {
      return LeaveRequestNotifier();
    });

// Stats for dashboard
class DashboardStats {
  final int totalRequests;
  final int pendingRequests;
  final int totalDaysOff;

  DashboardStats({
    required this.totalRequests,
    required this.pendingRequests,
    required this.totalDaysOff,
  });

  factory DashboardStats.fromRequests(List<LeaveRequest> requests) {
    final pending = requests
        .where((r) => r.status.toLowerCase() == 'pending')
        .length;
    final approved = requests.where(
      (r) => r.status.toLowerCase() == 'approved',
    );
    final totalDays = approved.fold<int>(0, (sum, r) => sum + r.totalDays);

    return DashboardStats(
      totalRequests: requests.length,
      pendingRequests: pending,
      totalDaysOff: totalDays,
    );
  }
}
