import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';

import '../leave/leave_history_screen.dart';
import '../leave/leave_request_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/manage_requests_screen.dart';
import '../admin/employee_list_screen.dart';
import '../admin/team_management_screen.dart';
import '../admin/statistics_screen.dart';
import '../notification/notification_screen.dart';
import '../admin/user_management_screen.dart';
import '../admin/department_management_screen.dart';
import '../admin/leave_type_management_screen.dart';
import '../admin/activity_logs_screen.dart';
import '../../providers/notification_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final employeeId = authState.userId ?? '';
    final roleName = authState.roleName?.toLowerCase() ?? 'employee';

    // Watch leave data
    final requestsAsync = ref.watch(leaveRequestsProvider(employeeId));
    final balancesAsync = ref.watch(myLeaveBalancesProvider);
    final allRequestsAsync = ref.watch(allLeaveRequestsProvider);

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
                  // New Request Button (Only for Employee/Managers)
                  if (roleName != 'hr')
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
                        ref.invalidate(myLeaveBalancesProvider);
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text('New'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                  // Notification Bell
                  const SizedBox(width: 8),
                  Consumer(
                    builder: (context, ref, child) {
                      final notifications = ref.watch(notificationListProvider);
                      final unreadCount = notifications
                          .where((n) => !n.isRead)
                          .length;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationScreen(),
                                ),
                              );
                            },
                            color: AppTheme.gray600,
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.danger,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(leaveRequestsProvider(employeeId));
                  ref.invalidate(myLeaveBalancesProvider);
                  if (roleName == 'hr' || roleName == 'manager') {
                    ref.invalidate(allLeaveRequestsProvider);
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role-specific Header
                      if (roleName == 'hr' ||
                          roleName == 'manager' ||
                          roleName == 'admin')
                        _AdminQuickActions(roleName: roleName),

                      if (roleName == 'hr' ||
                          roleName == 'manager' ||
                          roleName == 'admin')
                        const SizedBox(height: 24),

                      // Team Stats (Only for Managers/HR/Admin)
                      if (roleName == 'hr' ||
                          roleName == 'manager' ||
                          roleName == 'admin') ...[
                        Text(
                          'Team Leave Overview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gray800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        allRequestsAsync.when(
                          data: (requests) {
                            final stats = DashboardStats.fromRequests(requests);
                            return _TeamStatsRow(stats: stats);
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error loading team stats: $e'),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Personal Stats Header
                      if (roleName == 'hr' ||
                          roleName == 'manager' ||
                          roleName == 'admin')
                        Text(
                          'My Leave Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gray800,
                          ),
                        ),
                      if (roleName == 'hr' ||
                          roleName == 'manager' ||
                          roleName == 'admin')
                        const SizedBox(height: 12),

                      // Stats Cards (Personal for Employee, Company for HR/Admin)
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

                      // Leave Balance Section (Only for personal view)
                      if (roleName != 'hr') ...[
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
                      ],

                      // Recent Requests Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            roleName == 'hr'
                                ? 'All Requests'
                                : 'Recent Request',
                            style: const TextStyle(
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
                                  employeeName: req.employeeName, // Pass name
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
                  if (roleName == 'hr' || roleName == 'manager')
                    _NavItem(
                      icon: Icons.rule,
                      label: 'Approvals',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageRequestsScreen(),
                          ),
                        );
                      },
                    ),
                  if (roleName == 'hr')
                    _NavItem(
                      icon: Icons.people_outline,
                      label: 'Employees',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmployeeListScreen(),
                          ),
                        );
                      },
                    ),
                  if (roleName == 'manager')
                    _NavItem(
                      icon: Icons.groups_outlined,
                      label: 'My Team',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TeamManagementScreen(),
                          ),
                        );
                      },
                    ),
                  if (roleName == 'admin')
                    _NavItem(
                      icon: Icons.manage_accounts,
                      label: 'Users',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserManagementScreen(),
                          ),
                        );
                      },
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

class _AdminQuickActions extends StatelessWidget {
  final String roleName;
  const _AdminQuickActions({required this.roleName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Management Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.gray800,
          ),
        ),
        const SizedBox(height: 12),
        // Row 1: Primary Actions
        Row(
          children: [
            if (roleName == 'hr' ||
                roleName == 'manager' ||
                roleName == 'admin')
              Expanded(
                child: _QuickActionCard(
                  title: 'Manage Requests',
                  subtitle: 'Approve or Reject',
                  icon: Icons.rule,
                  color: AppTheme.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageRequestsScreen(),
                      ),
                    );
                  },
                ),
              ),
            if (roleName == 'hr' || roleName == 'admin') ...[
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  title: 'Employees',
                  subtitle: 'Staff Directory',
                  icon: Icons.people_outline,
                  color: AppTheme.success,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmployeeListScreen(),
                      ),
                    );
                  },
                ),
              ),
            ] else if (roleName == 'manager') ...[
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  title: 'My Team',
                  subtitle: 'Team Overview',
                  icon: Icons.groups_outlined,
                  color: AppTheme.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TeamManagementScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),

        // Add additional rows for Admin
        if (roleName == 'admin') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: 'User Management',
                  subtitle: 'Login & Roles',
                  icon: Icons.manage_accounts,
                  color: AppTheme.danger,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserManagementScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  title: 'Dept Mgmt',
                  subtitle: 'Organization',
                  icon: Icons.business_outlined,
                  color: AppTheme.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DepartmentManagementScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: 'Leave Types',
                  subtitle: 'Policy Mgmt',
                  icon: Icons.event_note_outlined,
                  color: AppTheme.warning,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaveTypeManagementScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  title: 'Activity Logs',
                  subtitle: 'System Audit',
                  icon: Icons.history_outlined,
                  color: Colors.blueGrey,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ActivityLogsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],

        // Manager specific second row
        if (roleName == 'manager') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: 'Statistics',
                  subtitle: 'Leave Analysis',
                  icon: Icons.bar_chart,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StatisticsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.gray800,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: AppTheme.gray500),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamStatsRow extends StatelessWidget {
  final DashboardStats stats;

  const _TeamStatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _TeamStatItem(
                label: 'Pending Approval',
                value: '${stats.pendingRequests}',
                color: AppTheme.warning,
                icon: Icons.pending_actions,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.gray200,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              _TeamStatItem(
                label: 'Employees Off',
                value:
                    '${stats.totalRequests - stats.pendingRequests}', // This is a simplification
                color: AppTheme.success,
                icon: Icons.groups_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _TeamStatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gray800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: AppTheme.gray500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
  final String? employeeName;

  const _RequestCard({
    required this.type,
    required this.status,
    required this.dateRange,
    required this.reason,
    this.employeeName,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employeeName ?? 'Employee',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    type,
                    style: TextStyle(fontSize: 12, color: AppTheme.gray500),
                  ),
                ],
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
