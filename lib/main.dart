import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/bootstrap/app_bootstrap.dart';
import 'src/core/config/app_config.dart';
import 'src/core/config/env.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/routing/app_router.dart';

/// Application entry point.
/// Initializes the app and runs it in the default environment.
void main() async {
  await AppBootstrap.run(
    environment: Environment.dev,
    appBuilder: (config) => MyApp(config: config),
  );
}

/// Root application widget.
/// Configures theming, routing, and app-wide settings.
class MyApp extends ConsumerWidget {
  const MyApp({
    required this.config,
    super.key,
  });

  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      // Additional app-wide configurations
      builder: (context, child) {
        // This is where you can add app-wide overlays,
        // error handling widgets, or other wrappers
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
