import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/leave_provider.dart';
import '../../models/leave.dart';

class ManageRequestsScreen extends ConsumerWidget {
  const ManageRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(allLeaveRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Requests'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.gray800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allLeaveRequestsProvider),
          ),
        ],
      ),
      body: requestsAsync.when(
        data: (requests) {
          final pending = requests
              .where((r) => r.status.toLowerCase() == 'pending')
              .toList();
          final history = requests
              .where((r) => r.status.toLowerCase() != 'pending')
              .toList();

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.gray500,
                  indicatorColor: AppTheme.primary,
                  tabs: [
                    Tab(text: 'Pending'),
                    Tab(text: 'History'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _RequestList(requests: pending, isPending: true),
                      _RequestList(requests: history, isPending: false),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _RequestList extends ConsumerWidget {
  final List<LeaveRequest> requests;
  final bool isPending;

  const _RequestList({required this.requests, required this.isPending});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          isPending ? 'No pending requests' : 'No history',
          style: TextStyle(color: AppTheme.gray500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      req.username ?? 'Employee',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _StatusBadge(status: req.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${req.leaveTypeName} • ${req.totalDays} Days'),
                Text(
                  '${_formatDate(req.startDate)} - ${_formatDate(req.endDate)}',
                  style: TextStyle(color: AppTheme.gray600, fontSize: 13),
                ),
                if (req.reason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Reason: ${req.reason}',
                    style: TextStyle(
                      color: AppTheme.gray500,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _handleAction(context, ref, req.id, 'Rejected'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.danger,
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _handleAction(context, ref, req.id, 'Approved'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    String status,
  ) async {
    final success = await ref
        .read(leaveRequestNotifierProvider.notifier)
        .updateRequestStatus(requestId, status);
    if (success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request $status successfully')));
      ref.invalidate(allLeaveRequestsProvider);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    switch (status.toLowerCase()) {
      case 'approved':
        color = AppTheme.success;
        bgColor = AppTheme.success.withValues(alpha: 0.1);
        break;
      case 'rejected':
        color = AppTheme.danger;
        bgColor = AppTheme.danger.withValues(alpha: 0.1);
        break;
      default:
        color = AppTheme.warning;
        bgColor = AppTheme.warning.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
