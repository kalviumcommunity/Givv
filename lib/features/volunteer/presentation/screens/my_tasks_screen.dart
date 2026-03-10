import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../auth/providers/auth_providers.dart';
import '../../../organization/models/task_model.dart';
import '../../../organization/services/task_service.dart';

final myTasksProvider = StreamProvider<List<Task>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return TaskService().streamTasksByVolunteer(user.uid);
});

class MyTasksScreen extends ConsumerWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(myTasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('You have no assigned tasks', style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) => _buildTaskCard(context, ref, tasks[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                if (task.deadline != null)
                  Text('Due: ${task.deadline!.day}/${task.deadline!.month}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(task.description, style: TextStyle(color: Colors.blueGrey[600])),
            const SizedBox(height: 16),
            if (task.status == TaskStatus.pending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleSubmitProof(context, ref, task),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Complete & Upload Proof'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6794AA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            if (task.status == TaskStatus.completed)
              const Row(
                children: [
                  Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Waiting for organizer verification', style: TextStyle(color: Colors.orange, fontSize: 12)),
                ],
              ),
            if (task.status == TaskStatus.verified)
              const Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Verified! Points awarded.', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
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

  Future<void> _handleSubmitProof(BuildContext context, WidgetRef ref, Task task) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final noteController = TextEditingController();
      // Show dialog for additional note
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Submit Completion Proof'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(File(image.path), height: 150),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Short Note (optional)'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Upload logic
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading proof...')));
                  final service = TaskService();
                  final url = await service.uploadProofImage(task.id, File(image.path));
                  if (url != null) {
                    await service.submitTaskProof(task.id, url, noteController.text);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proof submitted!'), backgroundColor: Colors.green));
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      }
    }
  }
}
