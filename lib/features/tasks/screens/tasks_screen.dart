import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Add Animation
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
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
      body: Container(
        // Subtle Gradient Background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: taskState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (tasks) {
            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text("No tasks yet", style: Theme.of(context).textTheme.titleLarge),
                  ],
                ).animate().fadeIn(),
              );
            }
            return RefreshIndicator(
              onRefresh: () => ref.read(taskProvider.notifier).loadTasks(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  // Animated List Items
                  return _buildTaskCard(context, ref, task)
                      .animate(delay: (index * 50).ms)
                      .slideX(begin: 0.2, end: 0)
                      .fadeIn();
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context, ref, task: null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(task.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          ref.read(taskProvider.notifier).deleteTask(task.id);
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTaskDialog(context, ref, task: task),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: ListTile(
              leading: Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  shape: const CircleBorder(),
                  activeColor: Theme.of(context).primaryColor,
                  value: task.status == 'COMPLETED',
                  onChanged: (_) {
                    ref.read(taskProvider.notifier).toggleStatus(task);
                  },
                ),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: task.status == 'COMPLETED'
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.status == 'COMPLETED' ? Colors.grey : null,
                ),
              ),
              subtitle: task.description != null && task.description!.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
                  : null,
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit, size: 16, color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, WidgetRef ref, {Task? task}) {
    final isEditing = task != null;
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
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                if (isEditing) {
                  ref.read(taskProvider.notifier).editTaskDetails(
                      task, titleCtrl.text.trim(), descCtrl.text.trim());
                } else {
                  ref.read(taskProvider.notifier).addTask(
                      titleCtrl.text.trim(), descCtrl.text.trim());
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