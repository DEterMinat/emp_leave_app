import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
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

// My Leave Balances Provider (authenticated user) - Often called "Entitlements"
final myLeaveBalancesProvider = FutureProvider<List<LeaveBalance>>((ref) async {
  try {
    final response = await ApiClient().get(ApiConstants.myLeaveBalances);
    final List data = response.data as List;
    return data.map((json) => LeaveBalance.fromJson(json)).toList();
  } catch (e) {
    // Return empty list on error to allow UI to handle it gracefully
    return [];
  }
});

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

// All Leave Requests Provider (for HR/Managers)
final allLeaveRequestsProvider = FutureProvider<List<LeaveRequest>>((
  ref,
) async {
  final response = await ApiClient().get(ApiConstants.leaveRequests);
  final List data = response.data as List;
  return data.map((json) => LeaveRequest.fromJson(json)).toList();
});

// Leave Request Attachments Provider
final leaveAttachmentsProvider =
    FutureProvider.family<List<LeaveAttachment>, String>((
      ref,
      requestId,
    ) async {
      try {
        final response = await ApiClient().get(
          ApiConstants.leaveAttachments(requestId),
        );
        final List data = response.data as List;
        return data.map((json) => LeaveAttachment.fromJson(json)).toList();
      } catch (e) {
        return [];
      }
    });

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
    dynamic file, // File (io) or XFile (web) or PlatformFile
    String? fileName,
  }) async {
    state = LeaveRequestState(isLoading: true);

    try {
      if (file != null) {
        // Handle Request with Attachment
        final formData = FormData.fromMap({
          'EmployeeId': employeeId,
          'LeaveTypeId': leaveTypeId,
          'StartDate': startDate.toIso8601String(),
          'EndDate': endDate.toIso8601String(),
          'Reason': reason,
          // Handle file based on type (cross-platform consideration)
          // For now assuming dart:io File for mobile or standard path
          'File': await MultipartFile.fromFile(
            file.path,
            filename: fileName ?? 'attachment',
          ),
        });

        await ApiClient().post(
          ApiConstants.leaveRequestsWithAttachment,
          data: formData,
        );
      } else {
        // Standard Request
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
      }

      state = LeaveRequestState(isSuccess: true);
      return true;
    } catch (e) {
      state = LeaveRequestState(error: 'Failed to submit: $e');
      return false;
    }
  }

  Future<bool> cancelRequest(String requestId) async {
    state = LeaveRequestState(isLoading: true);
    try {
      await ApiClient().delete('${ApiConstants.leaveRequests}/$requestId');
      state = LeaveRequestState(isSuccess: true);
      return true;
    } catch (e) {
      state = LeaveRequestState(error: 'Failed to cancel: $e');
      return false;
    }
  }

  Future<bool> updateRequestStatus(String requestId, String status) async {
    state = LeaveRequestState(isLoading: true);
    try {
      await ApiClient().patch(
        '${ApiConstants.leaveRequests}/$requestId/status',
        data: {'status': status},
      );
      state = LeaveRequestState(isSuccess: true);
      return true;
    } catch (e) {
      state = LeaveRequestState(error: 'Failed to update status: $e');
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
