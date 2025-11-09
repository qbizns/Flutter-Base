import '../../../../core/errors/result.dart';
import '../entities/table.dart';
import '../repositories/tables_repository.dart';

/// Use case for retrieving available tables.
class GetAvailableTables {
  const GetAvailableTables(this.repository);

  final TablesRepository repository;

  Future<Result<List<Table>>> call({String? zoneId}) {
    return repository.getAvailableTables(zoneId: zoneId);
  }
}
