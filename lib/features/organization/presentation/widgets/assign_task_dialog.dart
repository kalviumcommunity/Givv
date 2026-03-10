import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event_model.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class AssignTaskDialog extends ConsumerStatefulWidget {
  final Event event;

  const AssignTaskDialog({super.key, required this.event});

  @override
  ConsumerState<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends ConsumerState<AssignTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedVolunteer;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign New Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title', hintText: 'e.g. Clean north side'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedVolunteer,
                decoration: const InputDecoration(labelText: 'Assign To'),
                items: widget.event.volunteersJoined.map((v) => DropdownMenuItem(value: v, child: Text('Volunteer $v'))).toList(),
                onChanged: (val) => setState(() => _selectedVolunteer = val),
                validator: (val) => val == null ? 'Select a volunteer' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6794AA), foregroundColor: Colors.white),
          child: const Text('Assign'),
        ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedVolunteer != null) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        assignedTo: _selectedVolunteer!,
        eventId: widget.event.id,
        status: TaskStatus.pending,
      );

      final success = await ref.read(taskProvider.notifier).createTask(task);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }
}
