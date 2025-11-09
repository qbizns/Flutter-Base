import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/table.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/tables_repository.dart';
import '../sources/tables_remote_source.dart';

/// Implementation of TablesRepository.
class TablesRepositoryImpl implements TablesRepository {
  const TablesRepositoryImpl({
    required this.remoteSource,
  });

  final TablesRemoteSource remoteSource;

  @override
  Future<Result<List<Table>>> getTables({
    String? zoneId,
    TableStatus? status,
    bool activeOnly = true,
  }) async {
    try {
      final tables = await remoteSource.getTables(
        zoneId: zoneId,
        status: status,
        activeOnly: activeOnly,
      );
      return Result.success(tables);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch tables: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Table>> getTableById(String id) async {
    try {
      final table = await remoteSource.getTableById(id);
      return Result.success(table);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch table: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Table>>> getAvailableTables({String? zoneId}) async {
    try {
      final tables = await remoteSource.getAvailableTables(zoneId: zoneId);
      return Result.success(tables);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch available tables: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Table>>> getOccupiedTables({String? zoneId}) async {
    try {
      final tables = await remoteSource.getOccupiedTables(zoneId: zoneId);
      return Result.success(tables);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch occupied tables: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Table>> updateTableStatus(
    String tableId,
    TableStatus newStatus,
  ) async {
    try {
      final table = await remoteSource.updateTableStatus(tableId, newStatus);
      return Result.success(table);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to update table status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Table>> assignOrderToTable(
    String tableId,
    String orderId,
  ) async {
    try {
      final table = await remoteSource.assignOrderToTable(tableId, orderId);
      return Result.success(table);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to assign order to table: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Table>> clearTable(String tableId) async {
    try {
      final table = await remoteSource.clearTable(tableId);
      return Result.success(table);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to clear table: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Zone>>> getZones({bool activeOnly = true}) async {
    try {
      final zones = await remoteSource.getZones(activeOnly: activeOnly);
      return Result.success(zones);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch zones: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Zone>> getZoneById(String id) async {
    try {
      final zone = await remoteSource.getZoneById(id);
      return Result.success(zone);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch zone: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Map<String, int>>> getTableCountByZone() async {
    try {
      final counts = await remoteSource.getTableCountByZone();
      return Result.success(counts);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch table counts: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<TableStatistics>> getTableStatistics() async {
    try {
      final statistics = await remoteSource.getTableStatistics();
      return Result.success(statistics);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch table statistics: ${e.toString()}'),
      );
    }
  }
}
