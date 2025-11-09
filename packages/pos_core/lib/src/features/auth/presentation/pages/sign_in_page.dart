import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/auth/auth_repository.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_sizes.dart';

/// Sign-in page with email/password or PIN authentication.
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();

  bool _isPinMode = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authStateNotifierProvider.notifier);

      if (_isPinMode) {
        // PIN login
        await authNotifier.loginWithPin(
          PinLoginCredentials(
            pin: _pinController.text.trim(),
          ),
        );
      } else {
        // Email/password login
        await authNotifier.loginWithPassword(
          LoginCredentials(
            identifier: _identifierController.text.trim(),
            password: _passwordController.text,
          ),
        );
      }

      // Check if login was successful
      final authState = ref.read(authStateNotifierProvider);
      authState.whenData((state) {
        if (state.isAuthenticated) {
          if (mounted) {
            context.go(Routes.home);
          }
        }
      });

      authState.whenOrNull(
        error: (error, stack) {
          if (mounted) {
            _showError(error.toString());
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Sizes.p24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Icon(
                      Icons.dashboard_rounded,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: Sizes.p24),

                    // Title
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Sizes.p8),

                    // Subtitle
                    Text(
                      'Sign in to continue',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Sizes.p32),

                    // Mode toggle
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Email/Password'),
                          icon: Icon(Icons.email_outlined),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('PIN'),
                          icon: Icon(Icons.pin_outlined),
                        ),
                      ],
                      selected: {_isPinMode},
                      onSelectionChanged: (Set<bool> selected) {
                        setState(() => _isPinMode = selected.first);
                      },
                    ),
                    const SizedBox(height: Sizes.p24),

                    // Form fields
                    if (_isPinMode) ...[
                      // PIN mode
                      TextFormField(
                        controller: _pinController,
                        decoration: const InputDecoration(
                          labelText: 'PIN',
                          hintText: 'Enter your PIN',
                          prefixIcon: Icon(Icons.pin_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your PIN';
                          }
                          if (value.length < 4) {
                            return 'PIN must be at least 4 digits';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      // Email/password mode
                      TextFormField(
                        controller: _identifierController,
                        decoration: const InputDecoration(
                          labelText: 'Email or Phone',
                          hintText: 'Enter your email or phone',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email or phone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Sizes.p16),

                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Sizes.p8),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.push(Routes.forgotPassword);
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                    ],
                    const SizedBox(height: Sizes.p24),

                    // Sign in button
                    FilledButton(
                      onPressed: _isLoading ? null : _handleSignIn,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign In'),
                    ),
                    const SizedBox(height: Sizes.p16),

                    // Sign up link
                    if (!_isPinMode)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(Routes.signUp);
                            },
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
