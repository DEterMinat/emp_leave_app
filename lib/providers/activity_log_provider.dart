import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_log.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';

final activityLogProvider = FutureProvider<List<ActivityLog>>((ref) async {
  final response = await ApiClient().get(
    ApiConstants.activityLogs,
    queryParameters: {'limit': 100},
  );
  final List<dynamic> data = response.data;
  return data
      .map((json) => ActivityLog.fromJson(json as Map<String, dynamic>))
      .toList();
});
