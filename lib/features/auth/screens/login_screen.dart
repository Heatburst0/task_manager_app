import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum AuthMode { login, signup }

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthMode _authMode = AuthMode.login;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _authMode =
      _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authControllerProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool success;
    if (_authMode == AuthMode.login) {
      success = await authNotifier.login(email, password);
    } else {
      success = await authNotifier.register(email, password);
    }

    if (success && mounted) {
      if (_authMode == AuthMode.signup) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created! Logging you in...')),
        );
        // Auto login after register
        final loginSuccess = await authNotifier.login(email, password);
        if(loginSuccess && mounted) context.go('/tasks');
      } else {
        context.go('/tasks');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for errors and show SnackBar
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.error != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, // Changed Icon to match Task App
                    size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Task Manager',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  _authMode == AuthMode.login
                      ? 'Sign in to continue'
                      : 'Create a new account',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 40),
                _buildForm(context),
                const SizedBox(height: 24),
                // _buildSocialLogin(context), // Hiding social login as backend doesn't support it yet
              ],
            ).animate().fadeIn(duration: 500.ms),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
                labelText: 'Email', prefixIcon: Icon(Icons.alternate_email)),
            keyboardType: TextInputType.emailAddress,
            validator: (val) =>
            Validators.isValidEmail(val ?? '') ? null : 'Enter a valid email',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
                labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
            obscureText: true,
            validator: (val) => Validators.isValidPassword(val ?? '')
                ? null
                : 'Password too short (min 6 chars)',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _submit,
              child: Text(
                  _authMode == AuthMode.login ? 'Login' : 'Sign Up'),
            ),
          ),
          TextButton(
            onPressed: _switchAuthMode,
            child: Text(_authMode == AuthMode.login
                ? "Don't have an account? Sign Up"
                : "Already have an account? Login"),
          ),
        ]
            .animate(interval: 100.ms)
            .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic)
            .fadeIn(),
      ),
    );
  }
}