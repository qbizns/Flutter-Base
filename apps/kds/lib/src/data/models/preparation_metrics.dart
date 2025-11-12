/// Preparation Metrics Models
/// Kitchen performance tracking following Odoo analytics patterns
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'preparation_metrics.freezed.dart';
part 'preparation_metrics.g.dart';

/// Preparation time record for individual items
@freezed
class PreparationRecord with _$PreparationRecord {
  const factory PreparationRecord({
    required String id,
    required String orderId,
    required String orderNumber,
    required String itemId,
    required String productName,
    required String categoryName,
    required String stationId,
    required DateTime startTime,
    required DateTime endTime,
    required int preparationSeconds,
    DateTime? orderCreatedAt,
  }) = _PreparationRecord;

  factory PreparationRecord.fromJson(Map<String, dynamic> json) =>
      _$PreparationRecordFromJson(json);
}

/// Station performance metrics
@freezed
class StationMetrics with _$StationMetrics {
  const StationMetrics._();

  const factory StationMetrics({
    required String stationId,
    required String stationName,
    required int totalOrders,
    required int completedOrders,
    required int delayedOrders,
    required double averagePreparationTime, // minutes
    required double completionRate, // 0.0 - 1.0
    required int currentActiveOrders,
    DateTime? lastOrderTime,
  }) = _StationMetrics;

  factory StationMetrics.fromJson(Map<String, dynamic> json) =>
      _$StationMetricsFromJson(json);

  /// Efficiency score (0-100)
  double get efficiencyScore {
    // Weighted score: 60% completion rate, 40% speed
    final speedScore = averagePreparationTime > 0
        ? (1.0 - (averagePreparationTime / 30).clamp(0.0, 1.0))
        : 0.0;
    return (completionRate * 0.6 + speedScore * 0.4) * 100;
  }

  /// Performance rating
  PerformanceRating get performanceRating {
    if (efficiencyScore >= 85) return PerformanceRating.excellent;
    if (efficiencyScore >= 70) return PerformanceRating.good;
    if (efficiencyScore >= 50) return PerformanceRating.average;
    return PerformanceRating.poor;
  }
}

/// Overall kitchen metrics
@freezed
class KitchenMetrics with _$KitchenMetrics {
  const KitchenMetrics._();

  const factory KitchenMetrics({
    required DateTime periodStart,
    required DateTime periodEnd,
    required int totalOrders,
    required int completedOrders,
    required int cancelledOrders,
    required int delayedOrders,
    required double averagePreparationTime, // minutes
    required double averageWaitTime, // minutes
    required double completionRate, // 0.0 - 1.0
    required double onTimeRate, // 0.0 - 1.0
    required int peakHourOrders,
    required String peakHour,
    @Default([]) List<StationMetrics> stationMetrics,
    @Default([]) List<CategoryMetrics> categoryMetrics,
  }) = _KitchenMetrics;

  factory KitchenMetrics.fromJson(Map<String, dynamic> json) =>
      _$KitchenMetricsFromJson(json);

  /// Orders per hour throughput
  double get ordersPerHour {
    final hours = periodEnd.difference(periodStart).inHours;
    return hours > 0 ? totalOrders / hours : 0.0;
  }

  /// Overall efficiency score
  double get overallEfficiency {
    return (completionRate * 0.4 + onTimeRate * 0.6) * 100;
  }

  /// Performance status
  PerformanceRating get performanceRating {
    if (overallEfficiency >= 85) return PerformanceRating.excellent;
    if (overallEfficiency >= 70) return PerformanceRating.good;
    if (overallEfficiency >= 50) return PerformanceRating.average;
    return PerformanceRating.poor;
  }
}

/// Category performance metrics
@freezed
class CategoryMetrics with _$CategoryMetrics {
  const CategoryMetrics._();

  const factory CategoryMetrics({
    required String categoryId,
    required String categoryName,
    required int totalItems,
    required int completedItems,
    required double averagePreparationTime,
    required int delayedItems,
  }) = _CategoryMetrics;

  factory CategoryMetrics.fromJson(Map<String, dynamic> json) =>
      _$CategoryMetricsFromJson(json);

  double get completionRate =>
      totalItems > 0 ? completedItems / totalItems : 0.0;

  double get delayRate =>
      totalItems > 0 ? delayedItems / totalItems : 0.0;
}

/// Hourly metrics for charts
@freezed
class HourlyMetrics with _$HourlyMetrics {
  const factory HourlyMetrics({
    required int hour, // 0-23
    required int orderCount,
    required double averagePreparationTime,
    required int delayedCount,
    required int completedCount,
  }) = _HourlyMetrics;

  factory HourlyMetrics.fromJson(Map<String, dynamic> json) =>
      _$HourlyMetricsFromJson(json);
}

/// Performance rating enum
enum PerformanceRating {
  excellent,
  good,
  average,
  poor,
}

/// Performance rating extensions
extension PerformanceRatingExtension on PerformanceRating {
  String get displayName {
    switch (this) {
      case PerformanceRating.excellent:
        return 'Excellent';
      case PerformanceRating.good:
        return 'Good';
      case PerformanceRating.average:
        return 'Average';
      case PerformanceRating.poor:
        return 'Poor';
    }
  }

  String get emoji {
    switch (this) {
      case PerformanceRating.excellent:
        return '⭐';
      case PerformanceRating.good:
        return '👍';
      case PerformanceRating.average:
        return '👌';
      case PerformanceRating.poor:
        return '⚠️';
    }
  }

  Color get color {
    switch (this) {
      case PerformanceRating.excellent:
        return const Color(0xFF16A085); // Teal
      case PerformanceRating.good:
        return const Color(0xFF27AE60); // Green
      case PerformanceRating.average:
        return const Color(0xFFF39C12); // Orange
      case PerformanceRating.poor:
        return const Color(0xFFE74C3C); // Red
    }
  }
}

/// Real-time performance snapshot
@freezed
class PerformanceSnapshot with _$PerformanceSnapshot {
  const factory PerformanceSnapshot({
    required DateTime timestamp,
    required int activeOrders,
    required int pendingOrders,
    required int completedToday,
    required double averageTimeToday,
    required int delayedToday,
    required Map<String, int> ordersByStation,
  }) = _PerformanceSnapshot;

  factory PerformanceSnapshot.fromJson(Map<String, dynamic> json) =>
      _$PerformanceSnapshotFromJson(json);
}

/// Time range for analytics
enum AnalyticsTimeRange {
  today,
  yesterday,
  last7Days,
  last30Days,
  thisMonth,
  custom,
}

extension AnalyticsTimeRangeExtension on AnalyticsTimeRange {
  String get displayName {
    switch (this) {
      case AnalyticsTimeRange.today:
        return 'Today';
      case AnalyticsTimeRange.yesterday:
        return 'Yesterday';
      case AnalyticsTimeRange.last7Days:
        return 'Last 7 Days';
      case AnalyticsTimeRange.last30Days:
        return 'Last 30 Days';
      case AnalyticsTimeRange.thisMonth:
        return 'This Month';
      case AnalyticsTimeRange.custom:
        return 'Custom Range';
    }
  }

  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case AnalyticsTimeRange.today:
        return DateTime(now.year, now.month, now.day);
      case AnalyticsTimeRange.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTime(yesterday.year, yesterday.month, yesterday.day);
      case AnalyticsTimeRange.last7Days:
        return now.subtract(const Duration(days: 7));
      case AnalyticsTimeRange.last30Days:
        return now.subtract(const Duration(days: 30));
      case AnalyticsTimeRange.thisMonth:
        return DateTime(now.year, now.month, 1);
      case AnalyticsTimeRange.custom:
        return now.subtract(const Duration(days: 7));
    }
  }

  DateTime get endDate {
    return DateTime.now();
  }
}
