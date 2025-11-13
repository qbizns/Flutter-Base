import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';

/// Product Overview Tab
///
/// Displays comprehensive product information in Odoo card layout
class ProductOverviewTab extends StatelessWidget {
  const ProductOverviewTab({
    required this.product,
    this.category,
    super.key,
  });

  final Product product;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Card
                    _buildImageCard(context),

                    const SizedBox(height: OdooSpacing.lg),

                    // Basic Information Card
                    _buildBasicInfoCard(),

                    const SizedBox(height: OdooSpacing.lg),

                    // Description Card
                    if (product.description != null) _buildDescriptionCard(),
                  ],
                ),
              ),

              const SizedBox(width: OdooSpacing.lg),

              // Right Column
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pricing Card
                    _buildPricingCard(),

                    const SizedBox(height: OdooSpacing.lg),

                    // Inventory Card
                    if (product.trackInventory) ...[
                      _buildInventoryCard(),
                      const SizedBox(height: OdooSpacing.lg),
                    ],

                    // Additional Info Card
                    _buildAdditionalInfoCard(),

                    const SizedBox(height: OdooSpacing.lg),

                    // Timestamps Card
                    _buildTimestampsCard(),
                  ],
                ),
              ),
            ],
          ),

          // Modifiers Card (full width at bottom)
          if (product.allowModifiers && product.modifierGroups.isNotEmpty) ...[
            const SizedBox(height: OdooSpacing.lg),
            _buildModifiersCard(),
          ],

          // Tags Card
          if (product.tags.isNotEmpty) ...[
            const SizedBox(height: OdooSpacing.lg),
            _buildTagsCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildImageCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Image',
              style: OdooTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: OdooColors.textPrimary,
              ),
            ),
            const SizedBox(height: OdooSpacing.md),
            Center(
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: OdooColors.gray100,
                  borderRadius:
                      BorderRadius.circular(OdooSpacing.radiusStandard),
                  border: Border.all(
                    color: OdooColors.border,
                    width: 1,
                  ),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(OdooSpacing.radiusStandard),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder(context);
                          },
                        ),
                      )
                    : _buildImagePlaceholder(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.fastfood,
          size: 80,
          color: OdooColors.gray400,
        ),
        const SizedBox(height: OdooSpacing.md),
        Text(
          'No image available',
          style: OdooTypography.bodyMedium.copyWith(
            color: OdooColors.textSecondary,
          ),
        ),
        const SizedBox(height: OdooSpacing.md),
        OutlinedButton.icon(
          onPressed: () => _handleImageUpload(context),
          icon: const Icon(Icons.upload),
          label: const Text('Upload Image'),
        ),
      ],
    );
  }

  Future<void> _handleImageUpload(BuildContext context) async {
    // TODO: Implement actual image upload to backend
    // For now, just show file picker dialog
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image selected: ${result.files.first.name}. Upload functionality to be implemented.',
            ),
            backgroundColor: OdooColors.info,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: OdooColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: OdooTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: OdooColors.textPrimary,
              ),
            ),
            const SizedBox(height: OdooSpacing.md),
            _buildInfoRow('Product Name', product.name),
            if (product.sku != null) _buildInfoRow('SKU', product.sku!),
            if (product.barcode != null)
              _buildInfoRow('Barcode', product.barcode!),
            if (category != null) _buildInfoRow('Category', category!.name),
            _buildInfoRow(
              'Status',
              product.isActive ? 'Active' : 'Inactive',
              valueColor: product.isActive
                  ? OdooColors.success
                  : OdooColors.textSecondary,
            ),
            _buildInfoRow(
              'Availability',
              product.isAvailable ? 'Available' : 'Unavailable',
              valueColor: product.isAvailable
                  ? OdooColors.success
                  : OdooColors.danger,
            ),
            if (product.isFeatured)
              _buildInfoRow(
                'Featured',
                'Yes',
                valueColor: OdooColors.warning,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: OdooTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: OdooColors.textPrimary,
              ),
            ),
            const SizedBox(height: OdooSpacing.md),
            Text(
              product.description!,
              style: OdooTypography.bodyMedium.copyWith(
                color: OdooColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard() {
    // Calculate profit margin if we had cost price
    // For now, just show pricing info
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing',
              style: OdooTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: OdooColors.textPrimary,
              ),
            ),
            const SizedBox(height: OdooSpacing.md),
            _buildPriceRow(
              'Base Price',
              product.price,
              isMain: true,
            ),
            if (product.prices.isNotEmpty) ...[
              const Divider(height: OdooSpacing.lg),
              Text(
                'Price Variations',
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: OdooSpacing.sm),
              ...product.prices.map(
                (priceVariation) => Padding(
                  padding: const EdgeInsets.only(bottom: OdooSpacing.xs),
                  child: _buildPriceRow(
                    priceVariation.name,
                    priceVariation.price,
                    isDefault: priceVariation.isDefault,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  size: OdooIconSizes.md,
                  color: OdooColors.primary,
                ),
                const SizedBox(width: OdooSpacing.sm),
                Text(
                  'Inventory',
                  style: OdooTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: OdooColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: OdooSpacing.md),
            _buildInfoRow(
              'Current Stock',
              product.stockQuantity?.toString() ?? 'N/A',
              valueColor: product.isLowStock
                  ? OdooColors.danger
                  : OdooColors.textPrimary,
            ),
            if (product.lowStockThreshold != null)
              _buildInfoRow(
                'Low Stock Threshold',
                product.lowStockThreshold.toString(),
              ),
            if (product.isLowStock)
              Container(
                margin: const EdgeInsets.only(top: OdooSpacing.sm),
                padding: const EdgeInsets.all(OdooSpacing.sm),
                decoration: BoxDecoration(
                  color: OdooColors.dangerLight,
                  borderRadius:
                      BorderRadius.circular(OdooSpacing.radiusStandard),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      size: OdooIconSizes.sm,
                      color: OdooColors.danger,
                    ),
                    const SizedBox(width: OdooSpacing.sm),
                    Expanded(
                      child: Text(
                        'Stock is running low!',
                        style: OdooTypography.bodySmall.copyWith(
                          color: OdooColors.danger,
                          fontWeight: FontWeight.w600,
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

  Widget _buildAdditionalInfoCard() {
    final hasAdditionalInfo = product.preparationTime != null ||
        product.calories != null ||
        product.allergens.isNotEmpty;

    if (!hasAdditionalInfo) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: OdooTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: OdooColors.textPrimary,
              ),
            ),
            const SizedBox(height: OdooSpacing.md),
            if (product.preparationTime != null)
              _buildInfoRow(
                'Preparation Time',
                '${product.preparationTime} min',
              ),
            if (product.calories != null)
              _buildInfoRow(
                'Calories',
                '${product.calories} kcal',
              ),
            if (product.allergens.isNotEmpty) ...[
              const SizedBox(height: OdooSpacing.sm),
              Text(
                'Allergens',
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: OdooSpacing.xs),
              Wrap(
                spacing: OdooSpacing.xs,
                runSpacing: OdooSpacing.xs,
                children: product.allergens.map((allergen) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OdooSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: OdooColors.warning.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(OdooSpacing.radiusStandard),
                      border: Border.all(
                        color: OdooColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      allergen,
                      style: OdooTypography.labelSmall.copyWith(
                        color: OdooColors.warning,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampsCard() {
    if (product.createdAt == null && product.updatedAt == null) {
      return const SizedBox.shrink();
    }

    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: OdooIconSizes.md,
                  color: OdooColors.textSecondary,
                ),
                const SizedBox(width: OdooSpacing.sm),
                Text(
                  'Timestamps',
                  style: OdooTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: OdooColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: OdooSpacing.md),
            if (product.createdAt != null)
              _buildInfoRow(
                'Created',
                dateFormat.format(product.createdAt!),
              ),
            if (product.updatedAt != null)
              _buildInfoRow(
                'Last Updated',
                dateFormat.format(product.updatedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModifiersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  size: OdooIconSizes.md,
                  color: OdooColors.primary,
                ),
                const SizedBox(width: OdooSpacing.sm),
                Text(
                  'Modifiers',
                  style: OdooTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: OdooColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: OdooSpacing.md),
            ...product.modifierGroups.map((group) {
              return Container(
                margin: const EdgeInsets.only(bottom: OdooSpacing.md),
                padding: const EdgeInsets.all(OdooSpacing.md),
                decoration: BoxDecoration(
                  color: OdooColors.gray50,
                  borderRadius:
                      BorderRadius.circular(OdooSpacing.radiusStandard),
                  border: Border.all(color: OdooColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: OdooTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: OdooColors.textPrimary,
                            ),
                          ),
                        ),
                        if (group.isRequired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: OdooSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: OdooColors.dangerLight,
                              borderRadius: BorderRadius.circular(
                                  OdooSpacing.radiusStandard),
                            ),
                            child: Text(
                              'Required',
                              style: OdooTypography.labelSmall.copyWith(
                                color: OdooColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: OdooSpacing.sm),
                    Text(
                      '${group.selectionType.name} selection',
                      style: OdooTypography.bodySmall.copyWith(
                        color: OdooColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: OdooSpacing.sm),
                    ...group.modifiers.map((modifier) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: OdooColors.textSecondary,
                            ),
                            const SizedBox(width: OdooSpacing.sm),
                            Expanded(
                              child: Text(
                                modifier.name,
                                style: OdooTypography.bodySmall.copyWith(
                                  color: OdooColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              modifier.price > 0
                                  ? '+\$${modifier.price.toStringAsFixed(2)}'
                                  : 'Free',
                              style: OdooTypography.bodySmall.copyWith(
                                color: modifier.price > 0
                                    ? OdooColors.primary
                                    : OdooColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.label,
                  size: OdooIconSizes.md,
                  color: OdooColors.info,
                ),
                const SizedBox(width: OdooSpacing.sm),
                Text(
                  'Tags',
                  style: OdooTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: OdooColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: OdooSpacing.md),
            Wrap(
              spacing: OdooSpacing.sm,
              runSpacing: OdooSpacing.sm,
              children: product.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OdooSpacing.md,
                    vertical: OdooSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: OdooColors.primary.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(OdooSpacing.radiusStandard),
                    border: Border.all(
                      color: OdooColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: OdooTypography.bodySmall.copyWith(
                      color: OdooColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OdooSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: OdooTypography.bodySmall.copyWith(
                color: OdooColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: OdooTypography.bodyMedium.copyWith(
                color: valueColor ?? OdooColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price,
      {bool isMain = false, bool isDefault = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OdooSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: (isMain
                        ? OdooTypography.bodyMedium
                        : OdooTypography.bodySmall)
                    .copyWith(
                  color: OdooColors.textSecondary,
                  fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (isDefault) ...[
                const SizedBox(width: OdooSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: OdooColors.successLight,
                    borderRadius:
                        BorderRadius.circular(OdooSpacing.radiusSmall),
                  ),
                  child: Text(
                    'Default',
                    style: OdooTypography.labelSmall.copyWith(
                      color: OdooColors.success,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style:
                (isMain ? OdooTypography.titleMedium : OdooTypography.bodyMedium)
                    .copyWith(
              color: OdooColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
