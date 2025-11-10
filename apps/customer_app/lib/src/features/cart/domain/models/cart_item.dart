import 'package:pos_core/pos_core.dart';

/// Cart Item Model
///
/// Represents a product in the shopping cart with quantity
class CartItem {
  final Product product;
  final int quantity;
  final String? specialInstructions;

  const CartItem({
    required this.product,
    required this.quantity,
    this.specialInstructions,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? specialInstructions,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          product.id == other.id;

  @override
  int get hashCode => product.id.hashCode;
}
