import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/employee_provider.dart';
import '../../providers/leave_provider.dart';
import '../../models/employee.dart';
import '../../models/leave.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  final String employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeDetailsProvider(employeeId));
    final balancesAsync = ref.watch(leaveBalancesProvider(employeeId));
    final requestsAsync = ref.watch(leaveRequestsProvider(employeeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.gray800,
        elevation: 0,
      ),
      body: employeeAsync.when(
        data: (employee) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EmployeeHeader(employee: employee),
              const SizedBox(height: 24),
              const Text(
                'Leave Balances',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              balancesAsync.when(
                data: (balances) => _BalanceList(balances: balances),
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error loading balances: $err'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              requestsAsync.when(
                data: (requests) => _RequestList(requests: requests),
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error loading requests: $err'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _EmployeeHeader extends StatelessWidget {
  final Employee employee;
  const _EmployeeHeader({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            child: Text(
              employee.firstName[0],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${employee.firstName} ${employee.lastName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  employee.departmentName ?? 'No Department',
                  style: TextStyle(color: AppTheme.gray600),
                ),
                if (employee.position != null)
                  Text(
                    employee.position!,
                    style: TextStyle(color: AppTheme.gray600, fontSize: 13),
                  ),
                if (employee.salary != null)
                  Text(
                    'Salary: \$${employee.salary}',
                    style: TextStyle(color: AppTheme.gray600, fontSize: 13),
                  ),
                const SizedBox(height: 4),
                Text(
                  employee.email,
                  style: TextStyle(color: AppTheme.gray500, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceList extends StatelessWidget {
  final List<LeaveBalance> balances;
  const _BalanceList({required this.balances});

  @override
  Widget build(BuildContext context) {
    if (balances.isEmpty) return const Text('No balance data');
    return Column(
      children: balances
          .map(
            (b) => ListTile(
              title: Text(b.leaveTypeName ?? 'Leave'),
              trailing: Text('${b.remainingDays}/${b.totalDays} Days'),
            ),
          )
          .toList(),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<LeaveRequest> requests;
  const _RequestList({required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) return const Text('No requests found');
    return Column(
      children: requests
          .take(5)
          .map(
            (r) => ListTile(
              title: Text(r.leaveTypeName ?? 'Leave'),
              subtitle: Text(
                '${r.startDate.day}/${r.startDate.month} - ${r.endDate.day}/${r.endDate.month}',
              ),
              trailing: _StatusBadge(status: r.status),
            ),
          )
          .toList(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppTheme.success;
      case 'rejected':
        return AppTheme.danger;
      default:
        return AppTheme.warning;
    }
  }
}
