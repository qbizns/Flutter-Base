/// Table Service
/// Manages restaurant tables, orders, and waiter operations with real backend
/// Following Odoo POS table service patterns 100%
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_core/pos_core.dart';

import '../models/waiter_models.dart';
import '../repositories/table_repository.dart';
import 'waiter_websocket_service.dart';

/// Table Service
/// High-level service that coordinates repository and real-time updates
class TableService {
  final TableRepository _repository;
  final WaiterWebSocketService? _websocketService;

  final _tablesController =
      StreamController<List<RestaurantTable>>.broadcast();
  final _ordersController = StreamController<List<TableOrder>>.broadcast();

  TableService({
    required TableRepository repository,
    WaiterWebSocketService? websocketService,
  })  : _repository = repository,
        _websocketService = websocketService {
    // Listen to WebSocket events if available
    _websocketService?.eventStream.listen(_handleWebSocketEvent);
  }

  /// Stream of table updates
  Stream<List<RestaurantTable>> get tablesStream => _tablesController.stream;

  /// Stream of order updates
  Stream<List<TableOrder>> get ordersStream => _ordersController.stream;

  /// Get WebSocket connection status
  Stream<WaiterConnectionStatus>? get connectionStatus =>
      _websocketService?.statusStream;

  /// Check if connected to real-time updates
  bool get isConnectedToRealtime => _websocketService?.isConnected ?? false;

  /// Handle WebSocket events for real-time updates
  void _handleWebSocketEvent(WaiterEvent event) {
    debugPrint('[TableService] WebSocket event: ${event.type.name}');

    switch (event.type) {
      case WaiterEventType.tableUpdated:
      case WaiterEventType.tableStatusChanged:
        // Refresh tables when updated
        // In production, you'd update specific table in local state
        debugPrint('[TableService] Table updated via WebSocket');
        break;

      case WaiterEventType.orderCreated:
      case WaiterEventType.orderUpdated:
      case WaiterEventType.orderStatusChanged:
        // Refresh orders when updated
        debugPrint('[TableService] Order updated via WebSocket');
        break;

      case WaiterEventType.orderSentToKitchen:
        debugPrint('[TableService] Order sent to kitchen via WebSocket');
        break;

      default:
        break;
    }
  }

  /// Get all floors with tables
  Future<Result<List<RestaurantFloor>>> getFloors() async {
    debugPrint('[TableService] Getting floors');
    return await _repository.getFloors();
  }

  /// Get specific floor by ID
  Future<Result<RestaurantFloor>> getFloor(String floorId) async {
    debugPrint('[TableService] Getting floor $floorId');
    return await _repository.getFloor(floorId);
  }

  /// Get all tables for a floor
  Future<Result<List<RestaurantTable>>> getTablesForFloor(
      String floorId) async {
    debugPrint('[TableService] Getting tables for floor $floorId');
    return await _repository.getTablesForFloor(floorId);
  }

  /// Get specific table by ID
  Future<Result<RestaurantTable>> getTable(String tableId) async {
    debugPrint('[TableService] Getting table $tableId');
    return await _repository.getTable(tableId);
  }

  /// Open a table
  Future<Result<RestaurantTable>> openTable({
    required String tableId,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  }) async {
    debugPrint('[TableService] Opening table $tableId for $waiterName');

    final result = await _repository.openTable(
      tableId: tableId,
      waiterId: waiterId,
      waiterName: waiterName,
      guestCount: guestCount,
    );

    // Subscribe to real-time updates for this table
    if (result.isSuccess) {
      _websocketService?.subscribeToTable(tableId);
    }

    return result;
  }

  /// Close a table
  Future<Result<RestaurantTable>> closeTable(String tableId) async {
    debugPrint('[TableService] Closing table $tableId');

    final result = await _repository.closeTable(tableId);

    // Unsubscribe from real-time updates
    if (result.isSuccess) {
      _websocketService?.unsubscribeFromTable(tableId);
    }

    return result;
  }

  /// Clean a table
  Future<Result<RestaurantTable>> cleanTable(String tableId) async {
    debugPrint('[TableService] Cleaning table $tableId');
    return await _repository.cleanTable(tableId);
  }

  /// Transfer table to another waiter
  Future<Result<RestaurantTable>> transferTable({
    required String tableId,
    required String newWaiterId,
    required String newWaiterName,
  }) async {
    debugPrint('[TableService] Transferring table $tableId to $newWaiterName');
    return await _repository.transferTable(
      tableId: tableId,
      newWaiterId: newWaiterId,
      newWaiterName: newWaiterName,
    );
  }

  /// Change guest count for a table
  Future<Result<RestaurantTable>> changeGuestCount({
    required String tableId,
    required int guestCount,
  }) async {
    debugPrint('[TableService] Changing guest count for $tableId to $guestCount');
    return await _repository.changeGuestCount(
      tableId: tableId,
      guestCount: guestCount,
    );
  }

  /// Create a new order for a table
  Future<Result<TableOrder>> createOrder({
    required String tableId,
    required String tableName,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  }) async {
    debugPrint('[TableService] Creating order for table $tableId');

    final result = await _repository.createOrder(
      tableId: tableId,
      tableName: tableName,
      waiterId: waiterId,
      waiterName: waiterName,
      guestCount: guestCount,
    );

    // Subscribe to real-time order updates
    if (result.isSuccess) {
      final order = result.data!;
      _websocketService?.subscribeToOrder(order.id);
    }

    return result;
  }

  /// Get order by ID
  Future<Result<TableOrder>> getOrder(String orderId) async {
    debugPrint('[TableService] Getting order $orderId');
    return await _repository.getOrder(orderId);
  }

  /// Get current order for a table
  Future<Result<TableOrder?>> getOrderForTable(String tableId) async {
    debugPrint('[TableService] Getting order for table $tableId');
    return await _repository.getOrderForTable(tableId);
  }

  /// Get all active orders for a waiter
  Future<Result<List<TableOrder>>> getActiveOrders(String waiterId) async {
    debugPrint('[TableService] Getting active orders for waiter $waiterId');
    return await _repository.getActiveOrders(waiterId);
  }

  /// Get all orders for current shift
  Future<Result<List<TableOrder>>> getAllOrders() async {
    debugPrint('[TableService] Getting all orders');
    return await _repository.getAllOrders();
  }

  /// Add item to order
  Future<Result<TableOrder>> addItemToOrder({
    required String orderId,
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    String? categoryId,
    String? categoryName,
    List<String>? modifiers,
    List<String>? notes,
  }) async {
    debugPrint('[TableService] Adding item $productName to order $orderId');

    return await _repository.addItemToOrder(
      orderId: orderId,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      categoryId: categoryId,
      categoryName: categoryName,
      modifiers: modifiers,
      notes: notes,
    );
  }

  /// Remove item from order
  Future<Result<TableOrder>> removeItemFromOrder({
    required String orderId,
    required String itemId,
  }) async {
    debugPrint('[TableService] Removing item $itemId from order $orderId');

    return await _repository.removeItemFromOrder(
      orderId: orderId,
      itemId: itemId,
    );
  }

  /// Update item quantity
  Future<Result<TableOrder>> updateItemQuantity({
    required String orderId,
    required String itemId,
    required int newQuantity,
  }) async {
    debugPrint('[TableService] Updating item $itemId quantity to $newQuantity');

    return await _repository.updateItemQuantity(
      orderId: orderId,
      itemId: itemId,
      newQuantity: newQuantity,
    );
  }

  /// Add note to order
  Future<Result<TableOrder>> addNoteToOrder({
    required String orderId,
    required String note,
  }) async {
    debugPrint('[TableService] Adding note to order $orderId');

    return await _repository.addNoteToOrder(
      orderId: orderId,
      note: note,
    );
  }

  /// Send order to kitchen
  Future<Result<TableOrder>> sendToKitchen(String orderId) async {
    debugPrint('[TableService] Sending order $orderId to kitchen');

    return await _repository.sendToKitchen(orderId);
  }

  /// Get current waiter info
  Future<Result<Waiter>> getCurrentWaiter() async {
    debugPrint('[TableService] Getting current waiter');
    return await _repository.getCurrentWaiter();
  }

  /// Get waiter by ID
  Future<Result<Waiter>> getWaiter(String waiterId) async {
    debugPrint('[TableService] Getting waiter $waiterId');
    return await _repository.getWaiter(waiterId);
  }

  /// Update waiter status
  Future<Result<Waiter>> updateWaiterStatus({
    required String waiterId,
    required WaiterStatus status,
  }) async {
    debugPrint('[TableService] Updating waiter $waiterId status to ${status.name}');
    return await _repository.updateWaiterStatus(
      waiterId: waiterId,
      status: status,
    );
  }

  /// Request bill for table
  Future<Result<void>> requestBill(String tableId) async {
    debugPrint('[TableService] Requesting bill for table $tableId');
    return await _repository.requestBill(tableId);
  }

  /// Split bill
  Future<Result<List<TableOrder>>> splitBill({
    required String orderId,
    required int splitCount,
  }) async {
    debugPrint('[TableService] Splitting bill for order $orderId into $splitCount');
    return await _repository.splitBill(
      orderId: orderId,
      splitCount: splitCount,
    );
  }

  /// Merge tables
  Future<Result<RestaurantTable>> mergeTables({
    required List<String> tableIds,
    required String primaryTableId,
  }) async {
    debugPrint('[TableService] Merging tables into $primaryTableId');
    return await _repository.mergeTables(
      tableIds: tableIds,
      primaryTableId: primaryTableId,
    );
  }

  /// Connect to real-time updates
  Future<void> connectToRealtime() async {
    await _websocketService?.connect();
  }

  /// Disconnect from real-time updates
  Future<void> disconnectFromRealtime() async {
    await _websocketService?.disconnect();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _tablesController.close();
    await _ordersController.close();
    await _websocketService?.dispose();
  }
}
