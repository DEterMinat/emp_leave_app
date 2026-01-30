import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';

import '../leave/leave_history_screen.dart';
import '../leave/leave_request_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final employeeId = authState.userId ?? '';

    // Watch leave data
    final requestsAsync = ref.watch(leaveRequestsProvider(employeeId));
    final balancesAsync = ref.watch(leaveBalancesProvider(employeeId));

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppTheme.gray200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // User Avatar
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppTheme.logoGradient,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.username ?? 'Username',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gray800,
                          ),
                        ),
                        Text(
                          '${authState.roleName ?? 'Employee'} - IT',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // New Request Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LeaveRequestScreen(),
                        ),
                      );
                      // Refresh data after returning
                      ref.invalidate(leaveRequestsProvider(employeeId));
                      ref.invalidate(leaveBalancesProvider(employeeId));
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('New Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(leaveRequestsProvider(employeeId));
                  ref.invalidate(leaveBalancesProvider(employeeId));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards
                      requestsAsync.when(
                        data: (requests) {
                          final stats = DashboardStats.fromRequests(requests);
                          return Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'Total Request',
                                  value: '${stats.totalRequests}',
                                  icon: Icons.assignment_outlined,
                                  iconColor: AppTheme.gray400,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'Pending',
                                  value: '${stats.pendingRequests}',
                                  valueColor: AppTheme.warning,
                                  icon: Icons.schedule,
                                  iconColor: AppTheme.warning,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'Days Off',
                                  value: '${stats.totalDaysOff}',
                                  valueColor: AppTheme.purple,
                                  icon: Icons.trending_up,
                                  iconColor: AppTheme.purple,
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, _) =>
                            _ErrorCard(message: 'Failed to load stats'),
                      ),

                      const SizedBox(height: 24),

                      // Leave Balance Section
                      const Text(
                        'Leave Balance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gray800,
                        ),
                      ),
                      const SizedBox(height: 12),

                      balancesAsync.when(
                        data: (balances) {
                          if (balances.isEmpty) {
                            return _EmptyCard(message: 'No balance data');
                          }
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: balances.map((balance) {
                              return SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width - 44) /
                                    3,
                                child: _LeaveBalanceCard(
                                  title: balance.leaveTypeName ?? 'Leave',
                                  remaining: balance.remainingDays,
                                  total: balance.totalDays,
                                  progressColor: _getColorForType(
                                    balance.leaveTypeName,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, _) =>
                            _ErrorCard(message: 'Failed to load balances'),
                      ),

                      const SizedBox(height: 24),

                      // Recent Requests Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Request',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gray800,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LeaveHistoryScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'View All',
                              style: TextStyle(color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      requestsAsync.when(
                        data: (requests) {
                          if (requests.isEmpty) {
                            return _EmptyCard(message: 'No requests yet');
                          }
                          final recent = requests.take(3).toList();
                          return Column(
                            children: recent.map((req) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RequestCard(
                                  type: req.leaveTypeName ?? 'Leave',
                                  status: req.status,
                                  dateRange: _formatDateRange(
                                    req.startDate,
                                    req.endDate,
                                  ),
                                  reason: req.reason,
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const SizedBox(),
                        error: (err, _) =>
                            _ErrorCard(message: 'Failed to load requests'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.gray200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    isActive: true,
                    onTap: () {},
                  ),
                  _NavItem(
                    icon: Icons.description_outlined,
                    label: 'My Request',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LeaveHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(String? typeName) {
    if (typeName == null) return AppTheme.primary;
    final name = typeName.toLowerCase();
    if (name.contains('annual')) return AppTheme.primary;
    if (name.contains('sick')) return AppTheme.success;
    if (name.contains('personal')) return AppTheme.purple;
    return AppTheme.warning;
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (start == end) {
      return '${months[start.month - 1]} ${start.day}, ${start.year}';
    }
    return '${months[start.month - 1]} ${start.day} - ${months[end.month - 1]} ${end.day}, ${end.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.valueColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppTheme.gray800,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: AppTheme.gray500)),
        ],
      ),
    );
  }
}

class _LeaveBalanceCard extends StatelessWidget {
  final String title;
  final int remaining;
  final int total;
  final Color progressColor;

  const _LeaveBalanceCard({
    required this.title,
    required this.remaining,
    required this.total,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final used = total - remaining;
    final progress = total > 0 ? used / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$remaining',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '/$total',
                style: TextStyle(fontSize: 12, color: AppTheme.gray400),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: AppTheme.gray600),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.gray100,
              valueColor: AlwaysStoppedAnimation(progressColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String type;
  final String status;
  final String dateRange;
  final String reason;

  const _RequestCard({
    required this.type,
    required this.status,
    required this.dateRange,
    required this.reason,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppTheme.success;
      case 'rejected':
        return AppTheme.danger;
      default:
        return AppTheme.warning;
    }
  }

  Color _getStatusBgColor() {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFFD1FAE5);
      case 'rejected':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppTheme.gray500),
              const SizedBox(width: 8),
              Text(
                dateRange,
                style: TextStyle(fontSize: 14, color: AppTheme.gray500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reason: $reason',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray500,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppTheme.primary : AppTheme.gray500),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppTheme.primary : AppTheme.gray500,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.danger),
          const SizedBox(width: 8),
          Text(message, style: TextStyle(color: AppTheme.danger)),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Center(
        child: Text(message, style: TextStyle(color: AppTheme.gray500)),
      ),
    );
  }
}
