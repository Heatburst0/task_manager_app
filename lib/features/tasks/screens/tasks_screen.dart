import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../../../core/services/storage_service.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. GRADIENT BACKGROUND
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.2, 0.95],
                colors: [
                  theme.colorScheme.secondary.withOpacity(0.5),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
              duration: 3500.ms,
              color: theme.colorScheme.primary.withOpacity(0.1)),

          // 2. CONTENT AREA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // Custom Header
                  _buildHeader(context, ref),

                  const SizedBox(height: 20),

                  // Task List
                  Expanded(
                    child: taskState.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (tasks) {
                        if (tasks.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.task_alt, size: 80, color: theme.disabledColor),
                                const SizedBox(height: 16),
                                Text(
                                  "No tasks yet",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.disabledColor,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () => ref.read(taskProvider.notifier).loadTasks(),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
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
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () => _showTaskDialog(context, ref, task: null),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }

  // --- CUSTOM HEADER ---
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Tasks',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your daily to-dos.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        _buildHeaderButton(
          context: context,
          icon: Icons.logout,
          onTap: () {
            ref.read(storageServiceProvider).clearTokens();
            context.go('/login');
          },
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildHeaderButton({required BuildContext context, required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Icon(
          icon,
          size: 22,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  // --- TASK CARD ---
  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // 2. CHANGED ELEVATION
      elevation: 4,
      shadowColor: theme.shadowColor.withOpacity(0.3),
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
                  activeColor: theme.colorScheme.primary,
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
                  color: task.status == 'COMPLETED'
                      ? theme.disabledColor
                      : theme.colorScheme.onSurface,
                ),
              ),
              subtitle: task.description != null && task.description!.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.textTheme.bodySmall?.color),
                ),
              )
                  : null,
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit, size: 16, color: theme.colorScheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- DIALOG ---
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
              decoration: const InputDecoration(labelText: 'Title *'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description *'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () {
                ref.read(taskProvider.notifier).deleteTask(task.id);
                Navigator.pop(ctx);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text("Delete"),
            ),

          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),

          ElevatedButton(
            onPressed: () {
              // 1. MANDATORY VALIDATION LOGIC
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();

              if (title.isEmpty || desc.isEmpty) {
                // Show warning if empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Title and Description are required!"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return; // Stop execution
              }

              if (isEditing) {
                ref.read(taskProvider.notifier).editTaskDetails(
                    task, title, desc);
              } else {
                ref.read(taskProvider.notifier).addTask(title, desc);
              }
              Navigator.pop(ctx);
            },
            child: Text(isEditing ? "Save" : "Add"),
          )
        ],
      ),
    );
  }
}