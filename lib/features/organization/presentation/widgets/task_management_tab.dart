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

                final pendingReview = tasks.where((t) => t.status == TaskStatus.completed).toList();

                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: const Color(0xFF6794AA),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF6794AA),
                        tabs: [
                          Tab(text: 'Pending Review (${pendingReview.length})'),
                          Tab(text: 'All Tasks (${tasks.length})'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildTaskList(pendingReview, context, ref, emptyMsg: 'No tasks pending review.'),
                            _buildTaskList(tasks, context, ref, emptyMsg: 'No tasks assigned.'),
                          ],
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildTaskList(List<Task> tasks, BuildContext context, WidgetRef ref, {required String emptyMsg}) {
    if (tasks.isEmpty) {
      return Center(child: Text(emptyMsg, style: const TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(context, ref, tasks[index]);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task) {
    final needsReview = task.status == TaskStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: needsReview ? const BorderSide(color: Colors.blueAccent, width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        onTap: needsReview ? () => _showVerificationDialog(context, ref, task) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  // In a real app we'd resolve UserID to Name. Here we truncate ID as makeshift placeholder.
                  Text('Volunteer ID: ${task.assignedTo.substring(0, 5)}...', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                ],
              ),
              const SizedBox(height: 12),
              Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(task.description, style: TextStyle(color: Colors.blueGrey[600], fontSize: 14)),
              if (needsReview) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.touch_app, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('Tap anywhere to review submission', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF6FF),
                        foregroundColor: const Color(0xFF6794AA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showVerificationDialog(context, ref, task),
                      child: const Text('Review', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
        title: const Text('Review Submission', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Task Details', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              if (task.proofImageUrl != null) ...[
                const Text('Proof Image provided', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: NetworkImage(task.proofImageUrl!), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text('Volunteer\'s Note:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(task.proofNote?.isNotEmpty == true ? task.proofNote! : "No additional note provided", style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            ],
          ),
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
