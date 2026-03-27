import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/activity_log_provider.dart';
import '../../models/activity_log.dart';

class ActivityLogsScreen extends ConsumerWidget {
  const ActivityLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(activityLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Activity Logs'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.gray800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(activityLogProvider),
          ),
        ],
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No activity logs found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return _ActivityLogCard(log: log);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _ActivityLogCard extends StatelessWidget {
  final ActivityLog log;

  const _ActivityLogCard({required this.log});

  Color _getActionColor() {
    if (log.action.contains('CREATE')) return AppTheme.success;
    if (log.action.contains('UPDATE')) return AppTheme.primary;
    if (log.action.contains('DELETE')) return AppTheme.danger;
    if (log.action.contains('APPROVE')) return Colors.green;
    if (log.action.contains('REJECT')) return AppTheme.warning;
    return AppTheme.gray500;
  }

  IconData _getActionIcon() {
    if (log.action.contains('CREATE')) return Icons.add_circle_outline;
    if (log.action.contains('UPDATE')) return Icons.edit_outlined;
    if (log.action.contains('DELETE')) return Icons.delete_outline;
    if (log.action.contains('APPROVE')) return Icons.check_circle_outline;
    if (log.action.contains('REJECT')) return Icons.cancel_outlined;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = _getActionColor();
    final timeStr = DateFormat(
      'MMM dd, yyyy HH:mm',
    ).format(log.createdAt.toLocal());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: actionColor.withValues(alpha: 0.2), width: 1),
      ),
      elevation: 0,
      color: actionColor.withValues(alpha: 0.02),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getActionIcon(), color: actionColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  log.action.replaceAll('_', ' '),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: actionColor,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  timeStr,
                  style: TextStyle(color: AppTheme.gray500, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              log.details ?? 'No details provided',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.gray800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: AppTheme.gray400),
                const SizedBox(width: 4),
                Text(
                  'By: ${log.username ?? "Unknown"}',
                  style: TextStyle(color: AppTheme.gray600, fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.category_outlined,
                  size: 14,
                  color: AppTheme.gray400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Target: ${log.targetType}',
                  style: TextStyle(color: AppTheme.gray600, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
