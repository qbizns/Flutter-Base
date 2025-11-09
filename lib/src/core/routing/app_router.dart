import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/welcome/presentation/pages/welcome_page.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// Router provider for the application.
/// Creates and manages the GoRouter instance.
@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: Routes.welcome,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: Routes.welcome,
        name: RouteNames.welcome,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const WelcomePage(),
        ),
      ),
      // Additional routes can be added here as the app grows.
      // Example:
      // GoRoute(
      //   path: Routes.dashboard,
      //   name: RouteNames.dashboard,
      //   pageBuilder: (context, state) => MaterialPage<void>(
      //     key: state.pageKey,
      //     child: const DashboardPage(),
      //   ),
      // ),
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
                onPressed: () => context.go(Routes.welcome),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
