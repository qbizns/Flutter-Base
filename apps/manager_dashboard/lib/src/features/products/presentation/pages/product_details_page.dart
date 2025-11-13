import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_overview_tab.dart';
import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';

/// Product Details Page - Comprehensive view of a single product
///
/// Features:
/// - Product image with upload capability
/// - Complete product information
/// - Edit and delete actions
/// - Tabbed interface: Overview, Sales History, Inventory, Settings
/// - Odoo design compliance
class ProductDetailsPage extends ConsumerStatefulWidget {
  const ProductDetailsPage({
    required this.productId,
    super.key,
  });

  final String productId;

  @override
  ConsumerState<ProductDetailsPage> createState() =>
      _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));
    final categoriesAsync = ref.watch(categoriesProvider());

    return Container(
      color: OdooColors.backgroundLight,
      child: productAsync.when(
        data: (product) {
          // Find category if product has one
          Category? category;
          if (product.categoryId != null) {
            categoriesAsync.whenData((categories) {
              category = categories.firstWhere(
                (c) => c.id == product.categoryId,
                orElse: () => const Category(id: '', name: 'Unknown'),
              );
            });
          }

          return Column(
            children: [
              // Header
              _buildHeader(product, category),

              // Tabs
              _buildTabBar(),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Overview Tab
                    ProductOverviewTab(
                      product: product,
                      category: category,
                    ),

                    // Sales History Tab
                    _buildPlaceholderTab(
                      icon: Icons.trending_up,
                      title: 'Sales History',
                      description: 'View product sales performance and history',
                    ),

                    // Inventory Tab
                    _buildPlaceholderTab(
                      icon: Icons.inventory_2,
                      title: 'Inventory',
                      description: 'Manage stock levels and inventory tracking',
                    ),

                    // Settings Tab
                    _buildPlaceholderTab(
                      icon: Icons.settings,
                      title: 'Settings',
                      description: 'Advanced product settings and configurations',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: OdooColors.primary,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: OdooColors.danger,
              ),
              const SizedBox(height: OdooSpacing.md),
              Text(
                'Error loading product',
                style: OdooTypography.titleMedium.copyWith(
                  color: OdooColors.textPrimary,
                ),
              ),
              const SizedBox(height: OdooSpacing.sm),
              Text(
                error.toString(),
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OdooSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(productProvider(widget.productId));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Product product, Category? category) {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to Products',
          ),

          const SizedBox(width: OdooSpacing.md),

          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: OdooColors.gray100,
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
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
                        return Icon(
                          Icons.fastfood,
                          color: OdooColors.gray400,
                          size: OdooIconSizes.xl,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.fastfood,
                    color: OdooColors.gray400,
                    size: OdooIconSizes.xl,
                  ),
          ),

          const SizedBox(width: OdooSpacing.lg),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: OdooTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: OdooColors.textPrimary,
                  ),
                ),
                const SizedBox(height: OdooSpacing.xs),
                Row(
                  children: [
                    if (product.sku != null) ...[
                      Icon(
                        Icons.qr_code,
                        size: OdooIconSizes.sm,
                        color: OdooColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'SKU: ${product.sku}',
                        style: OdooTypography.bodyMedium.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: OdooSpacing.md),
                    ],
                    if (category != null) ...[
                      Icon(
                        Icons.category,
                        size: OdooIconSizes.sm,
                        color: OdooColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category.name,
                        style: OdooTypography.bodyMedium.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: OdooSpacing.sm),
                Row(
                  children: [
                    // Availability Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OdooSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.isAvailable
                            ? OdooColors.successLight
                            : OdooColors.gray200,
                        borderRadius:
                            BorderRadius.circular(OdooSpacing.radiusStandard),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            product.isAvailable
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: OdooIconSizes.sm,
                            color: product.isAvailable
                                ? OdooColors.success
                                : OdooColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.isAvailable ? 'Available' : 'Unavailable',
                            style: OdooTypography.labelMedium.copyWith(
                              color: product.isAvailable
                                  ? OdooColors.success
                                  : OdooColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (product.isFeatured) ...[
                      const SizedBox(width: OdooSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OdooSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: OdooColors.warning.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(OdooSpacing.radiusStandard),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: OdooIconSizes.sm,
                              color: OdooColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Featured',
                              style: OdooTypography.labelMedium.copyWith(
                                color: OdooColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (product.trackInventory && product.isLowStock) ...[
                      const SizedBox(width: OdooSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OdooSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: OdooColors.dangerLight,
                          borderRadius:
                              BorderRadius.circular(OdooSpacing.radiusStandard),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning,
                              size: OdooIconSizes.sm,
                              color: OdooColors.danger,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Low Stock',
                              style: OdooTypography.labelMedium.copyWith(
                                color: OdooColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: OdooTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: OdooColors.primary,
                ),
              ),
              Text(
                'Base Price',
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(width: OdooSpacing.xl),

          // Action Buttons
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showEditDialog(product),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              const SizedBox(width: OdooSpacing.md),
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(product),
                icon: Icon(
                  Icons.delete,
                  color: OdooColors.danger,
                ),
                label: Text(
                  'Delete',
                  style: TextStyle(color: OdooColors.danger),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: OdooColors.danger),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: OdooColors.primary,
        unselectedLabelColor: OdooColors.textSecondary,
        indicatorColor: OdooColors.primary,
        labelStyle: OdooTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.info_outline),
            text: 'Overview',
          ),
          Tab(
            icon: Icon(Icons.trending_up),
            text: 'Sales History',
          ),
          Tab(
            icon: Icon(Icons.inventory_2),
            text: 'Inventory',
          ),
          Tab(
            icon: Icon(Icons.settings),
            text: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: OdooColors.gray400,
          ),
          const SizedBox(height: OdooSpacing.lg),
          Text(
            title,
            style: OdooTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: OdooColors.textPrimary,
            ),
          ),
          const SizedBox(height: OdooSpacing.sm),
          Text(
            description,
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.md),
          Text(
            'Coming soon',
            style: OdooTypography.bodySmall.copyWith(
              color: OdooColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(Product product) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );

    if (result == true && mounted) {
      // Product was saved successfully, refresh the data
      ref.invalidate(productProvider(widget.productId));
      ref.invalidate(productsProvider);
    }
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: OdooColors.warning,
              size: OdooIconSizes.lg,
            ),
            const SizedBox(width: OdooSpacing.md),
            const Text('Delete Product'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this product?',
              style: OdooTypography.bodyMedium,
            ),
            const SizedBox(height: OdooSpacing.md),
            Container(
              padding: const EdgeInsets.all(OdooSpacing.md),
              decoration: BoxDecoration(
                color: OdooColors.dangerLight,
                borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: OdooColors.danger,
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: OdooTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: OdooColors.danger,
                          ),
                        ),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: OdooTypography.bodySmall.copyWith(
                            color: OdooColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OdooSpacing.md),
            Text(
              'This action cannot be undone.',
              style: OdooTypography.bodySmall.copyWith(
                color: OdooColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: FilledButton.styleFrom(
              backgroundColor: OdooColors.danger,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteProduct(product);
    }
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      final apiClient = ref.read(apiClientProvider);

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: OdooSpacing.md),
              const Text('Deleting product...'),
            ],
          ),
          duration: const Duration(seconds: 30),
        ),
      );

      // Delete via API
      await apiClient.delete('/products/${product.id}');

      // Refresh products list
      ref.invalidate(productsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} deleted successfully'),
            backgroundColor: OdooColors.success,
          ),
        );
        // Navigate back to products list
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: ${e.toString()}'),
            backgroundColor: OdooColors.danger,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
