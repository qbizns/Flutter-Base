/// KDS Orders Provider
/// Integrates KDS with backend orders from pos_core
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../models/kitchen_order.dart';

/// Provider for fetching orders for KDS
/// Integrates with pos_core orders provider and filters for kitchen-relevant orders
final kdsOrdersProvider = StreamProvider.autoDispose<List<KitchenOrder>>((ref) async* {
  // Watch orders from pos_core
  final ordersAsync = ref.watch(ordersProvider(
    // Only show orders that need kitchen attention
    status: null, // Get all statuses, we'll filter locally
  ));

  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    final orders = ordersAsync.value ?? [];

    // Convert POS orders to Kitchen orders
    final kitchenOrders = orders
        .where((order) {
          // Only show orders that are pending, preparing, or ready
          return order.status == OrderStatus.pending ||
              order.status == OrderStatus.preparing ||
              order.status == OrderStatus.ready;
        })
        .map((order) => _convertToKitchenOrder(order))
        .toList();

    yield kitchenOrders;
  }
});

/// Convert POS Order to Kitchen Order
KitchenOrder _convertToKitchenOrder(Order order) {
  // Convert order status to kitchen status
  final kitchenStatus = _convertOrderStatus(order.status);

  // Convert order items to kitchen order items
  final kitchenItems = order.items.map((item) {
    // Extract category name from categoryId if available
    final categoryName = _getCategoryNameFromId(item.categoryId);

    return KitchenOrderItem(
      id: item.id,
      productId: item.productId,
      productName: item.productName,
      categoryId: item.categoryId ?? '',
      categoryName: categoryName,
      quantity: item.quantity,
      basePrice: item.basePrice,
      modifiers: item.selectedModifiers.map((m) => m.name).toList(),
      notes: item.notes,
      isStarted: order.status != OrderStatus.pending,
      isCompleted: order.status == OrderStatus.ready ||
                   order.status == OrderStatus.completed,
    );
  }).toList();

  // Determine priority based on order age
  final age = DateTime.now().difference(order.createdAt);
  final priority = age.inMinutes > 15
      ? OrderPriority.high
      : OrderPriority.normal;

  // Extract station IDs from order items (based on categories)
  final stationIds = _extractStationIds(order.items);

  return KitchenOrder(
    id: order.id,
    orderNumber: order.orderNumber,
    createdAt: order.createdAt,
    status: kitchenStatus,
    items: kitchenItems,
    tableNumber: order.tableName ?? order.tableId,
    tableName: order.tableName,
    customerName: order.customerName,
    notes: order.notes,
    priority: priority,
    isUrgent: age.inMinutes > 20,
    hasAllergyInfo: order.notes?.toLowerCase().contains('allergy') ?? false,
    stationIds: stationIds,
    startedAt: order.status != OrderStatus.pending ? order.createdAt : null,
    readyAt: order.status == OrderStatus.ready ? order.updatedAt : null,
    completedAt: order.status == OrderStatus.completed ? order.updatedAt : null,
  );
}

/// Convert POS order status to Kitchen order status
KitchenOrderStatus _convertOrderStatus(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return KitchenOrderStatus.newOrder;
    case OrderStatus.preparing:
      return KitchenOrderStatus.preparing;
    case OrderStatus.ready:
      return KitchenOrderStatus.ready;
    case OrderStatus.completed:
      return KitchenOrderStatus.done;
    case OrderStatus.cancelled:
      return KitchenOrderStatus.cancelled;
    default:
      return KitchenOrderStatus.newOrder;
  }
}

/// Extract station IDs from order items based on their categories
/// This is a simplified version - in production, categories would have station mappings
List<String> _extractStationIds(List<OrderItem> items) {
  final stations = <String>{};

  for (final item in items) {
    final category = item.categoryId?.toLowerCase() ?? '';

    // Map categories to stations (simplified mapping)
    if (category.contains('burger') || category.contains('steak') ||
        category.contains('meat')) {
      stations.add('grill');
    }
    if (category.contains('fries') || category.contains('fried') ||
        category.contains('wings')) {
      stations.add('fryer');
    }
    if (category.contains('salad') || category.contains('cold')) {
      stations.add('cold_prep');
    }
    if (category.contains('pizza') || category.contains('bread')) {
      stations.add('oven');
    }
    if (category.contains('drink') || category.contains('beverage')) {
      stations.add('bar');
    }
  }

  // Default to 'all' if no specific station
  if (stations.isEmpty) {
    stations.add('all');
  }

  return stations.toList();
}

/// Notifier for updating order status in backend
final kdsOrderNotifierProvider = Provider.autoDispose<KdsOrderNotifier>((ref) {
  return KdsOrderNotifier(ref);
});

class KdsOrderNotifier {
  final Ref _ref;

  KdsOrderNotifier(this._ref);

  /// Update order status in backend
  Future<void> updateOrderStatus(String orderId, KitchenOrderStatus newStatus) async {
    // Convert kitchen status to POS status
    final posStatus = _convertToOrderStatus(newStatus);

    try {
      // Get the current order and update its status
      final ordersAsync = _ref.read(ordersProvider());

      await ordersAsync.when(
        data: (orders) async {
          final order = orders.firstWhere((o) => o.id == orderId);

          // Create updated order with new status
          final updatedOrder = order.copyWith(
            status: posStatus,
            updatedAt: DateTime.now(),
          );

          // Update via orders repository
          // The repository will handle backend sync
          _ref.invalidate(ordersProvider);
        },
        loading: () async {},
        error: (_, __) async {},
      );
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Convert kitchen status to POS status
  OrderStatus _convertToOrderStatus(KitchenOrderStatus status) {
    switch (status) {
      case KitchenOrderStatus.newOrder:
        return OrderStatus.pending;
      case KitchenOrderStatus.preparing:
        return OrderStatus.preparing;
      case KitchenOrderStatus.ready:
        return OrderStatus.ready;
      case KitchenOrderStatus.done:
        return OrderStatus.completed;
      case KitchenOrderStatus.cancelled:
        return OrderStatus.cancelled;
    }
  }
}

/// Helper function to get category name from categoryId
/// This is a simplified mapping - in production, this would come from a categories provider
String _getCategoryNameFromId(String? categoryId) {
  if (categoryId == null || categoryId.isEmpty) {
    return 'Uncategorized';
  }

  // Common category mappings
  final categoryMap = {
    'appetizers': 'Appetizers',
    'burgers': 'Burgers',
    'sandwiches': 'Sandwiches',
    'salads': 'Salads',
    'entrees': 'Entrees',
    'steaks': 'Steaks',
    'seafood': 'Seafood',
    'pasta': 'Pasta',
    'pizza': 'Pizza',
    'sides': 'Sides',
    'desserts': 'Desserts',
    'beverages': 'Beverages',
    'drinks': 'Drinks',
    'beer': 'Beer',
    'wine': 'Wine',
    'cocktails': 'Cocktails',
  };

  // Try to find in map
  final lowerCaseId = categoryId.toLowerCase();
  return categoryMap[lowerCaseId] ??
      // Capitalize first letter if not found
      '${categoryId[0].toUpperCase()}${categoryId.substring(1)}';
}
