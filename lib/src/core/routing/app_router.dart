import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/verification_page.dart';
import '../../features/home_shell/presentation/pages/home_shell_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/welcome/presentation/pages/welcome_page.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// Router provider for the application.
/// Creates and manages the GoRouter instance.
@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Auth routes
      GoRoute(
        path: Routes.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: Routes.signIn,
        name: RouteNames.signIn,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const SignInPage(),
        ),
      ),
      GoRoute(
        path: Routes.signUp,
        name: RouteNames.signUp,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const SignUpPage(),
        ),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        name: RouteNames.forgotPassword,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: Routes.verification,
        name: RouteNames.verification,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return MaterialPage<void>(
            key: state.pageKey,
            child: VerificationPage(
              identifier: extra['identifier'] as String? ?? '',
              flow: extra['flow'] as String? ?? 'password_reset',
            ),
          );
        },
      ),

      // Main app routes
      GoRoute(
        path: Routes.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const OnboardingPage(),
        ),
      ),
      GoRoute(
        path: Routes.home,
        name: RouteNames.home,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const HomeShellPage(),
        ),
      ),
      GoRoute(
        path: Routes.profile,
        name: RouteNames.profile,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const ProfilePage(),
        ),
      ),

      // Legacy welcome route (will be removed after migration)
      GoRoute(
        path: Routes.welcome,
        name: RouteNames.welcome,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const WelcomePage(),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage<void>(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(Routes.splash),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
