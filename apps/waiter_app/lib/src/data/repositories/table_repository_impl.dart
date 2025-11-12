/// Table Repository Implementation
/// Implements table operations with error handling
library;

import 'package:flutter/foundation.dart';
import 'package:pos_core/pos_core.dart';

import '../datasources/table_remote_datasource.dart';
import '../models/waiter_models.dart';
import 'table_repository.dart';

/// Implementation of TableRepository
/// Wraps remote data source and converts exceptions to Result types
class TableRepositoryImpl implements TableRepository {
  final TableRemoteDataSource _remoteDataSource;

  TableRepositoryImpl({
    required TableRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<List<RestaurantFloor>>> getFloors() async {
    try {
      final floors = await _remoteDataSource.getFloors();
      return Result.success(floors);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Get floors failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Get floors unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to load floors',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<RestaurantFloor>> getFloor(String floorId) async {
    try {
      final floor = await _remoteDataSource.getFloor(floorId);
      return Result.success(floor);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Get floor $floorId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Get floor unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to load floor',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<List<RestaurantTable>>> getTablesForFloor(String floorId) async {
    try {
      final tables = await _remoteDataSource.getTablesForFloor(floorId);
      return Result.success(tables);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Get tables for floor $floorId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Get tables unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to load tables',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<RestaurantTable>> getTable(String tableId) async {
    try {
      final table = await _remoteDataSource.getTable(tableId);
      return Result.success(table);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Get table $tableId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Get table unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to load table',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<RestaurantTable>> openTable({
    required String tableId,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  }) async {
    try {
      final table = await _remoteDataSource.openTable(
        tableId: tableId,
        waiterId: waiterId,
        waiterName: waiterName,
        guestCount: guestCount,
      );
      debugPrint('[TableRepository] Table $tableId opened successfully');
      return Result.success(table);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Open table $tableId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Open table unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to open table',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<RestaurantTable>> closeTable(String tableId) async {
    try {
      final table = await _remoteDataSource.closeTable(tableId);
      debugPrint('[TableRepository] Table $tableId closed successfully');
      return Result.success(table);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Close table $tableId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Close table unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to close table',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<RestaurantTable>> cleanTable(String tableId) async {
    try {
      final table = await _remoteDataSource.cleanTable(tableId);
      debugPrint('[TableRepository] Table $tableId cleaned successfully');
      return Result.success(table);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Clean table $tableId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Clean table unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to clean table',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<RestaurantTable>> transferTable({
    required String tableId,
    required String newWaiterId,
    required String newWaiterName,
  }) async {
    try {
      final table = await _remoteDataSource.transferTable(
        tableId: tableId,
        newWaiterId: newWaiterId,
        newWaiterName: newWaiterName,
      );
      debugPrint('[TableRepository] Table $tableId transferred to $newWaiterName');
      return Result.success(table);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Transfer table $tableId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Transfer table unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to transfer table',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<RestaurantTable>> changeGuestCount({
    required String tableId,
    required int guestCount,
  }) async {
    try {
      final table = await _remoteDataSource.changeGuestCount(
        tableId: tableId,
        guestCount: guestCount,
      );
      debugPrint('[TableRepository] Guest count changed for table $tableId');
      return Result.success(table);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Change guest count for $tableId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Change guest count unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to change guest count',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<TableOrder>> createOrder({
    required String tableId,
    required String tableName,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  }) async {
    try {
      final order = await _remoteDataSource.createOrder(
        tableId: tableId,
        tableName: tableName,
        waiterId: waiterId,
        waiterName: waiterName,
        guestCount: guestCount,
      );
      debugPrint('[TableRepository] Order created for table $tableId: ${order.id}');
      return Result.success(order);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Create order for $tableId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Create order unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to create order',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<TableOrder>> getOrder(String orderId) async {
    try {
      final order = await _remoteDataSource.getOrder(orderId);
      return Result.success(order);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Get order $orderId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Get order unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to load order',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<TableOrder?>> getOrderForTable(String tableId) async {
    try {
      final order = await _remoteDataSource.getOrderForTable(tableId);
      return Result.success(order);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Get order for table $tableId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Get order for table unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to load order',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<List<TableOrder>>> getActiveOrders(String waiterId) async {
    try {
      final orders = await _remoteDataSource.getActiveOrders(waiterId);
      return Result.success(orders);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Get active orders for $waiterId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Get active orders unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to load active orders',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<List<TableOrder>>> getAllOrders() async {
    try {
      final orders = await _remoteDataSource.getAllOrders();
      return Result.success(orders);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Get all orders failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Get all orders unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to load orders',
        type: FailureType.unknown,
      ));
    }
  }

  @override
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
    try {
      final order = await _remoteDataSource.addItemToOrder(
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
      debugPrint('[TableRepository] Item added to order $orderId: $productName');
      return Result.success(order);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Add item to order $orderId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Add item unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to add item to order',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<TableOrder>> removeItemFromOrder({
    required String orderId,
    required String itemId,
  }) async {
    try {
      final order = await _remoteDataSource.removeItemFromOrder(
        orderId: orderId,
        itemId: itemId,
      );
      debugPrint('[TableRepository] Item $itemId removed from order $orderId');
      return Result.success(order);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Remove item from order $orderId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Remove item unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to remove item from order',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<TableOrder>> updateItemQuantity({
    required String orderId,
    required String itemId,
    required int newQuantity,
  }) async {
    try {
      final order = await _remoteDataSource.updateItemQuantity(
        orderId: orderId,
        itemId: itemId,
        newQuantity: newQuantity,
      );
      debugPrint('[TableRepository] Item $itemId quantity updated in order $orderId');
      return Result.success(order);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Update item quantity in order $orderId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Update item quantity unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to update item quantity',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<TableOrder>> addNoteToOrder({
    required String orderId,
    required String note,
  }) async {
    try {
      final order = await _remoteDataSource.addNoteToOrder(
        orderId: orderId,
        note: note,
      );
      debugPrint('[TableRepository] Note added to order $orderId');
      return Result.success(order);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Add note to order $orderId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Add note unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to add note to order',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<TableOrder>> sendToKitchen(String orderId) async {
    try {
      final order = await _remoteDataSource.sendToKitchen(orderId);
      debugPrint('[TableRepository] Order $orderId sent to kitchen');
      return Result.success(order);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Send order $orderId to kitchen failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Send to kitchen unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to send order to kitchen',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<Waiter>> getCurrentWaiter() async {
    try {
      final waiter = await _remoteDataSource.getCurrentWaiter();
      return Result.success(waiter);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Get current waiter failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Get current waiter unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to load waiter info',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<Waiter>> getWaiter(String waiterId) async {
    try {
      final waiter = await _remoteDataSource.getWaiter(waiterId);
      return Result.success(waiter);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Get waiter $waiterId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Get waiter unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to load waiter info',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<Waiter>> updateWaiterStatus({
    required String waiterId,
    required WaiterStatus status,
  }) async {
    try {
      final waiter = await _remoteDataSource.updateWaiterStatus(
        waiterId: waiterId,
        status: status,
      );
      debugPrint('[TableRepository] Waiter $waiterId status updated to ${status.name}');
      return Result.success(waiter);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Update waiter status failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Update waiter status unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to update waiter status',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<void>> requestBill(String tableId) async {
    try {
      await _remoteDataSource.requestBill(tableId);
      debugPrint('[TableRepository] Bill requested for table $tableId');
      return const Result.success(null);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Request bill for $tableId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Request bill unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to request bill',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<List<TableOrder>>> splitBill({
    required String orderId,
    required int splitCount,
  }) async {
    try {
      final orders = await _remoteDataSource.splitBill(
        orderId: orderId,
        splitCount: splitCount,
      );
      debugPrint('[TableRepository] Bill split for order $orderId into $splitCount');
      return Result.success(orders);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Split bill for $orderId failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Split bill unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to split bill',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Result<RestaurantTable>> mergeTables({
    required List<String> tableIds,
    required String primaryTableId,
  }) async {
    try {
      final table = await _remoteDataSource.mergeTables(
        tableIds: tableIds,
        primaryTableId: primaryTableId,
      );
      debugPrint('[TableRepository] Tables merged into $primaryTableId');
      return Result.success(table);
    } on AppException catch (e) {
      debugPrint('[TableRepository] Merge tables failed: ${e.message}');
      return Result.failure(Failure(
        message: e.message,
        type: _mapExceptionToFailureType(e),
      ));
    } catch (e) {
      debugPrint('[TableRepository] Merge tables unexpected error: $e');
      return Result.failure(Failure(
        message: 'Failed to merge tables',
        type: FailureType.unknown,
      ));
    }
  }

  /// Map AppException to FailureType
  FailureType _mapExceptionToFailureType(AppException exception) {
    if (exception is NetworkException) {
      return FailureType.network;
    } else if (exception is ServerException) {
      return FailureType.server;
    } else if (exception is ValidationException) {
      return FailureType.validation;
    } else if (exception is AuthException) {
      return FailureType.auth;
    }
    return FailureType.unknown;
  }
}
