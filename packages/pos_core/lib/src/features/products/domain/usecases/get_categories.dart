import '../../../../core/errors/result.dart';
import '../entities/category.dart';
import '../repositories/products_repository.dart';

/// Use case for getting categories list.
///
/// Encapsulates the business logic for fetching categories.
class GetCategories {
  const GetCategories(this.repository);

  final ProductsRepository repository;

  Future<Result<List<Category>>> call({
    String? parentId,
    bool activeOnly = true,
  }) {
    return repository.getCategories(
      parentId: parentId,
      activeOnly: activeOnly,
    );
  }
}
