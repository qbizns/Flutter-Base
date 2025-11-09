import '../../../../core/errors/result.dart';
import '../entities/table.dart';
import '../repositories/tables_repository.dart';

/// Use case for updating a table's status.
class UpdateTableStatus {
  const UpdateTableStatus(this.repository);

  final TablesRepository repository;

  Future<Result<Table>> call(String tableId, TableStatus newStatus) {
    return repository.updateTableStatus(tableId, newStatus);
  }
}
