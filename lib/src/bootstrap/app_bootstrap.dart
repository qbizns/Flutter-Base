import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../core/config/env.dart';
import '../core/utils/logger.dart';

/// Application bootstrap.
/// Handles app initialization and setup before running the app.
class AppBootstrap {
  const AppBootstrap._();

  /// Initialize and run the application.
  static Future<void> run({
    required Environment environment,
    required Widget Function(AppConfig config) appBuilder,
  }) async {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Set current environment
    currentEnvironment = environment;

    // Create app configuration
    final config = AppConfig.fromEnvironment(environment);

    // Initialize logger
    AppLogger.init(config);
    AppLogger.info('Starting app in ${environment.name} mode');

    // Setup error handlers
    _setupErrorHandlers();

    // Run the app with Riverpod
    runApp(
      ProviderScope(
        child: appBuilder(config),
      ),
    );
  }

  /// Setup Flutter and Dart error handlers.
  static void _setupErrorHandlers() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.error(
        'Flutter error',
        details.exception,
        details.stack,
      );
    };

    // Handle errors outside Flutter framework
    // In production, you might want to send these to a crash reporting service
  }
}
