import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

/// Cart Page - Review and edit order
///
/// Features:
/// - Large item cards with images
/// - Quantity controls (large buttons)
/// - Item removal
/// - Order summary (subtotal, tax, total)
/// - Proceed to checkout button
/// - Back to menu button
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartNotifierProvider);

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Order'),
        ),
        body: _buildEmptyCart(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Your Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => context.go('/menu'),
          tooltip: 'Back to Menu',
        ),
      ),
      body: Column(
        children: [
          // Items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return _buildCartItemCard(context, ref, item);
              },
            ),
          ),

          // Order summary and checkout
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Summary rows
                _buildSummaryRow(
                  context,
                  'Subtotal',
                  '\$${cart.subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  context,
                  'Tax',
                  '\$${cart.taxAmount.toStringAsFixed(2)}',
                ),
                const Divider(height: 32),
                _buildSummaryRow(
                  context,
                  'Total',
                  '\$${cart.total.toStringAsFixed(2)}',
                  isTotal: true,
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/menu'),
                        icon: const Icon(Icons.add_shopping_cart, size: 28),
                        label: const Text('Add More Items'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          textStyle: theme.textTheme.titleLarge,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: () => context.go('/checkout'),
                        icon: const Icon(Icons.payment, size: 28),
                        label: Text(
                          'Proceed to Checkout - \$${cart.total.toStringAsFixed(2)}',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          textStyle: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 32),
          Text(
            'Your cart is empty',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add items from the menu to get started',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: 400,
            height: 80,
            child: FilledButton.icon(
              onPressed: () => context.go('/menu'),
              icon: const Icon(Icons.restaurant_menu, size: 32),
              label: const Text('Browse Menu'),
              style: FilledButton.styleFrom(
                textStyle: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    WidgetRef ref,
    OrderItem item,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Product image placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restaurant,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 24),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.selectedModifiers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...item.selectedModifiers.map((mod) => Text(
                          '+ ${mod.modifierName}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        )),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity controls
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (item.quantity > 1) {
                        ref.read(cartNotifierProvider.notifier).updateQuantity(
                              item.id,
                              item.quantity - 1,
                            );
                      } else {
                        _confirmRemove(context, ref, item);
                      }
                    },
                    icon: Icon(
                      item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                      size: 32,
                    ),
                    tooltip: item.quantity > 1 ? 'Decrease' : 'Remove',
                    padding: const EdgeInsets.all(16),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 60),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(cartNotifierProvider.notifier).updateQuantity(
                            item.id,
                            item.quantity + 1,
                          );
                    },
                    icon: const Icon(Icons.add, size: 32),
                    tooltip: 'Increase',
                    padding: const EdgeInsets.all(16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    final style = isTotal
        ? theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          )
        : theme.textTheme.headlineSmall;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style?.copyWith(
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    OrderItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item?'),
        content: Text('Remove ${item.productName} from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 18),
              padding: const EdgeInsets.all(20),
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              textStyle: const TextStyle(fontSize: 18),
              padding: const EdgeInsets.all(20),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(cartNotifierProvider.notifier).removeItem(item.id);
    }
  }
}
