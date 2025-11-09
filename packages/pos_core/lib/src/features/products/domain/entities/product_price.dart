import 'package:equatable/equatable.dart';

/// Product price variation (size, time-based, etc.)
///
/// Represents different pricing tiers for a product.
/// Examples: Small/Medium/Large, Happy Hour pricing, Lunch/Dinner pricing
class ProductPrice extends Equatable {
  const ProductPrice({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.sku,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  /// Unique identifier for this price tier
  final String id;

  /// Price tier name (e.g., "Small", "Medium", "Large")
  final String name;

  /// Price for this tier
  final double price;

  /// Optional description
  final String? description;

  /// Optional SKU for this price variation
  final String? sku;

  /// Is this the default price
  final bool isDefault;

  /// Sort order for display
  final int sortOrder;

  /// Copy with method for immutability
  ProductPrice copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? sku,
    bool? isDefault,
    int? sortOrder,
  }) {
    return ProductPrice(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        description,
        sku,
        isDefault,
        sortOrder,
      ];
}
