/// Waiter Offline Order Service
/// Manages offline-first order operations with sync queue and conflict resolution
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../database/waiter_local_database.dart';
import 'waiter_realtime_service.dart';

/// Sync operation types
enum SyncOperationType {
  create,
  update,
  statusChange,
  cancel,
  addItem,
  removeItem,
  updateItem,
}

/// Sync status
enum SyncStatus {
  idle,
  syncing,
  error,
}

/// Offline order service
class WaiterOfflineOrderService {
  final WaiterLocalDatabase _database;
  final WaiterRealtimeService _realtimeService;
  final Ref _ref;

  Timer? _syncTimer;
  SyncStatus _syncStatus = SyncStatus.idle;
  String? _syncError;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  SyncStatus get currentSyncStatus => _syncStatus;
  String? get syncError => _syncError;

  WaiterOfflineOrderService({
    required WaiterLocalDatabase database,
    required WaiterRealtimeService realtimeService,
    required Ref ref,
  })  : _database = database,
        _realtimeService = realtimeService,
        _ref = ref {
    _initialize();
  }

  /// Initialize service
  void _initialize() {
    // Start background sync timer
    _startSyncTimer();

    // Listen to connection status changes
    _realtimeService.statusStream.listen((status) {
      if (status == WaiterConnectionStatus.connected) {
        // Connection restored, trigger sync
        syncPendingOperations();
      }
    });
  }

  /// Start background sync timer
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_realtimeService.currentStatus == WaiterConnectionStatus.connected) {
        syncPendingOperations();
      }
    });
  }

  // ==================== Order Operations ====================

  /// Create new order (optimistic)
  Future<Order> createOrder({
    required String tableId,
    required String tableName,
    String? serverId,
    String? serverName,
    List<OrderItem> items = const [],
    String? notes,
    int? guestCount,
  }) async {
    final order = Order(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      tableId: tableId,
      tableName: tableName,
      serverId: serverId,
      serverName: serverName,
      status: OrderStatus.pending,
      items: items,
      subtotal: _calculateSubtotal(items),
      tax: _calculateTax(items),
      total: _calculateTotal(items),
      notes: notes,
      guestCount: guestCount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save locally first (optimistic)
    await _database.insertOrder(order, isSynced: false);

    // Queue sync operation
    await _database.addSyncOperation(
      orderId: order.id,
      operation: SyncOperationType.create.name,
      data: order.toJson(),
      priority: 10, // High priority for new orders
    );

    // Try immediate sync if online
    if (_realtimeService.currentStatus == WaiterConnectionStatus.connected) {
      unawaited(_syncOrder(order.id));
    }

    return order;
  }

  /// Update order (optimistic)
  Future<void> updateOrder(Order order) async {
    final updated = order.copyWith(
      updatedAt: DateTime.now(),
      subtotal: _calculateSubtotal(order.items),
      tax: _calculateTax(order.items),
      total: _calculateTotal(order.items),
    );

    // Update locally first
    await _database.insertOrder(updated, isSynced: false);

    // Queue sync operation
    await _database.addSyncOperation(
      orderId: updated.id,
      operation: SyncOperationType.update.name,
      data: updated.toJson(),
      priority: 8,
    );

    // Try immediate sync if online
    if (_realtimeService.currentStatus == WaiterConnectionStatus.connected) {
      unawaited(_syncOrder(updated.id));
    }
  }

  /// Add item to order (optimistic)
  Future<void> addItemToOrder(String orderId, OrderItem item) async {
    final localOrder = await _database.getOrderById(orderId);
    if (localOrder == null) return;

    final order = _database.localOrderToOrder(localOrder);
    final updatedOrder = order.copyWith(
      items: [...order.items, item],
      updatedAt: DateTime.now(),
    );

    await updateOrder(updatedOrder);

    // Record modification
    await _database.addModification(
      orderId: orderId,
      itemId: item.id,
      modificationType: 'add',
      data: item.toJson(),
    );
  }

  /// Remove item from order (optimistic)
  Future<void> removeItemFromOrder(String orderId, String itemId) async {
    final localOrder = await _database.getOrderById(orderId);
    if (localOrder == null) return;

    final order = _database.localOrderToOrder(localOrder);
    final updatedOrder = order.copyWith(
      items: order.items.where((i) => i.id != itemId).toList(),
      updatedAt: DateTime.now(),
    );

    await updateOrder(updatedOrder);

    // Record modification
    await _database.addModification(
      orderId: orderId,
      itemId: itemId,
      modificationType: 'remove',
      data: {'item_id': itemId},
    );
  }

  /// Update item quantity (optimistic)
  Future<void> updateItemQuantity(
    String orderId,
    String itemId,
    int quantity,
  ) async {
    final localOrder = await _database.getOrderById(orderId);
    if (localOrder == null) return;

    final order = _database.localOrderToOrder(localOrder);
    final updatedItems = order.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    final updatedOrder = order.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    await updateOrder(updatedOrder);

    // Record modification
    await _database.addModification(
      orderId: orderId,
      itemId: itemId,
      modificationType: 'update_quantity',
      data: {'quantity': quantity},
    );
  }

  /// Update order status (optimistic)
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    // Update locally first
    await _database.updateOrderStatus(orderId, status);

    // Queue sync operation
    await _database.addSyncOperation(
      orderId: orderId,
      operation: SyncOperationType.statusChange.name,
      data: {'status': status.name},
      priority: 9,
    );

    // Try immediate sync if online
    if (_realtimeService.currentStatus == WaiterConnectionStatus.connected) {
      unawaited(_syncOrder(orderId));
    }
  }

  /// Send order to kitchen
  Future<void> sendToKitchen(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.confirmed);

    // Notify via WebSocket
    final localOrder = await _database.getOrderById(orderId);
    if (localOrder != null) {
      final order = _database.localOrderToOrder(localOrder);
      _realtimeService.notifyOrderCreated(order);
    }
  }

  /// Cancel order (optimistic)
  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.cancelled);

    // Queue sync operation with high priority
    await _database.addSyncOperation(
      orderId: orderId,
      operation: SyncOperationType.cancel.name,
      data: {'cancelled_at': DateTime.now().toIso8601String()},
      priority: 10,
    );

    // Try immediate sync if online
    if (_realtimeService.currentStatus == WaiterConnectionStatus.connected) {
      unawaited(_syncOrder(orderId));
    }
  }

  // ==================== Sync Operations ====================

  /// Sync all pending operations
  Future<void> syncPendingOperations() async {
    if (_syncStatus == SyncStatus.syncing) return;

    try {
      _updateSyncStatus(SyncStatus.syncing, null);

      // Get all pending operations
      final operations = await _database.getPendingSyncOperations();

      for (final op in operations) {
        try {
          await _processSyncOperation(op);
          await _database.removeSyncOperation(op.id);
        } catch (e) {
          // Record failed attempt
          await _database.recordSyncOperationAttempt(op.id, e.toString());

          // If too many attempts, remove from queue
          if (op.attempts >= 5) {
            await _database.removeSyncOperation(op.id);
          }
        }
      }

      // Sync unsynced orders
      final unsyncedOrders = await _database.getUnsyncedOrders();
      for (final localOrder in unsyncedOrders) {
        try {
          await _syncOrder(localOrder.id);
        } catch (e) {
          await _database.recordSyncAttempt(localOrder.id, e.toString());
        }
      }

      _updateSyncStatus(SyncStatus.idle, null);
    } catch (e) {
      _updateSyncStatus(SyncStatus.error, e.toString());
    }
  }

  /// Sync specific order
  Future<void> _syncOrder(String orderId) async {
    final localOrder = await _database.getOrderById(orderId);
    if (localOrder == null) return;

    // In production, send to backend API
    // For now, just mark as synced after short delay
    await Future.delayed(const Duration(milliseconds: 100));

    // TODO: Replace with actual API call
    // final response = await _apiClient.createOrder(order);
    // if (response.success) {
    //   await _database.markOrderAsSynced(orderId);
    //   await _database.clearSyncQueueForOrder(orderId);
    // }

    // Mock success
    await _database.markOrderAsSynced(orderId);
    await _database.clearSyncQueueForOrder(orderId);
  }

  /// Process sync operation
  Future<void> _processSyncOperation(SyncQueueData operation) async {
    final data = jsonDecode(operation.dataJson) as Map<String, dynamic>;

    switch (operation.operation) {
      case 'create':
        // TODO: Send to backend API
        // await _apiClient.createOrder(Order.fromJson(data));
        break;

      case 'update':
        // TODO: Send to backend API
        // await _apiClient.updateOrder(Order.fromJson(data));
        break;

      case 'statusChange':
        final status = data['status'] as String;
        // TODO: Send to backend API
        // await _apiClient.updateOrderStatus(operation.orderId, status);
        break;

      case 'cancel':
        // TODO: Send to backend API
        // await _apiClient.cancelOrder(operation.orderId);
        break;

      case 'addItem':
      case 'removeItem':
      case 'updateItem':
        // TODO: Send to backend API
        // await _apiClient.modifyOrder(operation.orderId, data);
        break;
    }

    // Mock delay
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Handle incoming order update from WebSocket (conflict resolution)
  Future<void> handleIncomingOrderUpdate(Order remoteOrder) async {
    final localOrder = await _database.getOrderById(remoteOrder.id);

    if (localOrder == null) {
      // New order from another device, save it
      await _database.insertOrder(remoteOrder, isSynced: true);
      return;
    }

    // Conflict resolution strategy:
    // 1. If local is synced, remote wins
    // 2. If local has pending changes, local wins (will sync later)
    // 3. Use server's timestamp as tiebreaker

    if (localOrder.isSynced) {
      // Remote wins, update local
      await _database.insertOrder(remoteOrder, isSynced: true);
    } else {
      // Local has pending changes, keep local version
      // It will sync when connection is stable

      // But update status if remote is more advanced
      final localStatus = OrderStatus.values.firstWhere(
        (s) => s.name == localOrder.status,
        orElse: () => OrderStatus.pending,
      );

      if (_isStatusMoreAdvanced(remoteOrder.status, localStatus)) {
        await _database.updateOrderStatus(remoteOrder.id, remoteOrder.status);
      }
    }
  }

  /// Check if status is more advanced
  bool _isStatusMoreAdvanced(OrderStatus remote, OrderStatus local) {
    final statusOrder = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.completed,
      OrderStatus.cancelled,
    ];

    final remoteIndex = statusOrder.indexOf(remote);
    final localIndex = statusOrder.indexOf(local);

    return remoteIndex > localIndex;
  }

  // ==================== Query Operations ====================

  /// Get all orders
  Future<List<Order>> getAllOrders() async {
    final localOrders = await _database.getAllOrders();
    return localOrders.map(_database.localOrderToOrder).toList();
  }

  /// Get orders by status
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final localOrders = await _database.getOrdersByStatus(status.name);
    return localOrders.map(_database.localOrderToOrder).toList();
  }

  /// Get active orders (not completed or cancelled)
  Future<List<Order>> getActiveOrders() async {
    final allOrders = await getAllOrders();
    return allOrders.where((order) {
      return order.status != OrderStatus.completed &&
          order.status != OrderStatus.cancelled;
    }).toList();
  }

  /// Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    final localOrder = await _database.getOrderById(orderId);
    if (localOrder == null) return null;
    return _database.localOrderToOrder(localOrder);
  }

  /// Get orders by table
  Future<List<Order>> getOrdersByTable(String tableId) async {
    final localOrders = await _database.getOrdersByTable(tableId);
    return localOrders.map(_database.localOrderToOrder).toList();
  }

  /// Get unsynced orders count
  Future<int> getUnsyncedCount() async {
    final unsynced = await _database.getUnsyncedOrders();
    return unsynced.length;
  }

  /// Get sync statistics
  Future<Map<String, int>> getSyncStats() async {
    return await _database.getStats();
  }

  // ==================== Cleanup Operations ====================

  /// Cleanup old synced data
  Future<void> cleanup() async {
    // Delete synced orders older than 7 days
    await _database.cleanupSyncedOrders(const Duration(days: 7));

    // Delete synced modifications older than 7 days
    await _database.cleanupSyncedModifications(const Duration(days: 7));
  }

  // ==================== Calculation Helpers ====================

  double _calculateSubtotal(List<OrderItem> items) {
    return items.fold(0.0, (sum, item) {
      final itemTotal = item.price * item.quantity;
      final modifiersTotal = item.modifiers?.fold(0.0, (sum, mod) {
            return sum + (mod.price * item.quantity);
          }) ??
          0.0;
      return sum + itemTotal + modifiersTotal;
    });
  }

  double _calculateTax(List<OrderItem> items) {
    final subtotal = _calculateSubtotal(items);
    return subtotal * 0.1; // 10% tax
  }

  double _calculateTotal(List<OrderItem> items) {
    return _calculateSubtotal(items) + _calculateTax(items);
  }

  /// Update sync status
  void _updateSyncStatus(SyncStatus status, String? error) {
    _syncStatus = status;
    _syncError = error;
    _syncStatusController.add(status);
  }

  /// Dispose resources
  Future<void> dispose() async {
    _syncTimer?.cancel();
    await _syncStatusController.close();
  }
}

/// Waiter offline order service provider
final waiterOfflineOrderServiceProvider =
    Provider<WaiterOfflineOrderService>((ref) {
  final database = ref.watch(waiterLocalDatabaseProvider);
  final realtimeService = ref.watch(waiterRealtimeServiceProvider);

  final service = WaiterOfflineOrderService(
    database: database,
    realtimeService: realtimeService,
    ref: ref,
  );

  ref.onDispose(() => service.dispose());

  return service;
});

/// Waiter local database provider
final waiterLocalDatabaseProvider = Provider<WaiterLocalDatabase>((ref) {
  return WaiterLocalDatabase();
});

/// Active orders provider
final waiterActiveOrdersProvider = StreamProvider<List<Order>>((ref) async* {
  final service = ref.watch(waiterOfflineOrderServiceProvider);

  // Initial load
  yield await service.getActiveOrders();

  // Listen to sync status changes and reload
  await for (final _ in service.syncStatusStream) {
    yield await service.getActiveOrders();
  }
});

/// Unsynced count provider
final waiterUnsyncedCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(waiterOfflineOrderServiceProvider);
  return await service.getUnsyncedCount();
});

/// Sync status provider
final waiterSyncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final service = ref.watch(waiterOfflineOrderServiceProvider);
  return service.syncStatusStream;
});
