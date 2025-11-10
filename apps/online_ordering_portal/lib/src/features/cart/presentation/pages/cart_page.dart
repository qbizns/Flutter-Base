import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Cart Page
///
/// Shopping cart with order summary and checkout.
/// Features:
/// - Cart item management (add, remove, quantity)
/// - Order type selection (delivery, pickup, dine-in)
/// - Promo code application
/// - Order summary with taxes and fees
/// - Checkout flow
class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  OrderType _orderType = OrderType.delivery;
  final TextEditingController _promoCodeController = TextEditingController();
  String? _appliedPromo;

  // Mock cart data
  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      name: 'Classic Burger',
      price: 12.99,
      quantity: 2,
      specialInstructions: 'No onions',
    ),
    CartItem(
      id: '2',
      name: 'Margherita Pizza',
      price: 14.99,
      quantity: 1,
      specialInstructions: '',
    ),
    CartItem(
      id: '3',
      name: 'Caesar Salad',
      price: 9.99,
      quantity: 1,
      specialInstructions: 'Extra dressing on the side',
    ),
  ];

  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get _tax {
    return _subtotal * 0.08; // 8% tax
  }

  double get _deliveryFee {
    if (_orderType == OrderType.delivery) {
      return _subtotal >= 50.0 ? 0.0 : 4.99;
    }
    return 0.0;
  }

  double get _discount {
    if (_appliedPromo == 'SAVE10') {
      return _subtotal * 0.10;
    }
    return 0.0;
  }

  double get _total {
    return _subtotal + _tax + _deliveryFee - _discount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    if (_cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 120,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'Your cart is empty',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Browse Menu'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: _clearCart,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear'),
            ),
        ],
      ),
      body: isWideScreen
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildCartItems(theme),
                ),
                SizedBox(
                  width: 400,
                  child: _buildOrderSummary(theme),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildCartItems(theme)),
                _buildOrderSummary(theme),
              ],
            ),
    );
  }

  Widget _buildCartItems(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Order type selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Type',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<OrderType>(
                  segments: const [
                    ButtonSegment(
                      value: OrderType.delivery,
                      label: Text('Delivery'),
                      icon: Icon(Icons.delivery_dining),
                    ),
                    ButtonSegment(
                      value: OrderType.pickup,
                      label: Text('Pickup'),
                      icon: Icon(Icons.shopping_bag),
                    ),
                    ButtonSegment(
                      value: OrderType.dineIn,
                      label: Text('Dine-In'),
                      icon: Icon(Icons.restaurant),
                    ),
                  ],
                  selected: {_orderType},
                  onSelectionChanged: (Set<OrderType> newSelection) {
                    setState(() {
                      _orderType = newSelection.first;
                    });
                  },
                ),
                if (_orderType == OrderType.delivery) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _subtotal >= 50.0
                                ? 'Free delivery on orders over \$50!'
                                : 'Add \$${(50.0 - _subtotal).toStringAsFixed(2)} for free delivery',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Cart items
        Text(
          'Items (${_cartItems.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._cartItems.map((item) => _buildCartItemCard(theme, item)),

        const SizedBox(height: 16),

        // Promo code
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promo Code',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoCodeController,
                        decoration: const InputDecoration(
                          hintText: 'Enter code',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        enabled: _appliedPromo == null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _appliedPromo == null
                        ? FilledButton(
                            onPressed: _applyPromoCode,
                            child: const Text('Apply'),
                          )
                        : FilledButton.tonal(
                            onPressed: _removePromoCode,
                            child: const Text('Remove'),
                          ),
                  ],
                ),
                if (_appliedPromo != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Promo code "$_appliedPromo" applied!',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(ThemeData theme, CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restaurant,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 12),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(item.price),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.specialInstructions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.specialInstructions,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Quantity controls
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _decrementQuantity(item),
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 28,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _incrementQuantity(item),
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 28,
                    ),
                  ],
                ),
                Text(
                  NumberFormat.currency(symbol: '\$').format(item.price * item.quantity),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal', _subtotal),
            const SizedBox(height: 8),
            _buildSummaryRow('Tax', _tax),
            if (_orderType == OrderType.delivery) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('Delivery Fee', _deliveryFee),
            ],
            if (_discount > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('Discount', -_discount, isDiscount: true),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  NumberFormat.currency(symbol: '\$').format(_total),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _proceedToCheckout,
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Proceed to Checkout'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Continue Shopping'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          NumberFormat.currency(symbol: '\$').format(amount.abs()),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.green : null,
          ),
        ),
      ],
    );
  }

  void _incrementQuantity(CartItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void _decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      setState(() {
        item.quantity--;
      });
    } else {
      _removeItem(item);
    }
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cartItems.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed from cart'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _cartItems.add(item);
            });
          },
        ),
      ),
    );
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _cartItems.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _applyPromoCode() {
    final code = _promoCodeController.text.trim().toUpperCase();
    if (code == 'SAVE10') {
      setState(() {
        _appliedPromo = code;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promo code applied! 10% discount'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid promo code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removePromoCode() {
    setState(() {
      _appliedPromo = null;
      _promoCodeController.clear();
    });
  }

  void _proceedToCheckout() {
    // Navigate to checkout page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proceeding to checkout...')),
    );
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }
}

// Models
class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String specialInstructions;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.specialInstructions,
  });
}

enum OrderType {
  delivery,
  pickup,
  dineIn,
}
