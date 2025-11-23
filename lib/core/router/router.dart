import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../services/storage_service.dart';
import '../../features/tasks/screens/tasks_screen.dart';

// Placeholder for now
class TasksScreenPlaceholder extends ConsumerWidget {
  const TasksScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ref.read(storageServiceProvider).clearTokens();
            context.go('/login');
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final storage = ref.read(storageServiceProvider);
      final token = await storage.getAccessToken();
      final isLogin = state.uri.toString() == '/login';
      final isRegister = state.uri.toString() == '/register';

      // If logged in and trying to access auth pages, go to tasks
      if (token != null && (isLogin || isRegister)) {
        return '/tasks';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/tasks', builder: (context, state) => const TasksScreen()),
    ],
  );
});