import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/employee.dart';
import 'auth_provider.dart';

// Profile State
class ProfileState {
  final bool isLoading;
  final Employee? employee;
  final String? error;
  final bool isSuccess;

  ProfileState({
    this.isLoading = false,
    this.employee,
    this.error,
    this.isSuccess = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    Employee? employee,
    String? error,
    bool? isSuccess,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      employee: employee ?? this.employee,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ApiClient _apiClient;
  final String? _userId;

  ProfileNotifier(this._apiClient, this._userId) : super(ProfileState()) {
    if (_userId != null) {
      fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    if (_userId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(
        '${ApiConstants.employees}/user/$_userId',
      );
      final employee = Employee.fromJson(response.data);
      state = state.copyWith(isLoading: false, employee: employee);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: $e',
      );
    }
  }

  Future<bool> createProfile(
    String firstName,
    String lastName,
    String email,
    String phone,
    String address,
    String departmentId,
  ) async {
    if (_userId == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(
        ApiConstants.employees,
        data: {
          'userId': _userId,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'address': address,
          'departmentId': departmentId,
        },
      );

      final newEmployee = Employee.fromJson(response.data);
      // 2. Initialize Leave Balances for the new employee
      try {
        await _apiClient.post(
          '${ApiConstants.leaveBalances}/initialize/${_userId}?year=${DateTime.now().year}',
        );
      } catch (e) {
        debugPrint('Failed to initialize balances: $e');
        // Non-critical error, continue
      }

      state = state.copyWith(
        isLoading: false,
        employee: newEmployee,
        isSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create: $e');
      return false;
    }
  }

  Future<bool> updateProfile(
    String firstName,
    String lastName,
    String email,
    String phone,
    String address,
    String departmentId,
  ) async {
    // If no employee record exists, create one instead
    if (state.employee == null) {
      return createProfile(
        firstName,
        lastName,
        email,
        phone,
        address,
        departmentId,
      );
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.put(
        '${ApiConstants.employees}/${state.employee!.id}',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'address': address,
          'departmentId': departmentId,
        },
      );

      final updatedEmployee = Employee.fromJson(response.data);
      state = state.copyWith(
        isLoading: false,
        employee: updatedEmployee,
        isSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update: $e');
      return false;
    }
  }
}

final profileProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>((ref) {
      final authState = ref.watch(authProvider);
      return ProfileNotifier(ApiClient(), authState.userId);
    });
