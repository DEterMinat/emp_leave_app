import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/activity_log.dart';
import '../core/services/notification_service.dart';

// Notification Model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

// Notification State Notifier
class NotificationNotifier extends StateNotifier<List<NotificationItem>> {
  final AuthState _authState;

  NotificationNotifier(this._authState) : super([]) {
    _loadInitialNotifications();
  }

  Future<void> _loadInitialNotifications() async {
    final role = _authState.roleName?.toLowerCase();
    // Only Admin and HR can access Activity Logs
    if (role != 'admin' && role != 'hr') {
      return;
    }

    try {
      final response = await ApiClient().get(ApiConstants.activityLogs);
      if (response.data is List) {
        final List data = response.data as List;
        final logs = data.map((json) => ActivityLog.fromJson(json)).toList();

        // Convert ActivityLogs to NotificationItems
        final notifications = logs.map((log) {
          return NotificationItem(
            id: log.id,
            title: '${log.action} - ${log.targetType}',
            message: log.details ?? 'Activity recorded',
            timestamp: log.createdAt,
          );
        }).toList();

        // Sort by date (newest first)
        notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        state = notifications;
      }
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
    }
  }

  void addNotification(String title, String message) {
    final newItem = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
    );
    state = [newItem, ...state];
  }

  void markAsRead(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();
  }

  void clearAll() {
    state = [];
  }
}

// Providers
final notificationListProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationItem>>((ref) {
      final authState = ref.watch(authProvider);
      return NotificationNotifier(authState);
    });

final notificationServiceProvider = Provider((ref) {
  final service = NotificationService();
  // Link SignalR to NotificationNotifier
  service.onNotificationReceived = (title, message) {
    ref.read(notificationListProvider.notifier).addNotification(title, message);
  };
  return service;
});
