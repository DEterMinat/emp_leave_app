import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/user.dart';

// Users List Provider
final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final response = await ApiClient().get(ApiConstants.users);
  final List data = response.data as List;
  return data.map((json) => User.fromJson(json)).toList();
});

// Roles List Provider
final allRolesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final response = await ApiClient().get(ApiConstants.roles);
  return (response.data as List).map((e) => e as Map<String, dynamic>).toList();
});

// Departments List Provider
final allDepartmentsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final response = await ApiClient().get(ApiConstants.departments);
  return (response.data as List).map((e) => e as Map<String, dynamic>).toList();
});

// Leave Types List Provider
final allLeaveTypesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final response = await ApiClient().get(ApiConstants.leaveTypes);
  return (response.data as List).map((e) => e as Map<String, dynamic>).toList();
});

// User Management Actions Notifier
class UserManagementNotifier extends StateNotifier<UserManagementState> {
  UserManagementNotifier() : super(UserManagementState());

  final _apiClient = ApiClient();

  Future<bool> createUser(Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _apiClient.post(ApiConstants.users, data: userData);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _apiClient.put('${ApiConstants.users}/$userId', data: userData);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _apiClient.delete('${ApiConstants.users}/$userId');
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void resetState() {
    state = UserManagementState();
  }

  // Department CRUD
  Future<bool> createDepartment(Map<String, dynamic> deptData) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _apiClient.post(ApiConstants.departments, data: deptData);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateDepartment(
    String deptId,
    Map<String, dynamic> deptData,
  ) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _apiClient.put(
        '${ApiConstants.departments}/$deptId',
        data: deptData,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteDepartment(String deptId) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _apiClient.delete('${ApiConstants.departments}/$deptId');
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Leave Type CRUD
  Future<bool> createLeaveType(Map<String, dynamic> typeData) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _apiClient.post(ApiConstants.leaveTypes, data: typeData);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateLeaveType(
    String typeId,
    Map<String, dynamic> typeData,
  ) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _apiClient.put(
        '${ApiConstants.leaveTypes}/$typeId',
        data: typeData,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteLeaveType(String typeId) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _apiClient.delete('${ApiConstants.leaveTypes}/$typeId');
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

class UserManagementState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  UserManagementState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  UserManagementState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return UserManagementState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

final userManagementProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
      return UserManagementNotifier();
    });
