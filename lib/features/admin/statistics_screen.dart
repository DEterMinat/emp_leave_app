import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/leave_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(allLeaveRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Statistics'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.gray800,
        elevation: 0,
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final total = requests.length;
          final approved = requests
              .where((r) => r.status.toLowerCase() == 'approved')
              .length;
          final rejected = requests
              .where((r) => r.status.toLowerCase() == 'rejected')
              .length;
          final pending = requests
              .where((r) => r.status.toLowerCase() == 'pending')
              .length;

          // Group by type
          final byType = <String, int>{};
          for (var r in requests) {
            final type = r.leaveTypeName ?? 'Other';
            byType[type] = (byType[type] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard('Total', '$total', Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        'Approved',
                        '$approved',
                        AppTheme.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        'Pending',
                        '$pending',
                        AppTheme.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        'Rejected',
                        '$rejected',
                        AppTheme.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Requests by Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...byType.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TypeBar(label: e.key, count: e.value, total: total),
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

class _TypeBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;

  const _TypeBar({
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '$count (${(pct * 100).toStringAsFixed(0)}%)',
              style: TextStyle(color: AppTheme.gray500, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: AppTheme.gray100,
            valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
          ),
        ),
      ],
    );
  }
}
