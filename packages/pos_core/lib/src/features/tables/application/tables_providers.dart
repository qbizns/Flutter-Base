import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/tables_repository_impl.dart';
import '../data/sources/tables_remote_source.dart';
import '../domain/entities/table.dart';
import '../domain/entities/zone.dart';
import '../domain/repositories/tables_repository.dart';
import '../domain/usecases/assign_order_to_table.dart';
import '../domain/usecases/clear_table.dart';
import '../domain/usecases/get_available_tables.dart';
import '../domain/usecases/get_tables.dart';
import '../domain/usecases/get_zones.dart';
import '../domain/usecases/update_table_status.dart';
import '../../../core/network/api_providers.dart';
import '../../../core/config/config_providers.dart';
import '../../../core/context/context_providers.dart';

part 'tables_providers.g.dart';

/// Provides the tables remote data source.
@riverpod
TablesRemoteSource tablesRemoteSource(TablesRemoteSourceRef ref) {
  final config = ref.watch(appConfigProvider);
  final context = ref.watch(appContextProvider);

  // Use HTTP implementation if API URL is configured and we have tenant ID
  if (config.apiBaseUrl.isNotEmpty && context.tenantId != null) {
    final apiClient = ref.watch(apiClientProvider);
    return TablesRemoteSourceHttp(
      apiClient: apiClient,
      organizationId: context.tenantId!,
    );
  }

  // Fall back to mock for development/testing
  return TablesRemoteSourceMock();
}

/// Provides the tables repository.
@riverpod
TablesRepository tablesRepository(TablesRepositoryRef ref) {
  final remoteSource = ref.watch(tablesRemoteSourceProvider);
  return TablesRepositoryImpl(remoteSource: remoteSource);
}

/// Provides GetTables use case.
@riverpod
GetTables getTablesUseCase(GetTablesUseCaseRef ref) {
  final repository = ref.watch(tablesRepositoryProvider);
  return GetTables(repository);
}

/// Provides GetAvailableTables use case.
@riverpod
GetAvailableTables getAvailableTablesUseCase(
  GetAvailableTablesUseCaseRef ref,
) {
  final repository = ref.watch(tablesRepositoryProvider);
  return GetAvailableTables(repository);
}

/// Provides UpdateTableStatus use case.
@riverpod
UpdateTableStatus updateTableStatusUseCase(UpdateTableStatusUseCaseRef ref) {
  final repository = ref.watch(tablesRepositoryProvider);
  return UpdateTableStatus(repository);
}

/// Provides AssignOrderToTable use case.
@riverpod
AssignOrderToTable assignOrderToTableUseCase(
  AssignOrderToTableUseCaseRef ref,
) {
  final repository = ref.watch(tablesRepositoryProvider);
  return AssignOrderToTable(repository);
}

/// Provides ClearTable use case.
@riverpod
ClearTable clearTableUseCase(ClearTableUseCaseRef ref) {
  final repository = ref.watch(tablesRepositoryProvider);
  return ClearTable(repository);
}

/// Provides GetZones use case.
@riverpod
GetZones getZonesUseCase(GetZonesUseCaseRef ref) {
  final repository = ref.watch(tablesRepositoryProvider);
  return GetZones(repository);
}

/// Provides a single table by ID.
@riverpod
Future<Table> table(TableRef ref, String tableId) async {
  final repository = ref.watch(tablesRepositoryProvider);
  final result = await repository.getTableById(tableId);

  return result.when(
    success: (table) => table,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides the list of all tables filtered by zone and status.
@riverpod
Future<List<Table>> tables(
  TablesRef ref, {
  String? zoneId,
  TableStatus? status,
  bool activeOnly = true,
}) async {
  final useCase = ref.watch(getTablesUseCaseProvider);
  final result = await useCase(
    zoneId: zoneId,
    status: status,
    activeOnly: activeOnly,
  );

  return result.when(
    success: (tables) => tables,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides the list of available tables.
@riverpod
Future<List<Table>> availableTables(
  AvailableTablesRef ref, {
  String? zoneId,
}) async {
  final useCase = ref.watch(getAvailableTablesUseCaseProvider);
  final result = await useCase(zoneId: zoneId);

  return result.when(
    success: (tables) => tables,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides the list of occupied tables.
@riverpod
Future<List<Table>> occupiedTables(
  OccupiedTablesRef ref, {
  String? zoneId,
}) async {
  final repository = ref.watch(tablesRepositoryProvider);
  final result = await repository.getOccupiedTables(zoneId: zoneId);

  return result.when(
    success: (tables) => tables,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides the list of zones.
@riverpod
Future<List<Zone>> zones(ZonesRef ref, {bool activeOnly = true}) async {
  final useCase = ref.watch(getZonesUseCaseProvider);
  final result = await useCase(activeOnly: activeOnly);

  return result.when(
    success: (zones) => zones,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides table statistics.
@riverpod
Future<TableStatistics> tableStatistics(TableStatisticsRef ref) async {
  final repository = ref.watch(tablesRepositoryProvider);
  final result = await repository.getTableStatistics();

  return result.when(
    success: (stats) => stats,
    failure: (failure) => throw Exception(failure.message),
  );
}
