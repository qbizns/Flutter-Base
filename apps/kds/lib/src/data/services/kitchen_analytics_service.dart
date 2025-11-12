/// Kitchen Analytics Service
/// Performance tracking and metrics calculation following Odoo patterns
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kitchen_order.dart';
import '../models/preparation_metrics.dart';
import '../models/kitchen_station.dart';

/// Kitchen Analytics Service
/// Tracks and calculates kitchen performance metrics
class KitchenAnalyticsService {
  final List<PreparationRecord> _preparationRecords = [];
  final List<KitchenOrder> _orderHistory = [];

  final _metricsController = StreamController<KitchenMetrics>.broadcast();
  Stream<KitchenMetrics> get metricsStream => _metricsController.stream;

  /// Record item preparation completion
  void recordItemPreparation({
    required String orderId,
    required String orderNumber,
    required String itemId,
    required String productName,
    required String categoryName,
    required String stationId,
    required DateTime startTime,
    required DateTime endTime,
    DateTime? orderCreatedAt,
  }) {
    final record = PreparationRecord(
      id: '${orderId}_$itemId',
      orderId: orderId,
      orderNumber: orderNumber,
      itemId: itemId,
      productName: productName,
      categoryName: categoryName,
      stationId: stationId,
      startTime: startTime,
      endTime: endTime,
      preparationSeconds: endTime.difference(startTime).inSeconds,
      orderCreatedAt: orderCreatedAt,
    );

    _preparationRecords.add(record);

    // Trigger metrics recalculation
    _updateMetrics();
  }

  /// Record order completion
  void recordOrderCompletion(KitchenOrder order) {
    _orderHistory.add(order);
    _updateMetrics();
  }

  /// Get kitchen metrics for time range
  KitchenMetrics getMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 1));
    final end = endDate ?? DateTime.now();

    // Filter orders in range
    final ordersInRange = _orderHistory.where((order) {
      return order.createdAt.isAfter(start) && order.createdAt.isBefore(end);
    }).toList();

    // Filter preparation records in range
    final recordsInRange = _preparationRecords.where((record) {
      return record.startTime.isAfter(start) && record.startTime.isBefore(end);
    }).toList();

    // Calculate metrics
    final totalOrders = ordersInRange.length;
    final completedOrders = ordersInRange
        .where((o) => o.status == KitchenOrderStatus.done)
        .length;
    final cancelledOrders = ordersInRange
        .where((o) => o.status == KitchenOrderStatus.cancelled)
        .length;
    final delayedOrders = ordersInRange.where((o) => o.isOrderDelayed).length;

    // Average preparation time
    final avgPrepTime = recordsInRange.isNotEmpty
        ? recordsInRange.fold<int>(
                0, (sum, r) => sum + r.preparationSeconds) /
            recordsInRange.length /
            60
        : 0.0;

    // Average wait time (from order creation to completion)
    final completedOrdersWithTime = ordersInRange.where((o) =>
        o.status == KitchenOrderStatus.done && o.completedAt != null);

    final avgWaitTime = completedOrdersWithTime.isNotEmpty
        ? completedOrdersWithTime.fold<int>(
                0,
                (sum, o) =>
                    sum + o.completedAt!.difference(o.createdAt).inMinutes) /
            completedOrdersWithTime.length
        : 0.0;

    // Rates
    final completionRate =
        totalOrders > 0 ? completedOrders / totalOrders : 0.0;
    final onTimeRate = totalOrders > 0
        ? (totalOrders - delayedOrders) / totalOrders
        : 0.0;

    // Peak hour analysis
    final hourlyOrders = _calculateHourlyOrders(ordersInRange);
    final peakHour = _findPeakHour(hourlyOrders);
    final peakHourOrders = hourlyOrders[peakHour] ?? 0;

    // Station metrics
    final stationMetrics = _calculateStationMetrics(
      ordersInRange,
      recordsInRange,
    );

    // Category metrics
    final categoryMetrics = _calculateCategoryMetrics(recordsInRange);

    return KitchenMetrics(
      periodStart: start,
      periodEnd: end,
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      delayedOrders: delayedOrders,
      averagePreparationTime: avgPrepTime,
      averageWaitTime: avgWaitTime,
      completionRate: completionRate,
      onTimeRate: onTimeRate,
      peakHourOrders: peakHourOrders,
      peakHour: _formatHour(peakHour),
      stationMetrics: stationMetrics,
      categoryMetrics: categoryMetrics,
    );
  }

  /// Get station metrics
  List<StationMetrics> _calculateStationMetrics(
    List<KitchenOrder> orders,
    List<PreparationRecord> records,
  ) {
    final stationMap = <String, _StationData>{};

    // Group by station
    for (final order in orders) {
      for (final stationId in order.stationIds) {
        stationMap.putIfAbsent(
          stationId,
          () => _StationData(stationId: stationId),
        );

        final data = stationMap[stationId]!;
        data.totalOrders++;

        if (order.status == KitchenOrderStatus.done) {
          data.completedOrders++;
        }

        if (order.isOrderDelayed) {
          data.delayedOrders++;
        }

        if (order.status != KitchenOrderStatus.done &&
            order.status != KitchenOrderStatus.cancelled) {
          data.currentActiveOrders++;
        }

        if (order.completedAt != null) {
          data.lastOrderTime = order.completedAt;
        }
      }
    }

    // Calculate average prep times from records
    for (final record in records) {
      final data = stationMap[record.stationId];
      if (data != null) {
        data.totalPrepTime += record.preparationSeconds;
        data.prepCount++;
      }
    }

    // Build station metrics
    return stationMap.entries.map((entry) {
      final data = entry.value;
      final station = DefaultKitchenStations.getStationById(entry.key);

      final avgPrepTime = data.prepCount > 0
          ? data.totalPrepTime / data.prepCount / 60
          : 0.0;

      final completionRate = data.totalOrders > 0
          ? data.completedOrders / data.totalOrders
          : 0.0;

      return StationMetrics(
        stationId: entry.key,
        stationName: station?.name ?? entry.key,
        totalOrders: data.totalOrders,
        completedOrders: data.completedOrders,
        delayedOrders: data.delayedOrders,
        averagePreparationTime: avgPrepTime,
        completionRate: completionRate,
        currentActiveOrders: data.currentActiveOrders,
        lastOrderTime: data.lastOrderTime,
      );
    }).toList()
      ..sort((a, b) => b.efficiencyScore.compareTo(a.efficiencyScore));
  }

  /// Calculate category metrics
  List<CategoryMetrics> _calculateCategoryMetrics(
    List<PreparationRecord> records,
  ) {
    final categoryMap = <String, _CategoryData>{};

    for (final record in records) {
      categoryMap.putIfAbsent(
        record.categoryName,
        () => _CategoryData(
          categoryId: record.categoryName.toLowerCase().replaceAll(' ', '_'),
          categoryName: record.categoryName,
        ),
      );

      final data = categoryMap[record.categoryName]!;
      data.totalItems++;
      data.completedItems++;
      data.totalPrepTime += record.preparationSeconds;

      // Check if delayed (>15 minutes)
      if (record.preparationSeconds > 900) {
        data.delayedItems++;
      }
    }

    return categoryMap.values.map((data) {
      final avgPrepTime =
          data.totalItems > 0 ? data.totalPrepTime / data.totalItems / 60 : 0.0;

      return CategoryMetrics(
        categoryId: data.categoryId,
        categoryName: data.categoryName,
        totalItems: data.totalItems,
        completedItems: data.completedItems,
        averagePreparationTime: avgPrepTime,
        delayedItems: data.delayedItems,
      );
    }).toList()
      ..sort((a, b) => b.totalItems.compareTo(a.totalItems));
  }

  /// Calculate orders per hour
  Map<int, int> _calculateHourlyOrders(List<KitchenOrder> orders) {
    final hourlyMap = <int, int>{};

    for (final order in orders) {
      final hour = order.createdAt.hour;
      hourlyMap[hour] = (hourlyMap[hour] ?? 0) + 1;
    }

    return hourlyMap;
  }

  /// Find peak hour
  int _findPeakHour(Map<int, int> hourlyOrders) {
    if (hourlyOrders.isEmpty) return 12;

    int peakHour = 12;
    int maxOrders = 0;

    hourlyOrders.forEach((hour, count) {
      if (count > maxOrders) {
        maxOrders = count;
        peakHour = hour;
      }
    });

    return peakHour;
  }

  /// Format hour for display
  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  /// Get hourly breakdown for charts
  List<HourlyMetrics> getHourlyBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 1));
    final end = endDate ?? DateTime.now();

    final ordersInRange = _orderHistory.where((order) {
      return order.createdAt.isAfter(start) && order.createdAt.isBefore(end);
    }).toList();

    final recordsInRange = _preparationRecords.where((record) {
      return record.startTime.isAfter(start) && record.startTime.isBefore(end);
    }).toList();

    final hourlyData = <int, _HourlyData>{};

    // Process orders
    for (final order in ordersInRange) {
      final hour = order.createdAt.hour;
      hourlyData.putIfAbsent(hour, () => _HourlyData());

      final data = hourlyData[hour]!;
      data.orderCount++;

      if (order.status == KitchenOrderStatus.done) {
        data.completedCount++;
      }

      if (order.isOrderDelayed) {
        data.delayedCount++;
      }
    }

    // Process preparation records
    for (final record in recordsInRange) {
      final hour = record.startTime.hour;
      hourlyData.putIfAbsent(hour, () => _HourlyData());

      final data = hourlyData[hour]!;
      data.totalPrepTime += record.preparationSeconds;
      data.prepCount++;
    }

    // Build hourly metrics
    final metrics = <HourlyMetrics>[];
    for (int hour = 0; hour < 24; hour++) {
      final data = hourlyData[hour] ?? _HourlyData();
      final avgPrepTime =
          data.prepCount > 0 ? data.totalPrepTime / data.prepCount / 60 : 0.0;

      metrics.add(HourlyMetrics(
        hour: hour,
        orderCount: data.orderCount,
        averagePreparationTime: avgPrepTime,
        delayedCount: data.delayedCount,
        completedCount: data.completedCount,
      ));
    }

    return metrics;
  }

  /// Get performance snapshot
  PerformanceSnapshot getCurrentSnapshot() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayOrders = _orderHistory.where((order) {
      return order.createdAt.isAfter(today);
    }).toList();

    final activeOrders = todayOrders
        .where((o) =>
            o.status != KitchenOrderStatus.done &&
            o.status != KitchenOrderStatus.cancelled)
        .length;

    final pendingOrders = todayOrders
        .where((o) => o.status == KitchenOrderStatus.newOrder)
        .length;

    final completedToday = todayOrders
        .where((o) => o.status == KitchenOrderStatus.done)
        .length;

    final delayedToday = todayOrders.where((o) => o.isOrderDelayed).length;

    final todayRecords = _preparationRecords.where((record) {
      return record.startTime.isAfter(today);
    }).toList();

    final avgTimeToday = todayRecords.isNotEmpty
        ? todayRecords.fold<int>(
                0, (sum, r) => sum + r.preparationSeconds) /
            todayRecords.length /
            60
        : 0.0;

    // Orders by station
    final ordersByStation = <String, int>{};
    for (final order in todayOrders) {
      for (final stationId in order.stationIds) {
        ordersByStation[stationId] = (ordersByStation[stationId] ?? 0) + 1;
      }
    }

    return PerformanceSnapshot(
      timestamp: now,
      activeOrders: activeOrders,
      pendingOrders: pendingOrders,
      completedToday: completedToday,
      averageTimeToday: avgTimeToday,
      delayedToday: delayedToday,
      ordersByStation: ordersByStation,
    );
  }

  /// Update metrics and notify listeners
  void _updateMetrics() {
    final metrics = getMetrics();
    _metricsController.add(metrics);
  }

  /// Load mock data for development
  void loadMockData() {
    final now = DateTime.now();

    // Generate mock preparation records for the last 7 days
    for (int day = 0; day < 7; day++) {
      final date = now.subtract(Duration(days: day));

      for (int hour = 8; hour < 22; hour++) {
        final ordersInHour = hour >= 11 && hour <= 14 ? 15 : 8;

        for (int i = 0; i < ordersInHour; i++) {
          final orderTime = DateTime(
            date.year,
            date.month,
            date.day,
            hour,
            i * 4,
          );

          final prepTime = 300 + (i * 30); // 5-12 minutes

          recordItemPreparation(
            orderId: 'order_${day}_${hour}_$i',
            orderNumber: 'ORD-${day * 100 + hour * 10 + i}',
            itemId: 'item_$i',
            productName: _getMockProductName(i),
            categoryName: _getMockCategory(i),
            stationId: _getMockStation(i),
            startTime: orderTime,
            endTime: orderTime.add(Duration(seconds: prepTime)),
            orderCreatedAt: orderTime,
          );

          // Create mock order
          final order = KitchenOrder(
            id: 'order_${day}_${hour}_$i',
            orderNumber: 'ORD-${day * 100 + hour * 10 + i}',
            createdAt: orderTime,
            status: KitchenOrderStatus.done,
            items: [],
            stationIds: [_getMockStation(i)],
            completedAt: orderTime.add(Duration(seconds: prepTime)),
          );

          recordOrderCompletion(order);
        }
      }
    }
  }

  String _getMockProductName(int index) {
    final products = [
      'Burger',
      'Steak',
      'Pasta',
      'Salad',
      'Fries',
      'Pizza',
      'Chicken',
      'Fish'
    ];
    return products[index % products.length];
  }

  String _getMockCategory(int index) {
    final categories = [
      'Burgers',
      'Steaks',
      'Pasta',
      'Salads',
      'Sides',
      'Pizza',
      'Chicken',
      'Seafood'
    ];
    return categories[index % categories.length];
  }

  String _getMockStation(int index) {
    final stations = ['grill', 'fryer', 'hot', 'cold'];
    return stations[index % stations.length];
  }

  /// Dispose resources
  void dispose() {
    _metricsController.close();
  }
}

/// Helper class for station data aggregation
class _StationData {
  final String stationId;
  int totalOrders = 0;
  int completedOrders = 0;
  int delayedOrders = 0;
  int currentActiveOrders = 0;
  int totalPrepTime = 0;
  int prepCount = 0;
  DateTime? lastOrderTime;

  _StationData({required this.stationId});
}

/// Helper class for category data aggregation
class _CategoryData {
  final String categoryId;
  final String categoryName;
  int totalItems = 0;
  int completedItems = 0;
  int delayedItems = 0;
  int totalPrepTime = 0;

  _CategoryData({
    required this.categoryId,
    required this.categoryName,
  });
}

/// Helper class for hourly data aggregation
class _HourlyData {
  int orderCount = 0;
  int completedCount = 0;
  int delayedCount = 0;
  int totalPrepTime = 0;
  int prepCount = 0;
}

/// Kitchen analytics service provider
final kitchenAnalyticsServiceProvider = Provider<KitchenAnalyticsService>((ref) {
  final service = KitchenAnalyticsService();

  // Load mock data in development
  service.loadMockData();

  ref.onDispose(() => service.dispose());

  return service;
});

/// Current metrics provider
final currentMetricsProvider = Provider<KitchenMetrics>((ref) {
  final service = ref.watch(kitchenAnalyticsServiceProvider);
  return service.getMetrics();
});

/// Metrics stream provider
final metricsStreamProvider = StreamProvider<KitchenMetrics>((ref) {
  final service = ref.watch(kitchenAnalyticsServiceProvider);
  return service.metricsStream;
});

/// Performance snapshot provider
final performanceSnapshotProvider = Provider<PerformanceSnapshot>((ref) {
  final service = ref.watch(kitchenAnalyticsServiceProvider);
  return service.getCurrentSnapshot();
});

/// Hourly breakdown provider
final hourlyBreakdownProvider = Provider<List<HourlyMetrics>>((ref) {
  final service = ref.watch(kitchenAnalyticsServiceProvider);
  return service.getHourlyBreakdown();
});
