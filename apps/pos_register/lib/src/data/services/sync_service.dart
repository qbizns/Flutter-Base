/// Background Sync Service
/// Handles synchronization between local database and backend API
library;

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../database/local_database.dart';

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  offline,
}

/// Sync state model
class SyncState {
  final SyncStatus status;
  final bool isOnline;
  final DateTime? lastSyncTime;
  final int pendingOperations;
  final String? errorMessage;

  const SyncState({
    required this.status,
    required this.isOnline,
    this.lastSyncTime,
    this.pendingOperations = 0,
    this.errorMessage,
  });

  SyncState copyWith({
    SyncStatus? status,
    bool? isOnline,
    DateTime? lastSyncTime,
    int? pendingOperations,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Sync service for background synchronization
class SyncService {
  final LocalDatabase _database;
  final ApiClient _apiClient;
  final Connectivity _connectivity;

  Timer? _syncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final _syncStateController = StreamController<SyncState>.broadcast();
  Stream<SyncState> get syncStateStream => _syncStateController.stream;

  SyncState _currentState = const SyncState(
    status: SyncStatus.idle,
    isOnline: true,
  );

  SyncState get currentState => _currentState;

  SyncService({
    required LocalDatabase database,
    required ApiClient apiClient,
    Connectivity? connectivity,
  })  : _database = database,
        _apiClient = apiClient,
        _connectivity = connectivity ?? Connectivity();

  /// Initialize sync service
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        _onConnectivityChanged(results);
      },
    );

    // Start periodic sync timer (every 30 seconds)
    _syncTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => syncPendingOperations(),
    );

    // Initial sync
    await syncPendingOperations();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _syncTimer?.cancel();
    await _connectivitySubscription?.cancel();
    await _syncStateController.close();
  }

  /// Check connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _onConnectivityChanged(results);
    } catch (e) {
      _updateState(
        _currentState.copyWith(
          isOnline: false,
          status: SyncStatus.offline,
        ),
      );
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isOnline = results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);

    _updateState(_currentState.copyWith(isOnline: isOnline));

    // Trigger sync when coming back online
    if (isOnline && _currentState.status != SyncStatus.syncing) {
      syncPendingOperations();
    }
  }

  /// Update sync state
  void _updateState(SyncState newState) {
    _currentState = newState;
    _syncStateController.add(newState);
  }

  /// Sync all pending operations
  Future<void> syncPendingOperations() async {
    // Don't sync if offline or already syncing
    if (!_currentState.isOnline || _currentState.status == SyncStatus.syncing) {
      return;
    }

    try {
      _updateState(_currentState.copyWith(status: SyncStatus.syncing));

      // Get pending operations
      final operations = await _database.getPendingSyncOperations();

      if (operations.isEmpty) {
        _updateState(_currentState.copyWith(
          status: SyncStatus.success,
          lastSyncTime: DateTime.now(),
          pendingOperations: 0,
        ));
        return;
      }

      // Process each operation
      int successCount = 0;
      int errorCount = 0;

      for (final operation in operations) {
        try {
          await _processSyncOperation(operation);
          successCount++;

          // Mark as completed
          await _database.updateSyncOperationStatus(
            operationId: operation.id,
            status: 'completed',
          );
        } catch (e) {
          errorCount++;

          // Increment attempts
          await _database.incrementSyncOperationAttempts(operation.id);

          // Mark as failed if too many attempts
          if (operation.attempts >= 5) {
            await _database.updateSyncOperationStatus(
              operationId: operation.id,
              status: 'failed',
              error: e.toString(),
            );
          } else {
            await _database.updateSyncOperationStatus(
              operationId: operation.id,
              status: 'pending',
              error: e.toString(),
            );
          }
        }
      }

      // Update state
      final remainingOps = await _database.getPendingSyncOperations();
      _updateState(_currentState.copyWith(
        status: errorCount > 0 ? SyncStatus.error : SyncStatus.success,
        lastSyncTime: DateTime.now(),
        pendingOperations: remainingOps.length,
        errorMessage: errorCount > 0
            ? '$errorCount operations failed'
            : null,
      ));

      // Clean up completed operations
      await _database.deleteCompletedSyncOperations();
    } catch (e) {
      _updateState(_currentState.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Process a single sync operation
  Future<void> _processSyncOperation(SyncQueueData operation) async {
    final payload = jsonDecode(operation.payloadJson) as Map<String, dynamic>;

    switch (operation.operationType) {
      case 'create_order':
        await _syncCreateOrder(operation.entityId, payload);
        break;

      case 'update_order':
        await _syncUpdateOrder(operation.entityId, payload);
        break;

      case 'cash_movement':
        await _syncCashMovement(payload);
        break;

      default:
        throw Exception('Unknown operation type: ${operation.operationType}');
    }
  }

  /// Sync create order operation
  Future<void> _syncCreateOrder(String localOrderId, Map<String, dynamic> payload) async {
    // Get offline order and items
    final order = await _database.offlineOrders.select()
      .where((o) => o.id.equals(localOrderId))
      .getSingleOrNull();

    if (order == null) {
      throw Exception('Order not found: $localOrderId');
    }

    final items = await _database.getOrderItems(localOrderId);

    // Build order request
    final orderData = {
      'session_id': order.sessionId,
      'customer_id': order.customerId,
      'table_id': order.tableId,
      'notes': order.notes,
      'subtotal': order.subtotal,
      'tax': order.tax,
      'total': order.total,
      'items': items.map((item) => {
        'product_id': item.productId,
        'product_name': item.productName,
        'product_sku': item.productSku,
        'quantity': item.quantity,
        'base_price': item.basePrice,
        'total_price': item.totalPrice,
        'tax_percent': item.taxPercent,
        'modifiers': jsonDecode(item.modifiersJson),
        'notes': item.notes,
      }).toList(),
      'payment_lines': jsonDecode(order.paymentLines),
    };

    // Send to backend
    final response = await _apiClient.post('/api/v1/orders', orderData);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create order: ${response.statusCode}');
    }

    // Update local order status
    await _database.updateOrderSyncStatus(
      orderId: localOrderId,
      status: 'synced',
    );
  }

  /// Sync update order operation
  Future<void> _syncUpdateOrder(String orderId, Map<String, dynamic> payload) async {
    final response = await _apiClient.put('/api/v1/orders/$orderId', payload);

    if (response.statusCode != 200) {
      throw Exception('Failed to update order: ${response.statusCode}');
    }
  }

  /// Sync cash movement operation
  Future<void> _syncCashMovement(Map<String, dynamic> payload) async {
    final response = await _apiClient.post('/api/v1/cash-movements', payload);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to sync cash movement: ${response.statusCode}');
    }
  }

  /// Queue an order for offline sync
  Future<void> queueOrderForSync({
    required String orderId,
    required Map<String, dynamic> orderData,
    int priority = 5,
  }) async {
    await _database.addToSyncQueue(
      operationType: 'create_order',
      entityType: 'order',
      entityId: orderId,
      payloadJson: jsonEncode(orderData),
      priority: priority,
    );

    // Update pending operations count
    final pending = await _database.getPendingSyncOperations();
    _updateState(_currentState.copyWith(pendingOperations: pending.length));

    // Trigger immediate sync if online
    if (_currentState.isOnline) {
      syncPendingOperations();
    }
  }

  /// Save order offline
  Future<String> saveOrderOffline({
    required String orderNumber,
    required String sessionId,
    required String cashierId,
    required String cashierName,
    required List<OrderItem> items,
    required List<Map<String, dynamic>> paymentLines,
    String? customerId,
    String? customerName,
    String? tableId,
    String? tableName,
    String? notes,
  }) async {
    final orderId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    // Calculate totals
    final subtotal = items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
    final tax = items.fold<double>(0.0, (sum, item) {
      final itemSubtotal = item.basePrice * item.quantity;
      return sum + (itemSubtotal * item.taxPercent / 100);
    });
    final total = subtotal + tax;

    // Insert order
    await _database.upsertOfflineOrder(
      OfflineOrdersCompanion.insert(
        id: orderId,
        orderNumber: orderNumber,
        status: 'pending_sync',
        createdAt: now,
        updatedAt: now,
        subtotal: subtotal,
        tax: tax,
        total: total,
        itemsCount: items.length,
        customerId: drift.Value(customerId),
        customerName: drift.Value(customerName),
        tableId: drift.Value(tableId),
        tableName: drift.Value(tableName),
        notes: drift.Value(notes),
        sessionId: sessionId,
        cashierId: cashierId,
        cashierName: cashierName,
        paymentLines: jsonEncode(paymentLines),
      ),
    );

    // Insert order items
    final itemCompanions = items.map((item) {
      return OfflineOrderItemsCompanion.insert(
        id: item.id,
        orderId: orderId,
        productId: item.productId,
        productName: item.productName,
        productSku: item.productSku,
        productImageUrl: drift.Value(item.productImageUrl),
        categoryId: drift.Value(item.categoryId),
        basePrice: item.basePrice,
        totalPrice: item.totalPrice,
        quantity: item.quantity,
        taxPercent: item.taxPercent,
        modifiersJson: drift.Value(jsonEncode(
          item.selectedModifiers.map((m) => {
            'id': m.id,
            'name': m.name,
            'price': m.price,
          }).toList(),
        )),
        notes: drift.Value(item.notes),
      );
    }).toList();

    await _database.insertOrderItems(itemCompanions);

    // Queue for sync
    await queueOrderForSync(
      orderId: orderId,
      orderData: {
        'order_number': orderNumber,
        'session_id': sessionId,
        'customer_id': customerId,
        'table_id': tableId,
        'notes': notes,
      },
      priority: 1, // High priority for orders
    );

    return orderId;
  }

  /// Get pending operations count
  Future<int> getPendingOperationsCount() async {
    final operations = await _database.getPendingSyncOperations();
    return operations.length;
  }

  /// Force sync now
  Future<void> forceSyncNow() async {
    await syncPendingOperations();
  }

  /// Clear old failed operations
  Future<void> clearOldFailedOperations({int days = 7}) async {
    await _database.clearOldFailedOperations(days: days);
  }
}

/// Sync service provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final database = ref.watch(localDatabaseProvider);
  final apiClient = ref.watch(apiClientProvider);

  final service = SyncService(
    database: database,
    apiClient: apiClient,
  );

  // Initialize on first access
  service.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() => service.dispose());

  return service;
});

/// Local database provider
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  final database = LocalDatabase();

  // Dispose when provider is disposed
  ref.onDispose(() => database.close());

  return database;
});

/// Sync state provider
final syncStateProvider = StreamProvider<SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncStateStream;
});

/// Pending operations count provider
final pendingOperationsCountProvider = FutureProvider<int>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.getPendingOperationsCount();
});
