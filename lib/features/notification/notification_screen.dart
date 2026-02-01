import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.gray800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              ref.read(notificationListProvider.notifier).clearAll();
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: AppTheme.gray400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: AppTheme.gray500, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.notifications,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.message),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(notification.timestamp),
                        style: TextStyle(fontSize: 12, color: AppTheme.gray400),
                      ),
                    ],
                  ),
                  tileColor: notification.isRead
                      ? Colors.white
                      : AppTheme.gray50,
                  onTap: () {
                    ref
                        .read(notificationListProvider.notifier)
                        .markAsRead(notification.id);
                  },
                );
              },
            ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
