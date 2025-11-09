import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/products_repository_impl.dart';
import '../data/sources/products_remote_source.dart';
import '../domain/entities/category.dart';
import '../domain/entities/product.dart';
import '../domain/repositories/products_repository.dart';
import '../domain/usecases/get_categories.dart';
import '../domain/usecases/get_products.dart';
import '../domain/usecases/search_products.dart';

part 'products_providers.g.dart';

/// Provides the products remote data source.
@riverpod
ProductsRemoteSource productsRemoteSource(ProductsRemoteSourceRef ref) {
  // TODO: Replace with actual API implementation
  return ProductsRemoteSourceMock();
}

/// Provides the products repository.
@riverpod
ProductsRepository productsRepository(ProductsRepositoryRef ref) {
  final remoteSource = ref.watch(productsRemoteSourceProvider);
  return ProductsRepositoryImpl(remoteSource: remoteSource);
}

/// Provides GetProducts use case.
@riverpod
GetProducts getProductsUseCase(GetProductsUseCaseRef ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return GetProducts(repository);
}

/// Provides SearchProducts use case.
@riverpod
SearchProducts searchProductsUseCase(SearchProductsUseCaseRef ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return SearchProducts(repository);
}

/// Provides GetCategories use case.
@riverpod
GetCategories getCategoriesUseCase(GetCategoriesUseCaseRef ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return GetCategories(repository);
}

/// Provides the list of all products.
@riverpod
Future<List<Product>> products(
  ProductsRef ref, {
  String? categoryId,
}) async {
  final useCase = ref.watch(getProductsUseCaseProvider);
  final result = await useCase(categoryId: categoryId);

  return result.when(
    success: (products) => products,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides a single product by ID.
@riverpod
Future<Product> product(ProductRef ref, String productId) async {
  final repository = ref.watch(productsRepositoryProvider);
  final result = await repository.getProductById(productId);

  return result.when(
    success: (product) => product,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides the list of all categories.
@riverpod
Future<List<Category>> categories(CategoriesRef ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  final result = await useCase();

  return result.when(
    success: (categories) => categories,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides the list of featured products.
@riverpod
Future<List<Product>> featuredProducts(FeaturedProductsRef ref) async {
  final repository = ref.watch(productsRepositoryProvider);
  final result = await repository.getFeaturedProducts();

  return result.when(
    success: (products) => products,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Product search state notifier.
@riverpod
class ProductSearch extends _$ProductSearch {
  @override
  Future<List<Product>> build(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final useCase = ref.watch(searchProductsUseCaseProvider);
    final result = await useCase(query);

    return result.when(
      success: (products) => products,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  /// Update search query
  void search(String query) {
    state = AsyncValue.data([]);
    ref.invalidateSelf();
  }
}
