import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Tile widget for displaying an order item.
///
/// Shows item details, modifiers, quantity controls, and price.
class OrderItemTile extends StatelessWidget {
  const OrderItemTile({
    required this.item,
    this.onQuantityChanged,
    this.onRemove,
    this.showQuantityControls = true,
    super.key,
  });

  final OrderItem item;
  final void Function(int)? onQuantityChanged;
  final VoidCallback? onRemove;
  final bool showQuantityControls;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quantity Badge or Display
        if (showQuantityControls && onQuantityChanged != null)
          _buildQuantityControls(theme)
        else
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}x',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        const SizedBox(width: 12),

        // Item Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              Text(
                item.productName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Modifiers
              if (item.selectedModifiers.isNotEmpty) ...[
                const SizedBox(height: 4),
                ...item.selectedModifiers.map(
                  (modifier) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '+ ${modifier.modifierName}${modifier.price > 0 ? " (+\$${modifier.price.toStringAsFixed(2)})" : ""}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ],

              // Notes
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              // Price Breakdown
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '\$${item.unitPrice.toStringAsFixed(2)} each',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (item.totalDiscount > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '-\$${item.totalDiscount.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Price and Remove
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${item.total.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: theme.colorScheme.error,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityControls(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          onPressed: item.quantity > 1 ? () => onQuantityChanged!(item.quantity - 1) : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '${item.quantity}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onPressed: () => onQuantityChanged!(item.quantity + 1),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
