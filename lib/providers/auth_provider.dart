import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/user.dart';

// Auth State
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? token;
  final String? userId;
  final String? username;
  final String? roleId;
  final String? roleName;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.token,
    this.userId,
    this.username,
    this.roleId,
    this.roleName,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? token,
    String? userId,
    String? username,
    String? roleId,
    String? roleName,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthNotifier(this._apiClient) : super(AuthState());

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.token);

    if (token != null) {
      _apiClient.setToken(token);
      state = AuthState(
        isAuthenticated: true,
        token: token,
        userId: prefs.getString(StorageKeys.userId),
        username: prefs.getString(StorageKeys.username),
        roleId: prefs.getString(StorageKeys.roleId),
        roleName: prefs.getString(StorageKeys.roleName),
      );
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'username': username, 'password': password},
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.token, loginResponse.token);
      await prefs.setString(StorageKeys.userId, loginResponse.userId);
      await prefs.setString(StorageKeys.username, loginResponse.username);
      await prefs.setString(StorageKeys.roleId, loginResponse.roleId);
      if (loginResponse.roleName != null) {
        await prefs.setString(StorageKeys.roleName, loginResponse.roleName!);
      }

      // Set token in API client
      _apiClient.setToken(loginResponse.token);

      state = AuthState(
        isAuthenticated: true,
        token: loginResponse.token,
        userId: loginResponse.userId,
        username: loginResponse.username,
        roleId: loginResponse.roleId,
        roleName: loginResponse.roleName,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Login failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _apiClient.clearToken();
    state = AuthState();
  }
}

// Providers
final apiClientProvider = Provider((ref) => ApiClient());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiClientProvider));
});
