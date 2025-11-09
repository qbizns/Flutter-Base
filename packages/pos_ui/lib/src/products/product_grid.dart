import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';
import 'product_card.dart';

/// Grid layout for displaying products.
///
/// Supports responsive column count and product selection.
class ProductGrid extends StatelessWidget {
  const ProductGrid({
    required this.products,
    this.onProductTap,
    this.selectedProductId,
    this.crossAxisCount,
    this.compact = false,
    this.loading = false,
    super.key,
  });

  final List<Product> products;
  final void Function(Product)? onProductTap;
  final String? selectedProductId;
  final int? crossAxisCount;
  final bool compact;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No products available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    final effectiveCrossAxisCount = crossAxisCount ?? _getResponsiveColumns(context);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: effectiveCrossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: compact ? 1.0 : 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => onProductTap?.call(product),
          selected: product.id == selectedProductId,
          compact: compact,
        );
      },
    );
  }

  int _getResponsiveColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }
}
