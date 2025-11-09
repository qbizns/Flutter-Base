/// Feature flags for enabling/disabling features.
/// This allows you to control feature availability without code changes.
class FeatureFlags {
  const FeatureFlags({
    this.enableAnalytics = false,
    this.enableCrashReporting = false,
    this.enablePushNotifications = false,
    this.enableBiometricAuth = false,
    this.enableOfflineMode = true,
    this.enableDebugTools = false,
    this.enablePerformanceMonitoring = false,
    this.enableExperimentalFeatures = false,
  });

  /// Enable analytics tracking
  final bool enableAnalytics;

  /// Enable crash reporting
  final bool enableCrashReporting;

  /// Enable push notifications
  final bool enablePushNotifications;

  /// Enable biometric authentication
  final bool enableBiometricAuth;

  /// Enable offline mode/caching
  final bool enableOfflineMode;

  /// Enable debug tools (dev menu, inspector, etc.)
  final bool enableDebugTools;

  /// Enable performance monitoring
  final bool enablePerformanceMonitoring;

  /// Enable experimental features
  final bool enableExperimentalFeatures;

  /// Create from JSON
  factory FeatureFlags.fromJson(Map<String, dynamic> json) {
    return FeatureFlags(
      enableAnalytics: json['enableAnalytics'] as bool? ?? false,
      enableCrashReporting: json['enableCrashReporting'] as bool? ?? false,
      enablePushNotifications: json['enablePushNotifications'] as bool? ?? false,
      enableBiometricAuth: json['enableBiometricAuth'] as bool? ?? false,
      enableOfflineMode: json['enableOfflineMode'] as bool? ?? true,
      enableDebugTools: json['enableDebugTools'] as bool? ?? false,
      enablePerformanceMonitoring:
          json['enablePerformanceMonitoring'] as bool? ?? false,
      enableExperimentalFeatures:
          json['enableExperimentalFeatures'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'enableAnalytics': enableAnalytics,
      'enableCrashReporting': enableCrashReporting,
      'enablePushNotifications': enablePushNotifications,
      'enableBiometricAuth': enableBiometricAuth,
      'enableOfflineMode': enableOfflineMode,
      'enableDebugTools': enableDebugTools,
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
      'enableExperimentalFeatures': enableExperimentalFeatures,
    };
  }

  /// Create a copy with updated values
  FeatureFlags copyWith({
    bool? enableAnalytics,
    bool? enableCrashReporting,
    bool? enablePushNotifications,
    bool? enableBiometricAuth,
    bool? enableOfflineMode,
    bool? enableDebugTools,
    bool? enablePerformanceMonitoring,
    bool? enableExperimentalFeatures,
  }) {
    return FeatureFlags(
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      enableBiometricAuth: enableBiometricAuth ?? this.enableBiometricAuth,
      enableOfflineMode: enableOfflineMode ?? this.enableOfflineMode,
      enableDebugTools: enableDebugTools ?? this.enableDebugTools,
      enablePerformanceMonitoring:
          enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
      enableExperimentalFeatures:
          enableExperimentalFeatures ?? this.enableExperimentalFeatures,
    );
  }
}
