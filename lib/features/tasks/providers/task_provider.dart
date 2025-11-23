import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

// The StateNotifier handles the list of tasks
class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repo;

  TaskNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _repo.getTasks();
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTask(String title, String description) async {
    try {
      final newTask = await _repo.createTask(title, description);
      // Optimistic Update: Add to list immediately
      state.whenData((tasks) => state = AsyncValue.data([newTask, ...tasks]));
    } catch (e) {
      // Handle error (show toast, etc.)
    }
  }

  Future<void> toggleStatus(Task task) async {
    final newStatus = task.status == 'COMPLETED' ? 'PENDING' : 'COMPLETED';

    // 1. Optimistic Update (Update UI instantly)
    state.whenData((tasks) {
      state = AsyncValue.data(tasks.map((t) {
        if (t.id == task.id) return t.copyWith(status: newStatus);
        return t;
      }).toList());
    });

    try {
      // 2. Call API
      await _repo.updateTask(task.id, {'status': newStatus});
    } catch (e) {
      // Revert on failure (reload list)
      loadTasks();
    }
  }

  Future<void> deleteTask(int id) async {
    // Optimistic Update
    state.whenData((tasks) {
      state = AsyncValue.data(tasks.where((t) => t.id != id).toList());
    });

    try {
      await _repo.deleteTask(id);
    } catch (e) {
      loadTasks(); // Revert
    }
  }

  Future<void> editTaskDetails(Task task, String newTitle, String newDescription) async {
    // 1. Optimistic Update: Update the UI immediately before the API responds
    state.whenData((tasks) {
      state = AsyncValue.data(tasks.map((t) {
        // If this is the task we are editing, replace it with the new values
        if (t.id == task.id) {
          return t.copyWith(title: newTitle, description: newDescription);
        }
        return t;
      }).toList());
    });

    try {
      // 2. Call API to save changes
      await _repo.updateTask(task.id, {
        'title': newTitle,
        'description': newDescription,
      });
    } catch (e) {
      // If API fails, revert the changes (reload from server)
      loadTasks();
    }
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskNotifier(ref.watch(taskRepositoryProvider));
});