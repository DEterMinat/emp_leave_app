import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../models/employee.dart';
import 'auth_provider.dart';

final employeesProvider = FutureProvider<List<Employee>>((ref) async {
  final response = await ref
      .watch(apiClientProvider)
      .get(ApiConstants.employees);
  final List data = response.data as List;
  return data.map((json) => Employee.fromJson(json)).toList();
});

final employeeDetailsProvider = FutureProvider.family<Employee, String>((
  ref,
  id,
) async {
  final response = await ref
      .watch(apiClientProvider)
      .get('${ApiConstants.employees}/$id');
  return Employee.fromJson(response.data);
});

// Provider to get the current user's employee profile
final myEmployeeProfileProvider = FutureProvider<Employee?>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.userId == null) return null;

  try {
    final response = await ref
        .watch(apiClientProvider)
        .get('${ApiConstants.employees}/user/${authState.userId}');
    return Employee.fromJson(response.data);
  } catch (e) {
    return null;
  }
});

// Provider for department-specific employees (Team)
final teamEmployeesProvider = FutureProvider.family<List<Employee>, String>((
  ref,
  departmentId,
) async {
  final response = await ref
      .watch(apiClientProvider)
      .get(
        '${ApiConstants.employees}',
        queryParameters: {'departmentId': departmentId},
      );
  final List data = response.data as List;
  return data.map((json) => Employee.fromJson(json)).toList();
});
