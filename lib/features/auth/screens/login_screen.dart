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

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController(); // 1. New Controller

  // State Variables
  AuthMode _authMode = AuthMode.login;
  bool _isPasswordVisible = false; // 2. Toggle state for Password
  bool _isConfirmVisible = false;  // 3. Toggle state for Confirm Password

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
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
                Icon(Icons.check_circle_outline,
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
              ],
            ).animate().fadeIn(duration: 500.ms),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // --- EMAIL FIELD ---
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
                labelText: 'Email', prefixIcon: Icon(Icons.alternate_email)),
            keyboardType: TextInputType.emailAddress,
            validator: (val) =>
            Validators.isValidEmail(val ?? '') ? null : 'Enter a valid email',
          ),
          const SizedBox(height: 16),

          // --- PASSWORD FIELD ---
          TextFormField(
            controller: _passwordController,
            // 4. Use State variable to toggle visibility
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              // 5. Add Toggle Icon Button
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (val) => Validators.isValidPassword(val ?? '')
                ? null
                : 'Password too short (min 6 chars)',
          ),

          // --- CONFIRM PASSWORD FIELD (Only for Sign Up) ---
          if (_authMode == AuthMode.signup) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPassController,
              obscureText: !_isConfirmVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_reset),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmVisible = !_isConfirmVisible;
                    });
                  },
                ),
              ),
              validator: (val) {
                if (val != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ).animate().fadeIn().slideY(begin: -0.2, end: 0),
          ],

          const SizedBox(height: 24),

          // --- SUBMIT BUTTON ---
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

          // --- SWITCH MODE BUTTON ---
          TextButton(
            onPressed: () {
              // Clear inputs when switching
              _formKey.currentState?.reset();
              _emailController.clear();
              _passwordController.clear();
              _confirmPassController.clear();
              _switchAuthMode();
            },
            child: Text(_authMode == AuthMode.login
                ? "Don't have an account? Sign Up"
                : "Already have an account? Login"),
          ),
        ]
            .animate(interval: 50.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic)
            .fadeIn(),
      ),
    );
  }
}