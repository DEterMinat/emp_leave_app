import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final employeeId = authState.userId ?? '';
    final attendanceHistoryAsync = ref.watch(attendanceHistoryProvider(employeeId));

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.gray800,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(attendanceHistoryProvider(employeeId));
        },
        child: attendanceHistoryAsync.when(
          data: (records) {
            if (records.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return _AttendanceHistoryCard(record: record);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading history: $err')),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: AppTheme.gray400),
          const SizedBox(height: 16),
          Text(
            'No attendance records found.',
            style: TextStyle(color: AppTheme.gray500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _AttendanceHistoryCard extends StatelessWidget {
  final Attendance record;

  const _AttendanceHistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(record.attendanceDate);
    final checkInStr = record.checkInTime != null 
        ? DateFormat('hh:mm a').format(record.checkInTime!) 
        : '--:--';
    final checkOutStr = record.checkOutTime != null 
        ? DateFormat('hh:mm a').format(record.checkOutTime!) 
        : '--:--';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              _StatusBadge(status: record.status ?? 'Present'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeInfo(
                  label: 'Check In',
                  time: checkInStr,
                  icon: Icons.login_rounded,
                  color: AppTheme.primary,
                ),
              ),
              Container(height: 30, width: 1, color: AppTheme.gray200),
              Expanded(
                child: _TimeInfo(
                  label: 'Check Out',
                  time: checkOutStr,
                  icon: Icons.logout_rounded,
                  color: AppTheme.warning,
                ),
              ),
            ],
          ),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.notes, size: 14, color: AppTheme.gray500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.notes!,
                      style: TextStyle(fontSize: 12, color: AppTheme.gray600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimeInfo({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppTheme.gray500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'late':
        bgColor = AppTheme.danger.withOpacity(0.1);
        textColor = AppTheme.danger;
        break;
      case 'absent':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case 'leave':
        bgColor = AppTheme.info.withOpacity(0.1);
        textColor = AppTheme.info;
        break;
      default: // Present
        bgColor = AppTheme.success.withOpacity(0.1);
        textColor = AppTheme.success;
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
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
