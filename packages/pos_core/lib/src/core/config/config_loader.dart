import 'dart:convert';

import 'package:flutter/services.dart';
import 'app_config.dart';
import 'env.dart';
import 'feature_flags.dart';

/// Loads application configuration from JSON files.
/// This allows configuration to be data-driven instead of hardcoded.
class ConfigLoader {
  const ConfigLoader._();

  /// Load configuration from JSON file based on environment
  static Future<AppConfig> loadConfig(Environment environment) async {
    try {
      final configFileName = _getConfigFileName(environment);
      final jsonString = await rootBundle.loadString(
        'assets/config/$configFileName',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      return AppConfig(
        environment: environment,
        appName: jsonMap['appName'] as String,
        appTagline: jsonMap['appTagline'] as String,
        apiBaseUrl: jsonMap['apiBaseUrl'] as String,
        enableLogging: jsonMap['enableLogging'] as bool,
        featureFlags: jsonMap.containsKey('featureFlags')
            ? FeatureFlags.fromJson(
                jsonMap['featureFlags'] as Map<String, dynamic>,
              )
            : const FeatureFlags(),
      );
    } catch (e) {
      // Fallback to hardcoded config if JSON loading fails
      return AppConfig.fromEnvironment(environment);
    }
  }

  static String _getConfigFileName(Environment environment) {
    switch (environment) {
      case Environment.dev:
        return 'app_config_dev.json';
      case Environment.staging:
        return 'app_config_staging.json';
      case Environment.prod:
        return 'app_config_prod.json';
    }
  }
}
