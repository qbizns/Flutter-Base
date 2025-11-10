import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

/// Stock Levels Dashboard - Main inventory overview
///
/// Features:
/// - Current stock levels for all products
/// - Low stock alerts (visual indicators)
/// - Critical stock warnings
/// - Stock value summary
/// - Quick stock adjustment actions
/// - Search and filter by category
/// - Sort by name, stock level, or value
class StockLevelsPage extends ConsumerStatefulWidget {
  const StockLevelsPage({super.key});

  @override
  ConsumerState<StockLevelsPage> createState() => _StockLevelsPageState();
}

class _StockLevelsPageState extends ConsumerState<StockLevelsPage> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  String _sortBy = 'name'; // 'name', 'stock', 'value'

  // Stock thresholds (in a real app, these would come from settings)
  final int _lowStockThreshold = 10;
  final int _criticalStockThreshold = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider(categoryId: _selectedCategoryId));
    final categoriesAsync = ref.watch(categoriesProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Levels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(productsProvider);
            },
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'name',
                checked: _sortBy == 'name',
                child: const Text('Name'),
              ),
              CheckedPopupMenuItem(
                value: 'stock',
                checked: _sortBy == 'stock',
                child: const Text('Stock Level'),
              ),
              CheckedPopupMenuItem(
                value: 'value',
                checked: _sortBy == 'value',
                child: const Text('Stock Value'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(context),

          // Category filter
          categoriesAsync.when(
            data: (categories) => _buildCategoryFilter(context, categories),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(productsProvider);
              },
              child: productsAsync.when(
                data: (products) {
                  final filteredProducts = _filterAndSortProducts(products);
                  return _buildStockLevelsView(context, filteredProducts);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Error loading stock levels')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/stock-adjustment');
        },
        icon: const Icon(Icons.edit),
        label: const Text('Adjust Stock'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products...',
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, List<Category> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedCategoryId == null,
            onSelected: (selected) {
              setState(() {
                _selectedCategoryId = null;
              });
            },
          ),
          const SizedBox(width: 8),
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category.name),
                  selected: _selectedCategoryId == category.id,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = selected ? category.id : null;
                    });
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStockLevelsView(BuildContext context, List<Product> products) {
    final theme = Theme.of(context);

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    // Calculate summary metrics
    final lowStockCount = products
        .where((p) => _getStockLevel(p) <= _lowStockThreshold && _getStockLevel(p) > _criticalStockThreshold)
        .length;
    final criticalStockCount = products
        .where((p) => _getStockLevel(p) <= _criticalStockThreshold)
        .length;
    final totalStockValue = products.fold<double>(
      0,
      (sum, p) => sum + (p.price * _getStockLevel(p)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.inventory_2,
                  title: 'Total Items',
                  value: '${products.length}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.warning_amber,
                  title: 'Low Stock',
                  value: '$lowStockCount',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.error_outline,
                  title: 'Critical',
                  value: '$criticalStockCount',
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.attach_money,
                  title: 'Stock Value',
                  value: '\$${totalStockValue.toStringAsFixed(0)}',
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stock levels list
          if (criticalStockCount > 0) ...[
            _buildSectionHeader(
              context,
              'Critical Stock (${criticalStockCount})',
              Colors.red,
              Icons.error_outline,
            ),
            const SizedBox(height: 12),
            ...products
                .where((p) => _getStockLevel(p) <= _criticalStockThreshold)
                .map((product) => _buildStockCard(context, product)),
            const SizedBox(height: 24),
          ],

          if (lowStockCount > 0) ...[
            _buildSectionHeader(
              context,
              'Low Stock (${lowStockCount})',
              Colors.orange,
              Icons.warning_amber,
            ),
            const SizedBox(height: 12),
            ...products
                .where((p) =>
                    _getStockLevel(p) <= _lowStockThreshold &&
                    _getStockLevel(p) > _criticalStockThreshold)
                .map((product) => _buildStockCard(context, product)),
            const SizedBox(height: 24),
          ],

          _buildSectionHeader(
            context,
            'All Products (${products.length})',
            theme.colorScheme.primary,
            Icons.inventory_2,
          ),
          const SizedBox(height: 12),
          ...products.map((product) => _buildStockCard(context, product)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStockCard(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final stockLevel = _getStockLevel(product);
    final stockStatus = _getStockStatus(stockLevel);
    final stockValue = product.price * stockLevel;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        title: Text(
          product.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(product.category?.name ?? 'No category'),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockStatus.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        stockStatus.icon,
                        size: 14,
                        color: stockStatus.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$stockLevel units',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: stockStatus.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Value: \$${stockValue.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'per unit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'adjust':
                    // Navigate to stock adjustment
                    context.go('/stock-adjustment?productId=${product.id}');
                    break;
                  case 'history':
                    // Show stock history
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Stock history coming soon')),
                    );
                    break;
                  case 'reorder':
                    // Create purchase order
                    context.go('/purchase-orders/new?productId=${product.id}');
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'adjust',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Adjust Stock'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'history',
                  child: Row(
                    children: [
                      Icon(Icons.history),
                      SizedBox(width: 8),
                      Text('View History'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reorder',
                  child: Row(
                    children: [
                      Icon(Icons.add_shopping_cart),
                      SizedBox(width: 8),
                      Text('Reorder'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _filterAndSortProducts(List<Product> products) {
    var filtered = products;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.category?.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'stock':
        filtered.sort((a, b) => _getStockLevel(a).compareTo(_getStockLevel(b)));
        break;
      case 'value':
        filtered.sort((a, b) {
          final aValue = a.price * _getStockLevel(a);
          final bValue = b.price * _getStockLevel(b);
          return bValue.compareTo(aValue);
        });
        break;
    }

    return filtered;
  }

  // Helper to get stock level (placeholder - in real app would come from inventory data)
  int _getStockLevel(Product product) {
    // Simulating stock levels based on product ID
    // In a real app, this would query actual inventory records
    return product.trackInventory ? (product.id.hashCode % 50).abs() : 0;
  }

  StockStatus _getStockStatus(int stockLevel) {
    if (stockLevel <= _criticalStockThreshold) {
      return StockStatus(
        color: Colors.red,
        icon: Icons.error_outline,
        label: 'Critical',
      );
    } else if (stockLevel <= _lowStockThreshold) {
      return StockStatus(
        color: Colors.orange,
        icon: Icons.warning_amber,
        label: 'Low',
      );
    } else {
      return StockStatus(
        color: Colors.green,
        icon: Icons.check_circle,
        label: 'Good',
      );
    }
  }
}

// Helper class for stock status
class StockStatus {
  final Color color;
  final IconData icon;
  final String label;

  StockStatus({
    required this.color,
    required this.icon,
    required this.label,
  });
}
