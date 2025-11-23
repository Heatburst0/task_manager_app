import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';
import '../models/task.dart'; // Import Task model
import '../../../core/services/storage_service.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(storageServiceProvider).clearTokens();
              context.go('/login');
            },
          )
        ],
      ),
      body: taskState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text("No tasks yet. Create one!"));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(taskProvider.notifier).loadTasks(),
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: Key(task.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(taskProvider.notifier).deleteTask(task.id);
                  },
                  child: ListTile(
                    // 1. Tapping the whole row opens the Edit Dialog
                    onTap: () => _showTaskDialog(context, ref, task: task),

                    leading: Checkbox(
                      value: task.status == 'COMPLETED',
                      onChanged: (_) {
                        ref.read(taskProvider.notifier).toggleStatus(task);
                      },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.status == 'COMPLETED'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(task.description ?? ''),
                    trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // 2. Tapping FAB opens Dialog in "Add Mode" (task is null)
        onPressed: () => _showTaskDialog(context, ref, task: null),
        child: const Icon(Icons.add),
      ),
    );
  }

  // A Reusable Dialog for both Adding and Editing
  void _showTaskDialog(BuildContext context, WidgetRef ref, {Task? task}) {
    final isEditing = task != null;

    // Pre-fill controllers if editing, otherwise empty
    final titleCtrl = TextEditingController(text: isEditing ? task.title : '');
    final descCtrl = TextEditingController(text: isEditing ? task.description : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? "Edit Task" : "New Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                if (isEditing) {
                  // CALL EDIT METHOD
                  ref.read(taskProvider.notifier).editTaskDetails(
                      task,
                      titleCtrl.text.trim(),
                      descCtrl.text.trim()
                  );
                } else {
                  // CALL ADD METHOD
                  ref.read(taskProvider.notifier).addTask(
                      titleCtrl.text.trim(),
                      descCtrl.text.trim()
                  );
                }
                Navigator.pop(ctx);
              }
            },
            child: Text(isEditing ? "Save" : "Add"),
          )
        ],
      ),
    );
  }
}