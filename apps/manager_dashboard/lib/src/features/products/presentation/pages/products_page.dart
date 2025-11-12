import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_grid_card.dart';
import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';

/// Products Page - Product catalog management with full CRUD
///
/// Features:
/// - Grid view of all products
/// - Add/Edit/Delete products
/// - Search and category filter
/// - Backend API integration
/// - Odoo design compliance
class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider(categoryId: _selectedCategoryId));
    final categoriesAsync = ref.watch(categoriesProvider());

    return Container(
      color: OdooColors.backgroundLight,
      child: Column(
        children: [
          // Toolbar
          _buildToolbar(),

          // Search and Filters
          Container(
            padding: const EdgeInsets.all(OdooSpacing.lg),
            color: Colors.white,
            child: Column(
              children: [
                // Search bar
                _buildSearchBar(),

                const SizedBox(height: OdooSpacing.md),

                // Category filter
                categoriesAsync.when(
                  data: (categories) => _buildCategoryFilter(categories),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Products Grid/List
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filteredProducts = _filterProducts(products);

                if (filteredProducts.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productsProvider);
                  },
                  child: _isGridView
                      ? _buildGridView(filteredProducts)
                      : _buildListView(filteredProducts),
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
                      'Error loading products',
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
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.invalidate(productsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final productsAsync = ref.watch(productsProvider(categoryId: _selectedCategoryId));
    final productCount = productsAsync.maybeWhen(
      data: (products) => _filterProducts(products).length,
      orElse: () => 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.lg,
        vertical: OdooSpacing.md,
      ),
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
          // Title and count
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Products',
                style: OdooTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: OdooColors.textPrimary,
                ),
              ),
              Text(
                '$productCount products',
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),

          const Spacer(),

          // View toggle
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: OdooColors.border),
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isGridView = true;
                    });
                  },
                  icon: Icon(
                    Icons.grid_view,
                    color: _isGridView
                        ? OdooColors.primary
                        : OdooColors.textSecondary,
                  ),
                  tooltip: 'Grid view',
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: OdooColors.border,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isGridView = false;
                    });
                  },
                  icon: Icon(
                    Icons.view_list,
                    color: !_isGridView
                        ? OdooColors.primary
                        : OdooColors.textSecondary,
                  ),
                  tooltip: 'List view',
                ),
              ],
            ),
          ),

          const SizedBox(width: OdooSpacing.md),

          // Refresh button
          OutlinedButton.icon(
            onPressed: () {
              ref.invalidate(productsProvider);
              ref.invalidate(categoriesProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),

          const SizedBox(width: OdooSpacing.md),

          // Add product button
          FilledButton.icon(
            onPressed: () => _showProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search products by name or category...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildCategoryFilter(List<Category> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('All Categories'),
            selected: _selectedCategoryId == null,
            onSelected: (selected) {
              setState(() {
                _selectedCategoryId = null;
              });
            },
            backgroundColor: Colors.white,
            selectedColor: OdooColors.primary.withOpacity(0.1),
            checkmarkColor: OdooColors.primary,
          ),
          const SizedBox(width: OdooSpacing.sm),
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: OdooSpacing.sm),
                child: FilterChip(
                  label: Text(category.name),
                  selected: _selectedCategoryId == category.id,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = selected ? category.id : null;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: OdooColors.primary.withOpacity(0.1),
                  checkmarkColor: OdooColors.primary,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: OdooSpacing.lg,
        mainAxisSpacing: OdooSpacing.lg,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductGridCard(
          product: product,
          onTap: () {
            // TODO: Navigate to product details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product: ${product.name}')),
            );
          },
          onEdit: () => _showProductDialog(product: product),
          onDelete: () => _confirmDelete(product),
        );
      },
    );
  }

  Widget _buildListView(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: OdooSpacing.md),
          child: ListTile(
            contentPadding: const EdgeInsets.all(OdooSpacing.md),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: OdooColors.gray100,
                borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              ),
              child: Icon(
                Icons.fastfood,
                color: OdooColors.gray400,
                size: OdooIconSizes.lg,
              ),
            ),
            title: Text(
              product.name,
              style: OdooTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: OdooSpacing.xs),
                Text(
                  product.category?.name ?? 'No category',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
                const SizedBox(height: OdooSpacing.xs),
                Row(
                  children: [
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
                    if (product.trackInventory) ...[
                      const SizedBox(width: OdooSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OdooSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: OdooColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            OdooSpacing.radiusStandard,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 12,
                              color: OdooColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tracked',
                              style: OdooTypography.labelSmall.copyWith(
                                color: OdooColors.warning,
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: OdooTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: OdooColors.primary,
                      ),
                    ),
                    if (product.sku != null)
                      Text(
                        'SKU: ${product.sku}',
                        style: OdooTypography.bodySmall.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: OdooSpacing.md),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: OdooIconSizes.sm),
                          const SizedBox(width: OdooSpacing.sm),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: OdooIconSizes.sm,
                            color: OdooColors.danger,
                          ),
                          const SizedBox(width: OdooSpacing.sm),
                          Text(
                            'Delete',
                            style: TextStyle(color: OdooColors.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showProductDialog(product: product);
                    } else if (value == 'delete') {
                      _confirmDelete(product);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 120,
            color: OdooColors.gray400,
          ),
          const SizedBox(height: OdooSpacing.xl),
          Text(
            _searchQuery.isNotEmpty
                ? 'No products found'
                : 'No products yet',
            style: OdooTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: OdooColors.textPrimary,
            ),
          ),
          const SizedBox(height: OdooSpacing.md),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Start by adding your first product',
            style: OdooTypography.bodyLarge.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.xxl),
          FilledButton.icon(
            onPressed: () {
              if (_searchQuery.isNotEmpty) {
                setState(() {
                  _searchQuery = '';
                  _selectedCategoryId = null;
                });
              } else {
                _showProductDialog();
              }
            },
            icon: Icon(_searchQuery.isNotEmpty ? Icons.clear : Icons.add),
            label: Text(
              _searchQuery.isNotEmpty ? 'Clear Filters' : 'Add First Product',
            ),
          ),
        ],
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.category?.name ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (product.sku ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  Future<void> _showProductDialog({Product? product}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );

    if (result == true && mounted) {
      // Product was saved successfully
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
