import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/employee_provider.dart';
import 'employee_detail_screen.dart';

class TeamManagementScreen extends ConsumerWidget {
  const TeamManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myProfileAsync = ref.watch(myEmployeeProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Team'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.gray800,
        elevation: 0,
      ),
      body: myProfileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile information not found'));
          }

          if (profile.departmentId == null) {
            return const Center(
              child: Text('Department information not found'),
            );
          }

          final teamAsync = ref.watch(
            teamEmployeesProvider(profile.departmentId),
          );

          return teamAsync.when(
            data: (members) {
              if (members.isEmpty) {
                return const Center(child: Text('No team members found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  // Don't show self in team list (optional)
                  if (member.id == profile.id) return const SizedBox();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.purple.withValues(alpha: 0.1),
                        child: Text(
                          member.firstName[0],
                          style: const TextStyle(
                            color: AppTheme.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text('${member.firstName} ${member.lastName}'),
                      subtitle: Text(member.email),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EmployeeDetailScreen(employeeId: member.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading team: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading profile: $err')),
      ),
    );
  }
}
