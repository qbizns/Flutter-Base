/// Table Remote Data Source
/// Handles API calls for table and waiter operations
/// Following established patterns from POS Register app
library;

import 'package:pos_core/pos_core.dart';

import '../models/waiter_models.dart';

/// Interface for table-related API calls
abstract class TableRemoteDataSource {
  /// Get all floors with tables for current organization
  Future<List<RestaurantFloor>> getFloors();

  /// Get specific floor by ID
  Future<RestaurantFloor> getFloor(String floorId);

  /// Get all tables for a floor
  Future<List<RestaurantTable>> getTablesForFloor(String floorId);

  /// Get specific table by ID
  Future<RestaurantTable> getTable(String tableId);

  /// Open a table (mark as occupied)
  Future<RestaurantTable> openTable({
    required String tableId,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  });

  /// Close a table (mark as needs cleaning)
  Future<RestaurantTable> closeTable(String tableId);

  /// Clean a table (mark as available)
  Future<RestaurantTable> cleanTable(String tableId);

  /// Transfer table to another waiter
  Future<RestaurantTable> transferTable({
    required String tableId,
    required String newWaiterId,
    required String newWaiterName,
  });

  /// Change guest count for a table
  Future<RestaurantTable> changeGuestCount({
    required String tableId,
    required int guestCount,
  });

  /// Create a new order for a table
  Future<TableOrder> createOrder({
    required String tableId,
    required String tableName,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  });

  /// Get order by ID
  Future<TableOrder> getOrder(String orderId);

  /// Get current order for a table
  Future<TableOrder?> getOrderForTable(String tableId);

  /// Get all active orders for a waiter
  Future<List<TableOrder>> getActiveOrders(String waiterId);

  /// Get all orders for current shift
  Future<List<TableOrder>> getAllOrders();

  /// Add item to order
  Future<TableOrder> addItemToOrder({
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
  Future<TableOrder> removeItemFromOrder({
    required String orderId,
    required String itemId,
  });

  /// Update item quantity
  Future<TableOrder> updateItemQuantity({
    required String orderId,
    required String itemId,
    required int newQuantity,
  });

  /// Add note to order
  Future<TableOrder> addNoteToOrder({
    required String orderId,
    required String note,
  });

  /// Send order to kitchen
  Future<TableOrder> sendToKitchen(String orderId);

  /// Get current waiter info
  Future<Waiter> getCurrentWaiter();

  /// Get waiter by ID
  Future<Waiter> getWaiter(String waiterId);

  /// Update waiter status
  Future<Waiter> updateWaiterStatus({
    required String waiterId,
    required WaiterStatus status,
  });

  /// Request bill for table
  Future<void> requestBill(String tableId);

  /// Split bill
  Future<List<TableOrder>> splitBill({
    required String orderId,
    required int splitCount,
  });

  /// Merge tables
  Future<RestaurantTable> mergeTables({
    required List<String> tableIds,
    required String primaryTableId,
  });
}

/// Implementation of Table Remote Data Source
class TableRemoteDataSourceImpl implements TableRemoteDataSource {
  final ApiClient _apiClient;
  final String _organizationId;

  TableRemoteDataSourceImpl({
    required ApiClient apiClient,
    required String organizationId,
  })  : _apiClient = apiClient,
        _organizationId = organizationId;

  String get _basePath => '/organizations/$_organizationId/waiter';

  @override
  Future<List<RestaurantFloor>> getFloors() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/floors',
    );

    final data = response['data'] as List;
    return data
        .map((json) => RestaurantFloor.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RestaurantFloor> getFloor(String floorId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/floors/$floorId',
    );

    return RestaurantFloor.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<RestaurantTable>> getTablesForFloor(String floorId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/floors/$floorId/tables',
    );

    final data = response['data'] as List;
    return data
        .map((json) => RestaurantTable.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RestaurantTable> getTable(String tableId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/tables/$tableId',
    );

    return RestaurantTable.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<RestaurantTable> openTable({
    required String tableId,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/tables/$tableId/open',
      data: {
        'waiterId': waiterId,
        'waiterName': waiterName,
        if (guestCount != null) 'guestCount': guestCount,
      },
    );

    return RestaurantTable.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<RestaurantTable> closeTable(String tableId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/tables/$tableId/close',
      data: {},
    );

    return RestaurantTable.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<RestaurantTable> cleanTable(String tableId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/tables/$tableId/clean',
      data: {},
    );

    return RestaurantTable.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<RestaurantTable> transferTable({
    required String tableId,
    required String newWaiterId,
    required String newWaiterName,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/tables/$tableId/transfer',
      data: {
        'newWaiterId': newWaiterId,
        'newWaiterName': newWaiterName,
      },
    );

    return RestaurantTable.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<RestaurantTable> changeGuestCount({
    required String tableId,
    required int guestCount,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '$_basePath/tables/$tableId',
      data: {
        'guestCount': guestCount,
      },
    );

    return RestaurantTable.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<TableOrder> createOrder({
    required String tableId,
    required String tableName,
    required String waiterId,
    required String waiterName,
    int? guestCount,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/orders',
      data: {
        'tableId': tableId,
        'tableName': tableName,
        'waiterId': waiterId,
        'waiterName': waiterName,
        if (guestCount != null) 'guestCount': guestCount,
      },
    );

    return TableOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<TableOrder> getOrder(String orderId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/orders/$orderId',
    );

    return TableOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<TableOrder?> getOrderForTable(String tableId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_basePath/tables/$tableId/order',
      );

      return TableOrder.fromJson(response['data'] as Map<String, dynamic>);
    } on AppException catch (e) {
      // 404 means no current order
      if (e.message.contains('404') || e.message.toLowerCase().contains('not found')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<TableOrder>> getActiveOrders(String waiterId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/orders',
      queryParameters: {
        'waiterId': waiterId,
        'status': 'active',
      },
    );

    final data = response['data'] as List;
    return data
        .map((json) => TableOrder.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TableOrder>> getAllOrders() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/orders',
    );

    final data = response['data'] as List;
    return data
        .map((json) => TableOrder.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TableOrder> addItemToOrder({
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
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/orders/$orderId/items',
      data: {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        if (categoryId != null) 'categoryId': categoryId,
        if (categoryName != null) 'categoryName': categoryName,
        if (modifiers != null) 'modifiers': modifiers,
        if (notes != null) 'notes': notes,
      },
    );

    return TableOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<TableOrder> removeItemFromOrder({
    required String orderId,
    required String itemId,
  }) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '$_basePath/orders/$orderId/items/$itemId',
    );

    return TableOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<TableOrder> updateItemQuantity({
    required String orderId,
    required String itemId,
    required int newQuantity,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '$_basePath/orders/$orderId/items/$itemId',
      data: {
        'quantity': newQuantity,
      },
    );

    return TableOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<TableOrder> addNoteToOrder({
    required String orderId,
    required String note,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '$_basePath/orders/$orderId',
      data: {
        'notes': note,
      },
    );

    return TableOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<TableOrder> sendToKitchen(String orderId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/orders/$orderId/send-to-kitchen',
      data: {},
    );

    return TableOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<Waiter> getCurrentWaiter() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/me',
    );

    return Waiter.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<Waiter> getWaiter(String waiterId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/waiters/$waiterId',
    );

    return Waiter.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<Waiter> updateWaiterStatus({
    required String waiterId,
    required WaiterStatus status,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '$_basePath/waiters/$waiterId',
      data: {
        'status': status.name,
      },
    );

    return Waiter.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> requestBill(String tableId) async {
    await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/tables/$tableId/request-bill',
      data: {},
    );
  }

  @override
  Future<List<TableOrder>> splitBill({
    required String orderId,
    required int splitCount,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/orders/$orderId/split',
      data: {
        'splitCount': splitCount,
      },
    );

    final data = response['data'] as List;
    return data
        .map((json) => TableOrder.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RestaurantTable> mergeTables({
    required List<String> tableIds,
    required String primaryTableId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/tables/merge',
      data: {
        'tableIds': tableIds,
        'primaryTableId': primaryTableId,
      },
    );

    return RestaurantTable.fromJson(response['data'] as Map<String, dynamic>);
  }
}
