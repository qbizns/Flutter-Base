import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';
import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';

/// Product Grid Card
///
/// Card widget for displaying product in grid view with Odoo styling
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image or Placeholder
            _buildImage(),

            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(OdooSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: OdooTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: OdooColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: OdooSpacing.xs),

                    // SKU or placeholder
                    if (product.sku != null)
                      Text(
                        'SKU: ${product.sku}',
                        style: OdooTypography.bodySmall.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const Spacer(),

                    // Price and Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: OdooTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: OdooColors.primary,
                          ),
                        ),

                        // Availability Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OdooSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: product.isAvailable
                                ? OdooColors.successLight
                                : OdooColors.gray200,
                            borderRadius: BorderRadius.circular(
                              OdooSpacing.radiusStandard,
                            ),
                          ),
                          child: Text(
                            product.isAvailable ? 'Active' : 'Inactive',
                            style: OdooTypography.labelSmall.copyWith(
                              color: product.isAvailable
                                  ? OdooColors.success
                                  : OdooColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: OdooColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: OdooSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: OdooIconSizes.sm,
                              color: OdooColors.info,
                            ),
                            const SizedBox(width: OdooSpacing.xs),
                            Text(
                              'Edit',
                              style: OdooTypography.labelMedium.copyWith(
                                color: OdooColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: OdooColors.border,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: OdooSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: OdooIconSizes.sm,
                              color: OdooColors.danger,
                            ),
                            const SizedBox(width: OdooSpacing.xs),
                            Text(
                              'Delete',
                              style: OdooTypography.labelMedium.copyWith(
                                color: OdooColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // TODO: Replace with actual product image when image upload is implemented
    return Container(
      height: 150,
      color: OdooColors.gray100,
      child: Center(
        child: Icon(
          Icons.fastfood,
          size: 64,
          color: OdooColors.gray400,
        ),
      ),
    );
  }
}
