import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';
import 'order_item_tile.dart';

/// Panel widget for displaying the shopping cart.
///
/// Shows cart items, totals, and checkout button.
class CartPanel extends StatelessWidget {
  const CartPanel({
    required this.cart,
    this.onItemQuantityChanged,
    this.onItemRemoved,
    this.onCheckout,
    this.onClear,
    super.key,
  });

  final Cart cart;
  final void Function(OrderItem, int)? onItemQuantityChanged;
  final void Function(OrderItem)? onItemRemoved;
  final VoidCallback? onCheckout;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Order',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (cart.isNotEmpty && onClear != null)
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Clear'),
                  ),
              ],
            ),
          ),

          // Cart Items
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cart is empty',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add items to get started',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return OrderItemTile(
                        item: item,
                        onQuantityChanged: onItemQuantityChanged != null
                            ? (newQty) => onItemQuantityChanged!(item, newQty)
                            : null,
                        onRemove: onItemRemoved != null ? () => onItemRemoved!(item) : null,
                      );
                    },
                  ),
          ),

          // Cart Summary
          if (cart.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    'Subtotal',
                    '\$${cart.subtotal.toStringAsFixed(2)}',
                  ),
                  if (cart.cartDiscount > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      context,
                      'Discount',
                      '-\$${cart.cartDiscount.toStringAsFixed(2)}',
                      color: theme.colorScheme.error,
                    ),
                  ],
                  if (cart.taxAmount > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      context,
                      'Tax',
                      '\$${cart.taxAmount.toStringAsFixed(2)}',
                    ),
                  ],
                  if (cart.tipAmount > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      context,
                      'Tip',
                      '\$${cart.tipAmount.toStringAsFixed(2)}',
                    ),
                  ],
                  const Divider(height: 24),
                  _buildSummaryRow(
                    context,
                    'Total',
                    '\$${cart.total.toStringAsFixed(2)}',
                    bold: true,
                    large: true,
                  ),
                ],
              ),
            ),

            // Checkout Button
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: onCheckout,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment),
                      const SizedBox(width: 8),
                      Text(
                        'Checkout (${cart.itemsCount} items)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool bold = false,
    bool large = false,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (large ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)?.copyWith(
            fontWeight: bold ? FontWeight.bold : null,
          ),
        ),
        Text(
          value,
          style: (large ? theme.textTheme.titleLarge : theme.textTheme.bodyLarge)?.copyWith(
            fontWeight: bold ? FontWeight.bold : null,
            color: color,
          ),
        ),
      ],
    );
  }
}
