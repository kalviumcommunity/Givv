import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event_model.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../../volunteer/services/point_service.dart';
import 'assign_task_dialog.dart';

class TaskManagementTab extends ConsumerWidget {
  final Event event;

  const TaskManagementTab({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(eventTasksProvider(event.id));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Event Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAssignTaskDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Assign Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6794AA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks assigned yet', style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(context, ref, tasks[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AssignTaskDialog(event: event),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.status.name.toUpperCase(),
                    style: TextStyle(color: _getStatusColor(task.status), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text('Assigned to: ${task.assignedTo}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(task.description, style: TextStyle(color: Colors.blueGrey[600], fontSize: 14)),
            if (task.status == TaskStatus.completed) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.image_outlined, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text('Proof Submitted', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showVerificationDialog(context, ref, task),
                    child: const Text('Review Proof'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending: return Colors.orange;
      case TaskStatus.completed: return Colors.blue;
      case TaskStatus.verified: return Colors.green;
      case TaskStatus.rejected: return Colors.red;
    }
  }

  void _showVerificationDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.proofImageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: NetworkImage(task.proofImageUrl!), fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 12),
            Text('Note: ${task.proofNote ?? "No note provided"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(taskProvider.notifier).verifyTask(task.id, false);
              Navigator.pop(context);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(taskProvider.notifier).verifyTask(task.id, true);
              if (success) {
                await PointService().awardPointsForTaskVerification(task.assignedTo);
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Approve & Award Points'),
          ),
        ],
      ),
    );
  }
}
