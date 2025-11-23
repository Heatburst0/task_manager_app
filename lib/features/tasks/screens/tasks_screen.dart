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

    // 1. Listen for errors to show a Snackbar
    ref.listen<AsyncValue>(taskProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to fetch data. Please swipe to refresh."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => ref.read(taskProvider.notifier).loadTasks(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- BACKGROUND GRADIENT ---
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
          ),

          // --- CONTENT ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildHeader(context, ref),
                  const SizedBox(height: 20),

                  // 2. MOVED RefreshIndicator HERE (Wraps everything)
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ref.read(taskProvider.notifier).loadTasks(),
                      color: theme.colorScheme.primary,
                      child: taskState.when(
                        // Loading State
                        loading: () => const Center(child: CircularProgressIndicator()),

                        // Error State (Now Scrollable & Friendly)
                        error: (err, stack) => ListView(
                          physics: const AlwaysScrollableScrollPhysics(), // Key for Refresh
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_off, size: 80, color: theme.disabledColor),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Oops! Something went wrong.",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Swipe down to try again.",
                                    style: TextStyle(color: theme.disabledColor),
                                  ),
                                ],
                              ).animate().fadeIn(),
                            ),
                          ],
                        ),

                        // Data State
                        data: (tasks) {
                          if (tasks.isEmpty) {
                            // Empty State (Must be ListView for Refresh to work)
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                Center(
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
                                ),
                              ],
                            );
                          }
                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return _buildTaskCard(context, ref, task)
                                  .animate(delay: (index * 50).ms)
                                  .slideX(begin: 0.2, end: 0)
                                  .fadeIn();
                            },
                          );
                        },
                      ),
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

  // --- HEADER, CARD, and DIALOG functions remain EXACTLY the same as before ---
  // (Copy _buildHeader, _buildTaskCard, _showTaskDialog from previous response)

  // ... Paste helper methods here ...

  // --- COPY THESE HELPERS FROM PREVIOUS CODE ---
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
              Text('My Tasks', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 26, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 4),
              Text('Manage your daily to-dos.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
            ],
          ),
        ),
        _buildHeaderButton(context: context, icon: Icons.logout, onTap: () { ref.read(storageServiceProvider).clearTokens(); context.go('/login'); }),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildHeaderButton({required BuildContext context, required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.3), width: 1)), child: InkWell(borderRadius: BorderRadius.circular(16), onTap: onTap, child: Icon(icon, size: 22, color: theme.colorScheme.onSurface)));
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(task.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) { ref.read(taskProvider.notifier).deleteTask(task.id); },
      background: Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 4,
        shadowColor: theme.shadowColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showTaskDialog(context, ref, task: task),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: ListTile(
              leading: Transform.scale(scale: 1.5, child: Checkbox(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), activeColor: theme.colorScheme.primary, value: task.status == 'COMPLETED', onChanged: (_) { ref.read(taskProvider.notifier).toggleStatus(task); })),
              title: Text(task.title, style: TextStyle(fontWeight: FontWeight.w600, decoration: task.status == 'COMPLETED' ? TextDecoration.lineThrough : null, color: task.status == 'COMPLETED' ? theme.disabledColor : theme.colorScheme.onSurface)),
              subtitle: task.description != null && task.description!.isNotEmpty ? Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(task.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: theme.textTheme.bodySmall?.color))) : null,
              trailing: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit, size: 16, color: theme.colorScheme.primary)),
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
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(isEditing ? "Edit Task" : "New Task"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title *'), autofocus: true), const SizedBox(height: 16), TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description *'), maxLines: 3)]), actions: [if (isEditing) TextButton(onPressed: () { ref.read(taskProvider.notifier).deleteTask(task.id); Navigator.pop(ctx); }, style: TextButton.styleFrom(foregroundColor: Colors.redAccent), child: const Text("Delete")), TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")), ElevatedButton(onPressed: () { final title = titleCtrl.text.trim(); final desc = descCtrl.text.trim(); if (title.isEmpty || desc.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title and Description are required!"), backgroundColor: Colors.redAccent)); return; } if (isEditing) { ref.read(taskProvider.notifier).editTaskDetails(task, title, desc); } else { ref.read(taskProvider.notifier).addTask(title, desc); } Navigator.pop(ctx); }, child: Text(isEditing ? "Save" : "Add"))]));
  }
}