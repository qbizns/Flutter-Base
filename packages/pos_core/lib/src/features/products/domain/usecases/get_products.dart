import '../../../../core/errors/result.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

/// Use case for getting products list.
///
/// Encapsulates the business logic for fetching products,
/// optionally filtered by category.
class GetProducts {
  const GetProducts(this.repository);

  final ProductsRepository repository;

  Future<Result<List<Product>>> call({
    String? categoryId,
    bool activeOnly = true,
  }) {
    return repository.getProducts(
      categoryId: categoryId,
      activeOnly: activeOnly,
    );
  }
}
