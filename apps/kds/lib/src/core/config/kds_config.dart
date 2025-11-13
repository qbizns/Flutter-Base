/// KDS Configuration
/// Application configuration for Kitchen Display System
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

/// KDS Application Configuration
class KdsConfig {
  final String apiBaseUrl;
  final String wsBaseUrl;
  final Environment environment;
  final Duration reconnectDelay;
  final Duration pingInterval;
  final int maxReconnectAttempts;

  const KdsConfig({
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.environment,
    this.reconnectDelay = const Duration(seconds: 5),
    this.pingInterval = const Duration(seconds: 30),
    this.maxReconnectAttempts = 10,
  });

  /// Create config from environment
  factory KdsConfig.fromEnvironment(Environment environment) {
    String apiBaseUrl;
    String wsBaseUrl;

    switch (environment) {
      case Environment.development:
        apiBaseUrl = 'http://localhost:8080';
        wsBaseUrl = 'ws://localhost:8080';
        break;
      case Environment.staging:
        apiBaseUrl = 'https://staging-api.vodo.app';
        wsBaseUrl = 'wss://staging-api.vodo.app';
        break;
      case Environment.production:
        apiBaseUrl = 'https://api.vodo.app';
        wsBaseUrl = 'wss://api.vodo.app';
        break;
    }

    return KdsConfig(
      apiBaseUrl: apiBaseUrl,
      wsBaseUrl: wsBaseUrl,
      environment: environment,
    );
  }

  /// Get WebSocket URL for KDS
  String get kdsWebSocketUrl => '$wsBaseUrl/kds/ws';

  /// Check if development mode
  bool get isDevelopment => environment == Environment.development;

  /// Check if production mode
  bool get isProduction => environment == Environment.production;

  KdsConfig copyWith({
    String? apiBaseUrl,
    String? wsBaseUrl,
    Environment? environment,
    Duration? reconnectDelay,
    Duration? pingInterval,
    int? maxReconnectAttempts,
  }) {
    return KdsConfig(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      wsBaseUrl: wsBaseUrl ?? this.wsBaseUrl,
      environment: environment ?? this.environment,
      reconnectDelay: reconnectDelay ?? this.reconnectDelay,
      pingInterval: pingInterval ?? this.pingInterval,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
    );
  }
}

/// KDS Config Provider
/// Provides application configuration based on environment
final kdsConfigProvider = Provider<KdsConfig>((ref) {
  // Get environment from AppBootstrap
  // Default to development if not available
  const environment = Environment.development;

  return KdsConfig.fromEnvironment(environment);
});

/// Environment provider for overriding in tests
final environmentProvider = Provider<Environment>((ref) {
  return Environment.development;
});
