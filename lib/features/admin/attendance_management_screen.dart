import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/attendance_provider.dart';

class AttendanceManagementScreen extends ConsumerStatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  ConsumerState<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends ConsumerState<AttendanceManagementScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // For now, this uses the history provider but we might need a dedicated "get all for date" provider
    // In a real app, we'd have a specific provider for this.
    // For this demo, we'll assume we can use the history provider for a fixed set of employees or a general one.
    // Since we don't have a "get all" provider yet, I'll create a placeholder UI or use a dummy list.

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Attendance Management'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.gray800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _DateHeader(date: _selectedDate),
          Expanded(
            child: _AttendanceSummaryList(date: _selectedDate),
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            DateFormat('EEEE').format(date),
            style: TextStyle(color: AppTheme.gray500, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMMM d, yyyy').format(date),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.gray800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceSummaryList extends ConsumerWidget {
  final DateTime date;
  const _AttendanceSummaryList({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(allAttendanceProvider(date));

    return attendanceAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 48, color: AppTheme.gray300),
                const SizedBox(height: 16),
                Text('No records for this date', style: TextStyle(color: AppTheme.gray500)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _AttendanceUserCard(
              name: record.employeeName ?? 'Unknown',
              status: record.status ?? 'Present',
              checkIn: record.checkInTime != null 
                  ? DateFormat('hh:mm a').format(record.checkInTime!) 
                  : '-',
              checkOut: record.checkOutTime != null 
                  ? DateFormat('hh:mm a').format(record.checkOutTime!) 
                  : '-',
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _AttendanceUserCard extends StatelessWidget {
  final String name;
  final String status;
  final String checkIn;
  final String checkOut;

  const _AttendanceUserCard({
    required this.name,
    required this.status,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: Text(name[0], style: const TextStyle(color: AppTheme.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'In: $checkIn  Out: $checkOut',
                  style: TextStyle(color: AppTheme.gray500, fontSize: 12),
                ),
              ],
            ),
          ),
          _StatusBadge(status: status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'present': color = AppTheme.success; break;
      case 'late': color = AppTheme.warning; break;
      case 'absent': color = Colors.red; break;
      case 'leave': color = AppTheme.info; break;
      default: color = AppTheme.gray500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
