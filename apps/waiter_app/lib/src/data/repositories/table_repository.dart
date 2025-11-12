/// Table Repository Interface
/// Domain layer contract for table operations
library;

import 'package:pos_core/pos_core.dart';

import '../models/waiter_models.dart';

/// Repository for table-related operations
/// Returns Result types for functional error handling
abstract class TableRepository {
  /// Get all floors with tables
  Future<Result<List<RestaurantFloor>>> getFloors();

  /// Get specific floor by ID
  Future<Result<RestaurantFloor>> getFloor(String floorId);

  /// Get all tables for a floor
  Future<Result<List<RestaurantTable>>> getTablesForFloor(String floorId);

  /// Get specific table by ID
  Future<Result<RestaurantTable>> getTable(String tableId);

  /// Open a table (mark as occupied)
  Future<Result<RestaurantTable>> openTable({
    required String tableId,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  });

  /// Close a table (mark as needs cleaning)
  Future<Result<RestaurantTable>> closeTable(String tableId);

  /// Clean a table (mark as available)
  Future<Result<RestaurantTable>> cleanTable(String tableId);

  /// Transfer table to another waiter
  Future<Result<RestaurantTable>> transferTable({
    required String tableId,
    required String newWaiterId,
    required String newWaiterName,
  });

  /// Change guest count for a table
  Future<Result<RestaurantTable>> changeGuestCount({
    required String tableId,
    required int guestCount,
  });

  /// Create a new order for a table
  Future<Result<TableOrder>> createOrder({
    required String tableId,
    required String tableName,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  });

  /// Get order by ID
  Future<Result<TableOrder>> getOrder(String orderId);

  /// Get current order for a table (null if no order)
  Future<Result<TableOrder?>> getOrderForTable(String tableId);

  /// Get all active orders for a waiter
  Future<Result<List<TableOrder>>> getActiveOrders(String waiterId);

  /// Get all orders for current shift
  Future<Result<List<TableOrder>>> getAllOrders();

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
  });

  /// Remove item from order
  Future<Result<TableOrder>> removeItemFromOrder({
    required String orderId,
    required String itemId,
  });

  /// Update item quantity
  Future<Result<TableOrder>> updateItemQuantity({
    required String orderId,
    required String itemId,
    required int newQuantity,
  });

  /// Add note to order
  Future<Result<TableOrder>> addNoteToOrder({
    required String orderId,
    required String note,
  });

  /// Send order to kitchen
  Future<Result<TableOrder>> sendToKitchen(String orderId);

  /// Get current waiter info
  Future<Result<Waiter>> getCurrentWaiter();

  /// Get waiter by ID
  Future<Result<Waiter>> getWaiter(String waiterId);

  /// Update waiter status
  Future<Result<Waiter>> updateWaiterStatus({
    required String waiterId,
    required WaiterStatus status,
  });

  /// Request bill for table
  Future<Result<void>> requestBill(String tableId);

  /// Split bill
  Future<Result<List<TableOrder>>> splitBill({
    required String orderId,
    required int splitCount,
  });

  /// Merge tables
  Future<Result<RestaurantTable>> mergeTables({
    required List<String> tableIds,
    required String primaryTableId,
  });
}
