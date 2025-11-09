import '../../../../core/errors/result.dart';
import '../entities/table.dart';
import '../repositories/tables_repository.dart';

/// Use case for retrieving tables with optional filters.
class GetTables {
  const GetTables(this.repository);

  final TablesRepository repository;

  Future<Result<List<Table>>> call({
    String? zoneId,
    TableStatus? status,
    bool activeOnly = true,
  }) {
    return repository.getTables(
      zoneId: zoneId,
      status: status,
      activeOnly: activeOnly,
    );
  }
}
