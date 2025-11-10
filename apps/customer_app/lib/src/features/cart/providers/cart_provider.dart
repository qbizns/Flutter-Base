import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../domain/models/cart_item.dart';

/// Cart State
class CartState {
  final List<CartItem> items;

  const CartState({
    this.items = const [],
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * 0.08; // 8% tax

  double get deliveryFee => subtotal > 0 ? 3.99 : 0.0;

  double get total => subtotal + tax + deliveryFee;

  CartState copyWith({
    List<CartItem>? items,
  }) {
    return CartState(
      items: items ?? this.items,
    );
  }
}

/// Cart Notifier
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  /// Add item to cart
  void addItem(Product product, {int quantity = 1, String? specialInstructions}) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Update existing item
      final items = [...state.items];
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + quantity,
        specialInstructions: specialInstructions,
      );
      state = state.copyWith(items: items);
    } else {
      // Add new item
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            product: product,
            quantity: quantity,
            specialInstructions: specialInstructions,
          ),
        ],
      );
    }
  }

  /// Update item quantity
  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      removeItem(product);
      return;
    }

    final items = state.items.map((item) {
      if (item.product.id == product.id) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: items);
  }

  /// Remove item from cart
  void removeItem(Product product) {
    final items = state.items.where(
      (item) => item.product.id != product.id,
    ).toList();

    state = state.copyWith(items: items);
  }

  /// Clear cart
  void clear() {
    state = const CartState();
  }

  /// Get item quantity
  int getItemQuantity(Product product) {
    final item = state.items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    return item.quantity;
  }
}

/// Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
