import '../../../../core/errors/result.dart';
import '../entities/table.dart';
import '../repositories/tables_repository.dart';

/// Use case for assigning an order to a table.
class AssignOrderToTable {
  const AssignOrderToTable(this.repository);

  final TablesRepository repository;

  Future<Result<Table>> call(String tableId, String orderId) {
    return repository.assignOrderToTable(tableId, orderId);
  }
}
