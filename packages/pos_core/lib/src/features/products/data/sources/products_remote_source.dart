import '../../domain/entities/category.dart';
import '../../domain/entities/modifier.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_price.dart';

/// Remote data source for products.
///
/// This would typically make HTTP requests to a backend API.
/// For now, it returns mock data for development.
abstract class ProductsRemoteSource {
  Future<List<Product>> getProducts({
    String? categoryId,
    bool activeOnly = true,
  });

  Future<Product> getProductById(String id);

  Future<List<Product>> searchProducts(
    String query, {
    String? categoryId,
  });

  Future<List<Product>> getProductsByIds(List<String> ids);

  Future<List<Product>> getFeaturedProducts({int limit = 10});

  Future<List<Product>> getLowStockProducts();

  Future<List<Category>> getCategories({
    String? parentId,
    bool activeOnly = true,
  });

  Future<Category> getCategoryById(String id);

  Future<Map<String, int>> getProductsCountByCategory();

  Future<void> updateProductStock(String productId, int newQuantity);

  Future<void> updateProductAvailability(String productId, bool isAvailable);
}

/// Mock implementation of ProductsRemoteSource for development.
///
/// TODO: Replace with actual API implementation.
class ProductsRemoteSourceMock implements ProductsRemoteSource {
  // Mock data storage
  final List<Product> _products = [
    Product(
      id: 'p1',
      name: 'Margherita Pizza',
      price: 12.99,
      sku: 'PIZZA-001',
      barcode: '1234567890123',
      description: 'Classic pizza with tomato sauce, mozzarella, and basil',
      categoryId: 'c1',
      imageUrl: 'https://example.com/pizza.jpg',
      isActive: true,
      isAvailable: true,
      isFeatured: true,
      trackInventory: false,
      allowModifiers: true,
      modifierGroups: [
        ModifierGroup(
          id: 'mg1',
          name: 'Size',
          selectionType: ModifierSelectionType.single,
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          modifiers: [
            const Modifier(id: 'm1', name: 'Small', price: 0, isDefault: true),
            const Modifier(id: 'm2', name: 'Medium', price: 3.00),
            const Modifier(id: 'm3', name: 'Large', price: 5.00),
          ],
        ),
        ModifierGroup(
          id: 'mg2',
          name: 'Toppings',
          selectionType: ModifierSelectionType.multiple,
          isRequired: false,
          minSelection: 0,
          maxSelection: 5,
          modifiers: [
            const Modifier(id: 'm4', name: 'Extra Cheese', price: 1.50),
            const Modifier(id: 'm5', name: 'Mushrooms', price: 1.00),
            const Modifier(id: 'm6', name: 'Pepperoni', price: 2.00),
            const Modifier(id: 'm7', name: 'Olives', price: 1.00),
          ],
        ),
      ],
      prices: const [
        ProductPrice(id: 'pp1', name: 'Small', price: 12.99, isDefault: true),
        ProductPrice(id: 'pp2', name: 'Medium', price: 15.99),
        ProductPrice(id: 'pp3', name: 'Large', price: 18.99),
      ],
      tags: ['pizza', 'italian', 'vegetarian'],
      preparationTime: 15,
      calories: 800,
      allergens: ['dairy', 'gluten'],
      sortOrder: 1,
    ),
    const Product(
      id: 'p2',
      name: 'Caesar Salad',
      price: 8.99,
      sku: 'SALAD-001',
      description: 'Fresh romaine lettuce with Caesar dressing',
      categoryId: 'c2',
      isActive: true,
      isAvailable: true,
      trackInventory: false,
      tags: ['salad', 'healthy'],
      preparationTime: 5,
      calories: 350,
      sortOrder: 2,
    ),
    const Product(
      id: 'p3',
      name: 'Cheeseburger',
      price: 10.99,
      sku: 'BURGER-001',
      description: 'Juicy beef patty with cheese, lettuce, and tomato',
      categoryId: 'c3',
      isActive: true,
      isAvailable: true,
      isFeatured: true,
      trackInventory: true,
      stockQuantity: 50,
      lowStockThreshold: 10,
      tags: ['burger', 'beef'],
      preparationTime: 12,
      calories: 650,
      sortOrder: 3,
    ),
  ];

  final List<Category> _categories = [
    const Category(
      id: 'c1',
      name: 'Pizza',
      description: 'Delicious pizzas',
      iconName: 'pizza',
      color: '#FF5733',
      isActive: true,
      sortOrder: 1,
    ),
    const Category(
      id: 'c2',
      name: 'Salads',
      description: 'Fresh and healthy salads',
      iconName: 'salad',
      color: '#4CAF50',
      isActive: true,
      sortOrder: 2,
    ),
    const Category(
      id: 'c3',
      name: 'Burgers',
      description: 'Juicy burgers',
      iconName: 'burger',
      color: '#FFC107',
      isActive: true,
      sortOrder: 3,
    ),
  ];

  @override
  Future<List<Product>> getProducts({
    String? categoryId,
    bool activeOnly = true,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _products;

    if (activeOnly) {
      filtered = filtered.where((p) => p.isActive).toList();
    }

    if (categoryId != null) {
      filtered = filtered.where((p) => p.categoryId == categoryId).toList();
    }

    return filtered;
  }

  @override
  Future<Product> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _products.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Product not found'),
    );
  }

  @override
  Future<List<Product>> searchProducts(
    String query, {
    String? categoryId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final lowerQuery = query.toLowerCase();
    var results = _products.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          (p.sku?.toLowerCase().contains(lowerQuery) ?? false) ||
          (p.barcode?.contains(query) ?? false);
    }).toList();

    if (categoryId != null) {
      results = results.where((p) => p.categoryId == categoryId).toList();
    }

    return results;
  }

  @override
  Future<List<Product>> getProductsByIds(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _products.where((p) => ids.contains(p.id)).toList();
  }

  @override
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _products.where((p) => p.isFeatured).take(limit).toList();
  }

  @override
  Future<List<Product>> getLowStockProducts() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _products.where((p) => p.isLowStock).toList();
  }

  @override
  Future<List<Category>> getCategories({
    String? parentId,
    bool activeOnly = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    var filtered = _categories;

    if (activeOnly) {
      filtered = filtered.where((c) => c.isActive).toList();
    }

    if (parentId != null) {
      filtered = filtered.where((c) => c.parentId == parentId).toList();
    }

    return filtered;
  }

  @override
  Future<Category> getCategoryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Category not found'),
    );
  }

  @override
  Future<Map<String, int>> getProductsCountByCategory() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final counts = <String, int>{};
    for (final category in _categories) {
      counts[category.id] =
          _products.where((p) => p.categoryId == category.id).length;
    }
    return counts;
  }

  @override
  Future<void> updateProductStock(String productId, int newQuantity) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(stockQuantity: newQuantity);
    }
  }

  @override
  Future<void> updateProductAvailability(
    String productId,
    bool isAvailable,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(isAvailable: isAvailable);
    }
  }
}
