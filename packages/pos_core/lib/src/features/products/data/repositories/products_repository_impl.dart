import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../sources/products_remote_source.dart';

/// Implementation of ProductsRepository.
///
/// Coordinates between remote and local data sources to provide
/// products data to the domain layer.
class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl({
    required this.remoteSource,
  });

  final ProductsRemoteSource remoteSource;

  @override
  Future<Result<List<Product>>> getProducts({
    String? categoryId,
    bool activeOnly = true,
  }) async {
    try {
      final products = await remoteSource.getProducts(
        categoryId: categoryId,
        activeOnly: activeOnly,
      );
      return Result.success(products);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch products: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Product>> getProductById(String id) async {
    try {
      final product = await remoteSource.getProductById(id);
      return Result.success(product);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch product: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Product>>> searchProducts(
    String query, {
    String? categoryId,
  }) async {
    try {
      final products = await remoteSource.searchProducts(
        query,
        categoryId: categoryId,
      );
      return Result.success(products);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to search products: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Product>>> getProductsByIds(List<String> ids) async {
    try {
      final products = await remoteSource.getProductsByIds(ids);
      return Result.success(products);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch products: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Product>>> getFeaturedProducts({int limit = 10}) async {
    try {
      final products = await remoteSource.getFeaturedProducts(limit: limit);
      return Result.success(products);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch featured products: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Product>>> getLowStockProducts() async {
    try {
      final products = await remoteSource.getLowStockProducts();
      return Result.success(products);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Failed to fetch low stock products: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<List<Category>>> getCategories({
    String? parentId,
    bool activeOnly = true,
  }) async {
    try {
      final categories = await remoteSource.getCategories(
        parentId: parentId,
        activeOnly: activeOnly,
      );
      return Result.success(categories);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch categories: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Category>> getCategoryById(String id) async {
    try {
      final category = await remoteSource.getCategoryById(id);
      return Result.success(category);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch category: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Map<String, int>>> getProductsCountByCategory() async {
    try {
      final counts = await remoteSource.getProductsCountByCategory();
      return Result.success(counts);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Failed to fetch products count: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void>> updateProductStock(
    String productId,
    int newQuantity,
  ) async {
    try {
      await remoteSource.updateProductStock(productId, newQuantity);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to update product stock: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> updateProductAvailability(
    String productId,
    bool isAvailable,
  ) async {
    try {
      await remoteSource.updateProductAvailability(productId, isAvailable);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Failed to update product availability: ${e.toString()}',
        ),
      );
    }
  }
}
