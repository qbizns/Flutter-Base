/// Sales Analytics Provider
/// Provides sales data, analytics, and reporting for manager dashboard
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

/// Period for analytics
enum AnalyticsPeriod {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  custom,
}

/// Sales summary
class SalesSummary {
  final double grossSales;
  final double discounts;
  final double refunds;
  final double netSales;
  final double tax;
  final int ordersCount;
  final int itemsCount;
  final double averageOrderValue;
  final Map<String, double> paymentMethodBreakdown;
  final DateTime startDate;
  final DateTime endDate;

  SalesSummary({
    required this.grossSales,
    required this.discounts,
    required this.refunds,
    required this.netSales,
    required this.tax,
    required this.ordersCount,
    required this.itemsCount,
    required this.averageOrderValue,
    required this.paymentMethodBreakdown,
    required this.startDate,
    required this.endDate,
  });

  factory SalesSummary.fromOrders(List<Order> orders, DateTime start, DateTime end) {
    final grossSales = orders.fold<double>(0, (sum, order) => sum + order.total);
    final discounts = orders.fold<double>(
      0,
      (sum, order) => sum + (order.discountAmount ?? 0),
    );
    final refunds = 0.0; // TODO: Calculate from refunds
    final netSales = grossSales - discounts - refunds;
    final tax = orders.fold<double>(0, (sum, order) => sum + order.taxAmount);
    final ordersCount = orders.length;
    final itemsCount = orders.fold<int>(
      0,
      (sum, order) => sum + order.items.length,
    );
    final averageOrderValue = ordersCount > 0 ? netSales / ordersCount : 0.0;

    // Payment methods breakdown (mock for now)
    final paymentMethodBreakdown = <String, double>{
      'Cash': grossSales * 0.4,
      'Card': grossSales * 0.5,
      'Digital Wallet': grossSales * 0.1,
    };

    return SalesSummary(
      grossSales: grossSales,
      discounts: discounts,
      refunds: refunds,
      netSales: netSales,
      tax: tax,
      ordersCount: ordersCount,
      itemsCount: itemsCount,
      averageOrderValue: averageOrderValue,
      paymentMethodBreakdown: paymentMethodBreakdown,
      startDate: start,
      endDate: end,
    );
  }
}

/// Hourly sales data
class HourlySales {
  final int hour;
  final double sales;
  final int orders;

  HourlySales({
    required this.hour,
    required this.sales,
    required this.orders,
  });
}

/// Product performance
class ProductPerformance {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;
  final double averagePrice;

  ProductPerformance({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.averagePrice,
  });
}

/// Category performance
class CategoryPerformance {
  final String categoryId;
  final String categoryName;
  final int itemsSold;
  final double revenue;
  final double percentage;

  CategoryPerformance({
    required this.categoryId,
    required this.categoryName,
    required this.itemsSold,
    required this.revenue,
    required this.percentage,
  });
}

/// Staff performance
class StaffPerformance {
  final String staffId;
  final String staffName;
  final int ordersServed;
  final double totalSales;
  final double averageOrderValue;
  final double tips;

  StaffPerformance({
    required this.staffId,
    required this.staffName,
    required this.ordersServed,
    required this.totalSales,
    required this.averageOrderValue,
    required this.tips,
  });
}

/// Date range state
class DateRangeState {
  final DateTime startDate;
  final DateTime endDate;
  final AnalyticsPeriod period;

  DateRangeState({
    required this.startDate,
    required this.endDate,
    required this.period,
  });

  factory DateRangeState.today() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateRangeState(
      startDate: start,
      endDate: end,
      period: AnalyticsPeriod.today,
    );
  }

  factory DateRangeState.yesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
    return DateRangeState(
      startDate: start,
      endDate: end,
      period: AnalyticsPeriod.yesterday,
    );
  }

  factory DateRangeState.thisWeek() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final start = now.subtract(Duration(days: weekday - 1));
    final startOfWeek = DateTime(start.year, start.month, start.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return DateRangeState(
      startDate: startOfWeek,
      endDate: endOfWeek,
      period: AnalyticsPeriod.thisWeek,
    );
  }

  factory DateRangeState.thisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateRangeState(
      startDate: start,
      endDate: end,
      period: AnalyticsPeriod.thisMonth,
    );
  }

  factory DateRangeState.custom(DateTime start, DateTime end) {
    return DateRangeState(
      startDate: start,
      endDate: end,
      period: AnalyticsPeriod.custom,
    );
  }
}

/// Selected date range provider
class DateRangeNotifier extends StateNotifier<DateRangeState> {
  DateRangeNotifier() : super(DateRangeState.today());

  void setToday() => state = DateRangeState.today();
  void setYesterday() => state = DateRangeState.yesterday();
  void setThisWeek() => state = DateRangeState.thisWeek();
  void setThisMonth() => state = DateRangeState.thisMonth();
  void setCustomRange(DateTime start, DateTime end) =>
      state = DateRangeState.custom(start, end);
}

final dateRangeProvider = StateNotifierProvider<DateRangeNotifier, DateRangeState>(
  (ref) => DateRangeNotifier(),
);

/// Sales summary for selected date range
final salesSummaryProvider = Provider<SalesSummary>((ref) {
  final dateRange = ref.watch(dateRangeProvider);
  final ordersAsync = ref.watch(ordersProvider());

  return ordersAsync.maybeWhen(
    data: (orders) {
      // Filter orders by date range
      final filteredOrders = orders.where((order) {
        return order.createdAt.isAfter(dateRange.startDate) &&
            order.createdAt.isBefore(dateRange.endDate);
      }).toList();

      return SalesSummary.fromOrders(
        filteredOrders,
        dateRange.startDate,
        dateRange.endDate,
      );
    },
    orElse: () => SalesSummary(
      grossSales: 0,
      discounts: 0,
      refunds: 0,
      netSales: 0,
      tax: 0,
      ordersCount: 0,
      itemsCount: 0,
      averageOrderValue: 0,
      paymentMethodBreakdown: {},
      startDate: dateRange.startDate,
      endDate: dateRange.endDate,
    ),
  );
});

/// Hourly sales breakdown
final hourlySalesProvider = Provider<List<HourlySales>>((ref) {
  final dateRange = ref.watch(dateRangeProvider);
  final ordersAsync = ref.watch(ordersProvider());

  return ordersAsync.maybeWhen(
    data: (orders) {
      // Filter orders by date range
      final filteredOrders = orders.where((order) {
        return order.createdAt.isAfter(dateRange.startDate) &&
            order.createdAt.isBefore(dateRange.endDate);
      }).toList();

      // Group by hour
      final hourlyData = <int, List<Order>>{};
      for (final order in filteredOrders) {
        final hour = order.createdAt.hour;
        hourlyData.putIfAbsent(hour, () => []).add(order);
      }

      // Convert to HourlySales
      return List.generate(24, (hour) {
        final ordersInHour = hourlyData[hour] ?? [];
        final sales = ordersInHour.fold<double>(0, (sum, order) => sum + order.total);
        return HourlySales(
          hour: hour,
          sales: sales,
          orders: ordersInHour.length,
        );
      });
    },
    orElse: () => [],
  );
});

/// Top products by revenue
final topProductsByRevenueProvider = Provider<List<ProductPerformance>>((ref) {
  final dateRange = ref.watch(dateRangeProvider);
  final ordersAsync = ref.watch(ordersProvider());

  return ordersAsync.maybeWhen(
    data: (orders) {
      // Filter orders by date range
      final filteredOrders = orders.where((order) {
        return order.createdAt.isAfter(dateRange.startDate) &&
            order.createdAt.isBefore(dateRange.endDate);
      }).toList();

      // Calculate product performance
      final productData = <String, ProductPerformance>{};
      for (final order in filteredOrders) {
        for (final item in order.items) {
          final existing = productData[item.productId];
          if (existing == null) {
            productData[item.productId] = ProductPerformance(
              productId: item.productId,
              productName: item.productName,
              quantitySold: item.quantity,
              revenue: item.price * item.quantity,
              averagePrice: item.price,
            );
          } else {
            final newQuantity = existing.quantitySold + item.quantity;
            final newRevenue = existing.revenue + (item.price * item.quantity);
            productData[item.productId] = ProductPerformance(
              productId: item.productId,
              productName: item.productName,
              quantitySold: newQuantity,
              revenue: newRevenue,
              averagePrice: newRevenue / newQuantity,
            );
          }
        }
      }

      // Sort by revenue and take top 20
      final products = productData.values.toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));
      return products.take(20).toList();
    },
    orElse: () => [],
  );
});

/// Top products by quantity
final topProductsByQuantityProvider = Provider<List<ProductPerformance>>((ref) {
  final topProducts = ref.watch(topProductsByRevenueProvider);
  return topProducts.toList()
    ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
});

/// Category performance
final categoryPerformanceProvider = Provider<List<CategoryPerformance>>((ref) {
  // Mock category data for now
  // TODO: Integrate with actual category data from products
  final products = ref.watch(topProductsByRevenueProvider);

  if (products.isEmpty) return [];

  final totalRevenue = products.fold<double>(0, (sum, p) => sum + p.revenue);

  return [
    CategoryPerformance(
      categoryId: 'cat-1',
      categoryName: 'Beverages',
      itemsSold: 145,
      revenue: totalRevenue * 0.3,
      percentage: 30.0,
    ),
    CategoryPerformance(
      categoryId: 'cat-2',
      categoryName: 'Main Course',
      itemsSold: 98,
      revenue: totalRevenue * 0.45,
      percentage: 45.0,
    ),
    CategoryPerformance(
      categoryId: 'cat-3',
      categoryName: 'Desserts',
      itemsSold: 67,
      revenue: totalRevenue * 0.15,
      percentage: 15.0,
    ),
    CategoryPerformance(
      categoryId: 'cat-4',
      categoryName: 'Appetizers',
      itemsSold: 54,
      revenue: totalRevenue * 0.1,
      percentage: 10.0,
    ),
  ];
});

/// Staff performance (mock for now)
final staffPerformanceProvider = Provider<List<StaffPerformance>>((ref) {
  final summary = ref.watch(salesSummaryProvider);

  if (summary.ordersCount == 0) return [];

  return [
    StaffPerformance(
      staffId: 'staff-1',
      staffName: 'John Doe',
      ordersServed: (summary.ordersCount * 0.35).round(),
      totalSales: summary.grossSales * 0.35,
      averageOrderValue: summary.averageOrderValue * 1.05,
      tips: summary.grossSales * 0.035,
    ),
    StaffPerformance(
      staffId: 'staff-2',
      staffName: 'Jane Smith',
      ordersServed: (summary.ordersCount * 0.30).round(),
      totalSales: summary.grossSales * 0.30,
      averageOrderValue: summary.averageOrderValue * 0.95,
      tips: summary.grossSales * 0.030,
    ),
    StaffPerformance(
      staffId: 'staff-3',
      staffName: 'Mike Johnson',
      ordersServed: (summary.ordersCount * 0.25).round(),
      totalSales: summary.grossSales * 0.25,
      averageOrderValue: summary.averageOrderValue,
      tips: summary.grossSales * 0.025,
    ),
    StaffPerformance(
      staffId: 'staff-4',
      staffName: 'Sarah Williams',
      ordersServed: (summary.ordersCount * 0.10).round(),
      totalSales: summary.grossSales * 0.10,
      averageOrderValue: summary.averageOrderValue * 0.90,
      tips: summary.grossSales * 0.010,
    ),
  ];
});

/// Peak hours analysis
final peakHoursProvider = Provider<List<int>>((ref) {
  final hourlySales = ref.watch(hourlySalesProvider);

  if (hourlySales.isEmpty) return [];

  // Get hours sorted by sales
  final sortedHours = hourlySales.toList()
    ..sort((a, b) => b.sales.compareTo(a.sales));

  // Return top 3 peak hours
  return sortedHours.take(3).map((h) => h.hour).toList();
});
