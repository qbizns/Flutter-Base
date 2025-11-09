import '../../../../core/errors/result.dart';
import '../entities/table.dart';
import '../repositories/tables_repository.dart';

/// Use case for clearing a table (removing order assignment).
class ClearTable {
  const ClearTable(this.repository);

  final TablesRepository repository;

  Future<Result<Table>> call(String tableId) {
    return repository.clearTable(tableId);
  }
}
