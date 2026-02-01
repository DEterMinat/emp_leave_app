import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  NotificationNotifier() : super([]);

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
      return NotificationNotifier();
    });

final notificationServiceProvider = Provider((ref) {
  final service = NotificationService();
  // Link SignalR to NotificationNotifier
  service.onNotificationReceived = (title, message) {
    ref.read(notificationListProvider.notifier).addNotification(title, message);
  };
  return service;
});
