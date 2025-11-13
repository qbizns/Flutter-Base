import 'package:dio/dio.dart';
import '../../domain/entities/table.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/tables_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';

/// Remote data source for tables.
///
/// This would typically make HTTP requests to a backend API.
/// For now, it returns mock data for development.
abstract class TablesRemoteSource {
  Future<List<Table>> getTables({
    String? zoneId,
    TableStatus? status,
    bool activeOnly = true,
  });

  Future<Table> getTableById(String id);

  Future<List<Table>> getAvailableTables({String? zoneId});

  Future<List<Table>> getOccupiedTables({String? zoneId});

  Future<Table> updateTableStatus(String tableId, TableStatus newStatus);

  Future<Table> assignOrderToTable(String tableId, String orderId);

  Future<Table> clearTable(String tableId);

  Future<List<Zone>> getZones({bool activeOnly = true});

  Future<Zone> getZoneById(String id);

  Future<Map<String, int>> getTableCountByZone();

  Future<TableStatistics> getTableStatistics();
}

/// HTTP implementation of TablesRemoteSource.
/// Makes actual API calls to the backend.
class TablesRemoteSourceHttp implements TablesRemoteSource {
  TablesRemoteSourceHttp({
    required ApiClient apiClient,
    required String organizationId,
  })  : _apiClient = apiClient,
        _orgId = organizationId;

  final ApiClient _apiClient;
  final String _orgId;

  String get _tablesPath => '/organizations/$_orgId/tables';
  String get _zonesPath => '/organizations/$_orgId/zones';

  @override
  Future<List<Table>> getTables({
    String? zoneId,
    TableStatus? status,
    bool activeOnly = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (zoneId != null) queryParams['zone_id'] = zoneId;
      if (status != null) queryParams['status'] = status.name;
      if (activeOnly) queryParams['active_only'] = true;

      final response = await _apiClient.get<Map<String, dynamic>>(
        _tablesPath,
        queryParameters: queryParams,
      );

      final data = response.data!['data'] as List;
      return data.map((json) => _tableFromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Table> getTableById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_tablesPath/$id',
      );

      return _tableFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Table>> getAvailableTables({String? zoneId}) async {
    return getTables(
      zoneId: zoneId,
      status: TableStatus.available,
    );
  }

  @override
  Future<List<Table>> getOccupiedTables({String? zoneId}) async {
    return getTables(
      zoneId: zoneId,
      status: TableStatus.occupied,
    );
  }

  @override
  Future<Table> updateTableStatus(String tableId, TableStatus newStatus) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '$_tablesPath/$tableId/status',
        data: {'status': newStatus.name},
      );

      return _tableFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Table> assignOrderToTable(String tableId, String orderId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_tablesPath/$tableId/assign-order',
        data: {'order_id': orderId},
      );

      return _tableFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Table> clearTable(String tableId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_tablesPath/$tableId/clear',
      );

      return _tableFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Zone>> getZones({bool activeOnly = true}) async {
    try {
      final queryParams = <String, dynamic>{};

      if (activeOnly) queryParams['active_only'] = true;

      final response = await _apiClient.get<Map<String, dynamic>>(
        _zonesPath,
        queryParameters: queryParams,
      );

      final data = response.data!['data'] as List;
      return data.map((json) => _zoneFromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Zone> getZoneById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_zonesPath/$id',
      );

      return _zoneFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, int>> getTableCountByZone() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_tablesPath/count-by-zone',
      );

      final data = response.data!['data'] as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TableStatistics> getTableStatistics() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_tablesPath/statistics',
      );

      return _tableStatisticsFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // JSON serialization helpers
  Table _tableFromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'] as String,
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      status: TableStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TableStatus.available,
      ),
      number: json['number'] as int?,
      zoneId: json['zone_id'] as String?,
      zoneName: json['zone_name'] as String?,
      shape: json['shape'] != null
          ? TableShape.values.firstWhere(
              (e) => e.name == json['shape'],
              orElse: () => TableShape.rectangle,
            )
          : TableShape.rectangle,
      position: json['position'] != null
          ? _tablePositionFromJson(json['position'] as Map<String, dynamic>)
          : null,
      currentOrderId: json['current_order_id'] as String?,
      assignedTo: json['assigned_to'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  TablePosition _tablePositionFromJson(Map<String, dynamic> json) {
    return TablePosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num?)?.toDouble() ?? 100,
      height: (json['height'] as num?)?.toDouble() ?? 100,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
    );
  }

  Zone _zoneFromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      iconName: json['icon_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      tableCount: json['table_count'] as int? ?? 0,
    );
  }

  TableStatistics _tableStatisticsFromJson(Map<String, dynamic> json) {
    return TableStatistics(
      totalTables: json['total_tables'] as int,
      availableTables: json['available_tables'] as int,
      occupiedTables: json['occupied_tables'] as int,
      reservedTables: json['reserved_tables'] as int,
      occupancyRate: (json['occupancy_rate'] as num).toDouble(),
      averageTurnoverTime: Duration(
        minutes: json['average_turnover_minutes'] as int? ?? 0,
      ),
    );
  }
}

/// Mock implementation of TablesRemoteSource for development.
///
/// TODO: Replace with actual API implementation.
class TablesRemoteSourceMock implements TablesRemoteSource {
  // Mock data storage
  final List<Table> _tables = [
    const Table(
      id: 't1',
      name: 'Table 1',
      number: 1,
      capacity: 4,
      status: TableStatus.available,
      zoneId: 'z1',
      zoneName: 'Main Floor',
      shape: TableShape.rectangle,
      position: TablePosition(x: 50, y: 50, width: 120, height: 80),
      sortOrder: 1,
    ),
    const Table(
      id: 't2',
      name: 'Table 2',
      number: 2,
      capacity: 2,
      status: TableStatus.available,
      zoneId: 'z1',
      zoneName: 'Main Floor',
      shape: TableShape.square,
      position: TablePosition(x: 200, y: 50, width: 80, height: 80),
      sortOrder: 2,
    ),
    const Table(
      id: 't3',
      name: 'Table 3',
      number: 3,
      capacity: 6,
      status: TableStatus.occupied,
      zoneId: 'z1',
      zoneName: 'Main Floor',
      shape: TableShape.rectangle,
      position: TablePosition(x: 50, y: 200, width: 150, height: 100),
      currentOrderId: 'o3',
      assignedTo: 'John Doe',
      sortOrder: 3,
    ),
    const Table(
      id: 't4',
      name: 'Table 4',
      number: 4,
      capacity: 4,
      status: TableStatus.cleaning,
      zoneId: 'z1',
      zoneName: 'Main Floor',
      shape: TableShape.circle,
      position: TablePosition(x: 250, y: 200, width: 100, height: 100),
      sortOrder: 4,
    ),
    const Table(
      id: 't5',
      name: 'Table 5',
      number: 5,
      capacity: 8,
      status: TableStatus.occupied,
      zoneId: 'z2',
      zoneName: 'Patio',
      shape: TableShape.rectangle,
      position: TablePosition(x: 50, y: 50, width: 180, height: 100),
      currentOrderId: 'o1',
      assignedTo: 'John Doe',
      sortOrder: 5,
    ),
    const Table(
      id: 't6',
      name: 'VIP 1',
      number: 101,
      capacity: 6,
      status: TableStatus.reserved,
      zoneId: 'z3',
      zoneName: 'VIP Section',
      shape: TableShape.oval,
      position: TablePosition(x: 100, y: 100, width: 150, height: 120),
      assignedTo: 'Sarah Johnson',
      sortOrder: 6,
    ),
  ];

  final List<Zone> _zones = [
    const Zone(
      id: 'z1',
      name: 'Main Floor',
      description: 'Main dining area',
      color: '#4CAF50',
      iconName: 'restaurant',
      isActive: true,
      sortOrder: 1,
      tableCount: 4,
    ),
    const Zone(
      id: 'z2',
      name: 'Patio',
      description: 'Outdoor seating area',
      color: '#2196F3',
      iconName: 'outdoor_grill',
      isActive: true,
      sortOrder: 2,
      tableCount: 1,
    ),
    const Zone(
      id: 'z3',
      name: 'VIP Section',
      description: 'Private dining area',
      color: '#FF9800',
      iconName: 'star',
      isActive: true,
      sortOrder: 3,
      tableCount: 1,
    ),
  ];

  @override
  Future<List<Table>> getTables({
    String? zoneId,
    TableStatus? status,
    bool activeOnly = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _tables;

    if (activeOnly) {
      filtered = filtered.where((t) => t.isActive).toList();
    }

    if (zoneId != null) {
      filtered = filtered.where((t) => t.zoneId == zoneId).toList();
    }

    if (status != null) {
      filtered = filtered.where((t) => t.status == status).toList();
    }

    filtered.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return filtered;
  }

  @override
  Future<Table> getTableById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _tables.firstWhere(
      (t) => t.id == id,
      orElse: () => throw Exception('Table not found'),
    );
  }

  @override
  Future<List<Table>> getAvailableTables({String? zoneId}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    var available = _tables.where((t) => t.isAvailable).toList();

    if (zoneId != null) {
      available = available.where((t) => t.zoneId == zoneId).toList();
    }

    available.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return available;
  }

  @override
  Future<List<Table>> getOccupiedTables({String? zoneId}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    var occupied = _tables.where((t) => t.isOccupied).toList();

    if (zoneId != null) {
      occupied = occupied.where((t) => t.zoneId == zoneId).toList();
    }

    occupied.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return occupied;
  }

  @override
  Future<Table> updateTableStatus(
    String tableId,
    TableStatus newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _tables.indexWhere((t) => t.id == tableId);
    if (index == -1) {
      throw Exception('Table not found');
    }

    final updatedTable = _tables[index].copyWith(status: newStatus);
    _tables[index] = updatedTable;
    return updatedTable;
  }

  @override
  Future<Table> assignOrderToTable(String tableId, String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _tables.indexWhere((t) => t.id == tableId);
    if (index == -1) {
      throw Exception('Table not found');
    }

    final updatedTable = _tables[index].copyWith(
      currentOrderId: orderId,
      status: TableStatus.occupied,
    );
    _tables[index] = updatedTable;
    return updatedTable;
  }

  @override
  Future<Table> clearTable(String tableId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _tables.indexWhere((t) => t.id == tableId);
    if (index == -1) {
      throw Exception('Table not found');
    }

    final updatedTable = _tables[index].copyWith(
      currentOrderId: '',
      status: TableStatus.cleaning,
    );
    _tables[index] = updatedTable;
    return updatedTable;
  }

  @override
  Future<List<Zone>> getZones({bool activeOnly = true}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    var filtered = _zones;

    if (activeOnly) {
      filtered = filtered.where((z) => z.isActive).toList();
    }

    filtered.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return filtered;
  }

  @override
  Future<Zone> getZoneById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _zones.firstWhere(
      (z) => z.id == id,
      orElse: () => throw Exception('Zone not found'),
    );
  }

  @override
  Future<Map<String, int>> getTableCountByZone() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final counts = <String, int>{};
    for (final zone in _zones) {
      counts[zone.id] = _tables.where((t) => t.zoneId == zone.id).length;
    }
    return counts;
  }

  @override
  Future<TableStatistics> getTableStatistics() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final totalTables = _tables.where((t) => t.isActive).length;
    final availableTables =
        _tables.where((t) => t.status == TableStatus.available).length;
    final occupiedTables =
        _tables.where((t) => t.status == TableStatus.occupied).length;
    final reservedTables =
        _tables.where((t) => t.status == TableStatus.reserved).length;

    final occupancyRate = totalTables > 0 ? occupiedTables / totalTables : 0.0;

    return TableStatistics(
      totalTables: totalTables,
      availableTables: availableTables,
      occupiedTables: occupiedTables,
      reservedTables: reservedTables,
      occupancyRate: occupancyRate,
      averageTurnoverTime: const Duration(minutes: 45),
    );
  }
}
