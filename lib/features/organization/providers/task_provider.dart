import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

final eventTasksProvider = StreamProvider.family<List<Task>, String>((ref, eventId) {
  return ref.watch(taskServiceProvider).streamTasksByEvent(eventId);
});

class TaskNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> createTask(Task task) async {
    final result = await AsyncValue.guard(() => 
      ref.read(taskServiceProvider).createTask(task)
    );
    return !result.hasError;
  }

  Future<bool> verifyTask(String taskId, bool approved) async {
    final result = await AsyncValue.guard(() => 
      ref.read(taskServiceProvider).verifyTask(taskId, approved)
    );
    return !result.hasError;
  }
}

final taskProvider = AsyncNotifierProvider<TaskNotifier, void>(() => TaskNotifier());
