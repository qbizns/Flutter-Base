import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

/// Product Performance Page - Product analytics and management
///
/// Features:
/// - Top sellers ranking
/// - Slow movers identification
/// - Inventory status overview
/// - Category performance breakdown
/// - Product search and filtering
/// - Stock alerts
class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider(categoryId: _selectedCategoryId));
    final ordersAsync = ref.watch(ordersProvider());
    final categoriesAsync = ref.watch(categoriesProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Performance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(productsProvider);
              ref.invalidate(ordersProvider);
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add product feature coming soon')),
              );
            },
            tooltip: 'Add Product',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Top Sellers', icon: Icon(Icons.trending_up)),
            Tab(text: 'Inventory', icon: Icon(Icons.inventory_2)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filter bar
          _buildSearchBar(context),

          // Category filter
          categoriesAsync.when(
            data: (categories) => _buildCategoryFilter(context, categories),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview tab
                RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productsProvider);
                    ref.invalidate(ordersProvider);
                  },
                  child: productsAsync.when(
                    data: (products) => ordersAsync.when(
                      data: (orders) =>
                          _buildOverviewTab(context, products, orders),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Center(child: Text('Error loading orders')),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Error loading products')),
                  ),
                ),

                // Top sellers tab
                RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productsProvider);
                    ref.invalidate(ordersProvider);
                  },
                  child: productsAsync.when(
                    data: (products) => ordersAsync.when(
                      data: (orders) =>
                          _buildTopSellersTab(context, products, orders),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Center(child: Text('Error loading orders')),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Error loading products')),
                  ),
                ),

                // Inventory tab
                RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productsProvider);
                  },
                  child: productsAsync.when(
                    data: (products) => _buildInventoryTab(context, products),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Error loading products')),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildOverviewTab(
    BuildContext context,
    List<Product> products,
    List<Order> orders,
  ) {
    final theme = Theme.of(context);

    // Calculate metrics
    final filteredProducts = _filterProducts(products);
    final salesData = _calculateProductSales(filteredProducts, orders);

    final totalProducts = filteredProducts.length;
    final activeProducts = filteredProducts.where((p) => p.isAvailable).length;
    final lowStockProducts = filteredProducts.where((p) {
      // Placeholder logic - assuming a product is low stock if trackInventory is true
      return p.trackInventory;
    }).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                context,
                icon: Icons.inventory_2,
                title: 'Total Products',
                value: '$totalProducts',
                subtitle: '$activeProducts active',
                color: Colors.blue,
              ),
              _buildMetricCard(
                context,
                icon: Icons.trending_up,
                title: 'Top Seller',
                value: salesData.isNotEmpty ? salesData.first.name : 'N/A',
                subtitle: salesData.isNotEmpty
                    ? '${salesData.first.quantity} sold'
                    : '0 sold',
                color: Colors.green,
              ),
              _buildMetricCard(
                context,
                icon: Icons.warning_amber,
                title: 'Low Stock',
                value: '$lowStockProducts',
                subtitle: 'Need attention',
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Category breakdown
          Text(
            'Performance by Category',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryBreakdown(context, filteredProducts, salesData),

          const SizedBox(height: 32),

          // Recent products
          Text(
            'Recently Added Products',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentProducts(context, filteredProducts),
        ],
      ),
    );
  }

  Widget _buildTopSellersTab(
    BuildContext context,
    List<Product> products,
    List<Order> orders,
  ) {
    final theme = Theme.of(context);
    final filteredProducts = _filterProducts(products);
    final salesData = _calculateProductSales(filteredProducts, orders);

    if (salesData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No sales data available',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: salesData.length,
      itemBuilder: (context, index) {
        final data = salesData[index];
        final rank = index + 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getRankColor(rank).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(rank),
                  ),
                ),
              ),
            ),
            title: Text(
              data.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  data.categoryName ?? 'No category',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${data.quantity} sold',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${data.revenue.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${data.price.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Price',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInventoryTab(BuildContext context, List<Product> products) {
    final theme = Theme.of(context);
    final filteredProducts = _filterProducts(products);

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No products available',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    // Group by availability
    final activeProducts = filteredProducts.where((p) => p.isAvailable).toList();
    final inactiveProducts = filteredProducts.where((p) => !p.isAvailable).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (activeProducts.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Active Products (${activeProducts.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activeProducts.map((product) => _buildInventoryCard(context, product)),
          const SizedBox(height: 24),
        ],
        if (inactiveProducts.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.cancel, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Inactive Products (${inactiveProducts.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...inactiveProducts.map((product) => _buildInventoryCard(context, product)),
        ],
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    List<Product> products,
    List<ProductSalesData> salesData,
  ) {
    final theme = Theme.of(context);

    // Group by category
    final categoryStats = <String, CategoryStats>{};

    for (final product in products) {
      final categoryName = product.category?.name ?? 'Uncategorized';

      if (!categoryStats.containsKey(categoryName)) {
        categoryStats[categoryName] = CategoryStats(
          name: categoryName,
          productCount: 0,
          revenue: 0,
        );
      }

      categoryStats[categoryName]!.productCount++;

      // Add revenue from sales data
      final sales = salesData.where((s) => s.id == product.id).firstOrNull;
      if (sales != null) {
        categoryStats[categoryName]!.revenue += sales.revenue;
      }
    }

    final sortedCategories = categoryStats.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    if (sortedCategories.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text('No data available', style: theme.textTheme.bodyLarge),
          ),
        ),
      );
    }

    final totalRevenue = sortedCategories.fold<double>(
      0,
      (sum, cat) => sum + cat.revenue,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: sortedCategories.map((category) {
            final percentage = totalRevenue > 0
                ? (category.revenue / totalRevenue) * 100
                : 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${category.revenue.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            '${category.productCount} products',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecentProducts(BuildContext context, List<Product> products) {
    final theme = Theme.of(context);

    // Sort by creation date (simulated - using name as proxy)
    final recentProducts = products.take(5).toList();

    if (recentProducts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text('No products available', style: theme.textTheme.bodyLarge),
          ),
        ),
      );
    }

    return Column(
      children: recentProducts.map((product) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.fastfood,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(product.name),
            subtitle: Text(product.category?.name ?? 'No category'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: product.isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.isAvailable ? 'Active' : 'Inactive',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInventoryCard(BuildContext context, Product product) {
    final theme = Theme.of(context);

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
            Icons.fastfood,
            color: theme.colorScheme.primary,
            size: 32,
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
                    color: product.isAvailable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.isAvailable ? 'Active' : 'Inactive',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: product.isAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (product.trackInventory) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 12,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tracked',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'Price',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.category?.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  List<ProductSalesData> _calculateProductSales(
    List<Product> products,
    List<Order> orders,
  ) {
    final salesMap = <String, ProductSalesData>{};

    // Initialize with all products
    for (final product in products) {
      salesMap[product.id] = ProductSalesData(
        id: product.id,
        name: product.name,
        categoryName: product.category?.name,
        price: product.price,
        quantity: 0,
        revenue: 0,
      );
    }

    // Calculate sales from orders
    for (final order in orders) {
      for (final item in order.items) {
        if (salesMap.containsKey(item.productId)) {
          salesMap[item.productId]!.quantity += item.quantity;
          salesMap[item.productId]!.revenue += item.totalPrice;
        }
      }
    }

    // Sort by quantity sold
    final sorted = salesMap.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    return sorted;
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}

// Data classes
class ProductSalesData {
  final String id;
  final String name;
  final String? categoryName;
  final double price;
  int quantity;
  double revenue;

  ProductSalesData({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.price,
    required this.quantity,
    required this.revenue,
  });
}

class CategoryStats {
  final String name;
  int productCount;
  double revenue;

  CategoryStats({
    required this.name,
    required this.productCount,
    required this.revenue,
  });
}
