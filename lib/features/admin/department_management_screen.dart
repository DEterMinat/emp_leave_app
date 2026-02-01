import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_management_provider.dart';

class DepartmentManagementScreen extends ConsumerWidget {
  const DepartmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptsAsync = ref.watch(allDepartmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Management'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.gray800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allDepartmentsProvider),
          ),
        ],
      ),
      body: deptsAsync.when(
        data: (depts) {
          if (depts.isEmpty) {
            return const Center(child: Text('No departments found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: depts.length,
            itemBuilder: (context, index) {
              final dept = depts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.business, color: Colors.white),
                  ),
                  title: Text(
                    dept['departmentName'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${dept['id']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.gray500),
                        onPressed: () => _showDeptDialog(context, ref, dept),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.danger),
                        onPressed: () => _confirmDelete(context, ref, dept),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDeptDialog(context, ref),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeptDialog(
    BuildContext context,
    WidgetRef ref, [
    Map<String, dynamic>? dept,
  ]) {
    final controller = TextEditingController(text: dept?['departmentName']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dept == null ? 'Add Department' : 'Edit Department'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Department Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final notifier = ref.read(userManagementProvider.notifier);
              bool success;
              if (dept == null) {
                success = await notifier.createDepartment({
                  'departmentName': name,
                });
              } else {
                success = await notifier.updateDepartment(dept['id'], {
                  'departmentName': name,
                });
              }

              if (success && context.mounted) {
                Navigator.pop(context);
                ref.invalidate(allDepartmentsProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      dept == null
                          ? 'Department created'
                          : 'Department updated',
                    ),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> dept,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text(
          'Are you sure you want to delete ${dept['departmentName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(userManagementProvider.notifier)
          .deleteDepartment(dept['id']);

      if (success && context.mounted) {
        ref.invalidate(allDepartmentsProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Department deleted')));
      }
    }
  }
}
