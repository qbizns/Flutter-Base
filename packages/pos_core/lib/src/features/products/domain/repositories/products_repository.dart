import '../../../../core/errors/result.dart';
import '../entities/category.dart';
import '../entities/product.dart';

/// Products repository interface.
///
/// This is a domain interface that defines what operations are available
/// for products. The actual implementation lives in the data layer.
abstract class ProductsRepository {
  /// Get all products
  Future<Result<List<Product>>> getProducts({
    String? categoryId,
    bool activeOnly = true,
  });

  /// Get a single product by ID
  Future<Result<Product>> getProductById(String id);

  /// Search products by name, SKU, or barcode
  Future<Result<List<Product>>> searchProducts(
    String query, {
    String? categoryId,
  });

  /// Get products by IDs (batch fetch)
  Future<Result<List<Product>>> getProductsByIds(List<String> ids);

  /// Get featured products
  Future<Result<List<Product>>> getFeaturedProducts({int limit = 10});

  /// Get low stock products
  Future<Result<List<Product>>> getLowStockProducts();

  /// Get all categories
  Future<Result<List<Category>>> getCategories({
    String? parentId,
    bool activeOnly = true,
  });

  /// Get a single category by ID
  Future<Result<Category>> getCategoryById(String id);

  /// Get products count by category
  Future<Result<Map<String, int>>> getProductsCountByCategory();

  /// Update product stock quantity (for inventory tracking)
  Future<Result<void>> updateProductStock(String productId, int newQuantity);

  /// Update product availability
  Future<Result<void>> updateProductAvailability(
    String productId,
    bool isAvailable,
  );
}
