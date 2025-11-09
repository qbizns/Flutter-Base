import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/routing/routes.dart';

/// Splash screen shown during app initialization.
/// Checks for existing session and navigates accordingly.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Wait for minimum splash duration (for branding visibility)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check authentication state
    final authState = ref.read(authStateNotifierProvider);

    authState.when(
      data: (state) {
        if (state.isAuthenticated) {
          // User is logged in - go to home
          context.go(Routes.home);
        } else {
          // User is not logged in - go to sign in
          context.go(Routes.signIn);
        }
      },
      loading: () {
        // Still loading - wait
      },
      error: (error, stack) {
        // Error loading session - go to sign in
        context.go(Routes.signIn);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Icon(
                Icons.dashboard_rounded,
                size: 120,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(height: 24),
              // App name
              Text(
                'Flutter Starter',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              // Loading indicator
              CircularProgressIndicator(
                color: theme.colorScheme.onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
