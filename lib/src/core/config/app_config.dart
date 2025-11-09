import 'env.dart';
import 'feature_flags.dart';

/// Application-wide configuration.
/// Provides environment-specific settings and constants.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.appName,
    required this.appTagline,
    this.apiBaseUrl = '',
    this.enableLogging = true,
    this.featureFlags = const FeatureFlags(),
  });

  final Environment environment;
  final String appName;
  final String appTagline;
  final String apiBaseUrl;
  final bool enableLogging;
  final FeatureFlags featureFlags;

  /// Development configuration.
  factory AppConfig.dev() => const AppConfig(
        environment: Environment.dev,
        appName: 'Flutter Starter (Dev)',
        appTagline: 'Your Production-Ready Flutter Foundation',
        apiBaseUrl: 'https://api-dev.example.com',
        enableLogging: true,
      );

  /// Staging configuration.
  factory AppConfig.staging() => const AppConfig(
        environment: Environment.staging,
        appName: 'Flutter Starter (Staging)',
        appTagline: 'Your Production-Ready Flutter Foundation',
        apiBaseUrl: 'https://api-staging.example.com',
        enableLogging: true,
      );

  /// Production configuration.
  factory AppConfig.prod() => const AppConfig(
        environment: Environment.prod,
        appName: 'Flutter Starter',
        appTagline: 'Your Production-Ready Flutter Foundation',
        apiBaseUrl: 'https://api.example.com',
        enableLogging: false,
      );

  /// Get configuration based on environment.
  factory AppConfig.fromEnvironment(Environment env) {
    switch (env) {
      case Environment.dev:
        return AppConfig.dev();
      case Environment.staging:
        return AppConfig.staging();
      case Environment.prod:
        return AppConfig.prod();
    }
  }
}
