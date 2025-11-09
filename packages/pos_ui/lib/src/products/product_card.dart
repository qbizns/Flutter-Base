import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Product card widget for displaying product information.
///
/// Shows product image, name, price, and availability status.
/// Supports tap callback for selection.
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    this.onTap,
    this.selected = false,
    this.compact = false,
    super.key,
  });

  final Product product;
  final VoidCallback? onTap;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = product.isAvailable && product.isInStock;

    return Card(
      elevation: selected ? 4 : 1,
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: Padding(
            padding: EdgeInsets.all(compact ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                if (product.imageUrl != null) ...[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder(theme);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 8),
                ] else ...[
                  Expanded(child: _buildPlaceholder(theme)),
                  SizedBox(height: compact ? 6 : 8),
                ],

                // Product Name
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: selected ? theme.colorScheme.onPrimaryContainer : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (!compact && product.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 8),

                // Price and Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: selected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Status Badge
                    if (!isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Out',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      )
                    else if (product.isLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Low',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.fastfood,
        size: compact ? 32 : 48,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
