import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_management_provider.dart';

class LeaveTypeManagementScreen extends ConsumerWidget {
  const LeaveTypeManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(allLeaveTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Type Management'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.gray800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allLeaveTypesProvider),
          ),
        ],
      ),
      body: typesAsync.when(
        data: (types) {
          if (types.isEmpty) {
            return const Center(child: Text('No leave types found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.warning,
                    child: Icon(Icons.event_note, color: Colors.white),
                  ),
                  title: Text(
                    type['typeName'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(type['description'] ?? 'No description'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.gray500),
                        onPressed: () => _showTypeDialog(context, ref, type),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.danger),
                        onPressed: () => _confirmDelete(context, ref, type),
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
        onPressed: () => _showTypeDialog(context, ref),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showTypeDialog(
    BuildContext context,
    WidgetRef ref, [
    Map<String, dynamic>? type,
  ]) {
    final nameController = TextEditingController(text: type?['typeName']);
    final descController = TextEditingController(text: type?['description']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == null ? 'Add Leave Type' : 'Edit Leave Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Type Name'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              if (name.isEmpty) return;

              final notifier = ref.read(userManagementProvider.notifier);
              bool success;
              final data = {'typeName': name, 'description': desc};
              if (type == null) {
                success = await notifier.createLeaveType(data);
              } else {
                success = await notifier.updateLeaveType(type['id'], data);
              }

              if (success && context.mounted) {
                Navigator.pop(context);
                ref.invalidate(allLeaveTypesProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      type == null
                          ? 'Leave type created'
                          : 'Leave type updated',
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
    Map<String, dynamic> type,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Leave Type'),
        content: Text('Are you sure you want to delete ${type['typeName']}?'),
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
          .deleteLeaveType(type['id']);

      if (success && context.mounted) {
        ref.invalidate(allLeaveTypesProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Leave type deleted')));
      }
    }
  }
}
