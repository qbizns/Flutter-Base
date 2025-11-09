import '../../../../core/errors/result.dart';
import '../entities/zone.dart';
import '../repositories/tables_repository.dart';

/// Use case for retrieving zones.
class GetZones {
  const GetZones(this.repository);

  final TablesRepository repository;

  Future<Result<List<Zone>>> call({bool activeOnly = true}) {
    return repository.getZones(activeOnly: activeOnly);
  }
}
