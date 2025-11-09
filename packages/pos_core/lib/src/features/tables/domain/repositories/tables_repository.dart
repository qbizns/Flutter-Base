import '../../../../core/errors/result.dart';
import '../entities/table.dart';
import '../entities/zone.dart';

/// Repository interface for tables.
abstract class TablesRepository {
  /// Get all tables
  Future<Result<List<Table>>> getTables({
    String? zoneId,
    TableStatus? status,
    bool activeOnly = true,
  });

  /// Get table by ID
  Future<Result<Table>> getTableById(String id);

  /// Get available tables
  Future<Result<List<Table>>> getAvailableTables({String? zoneId});

  /// Get occupied tables
  Future<Result<List<Table>>> getOccupiedTables({String? zoneId});

  /// Update table status
  Future<Result<Table>> updateTableStatus(String tableId, TableStatus newStatus);

  /// Assign order to table
  Future<Result<Table>> assignOrderToTable(String tableId, String orderId);

  /// Clear table (remove order assignment)
  Future<Result<Table>> clearTable(String tableId);

  /// Get all zones
  Future<Result<List<Zone>>> getZones({bool activeOnly = true});

  /// Get zone by ID
  Future<Result<Zone>> getZoneById(String id);

  /// Get table count by zone
  Future<Result<Map<String, int>>> getTableCountByZone();

  /// Get table statistics
  Future<Result<TableStatistics>> getTableStatistics();
}

/// Table statistics
class TableStatistics {
  const TableStatistics({
    required this.totalTables,
    required this.availableTables,
    required this.occupiedTables,
    required this.reservedTables,
    required this.occupancyRate,
    required this.averageTurnoverTime,
  });

  final int totalTables;
  final int availableTables;
  final int occupiedTables;
  final int reservedTables;
  final double occupancyRate;
  final Duration averageTurnoverTime;
}
