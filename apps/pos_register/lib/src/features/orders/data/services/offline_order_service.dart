/// Offline-First Order Service
/// Handles order creation and management with offline support (Odoo pattern)
library;

import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:pos_core/pos_core.dart';
import '../../../data/database/local_database.dart';
import '../../../core/services/connectivity_service.dart';

/// Offline-first order service following Odoo POS pattern
///
/// Key principles:
/// - Save locally first (immediate response)
/// - Add to sync queue
/// - Auto-sync when online
/// - Kitchen routing integration
class OfflineOrderService {
  final LocalDatabase _database;
  final ConnectivityService _connectivity;
  final ApiClient _apiClient;
  final AppContext _appContext;

  static const _uuid = Uuid();

  OfflineOrderService({
    required LocalDatabase database,
    required ConnectivityService connectivity,
    required ApiClient apiClient,
    required AppContext appContext,
  })  : _database = database,
        _connectivity = connectivity,
        _apiClient = apiClient,
        _appContext = appContext;

  /// Create new order (offline-first)
  Future<Result<Order>> createOrder({
    required List<OrderItem> items,
    required OrderType orderType,
    String? tableId,
    String? tableName,
    String? customerId,
    String? customerName,
    String? notes,
    double discountPercent = 0,
    double taxPercent = 8.5,
  }) async {
    try {
      final now = DateTime.now();
      final orderId = _uuid.v4();
      final orderNumber = _generateOrderNumber(now);

      // Calculate totals
      final subtotal = items.fold<double>(
        0,
        (sum, item) => sum + item.subtotal,
      );
      final discountAmount = subtotal * (discountPercent / 100);
      final subtotalAfterDiscount = subtotal - discountAmount;
      final taxAmount = subtotalAfterDiscount * (taxPercent / 100);
      final total = subtotalAfterDiscount + taxAmount;

      final order = Order(
        id: orderId,
        orderNumber: orderNumber,
        status: OrderStatus.draft,
        orderType: orderType,
        items: items,
        tableId: tableId,
        tableName: tableName,
        customerId: customerId,
        customerName: customerName,
        notes: notes,
        subtotal: subtotal,
        discountAmount: discountAmount,
        discountPercent: discountPercent,
        taxAmount: taxAmount,
        taxPercent: taxPercent,
        total: total,
        userId: _appContext.currentUserId,
        userName: _appContext.currentUserName,
        deviceId: await _getDeviceId(),
        createdAt: now,
      );

      // Save to local database first (Odoo pattern)
      await _saveOrderLocally(order);

      // Add to sync queue
      await _addToSyncQueue(order, 'create_order');

      // Attempt immediate sync if online
      if (_connectivity.isOnline) {
        _trySyncOrder(order).ignore();
      }

      return Result.success(order);
    } catch (e) {
      return Result.failure(AppException('Failed to create order: $e'));
    }
  }

  /// Confirm order (move from draft to confirmed)
  Future<Result<Order>> confirmOrder(String orderId) async {
    try {
      final order = await _getLocalOrder(orderId);
      if (order == null) {
        return Result.failure(AppException('Order not found'));
      }

      if (order.status != OrderStatus.draft) {
        return Result.failure(
          AppException('Can only confirm draft orders'),
        );
      }

      final confirmedOrder = order.copyWith(
        status: OrderStatus.confirmed,
        updatedAt: DateTime.now(),
      );

      // Update locally
      await _updateOrderLocally(confirmedOrder);

      // Add to sync queue
      await _addToSyncQueue(confirmedOrder, 'update_order');

      // Route to kitchen if online
      if (_connectivity.isOnline) {
        _routeToKitchen(confirmedOrder).ignore();
      }

      // Attempt immediate sync if online
      if (_connectivity.isOnline) {
        _trySyncOrder(confirmedOrder).ignore();
      }

      return Result.success(confirmedOrder);
    } catch (e) {
      return Result.failure(AppException('Failed to confirm order: $e'));
    }
  }

  /// Update order status
  Future<Result<Order>> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    try {
      final order = await _getLocalOrder(orderId);
      if (order == null) {
        return Result.failure(AppException('Order not found'));
      }

      // Validate status transition
      if (!_isValidStatusTransition(order.status, newStatus)) {
        return Result.failure(
          AppException('Invalid status transition: ${order.status} -> $newStatus'),
        );
      }

      final updatedOrder = order.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        completedAt: newStatus == OrderStatus.completed ? DateTime.now() : null,
      );

      // Update locally
      await _updateOrderLocally(updatedOrder);

      // Add to sync queue
      await _addToSyncQueue(updatedOrder, 'update_order_status');

      // Attempt immediate sync if online
      if (_connectivity.isOnline) {
        _trySyncOrder(updatedOrder).ignore();
      }

      return Result.success(updatedOrder);
    } catch (e) {
      return Result.failure(AppException('Failed to update order status: $e'));
    }
  }

  /// Add item to existing order
  Future<Result<Order>> addItemToOrder(
    String orderId,
    OrderItem newItem,
  ) async {
    try {
      final order = await _getLocalOrder(orderId);
      if (order == null) {
        return Result.failure(AppException('Order not found'));
      }

      if (!order.canModify) {
        return Result.failure(AppException('Order cannot be modified'));
      }

      final updatedItems = [...order.items, newItem];
      final updatedOrder = _recalculateTotals(order.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      ));

      // Update locally
      await _updateOrderLocally(updatedOrder);

      // Add to sync queue
      await _addToSyncQueue(updatedOrder, 'update_order');

      // Attempt immediate sync if online
      if (_connectivity.isOnline) {
        _trySyncOrder(updatedOrder).ignore();
      }

      return Result.success(updatedOrder);
    } catch (e) {
      return Result.failure(AppException('Failed to add item: $e'));
    }
  }

  /// Update item quantity in order
  Future<Result<Order>> updateItemQuantity(
    String orderId,
    String itemId,
    int newQuantity,
  ) async {
    try {
      if (newQuantity < 0) {
        return Result.failure(AppException('Quantity cannot be negative'));
      }

      final order = await _getLocalOrder(orderId);
      if (order == null) {
        return Result.failure(AppException('Order not found'));
      }

      if (!order.canModify) {
        return Result.failure(AppException('Order cannot be modified'));
      }

      final updatedItems = order.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(quantity: newQuantity);
        }
        return item;
      }).where((item) => item.quantity > 0).toList(); // Remove if quantity is 0

      final updatedOrder = _recalculateTotals(order.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      ));

      // Update locally
      await _updateOrderLocally(updatedOrder);

      // Add to sync queue
      await _addToSyncQueue(updatedOrder, 'update_order');

      // Attempt immediate sync if online
      if (_connectivity.isOnline) {
        _trySyncOrder(updatedOrder).ignore();
      }

      return Result.success(updatedOrder);
    } catch (e) {
      return Result.failure(AppException('Failed to update quantity: $e'));
    }
  }

  /// Remove item from order
  Future<Result<Order>> removeItemFromOrder(
    String orderId,
    String itemId,
  ) async {
    try {
      final order = await _getLocalOrder(orderId);
      if (order == null) {
        return Result.failure(AppException('Order not found'));
      }

      if (!order.canModify) {
        return Result.failure(AppException('Order cannot be modified'));
      }

      final updatedItems = order.items
          .where((item) => item.id != itemId)
          .toList();

      if (updatedItems.isEmpty) {
        return Result.failure(
          AppException('Cannot remove last item. Cancel order instead.'),
        );
      }

      final updatedOrder = _recalculateTotals(order.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      ));

      // Update locally
      await _updateOrderLocally(updatedOrder);

      // Add to sync queue
      await _addToSyncQueue(updatedOrder, 'update_order');

      // Attempt immediate sync if online
      if (_connectivity.isOnline) {
        _trySyncOrder(updatedOrder).ignore();
      }

      return Result.success(updatedOrder);
    } catch (e) {
      return Result.failure(AppException('Failed to remove item: $e'));
    }
  }

  /// Get pending sync orders count
  Future<int> getPendingSyncCount() async {
    final pending = await _database.getPendingOrders();
    return pending.length;
  }

  /// Force sync all pending orders
  Future<void> syncPendingOrders() async {
    if (!_connectivity.isOnline) {
      return;
    }

    final pending = await _database.getPendingOrders();

    for (final offlineOrder in pending) {
      try {
        // Convert to Order entity and sync
        final order = await _getLocalOrder(offlineOrder.id);
        if (order != null) {
          await _trySyncOrder(order);
        }
      } catch (e) {
        print('Error syncing order ${offlineOrder.id}: $e');
      }
    }
  }

  // =============== Private Helper Methods ===============

  Future<String> _getDeviceId() async {
    // TODO: Get actual device ID from device info plugin
    return 'device-${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateOrderNumber(DateTime timestamp) {
    final date = timestamp.toIso8601String().substring(0, 10);
    final time = timestamp.millisecondsSinceEpoch.toString().substring(8);
    return 'ORD-$date-$time';
  }

  Future<void> _saveOrderLocally(Order order) async {
    final companion = _orderToCompanion(order, 'pending_sync');
    await _database.upsertOfflineOrder(companion);

    // Save items
    final itemCompanions = order.items
        .map((item) => _orderItemToCompanion(item, order.id))
        .toList();
    await _database.insertOrderItems(itemCompanions);
  }

  Future<void> _updateOrderLocally(Order order) async {
    final companion = _orderToCompanion(order, 'pending_sync');
    await _database.upsertOfflineOrder(companion);

    // Delete old items and insert new ones
    await _database.deleteOrderItems(order.id);
    final itemCompanions = order.items
        .map((item) => _orderItemToCompanion(item, order.id))
        .toList();
    if (itemCompanions.isNotEmpty) {
      await _database.insertOrderItems(itemCompanions);
    }
  }

  Future<Order?> _getLocalOrder(String orderId) async {
    final offlineOrders = await _database.getAllOfflineOrders();
    final offlineOrder = offlineOrders.where((o) => o.id == orderId).firstOrNull;

    if (offlineOrder == null) return null;

    final items = await _database.getOrderItems(orderId);

    return Order(
      id: offlineOrder.id,
      orderNumber: offlineOrder.orderNumber,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == offlineOrder.status,
        orElse: () => OrderStatus.draft,
      ),
      orderType: OrderType.dineIn, // TODO: Parse from stored data
      items: items.map(_offlineItemToOrderItem).toList(),
      subtotal: offlineOrder.subtotal,
      taxAmount: offlineOrder.tax,
      total: offlineOrder.total,
      customerId: offlineOrder.customerId,
      customerName: offlineOrder.customerName,
      tableId: offlineOrder.tableId,
      tableName: offlineOrder.tableName,
      notes: offlineOrder.notes,
      createdAt: offlineOrder.createdAt,
      updatedAt: offlineOrder.updatedAt,
    );
  }

  OfflineOrdersCompanion _orderToCompanion(Order order, String status) {
    return OfflineOrdersCompanion.insert(
      id: order.id,
      orderNumber: order.orderNumber,
      status: status,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt ?? order.createdAt,
      subtotal: order.subtotal,
      tax: order.taxAmount,
      total: order.total,
      itemsCount: order.itemsCount,
      customerId: Value(order.customerId),
      customerName: Value(order.customerName),
      tableId: Value(order.tableId),
      tableName: Value(order.tableName),
      notes: Value(order.notes),
      sessionId: 'current-session', // TODO: Get from session provider
      cashierId: order.userId ?? 'unknown',
      cashierName: order.userName ?? 'Unknown',
      paymentLines: '[]', // TODO: Implement payment lines
    );
  }

  OfflineOrderItemsCompanion _orderItemToCompanion(OrderItem item, String orderId) {
    return OfflineOrderItemsCompanion.insert(
      id: item.id,
      orderId: orderId,
      productId: item.productId,
      productName: item.productName,
      productSku: item.productSku ?? '',
      productImageUrl: Value(item.productImageUrl),
      categoryId: Value(item.categoryId),
      basePrice: item.basePrice,
      totalPrice: item.total,
      quantity: item.quantity,
      taxPercent: item.taxPercent,
      modifiersJson: jsonEncode(item.selectedModifiers
          .map((m) => {
                'id': m.modifierId,
                'name': m.modifierName,
                'price': m.price,
                'quantity': m.quantity,
              })
          .toList()),
      notes: Value(item.notes),
    );
  }

  OrderItem _offlineItemToOrderItem(OfflineOrderItem item) {
    return OrderItem(
      id: item.id,
      productId: item.productId,
      productName: item.productName,
      basePrice: item.basePrice,
      quantity: item.quantity,
      productSku: item.productSku,
      productImageUrl: item.productImageUrl,
      categoryId: item.categoryId,
      taxPercent: item.taxPercent,
      notes: item.notes,
      // TODO: Parse modifiers from JSON
      selectedModifiers: [],
    );
  }

  Future<void> _addToSyncQueue(Order order, String operationType) async {
    await _database.addToSyncQueue(
      operationType: operationType,
      entityType: 'order',
      entityId: order.id,
      payloadJson: jsonEncode({
        'order': _orderToJson(order),
      }),
      priority: 1, // High priority for orders
    );
  }

  Map<String, dynamic> _orderToJson(Order order) {
    return {
      'id': order.id,
      'order_number': order.orderNumber,
      'status': order.status.name,
      'order_type': order.orderType.name,
      'items': order.items.map((item) => {
            'id': item.id,
            'product_id': item.productId,
            'product_name': item.productName,
            'base_price': item.basePrice,
            'quantity': item.quantity,
            'total': item.total,
          }).toList(),
      'subtotal': order.subtotal,
      'tax_amount': order.taxAmount,
      'total': order.total,
      'table_id': order.tableId,
      'customer_id': order.customerId,
      'notes': order.notes,
      'created_at': order.createdAt.toIso8601String(),
      'updated_at': order.updatedAt?.toIso8601String(),
    };
  }

  Future<void> _trySyncOrder(Order order) async {
    try {
      // TODO: Implement actual API sync
      // For now, just mark as synced after delay
      await Future.delayed(const Duration(seconds: 1));

      await _database.updateOrderSyncStatus(
        orderId: order.id,
        status: 'synced',
      );
    } catch (e) {
      await _database.updateOrderSyncStatus(
        orderId: order.id,
        status: 'failed',
        error: e.toString(),
      );
      await _database.incrementSyncAttempts(order.id);
    }
  }

  Future<void> _routeToKitchen(Order order) async {
    // TODO: Implement kitchen routing via WebSocket
    print('Routing order ${order.orderNumber} to kitchen');
  }

  bool _isValidStatusTransition(OrderStatus from, OrderStatus to) {
    // Odoo-style status transitions
    switch (from) {
      case OrderStatus.draft:
        return to == OrderStatus.confirmed || to == OrderStatus.cancelled;
      case OrderStatus.pending:
        return to == OrderStatus.confirmed || to == OrderStatus.cancelled;
      case OrderStatus.confirmed:
        return to == OrderStatus.preparing ||
            to == OrderStatus.cancelled ||
            to == OrderStatus.hold;
      case OrderStatus.preparing:
        return to == OrderStatus.ready ||
            to == OrderStatus.hold ||
            to == OrderStatus.cancelled;
      case OrderStatus.ready:
        return to == OrderStatus.delivering ||
            to == OrderStatus.completed ||
            to == OrderStatus.hold;
      case OrderStatus.delivering:
        return to == OrderStatus.completed || to == OrderStatus.hold;
      case OrderStatus.hold:
        return to == OrderStatus.preparing ||
            to == OrderStatus.cancelled;
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return false; // Terminal states
    }
  }

  Order _recalculateTotals(Order order) {
    final subtotal = order.items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    final discountAmount = order.discountPercent > 0
        ? subtotal * (order.discountPercent / 100)
        : order.discountAmount;

    final subtotalAfterDiscount = subtotal - discountAmount;

    final taxAmount = order.taxPercent > 0
        ? subtotalAfterDiscount * (order.taxPercent / 100)
        : order.taxAmount;

    final total = subtotalAfterDiscount + taxAmount;

    return order.copyWith(
      subtotal: subtotal,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      total: total,
    );
  }
}
