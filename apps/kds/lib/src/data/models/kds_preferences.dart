/// KDS User Preferences
/// Persistent settings for KDS display following Odoo patterns
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'kds_preferences.freezed.dart';
part 'kds_preferences.g.dart';

/// KDS User Preferences
/// Stores all user-configurable settings for the KDS display
@freezed
class KdsPreferences with _$KdsPreferences {
  const KdsPreferences._();

  const factory KdsPreferences({
    // Station settings
    @Default('all') String selectedStationId,
    @Default(true) bool showAllStations,

    // Display settings
    @Default(KdsViewMode.grid) KdsViewMode viewMode,
    @Default(2) int gridColumns,
    @Default(true) bool showCompletedOrders,
    @Default(300) int completedOrdersDisplaySeconds, // 5 minutes
    @Default(true) bool autoRefresh,
    @Default(30) int autoRefreshSeconds,

    // Timer settings
    @Default(10) int normalThresholdMinutes, // Green to Yellow
    @Default(15) int warningThresholdMinutes, // Yellow to Red
    @Default(true) bool showTimerIcon,
    @Default(true) bool showWarningIndicator,

    // Sound settings
    @Default(true) bool soundEnabled,
    @Default(0.7) double soundVolume,
    @Default(true) bool normalPrioritySound,
    @Default(true) bool highPrioritySound,
    @Default(true) bool urgentPrioritySound,

    // Animation settings
    @Default(true) bool animationsEnabled,
    @Default(true) bool entranceAnimations,
    @Default(true) bool statusChangeAnimations,
    @Default(true) bool newOrderAlerts,
    @Default(true) bool bumpAnimations,

    // Filter settings
    @Default(true) bool showNewOrders,
    @Default(true) bool showPreparingOrders,
    @Default(true) bool showReadyOrders,
    @Default(false) bool showDoneOrders,

    // Order display settings
    @Default(true) bool groupItemsByCategory,
    @Default(true) bool showCustomerName,
    @Default(true) bool showOrderNumber,
    @Default(true) bool showTableNumber,
    @Default(true) bool showOrderType,

    // Performance settings
    @Default(100) int maxVisibleOrders,
    @Default(true) bool enableRealTimeUpdates,
    @Default(5) int reconnectDelaySeconds,

    // Theme settings
    @Default(true) bool useSystemTheme,
    @Default(false) bool darkMode,
    @Default(1.0) double textScale,

    // Advanced settings
    @Default(false) bool enableDebugMode,
    @Default(false) bool showPerformanceOverlay,
    @Default(true) bool hapticFeedback,
  }) = _KdsPreferences;

  factory KdsPreferences.fromJson(Map<String, dynamic> json) =>
      _$KdsPreferencesFromJson(json);

  /// Default preferences following Odoo KDS defaults
  factory KdsPreferences.defaults() => const KdsPreferences();

  /// Check if order should be visible based on filters
  bool shouldShowOrder(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return showNewOrders;
      case 'preparing':
        return showPreparingOrders;
      case 'ready':
        return showReadyOrders;
      case 'done':
        return showDoneOrders;
      default:
        return true;
    }
  }

  /// Get timer thresholds
  (int normal, int warning) get timerThresholds =>
      (normalThresholdMinutes, warningThresholdMinutes);

  /// Check if animations should play
  bool shouldAnimate(AnimationType type) {
    if (!animationsEnabled) return false;

    switch (type) {
      case AnimationType.entrance:
        return entranceAnimations;
      case AnimationType.statusChange:
        return statusChangeAnimations;
      case AnimationType.newOrderAlert:
        return newOrderAlerts;
      case AnimationType.bump:
        return bumpAnimations;
    }
  }

  /// Validate preferences
  bool get isValid {
    return gridColumns >= 1 &&
        gridColumns <= 6 &&
        normalThresholdMinutes > 0 &&
        warningThresholdMinutes > normalThresholdMinutes &&
        soundVolume >= 0.0 &&
        soundVolume <= 1.0 &&
        autoRefreshSeconds >= 10 &&
        maxVisibleOrders > 0;
  }
}

/// KDS View Mode
enum KdsViewMode {
  grid,
  list,
  compact;

  String get displayName {
    switch (this) {
      case KdsViewMode.grid:
        return 'Grid View';
      case KdsViewMode.list:
        return 'List View';
      case KdsViewMode.compact:
        return 'Compact View';
    }
  }

  IconData get icon {
    switch (this) {
      case KdsViewMode.grid:
        return Icons.grid_view;
      case KdsViewMode.list:
        return Icons.view_list;
      case KdsViewMode.compact:
        return Icons.view_compact;
    }
  }
}

/// Animation Type
enum AnimationType {
  entrance,
  statusChange,
  newOrderAlert,
  bump;
}

/// Import required icons
class Icons {
  static const grid_view = 0xe3f5;
  static const view_list = 0xe3f7;
  static const view_compact = 0xe3f8;
}
