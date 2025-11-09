import 'package:equatable/equatable.dart';
import 'modifier.dart';
import 'product_price.dart';

/// Product entity representing an item in the catalog.
///
/// This is a domain entity - pure business logic with no dependencies
/// on infrastructure, UI, or external services.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.sku,
    this.barcode,
    this.description,
    this.categoryId,
    this.imageUrl,
    this.thumbnailUrl,
    this.isActive = true,
    this.isAvailable = true,
    this.isFeatured = false,
    this.stockQuantity,
    this.lowStockThreshold,
    this.trackInventory = false,
    this.allowModifiers = false,
    this.modifierGroups = const [],
    this.prices = const [],
    this.tags = const [],
    this.preparationTime,
    this.calories,
    this.allergens = const [],
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier
  final String id;

  /// Product name
  final String name;

  /// Base price
  final double price;

  /// Stock Keeping Unit
  final String? sku;

  /// Barcode/UPC
  final String? barcode;

  /// Product description
  final String? description;

  /// Category this product belongs to
  final String? categoryId;

  /// Full-size image URL
  final String? imageUrl;

  /// Thumbnail image URL
  final String? thumbnailUrl;

  /// Is product active in the system
  final bool isActive;

  /// Is product available for sale now
  final bool isAvailable;

  /// Is featured product (promoted)
  final bool isFeatured;

  /// Current stock quantity (if tracked)
  final int? stockQuantity;

  /// Low stock alert threshold
  final int? lowStockThreshold;

  /// Whether to track inventory for this product
  final bool trackInventory;

  /// Whether modifiers can be added
  final bool allowModifiers;

  /// Available modifier groups
  final List<ModifierGroup> modifierGroups;

  /// Price variations (size, time-based, etc.)
  final List<ProductPrice> prices;

  /// Tags for searching/filtering
  final List<String> tags;

  /// Estimated preparation time in minutes
  final int? preparationTime;

  /// Calorie information
  final int? calories;

  /// Allergen information
  final List<String> allergens;

  /// Sort order for display
  final int sortOrder;

  /// When product was created
  final DateTime? createdAt;

  /// When product was last updated
  final DateTime? updatedAt;

  /// Check if product is in stock (if inventory is tracked)
  bool get isInStock {
    if (!trackInventory) return true;
    if (stockQuantity == null) return true;
    return stockQuantity! > 0;
  }

  /// Check if product is low on stock
  bool get isLowStock {
    if (!trackInventory) return false;
    if (stockQuantity == null || lowStockThreshold == null) return false;
    return stockQuantity! <= lowStockThreshold!;
  }

  /// Get price for specific price tier/size
  double getPriceForTier(String? tierId) {
    if (tierId == null) return price;

    final tierPrice = prices.firstWhere(
      (p) => p.id == tierId,
      orElse: () => ProductPrice(id: 'default', name: 'Default', price: price),
    );

    return tierPrice.price;
  }

  /// Copy with method for immutability
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? sku,
    String? barcode,
    String? description,
    String? categoryId,
    String? imageUrl,
    String? thumbnailUrl,
    bool? isActive,
    bool? isAvailable,
    bool? isFeatured,
    int? stockQuantity,
    int? lowStockThreshold,
    bool? trackInventory,
    bool? allowModifiers,
    List<ModifierGroup>? modifierGroups,
    List<ProductPrice>? prices,
    List<String>? tags,
    int? preparationTime,
    int? calories,
    List<String>? allergens,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      trackInventory: trackInventory ?? this.trackInventory,
      allowModifiers: allowModifiers ?? this.allowModifiers,
      modifierGroups: modifierGroups ?? this.modifierGroups,
      prices: prices ?? this.prices,
      tags: tags ?? this.tags,
      preparationTime: preparationTime ?? this.preparationTime,
      calories: calories ?? this.calories,
      allergens: allergens ?? this.allergens,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        sku,
        barcode,
        description,
        categoryId,
        imageUrl,
        thumbnailUrl,
        isActive,
        isAvailable,
        isFeatured,
        stockQuantity,
        lowStockThreshold,
        trackInventory,
        allowModifiers,
        modifierGroups,
        prices,
        tags,
        preparationTime,
        calories,
        allergens,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}
