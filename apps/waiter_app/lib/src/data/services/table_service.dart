/// Table Service
/// Manages restaurant tables, orders, and waiter operations
/// Following Odoo POS table service patterns 100%
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/waiter_models.dart';

/// Table Service Provider
final tableServiceProvider = Provider<TableService>((ref) {
  return TableService();
});

/// Current Waiter Provider
final currentWaiterProvider = StateProvider<Waiter?>((ref) => null);

/// Floors Provider
final floorsProvider = StateProvider<List<RestaurantFloor>>((ref) {
  // Load mock floors
  return _mockFloors;
});

/// Selected Floor Provider
final selectedFloorProvider = StateProvider<RestaurantFloor?>((ref) {
  final floors = ref.watch(floorsProvider);
  return floors.isNotEmpty ? floors.first : null;
});

/// Tables Provider (from selected floor)
final tablesProvider = Provider<List<RestaurantTable>>((ref) {
  final selectedFloor = ref.watch(selectedFloorProvider);
  return selectedFloor?.tables ?? [];
});

/// Active Orders Provider
final activeOrdersProvider = StateProvider<List<TableOrder>>((ref) => []);

/// Table Service
/// Manages all table-related operations
class TableService {
  final _tablesController =
      StreamController<List<RestaurantTable>>.broadcast();
  final _ordersController = StreamController<List<TableOrder>>.broadcast();

  /// Stream of table updates
  Stream<List<RestaurantTable>> get tablesStream => _tablesController.stream;

  /// Stream of order updates
  Stream<List<TableOrder>> get ordersStream => _ordersController.stream;

  /// Open a table
  Future<void> openTable({
    required String tableId,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  }) async {
    debugPrint('[TableService] Opening table $tableId for $waiterName');

    // In production, call API
    await Future.delayed(const Duration(milliseconds: 500));

    // Update table status
    // This would update via API and refresh from server
  }

  /// Take order for a table
  Future<TableOrder> createOrder({
    required String tableId,
    required String tableName,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  }) async {
    debugPrint('[TableService] Creating order for table $tableId');

    final order = TableOrder(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      tableId: tableId,
      tableName: tableName,
      waiterId: waiterId,
      waiterName: waiterName,
      items: [],
      createdAt: DateTime.now(),
      guestCount: guestCount,
    );

    return order;
  }

  /// Add item to order
  Future<TableOrder> addItemToOrder({
    required TableOrder order,
    required TableOrderItem item,
  }) async {
    debugPrint('[TableService] Adding item ${item.productName} to order');

    final updatedItems = [...order.items, item];
    return order.copyWith(items: updatedItems);
  }

  /// Remove item from order
  Future<TableOrder> removeItemFromOrder({
    required TableOrder order,
    required String itemId,
  }) async {
    debugPrint('[TableService] Removing item $itemId from order');

    final updatedItems = order.items.where((i) => i.id != itemId).toList();
    return order.copyWith(items: updatedItems);
  }

  /// Update item quantity
  Future<TableOrder> updateItemQuantity({
    required TableOrder order,
    required String itemId,
    required int newQuantity,
  }) async {
    debugPrint('[TableService] Updating item $itemId quantity to $newQuantity');

    if (newQuantity <= 0) {
      return removeItemFromOrder(order: order, itemId: itemId);
    }

    final updatedItems = order.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    return order.copyWith(items: updatedItems);
  }

  /// Send order to kitchen
  Future<TableOrder> sendToKitchen(TableOrder order) async {
    debugPrint('[TableService] Sending order ${order.id} to kitchen');

    // Mark items as sent
    final updatedItems = order.items
        .map((item) => item.copyWith(
              isSentToKitchen: true,
              sentToKitchenAt: DateTime.now(),
            ))
        .toList();

    return order.copyWith(
      items: updatedItems,
      status: TableOrderStatus.sent,
      sentToKitchenAt: DateTime.now(),
    );
  }

  /// Request bill for table
  Future<void> requestBill(String tableId) async {
    debugPrint('[TableService] Requesting bill for table $tableId');

    // In production, generate bill and send to payment system
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Close table
  Future<void> closeTable(String tableId) async {
    debugPrint('[TableService] Closing table $tableId');

    // In production, mark table as needs cleaning
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Transfer table to another waiter
  Future<void> transferTable({
    required String tableId,
    required String newWaiterId,
    required String newWaiterName,
  }) async {
    debugPrint('[TableService] Transferring table $tableId to $newWaiterName');

    // In production, update via API
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Merge tables
  Future<void> mergeTables({
    required List<String> tableIds,
    required String primaryTableId,
  }) async {
    debugPrint('[TableService] Merging tables into $primaryTableId');

    // In production, merge orders and update tables
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Split bill
  Future<List<TableOrder>> splitBill({
    required TableOrder order,
    required int splitCount,
  }) async {
    debugPrint('[TableService] Splitting bill for order ${order.id} into $splitCount');

    // In production, create split orders
    await Future.delayed(const Duration(milliseconds: 500));

    // Return split orders
    return [];
  }

  /// Change guest count
  Future<void> changeGuestCount({
    required String tableId,
    required int newCount,
  }) async {
    debugPrint('[TableService] Changing guest count for table $tableId to $newCount');

    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Add note to order
  Future<TableOrder> addNoteToOrder({
    required TableOrder order,
    required String note,
  }) async {
    debugPrint('[TableService] Adding note to order ${order.id}');

    return order.copyWith(
      notes: note,
    );
  }

  /// Get order for table
  Future<TableOrder?> getOrderForTable(String tableId) async {
    debugPrint('[TableService] Getting order for table $tableId');

    // In production, fetch from API
    await Future.delayed(const Duration(milliseconds: 300));

    return null;
  }

  /// Get all active orders for waiter
  Future<List<TableOrder>> getActiveOrders(String waiterId) async {
    debugPrint('[TableService] Getting active orders for waiter $waiterId');

    // In production, fetch from API
    await Future.delayed(const Duration(milliseconds: 300));

    return _mockOrders;
  }

  /// Clean table
  Future<void> cleanTable(String tableId) async {
    debugPrint('[TableService] Cleaning table $tableId');

    // Mark table as available
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Dispose resources
  void dispose() {
    _tablesController.close();
    _ordersController.close();
  }
}

/// Mock Data
final _mockFloors = [
  RestaurantFloor(
    id: 'floor1',
    name: 'Main Floor',
    tables: [
      const RestaurantTable(
        id: 'table1',
        name: 'Table 1',
        floorId: 'floor1',
        seats: 4,
        shape: TableShape.square,
        position: TablePosition(x: 50, y: 50),
        status: TableStatus.available,
      ),
      const RestaurantTable(
        id: 'table2',
        name: 'Table 2',
        floorId: 'floor1',
        seats: 2,
        shape: TableShape.round,
        position: TablePosition(x: 200, y: 50),
        status: TableStatus.occupied,
        assignedWaiterId: 'waiter1',
        assignedWaiterName: 'John',
        guestCount: 2,
      ),
      const RestaurantTable(
        id: 'table3',
        name: 'Table 3',
        floorId: 'floor1',
        seats: 6,
        shape: TableShape.rectangle,
        position: TablePosition(x: 350, y: 50, width: 150),
        status: TableStatus.reserved,
      ),
      const RestaurantTable(
        id: 'table4',
        name: 'Table 4',
        floorId: 'floor1',
        seats: 4,
        shape: TableShape.square,
        position: TablePosition(x: 50, y: 200),
        status: TableStatus.available,
      ),
      const RestaurantTable(
        id: 'table5',
        name: 'Table 5',
        floorId: 'floor1',
        seats: 2,
        shape: TableShape.round,
        position: TablePosition(x: 200, y: 200),
        status: TableStatus.occupied,
        assignedWaiterId: 'waiter1',
        assignedWaiterName: 'John',
        guestCount: 1,
      ),
      const RestaurantTable(
        id: 'table6',
        name: 'Table 6',
        floorId: 'floor1',
        seats: 8,
        shape: TableShape.rectangle,
        position: TablePosition(x: 350, y: 200, width: 180, height: 120),
        status: TableStatus.available,
      ),
    ],
  ),
  RestaurantFloor(
    id: 'floor2',
    name: 'Patio',
    tables: [
      const RestaurantTable(
        id: 'patio1',
        name: 'Patio 1',
        floorId: 'floor2',
        seats: 4,
        shape: TableShape.round,
        position: TablePosition(x: 100, y: 100),
        status: TableStatus.available,
      ),
      const RestaurantTable(
        id: 'patio2',
        name: 'Patio 2',
        floorId: 'floor2',
        seats: 4,
        shape: TableShape.round,
        position: TablePosition(x: 300, y: 100),
        status: TableStatus.available,
      ),
      const RestaurantTable(
        id: 'patio3',
        name: 'Patio 3',
        floorId: 'floor2',
        seats: 6,
        shape: TableShape.rectangle,
        position: TablePosition(x: 100, y: 250, width: 150),
        status: TableStatus.occupied,
        assignedWaiterId: 'waiter2',
        assignedWaiterName: 'Sarah',
        guestCount: 4,
      ),
    ],
  ),
];

final _mockOrders = [
  TableOrder(
    id: 'order1',
    tableId: 'table2',
    tableName: 'Table 2',
    waiterId: 'waiter1',
    waiterName: 'John',
    items: const [
      TableOrderItem(
        id: 'item1',
        productId: 'burger1',
        productName: 'Classic Burger',
        quantity: 2,
        unitPrice: 12.99,
        categoryName: 'Burgers',
        modifiers: ['No onions'],
        isSentToKitchen: true,
      ),
      TableOrderItem(
        id: 'item2',
        productId: 'fries1',
        productName: 'French Fries',
        quantity: 2,
        unitPrice: 3.99,
        categoryName: 'Sides',
        isSentToKitchen: true,
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    status: TableOrderStatus.preparing,
    guestCount: 2,
    sentToKitchenAt: DateTime.now().subtract(const Duration(minutes: 14)),
  ),
  TableOrder(
    id: 'order2',
    tableId: 'patio3',
    tableName: 'Patio 3',
    waiterId: 'waiter2',
    waiterName: 'Sarah',
    items: const [
      TableOrderItem(
        id: 'item3',
        productId: 'steak1',
        productName: 'Ribeye Steak',
        quantity: 2,
        unitPrice: 24.99,
        categoryName: 'Steaks',
        modifiers: ['Medium Rare'],
        isSentToKitchen: true,
      ),
      TableOrderItem(
        id: 'item4',
        productId: 'salad1',
        productName: 'Caesar Salad',
        quantity: 2,
        unitPrice: 8.99,
        categoryName: 'Salads',
        isSentToKitchen: true,
      ),
      TableOrderItem(
        id: 'item5',
        productId: 'wine1',
        productName: 'Red Wine',
        quantity: 1,
        unitPrice: 12.99,
        categoryName: 'Beverages',
        isSentToKitchen: true,
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    status: TableOrderStatus.ready,
    guestCount: 4,
    sentToKitchenAt: DateTime.now().subtract(const Duration(minutes: 24)),
  ),
];
