import 'package:dio/dio.dart';
import 'package:pos_core/pos_core.dart';

import '../../models/restaurant_table.dart';

/// Remote data source for restaurant management.
///
/// This handles API calls for tables and kitchen stations.
abstract class RestaurantRemoteSource {
  // Tables CRUD
  Future<List<RestaurantTable>> getTables();
  Future<RestaurantTable> getTableById(String id);
  Future<RestaurantTable> createTable(RestaurantTable table);
  Future<RestaurantTable> updateTable(String id, RestaurantTable table);
  Future<void> deleteTable(String id);

  // Kitchen Stations CRUD
  Future<List<KitchenStation>> getKitchenStations();
  Future<KitchenStation> getKitchenStationById(String id);
  Future<KitchenStation> createKitchenStation(KitchenStation station);
  Future<KitchenStation> updateKitchenStation(String id, KitchenStation station);
  Future<void> deleteKitchenStation(String id);
}

/// HTTP implementation of RestaurantRemoteSource.
/// Makes actual API calls to the backend.
class RestaurantRemoteSourceHttp implements RestaurantRemoteSource {
  RestaurantRemoteSourceHttp({
    required ApiClient apiClient,
    required String organizationId,
  })  : _apiClient = apiClient,
        _orgId = organizationId;

  final ApiClient _apiClient;
  final String _orgId;

  String get _tablesPath => '/organizations/$_orgId/tables';
  String get _kitchenStationsPath => '/organizations/$_orgId/kitchen-stations';

  // ========== Tables CRUD ==========

  @override
  Future<List<RestaurantTable>> getTables() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _tablesPath,
      );

      final data = response.data!['data'] as List;
      return data
          .map((json) => _restaurantTableFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RestaurantTable> getTableById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_tablesPath/$id',
      );

      return _restaurantTableFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RestaurantTable> createTable(RestaurantTable table) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _tablesPath,
        data: _restaurantTableToJson(table),
      );

      return _restaurantTableFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RestaurantTable> updateTable(String id, RestaurantTable table) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '$_tablesPath/$id',
        data: _restaurantTableToJson(table),
      );

      return _restaurantTableFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTable(String id) async {
    try {
      await _apiClient.delete<Map<String, dynamic>>(
        '$_tablesPath/$id',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ========== Kitchen Stations CRUD ==========

  @override
  Future<List<KitchenStation>> getKitchenStations() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _kitchenStationsPath,
      );

      final data = response.data!['data'] as List;
      return data
          .map((json) => _kitchenStationFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<KitchenStation> getKitchenStationById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_kitchenStationsPath/$id',
      );

      return _kitchenStationFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<KitchenStation> createKitchenStation(KitchenStation station) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _kitchenStationsPath,
        data: _kitchenStationToJson(station),
      );

      return _kitchenStationFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<KitchenStation> updateKitchenStation(
    String id,
    KitchenStation station,
  ) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '$_kitchenStationsPath/$id',
        data: _kitchenStationToJson(station),
      );

      return _kitchenStationFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteKitchenStation(String id) async {
    try {
      await _apiClient.delete<Map<String, dynamic>>(
        '$_kitchenStationsPath/$id',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ========== JSON Serialization Helpers ==========

  RestaurantTable _restaurantTableFromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as String,
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      status: TableStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TableStatus.available,
      ),
      shape: TableShape.values.firstWhere(
        (e) => e.name == json['shape'],
        orElse: () => TableShape.square,
      ),
      positionX: (json['position_x'] as num?)?.toDouble() ?? 0,
      positionY: (json['position_y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 100,
      height: (json['height'] as num?)?.toDouble() ?? 100,
      section: json['section'] as String?,
      currentOrderId: json['current_order_id'] as String?,
      reservationTime: json['reservation_time'] != null
          ? DateTime.parse(json['reservation_time'] as String)
          : null,
      reservationName: json['reservation_name'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> _restaurantTableToJson(RestaurantTable table) {
    return {
      'id': table.id,
      'name': table.name,
      'capacity': table.capacity,
      'status': table.status.name,
      'shape': table.shape.name,
      'position_x': table.positionX,
      'position_y': table.positionY,
      'width': table.width,
      'height': table.height,
      'section': table.section,
      'current_order_id': table.currentOrderId,
      'reservation_time': table.reservationTime?.toIso8601String(),
      'reservation_name': table.reservationName,
      'notes': table.notes,
    };
  }

  KitchenStation _kitchenStationFromJson(Map<String, dynamic> json) {
    return KitchenStation(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      color: Color(json['color'] as int),
      categories: List<String>.from(json['categories'] as List),
      isActive: json['is_active'] as bool? ?? true,
      orderPosition: json['order_position'] as int? ?? 0,
    );
  }

  Map<String, dynamic> _kitchenStationToJson(KitchenStation station) {
    return {
      'id': station.id,
      'name': station.name,
      'description': station.description,
      'color': station.color.value,
      'categories': station.categories,
      'is_active': station.isActive,
      'order_position': station.orderPosition,
    };
  }
}

/// Mock implementation of RestaurantRemoteSource for development.
///
/// This provides mock data for testing without a backend.
class RestaurantRemoteSourceMock implements RestaurantRemoteSource {
  // Mock data storage
  final List<RestaurantTable> _tables = [
    // Main Hall
    const RestaurantTable(
      id: '1',
      name: 'Table 1',
      capacity: 4,
      status: TableStatus.available,
      shape: TableShape.square,
      positionX: 10,
      positionY: 10,
      width: 100,
      height: 100,
      section: 'Main Hall',
    ),
    const RestaurantTable(
      id: '2',
      name: 'Table 2',
      capacity: 4,
      status: TableStatus.occupied,
      shape: TableShape.square,
      positionX: 30,
      positionY: 10,
      width: 100,
      height: 100,
      section: 'Main Hall',
      currentOrderId: 'order-123',
    ),
    const RestaurantTable(
      id: '3',
      name: 'Table 3',
      capacity: 6,
      status: TableStatus.reserved,
      shape: TableShape.rectangle,
      positionX: 50,
      positionY: 10,
      width: 150,
      height: 100,
      section: 'Main Hall',
      reservationName: 'John Doe',
    ),
    const RestaurantTable(
      id: '4',
      name: 'Table 4',
      capacity: 2,
      status: TableStatus.available,
      shape: TableShape.circle,
      positionX: 10,
      positionY: 35,
      width: 80,
      height: 80,
      section: 'Main Hall',
    ),
    const RestaurantTable(
      id: '5',
      name: 'Table 5',
      capacity: 4,
      status: TableStatus.cleaning,
      shape: TableShape.square,
      positionX: 30,
      positionY: 35,
      width: 100,
      height: 100,
      section: 'Main Hall',
    ),
    // Patio
    const RestaurantTable(
      id: '6',
      name: 'Table 6',
      capacity: 4,
      status: TableStatus.available,
      shape: TableShape.circle,
      positionX: 10,
      positionY: 60,
      width: 100,
      height: 100,
      section: 'Patio',
    ),
    const RestaurantTable(
      id: '7',
      name: 'Table 7',
      capacity: 6,
      status: TableStatus.occupied,
      shape: TableShape.rectangle,
      positionX: 30,
      positionY: 60,
      width: 150,
      height: 100,
      section: 'Patio',
      currentOrderId: 'order-456',
    ),
    // VIP Section
    const RestaurantTable(
      id: '8',
      name: 'VIP 1',
      capacity: 8,
      status: TableStatus.reserved,
      shape: TableShape.roundedRectangle,
      positionX: 70,
      positionY: 35,
      width: 180,
      height: 120,
      section: 'VIP',
      reservationName: 'Sarah Johnson',
    ),
    const RestaurantTable(
      id: '9',
      name: 'VIP 2',
      capacity: 6,
      status: TableStatus.available,
      shape: TableShape.roundedRectangle,
      positionX: 70,
      positionY: 60,
      width: 150,
      height: 100,
      section: 'VIP',
    ),
    // Bar Area
    const RestaurantTable(
      id: '10',
      name: 'Bar 1',
      capacity: 2,
      status: TableStatus.occupied,
      shape: TableShape.circle,
      positionX: 70,
      positionY: 10,
      width: 70,
      height: 70,
      section: 'Bar',
      currentOrderId: 'order-789',
    ),
    const RestaurantTable(
      id: '11',
      name: 'Bar 2',
      capacity: 2,
      status: TableStatus.available,
      shape: TableShape.circle,
      positionX: 82,
      positionY: 10,
      width: 70,
      height: 70,
      section: 'Bar',
    ),
  ];

  final List<KitchenStation> _stations = [
    const KitchenStation(
      id: '1',
      name: 'Grill Station',
      description: 'Handles all grilled items and meats',
      color: Color(0xFFDC3545), // OdooColors.danger
      categories: ['Steaks', 'Burgers', 'Grilled Chicken'],
      isActive: true,
      orderPosition: 0,
    ),
    const KitchenStation(
      id: '2',
      name: 'Salad & Cold Station',
      description: 'Prepares salads, appetizers, and cold dishes',
      color: Color(0xFF28A745), // OdooColors.success
      categories: ['Salads', 'Appetizers', 'Cold Sandwiches'],
      isActive: true,
      orderPosition: 1,
    ),
    const KitchenStation(
      id: '3',
      name: 'Pasta & Hot Kitchen',
      description: 'Pasta, soups, and hot entrees',
      color: Color(0xFFFFC107), // OdooColors.warning
      categories: ['Pasta', 'Soups', 'Hot Entrees'],
      isActive: true,
      orderPosition: 2,
    ),
    const KitchenStation(
      id: '4',
      name: 'Dessert Station',
      description: 'Desserts and sweet preparations',
      color: Color(0xFF6C757D), // OdooColors.secondary
      categories: ['Desserts', 'Pastries', 'Ice Cream'],
      isActive: true,
      orderPosition: 3,
    ),
    const KitchenStation(
      id: '5',
      name: 'Beverage Station',
      description: 'Drinks, coffee, and cocktails',
      color: Color(0xFF007BFF), // OdooColors.primary
      categories: ['Beverages', 'Coffee', 'Cocktails'],
      isActive: true,
      orderPosition: 4,
    ),
  ];

  // ========== Tables CRUD ==========

  @override
  Future<List<RestaurantTable>> getTables() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_tables);
  }

  @override
  Future<RestaurantTable> getTableById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _tables.firstWhere(
      (table) => table.id == id,
      orElse: () => throw Exception('Table not found'),
    );
  }

  @override
  Future<RestaurantTable> createTable(RestaurantTable table) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _tables.add(table);
    return table;
  }

  @override
  Future<RestaurantTable> updateTable(String id, RestaurantTable table) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _tables.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw Exception('Table not found');
    }

    _tables[index] = table;
    return table;
  }

  @override
  Future<void> deleteTable(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _tables.removeWhere((table) => table.id == id);
  }

  // ========== Kitchen Stations CRUD ==========

  @override
  Future<List<KitchenStation>> getKitchenStations() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_stations);
  }

  @override
  Future<KitchenStation> getKitchenStationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _stations.firstWhere(
      (station) => station.id == id,
      orElse: () => throw Exception('Kitchen station not found'),
    );
  }

  @override
  Future<KitchenStation> createKitchenStation(KitchenStation station) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _stations.add(station);
    return station;
  }

  @override
  Future<KitchenStation> updateKitchenStation(
    String id,
    KitchenStation station,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _stations.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw Exception('Kitchen station not found');
    }

    _stations[index] = station;
    return station;
  }

  @override
  Future<void> deleteKitchenStation(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _stations.removeWhere((station) => station.id == id);
  }
}
