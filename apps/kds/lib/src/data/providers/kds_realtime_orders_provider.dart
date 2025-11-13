/// KDS Real-time Orders Provider
/// Manages kitchen orders with WebSocket integration and sound notifications
library;

import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kitchen_order.dart';
import '../models/kitchen_station.dart';
import '../services/kds_websocket_service.dart';
import '../services/sound_notification_service.dart';

/// Orders state
class KdsOrdersState {
  final Map<String, KitchenOrder> orders;
  final WebSocketStatus connectionStatus;
  final DateTime? lastUpdate;
  final String? error;

  KdsOrdersState({
    Map<String, KitchenOrder>? orders,
    this.connectionStatus = WebSocketStatus.disconnected,
    this.lastUpdate,
    this.error,
  }) : orders = orders ?? {};

  /// Get orders as list, sorted by priority and age
  List<KitchenOrder> get ordersList {
    final list = orders.values.toList();

    // Sort by:
    // 1. Priority (urgent first)
    // 2. Status (new orders first)
    // 3. Age (older first)
    list.sort((a, b) {
      // Priority comparison
      final priorityDiff = a.priority.sortOrder - b.priority.sortOrder;
      if (priorityDiff != 0) return priorityDiff;

      // Status comparison (new orders first)
      final statusOrder = _getStatusSortOrder(a.status) -
          _getStatusSortOrder(b.status);
      if (statusOrder != 0) return statusOrder;

      // Age comparison (older first)
      return a.createdAt.compareTo(b.createdAt);
    });

    return list;
  }

  /// Get active orders (not done or cancelled)
  List<KitchenOrder> get activeOrders {
    return ordersList
        .where((o) =>
            o.status != KitchenOrderStatus.done &&
            o.status != KitchenOrderStatus.cancelled)
        .toList();
  }

  /// Get orders by station
  List<KitchenOrder> getOrdersByStation(String stationId) {
    if (stationId == 'all') return activeOrders;

    return activeOrders
        .where((order) => order.stationIds.contains(stationId))
        .toList();
  }

  /// Get orders by status
  List<KitchenOrder> getOrdersByStatus(KitchenOrderStatus status) {
    return activeOrders.where((order) => order.status == status).toList();
  }

  /// Get delayed orders
  List<KitchenOrder> get delayedOrders {
    return activeOrders.where((order) => order.isOrderDelayed).toList();
  }

  /// Get order counts by status
  Map<KitchenOrderStatus, int> get orderCountsByStatus {
    final counts = <KitchenOrderStatus, int>{};

    for (final order in activeOrders) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }

    return counts;
  }

  /// Status sort order (lower = higher priority in display)
  int _getStatusSortOrder(KitchenOrderStatus status) {
    switch (status) {
      case KitchenOrderStatus.newOrder:
        return 1;
      case KitchenOrderStatus.preparing:
        return 2;
      case KitchenOrderStatus.ready:
        return 3;
      case KitchenOrderStatus.done:
        return 4;
      case KitchenOrderStatus.cancelled:
        return 5;
    }
  }

  bool get isConnected => connectionStatus == WebSocketStatus.connected;
  bool get isConnecting => connectionStatus == WebSocketStatus.connecting ||
      connectionStatus == WebSocketStatus.reconnecting;

  KdsOrdersState copyWith({
    Map<String, KitchenOrder>? orders,
    WebSocketStatus? connectionStatus,
    DateTime? lastUpdate,
    String? error,
    bool clearError = false,
  }) {
    return KdsOrdersState(
      orders: orders ?? this.orders,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// KDS Orders Notifier
/// Manages kitchen orders state with real-time updates
class KdsOrdersNotifier extends StateNotifier<KdsOrdersState> {
  final KdsWebSocketService _wsService;
  final SoundNotificationService _soundService;
  StreamSubscription<KitchenOrder>? _orderSubscription;
  StreamSubscription<WebSocketStatus>? _statusSubscription;

  KdsOrdersNotifier({
    required KdsWebSocketService wsService,
    required SoundNotificationService soundService,
  })  : _wsService = wsService,
        _soundService = soundService,
        super(KdsOrdersState()) {
    _initialize();
  }

  /// Initialize WebSocket connection and listeners
  void _initialize() {
    // Connect to WebSocket
    _wsService.connect();

    // Listen to connection status
    _statusSubscription = _wsService.statusStream.listen((status) {
      state = state.copyWith(connectionStatus: status);
    });

    // Listen to order updates
    _orderSubscription = _wsService.orderStream.listen(
      _handleOrderUpdate,
      onError: (error) {
        state = state.copyWith(error: error.toString());
      },
    );
  }

  /// Handle incoming order update
  void _handleOrderUpdate(KitchenOrder order) {
    final orders = Map<String, KitchenOrder>.from(state.orders);
    final existingOrder = orders[order.id];

    // Check if this is a new order
    final isNewOrder = existingOrder == null &&
        order.status == KitchenOrderStatus.newOrder;

    // Update or add order
    orders[order.id] = order;

    state = state.copyWith(
      orders: orders,
      lastUpdate: DateTime.now(),
      clearError: true,
    );

    // Play sound notification for new orders
    if (isNewOrder) {
      _soundService.playNewOrder(order);
    }
    // Play sound for order ready
    else if (existingOrder?.status != KitchenOrderStatus.ready &&
        order.status == KitchenOrderStatus.ready) {
      _soundService.playOrderReady();
    }
  }

  /// Update order status locally and send to backend
  Future<void> updateOrderStatus(
    String orderId,
    KitchenOrderStatus newStatus,
  ) async {
    final order = state.orders[orderId];
    if (order == null) return;

    // Validate transition
    if (!_isValidTransition(order.status, newStatus)) {
      state = state.copyWith(
        error: 'Invalid status transition: ${order.status.displayName} → ${newStatus.displayName}',
      );
      return;
    }

    try {
      // Update locally first (optimistic update)
      final now = DateTime.now();
      final updatedOrder = order.copyWith(
        status: newStatus,
        startedAt: newStatus == KitchenOrderStatus.preparing && order.startedAt == null
            ? now
            : order.startedAt,
        readyAt: newStatus == KitchenOrderStatus.ready && order.readyAt == null
            ? now
            : order.readyAt,
        completedAt: newStatus == KitchenOrderStatus.done && order.completedAt == null
            ? now
            : order.completedAt,
      );

      final orders = Map<String, KitchenOrder>.from(state.orders);
      orders[orderId] = updatedOrder;

      state = state.copyWith(
        orders: orders,
        lastUpdate: now,
        clearError: true,
      );

      // Send update to backend via WebSocket
      await _sendStatusUpdate(orderId, newStatus);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update order: $e');
    }
  }

  /// Send status update via WebSocket
  Future<void> _sendStatusUpdate(
    String orderId,
    KitchenOrderStatus newStatus,
  ) async {
    try {
      _wsService.send({
        'type': 'order_status_update',
        'data': {
          'order_id': orderId,
          'status': newStatus.name,
          'updated_at': DateTime.now().toIso8601String(),
        },
      });
    } catch (e) {
      // WebSocket send failed - will retry on reconnect
      state = state.copyWith(
        error: 'Failed to send update to server: $e',
      );
    }
  }

  /// Validate status transition (Odoo pattern)
  bool _isValidTransition(
    KitchenOrderStatus from,
    KitchenOrderStatus to,
  ) {
    // Can always cancel
    if (to == KitchenOrderStatus.cancelled) return true;

    // Can't transition from terminal states
    if (from == KitchenOrderStatus.done ||
        from == KitchenOrderStatus.cancelled) {
      return false;
    }

    // Valid transitions
    switch (from) {
      case KitchenOrderStatus.newOrder:
        return to == KitchenOrderStatus.preparing;
      case KitchenOrderStatus.preparing:
        return to == KitchenOrderStatus.ready;
      case KitchenOrderStatus.ready:
        return to == KitchenOrderStatus.done;
      case KitchenOrderStatus.done:
      case KitchenOrderStatus.cancelled:
        return false;
    }
  }

  /// Toggle item completion
  void toggleItemCompletion(String orderId, String itemId) {
    final order = state.orders[orderId];
    if (order == null) return;

    final itemIndex = order.items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return;

    final item = order.items[itemIndex];
    final now = DateTime.now();

    // Toggle completion
    final updatedItem = item.copyWith(
      isStarted: true,
      isCompleted: !item.isCompleted,
      startedAt: item.startedAt ?? now,
      completedAt: !item.isCompleted ? now : null,
    );

    final updatedItems = List<KitchenOrderItem>.from(order.items);
    updatedItems[itemIndex] = updatedItem;

    final updatedOrder = order.copyWith(items: updatedItems);

    final orders = Map<String, KitchenOrder>.from(state.orders);
    orders[orderId] = updatedOrder;

    state = state.copyWith(
      orders: orders,
      lastUpdate: now,
    );

    // Play sound for item completion
    if (updatedItem.isCompleted) {
      _soundService.playItemCompleted();
    }
  }

  /// Reconnect to WebSocket
  Future<void> reconnect() async {
    await _wsService.disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await _wsService.connect();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    _statusSubscription?.cancel();
    _wsService.dispose();
    super.dispose();
  }
}

/// Real-time orders provider
/// Uses WebSocket for live updates
final kdsRealtimeOrdersProvider =
    StateNotifierProvider<KdsOrdersNotifier, KdsOrdersState>((ref) {
  final wsService = ref.watch(kdsWebSocketServiceProvider);
  final soundService = ref.watch(soundNotificationServiceProvider);

  return KdsOrdersNotifier(
    wsService: wsService,
    soundService: soundService,
  );
});

/// Filtered orders providers for convenience
/// Active orders only (not done/cancelled)
final kdsActiveOrdersProvider = Provider<List<KitchenOrder>>((ref) {
  final state = ref.watch(kdsRealtimeOrdersProvider);
  return state.activeOrders;
});

/// Orders filtered by station
final kdsOrdersByStationProvider =
    Provider.family<List<KitchenOrder>, String>((ref, stationId) {
  final state = ref.watch(kdsRealtimeOrdersProvider);
  return state.getOrdersByStation(stationId);
});

/// Orders filtered by status
final kdsOrdersByStatusProvider =
    Provider.family<List<KitchenOrder>, KitchenOrderStatus>((ref, status) {
  final state = ref.watch(kdsRealtimeOrdersProvider);
  return state.getOrdersByStatus(status);
});

/// Delayed orders provider
final kdsDelayedOrdersProvider = Provider<List<KitchenOrder>>((ref) {
  final state = ref.watch(kdsRealtimeOrdersProvider);
  return state.delayedOrders;
});

/// Order counts by status
final kdsOrderCountsProvider =
    Provider<Map<KitchenOrderStatus, int>>((ref) {
  final state = ref.watch(kdsRealtimeOrdersProvider);
  return state.orderCountsByStatus;
});

/// Connection status provider
final kdsConnectionStatusProvider = Provider<WebSocketStatus>((ref) {
  final state = ref.watch(kdsRealtimeOrdersProvider);
  return state.connectionStatus;
});
