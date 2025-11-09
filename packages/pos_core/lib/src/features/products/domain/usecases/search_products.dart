import '../../../../core/errors/result.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

/// Use case for searching products.
///
/// Searches products by name, SKU, or barcode.
class SearchProducts {
  const SearchProducts(this.repository);

  final ProductsRepository repository;

  Future<Result<List<Product>>> call(
    String query, {
    String? categoryId,
  }) {
    // Trim and validate query
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return Future.value(const Result.success([]));
    }

    return repository.searchProducts(
      trimmedQuery,
      categoryId: categoryId,
    );
  }
}
