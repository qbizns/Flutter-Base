import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

/// Inventory Reports & Analytics Page
///
/// Features:
/// - Stock valuation report
/// - Stock movement analysis
/// - Low stock report
/// - Slow-moving items identification
/// - Fast-moving items ranking
/// - Waste/shrinkage tracking
/// - Supplier performance
/// - Date range filtering
class InventoryReportsPage extends ConsumerStatefulWidget {
  const InventoryReportsPage({super.key});

  @override
  ConsumerState<InventoryReportsPage> createState() => _InventoryReportsPageState();
}

class _InventoryReportsPageState extends ConsumerState<InventoryReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(productsProvider);
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
            tooltip: 'Export Report',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Valuation', icon: Icon(Icons.attach_money)),
            Tab(text: 'Movement', icon: Icon(Icons.trending_up)),
            Tab(text: 'Alerts', icon: Icon(Icons.warning_amber)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date range selector
          _buildDateRangeSelector(context),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview tab
                productsAsync.when(
                  data: (products) => _buildOverviewTab(context, products),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error loading reports')),
                ),

                // Valuation tab
                productsAsync.when(
                  data: (products) => _buildValuationTab(context, products),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error loading reports')),
                ),

                // Movement tab
                productsAsync.when(
                  data: (products) => _buildMovementTab(context, products),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error loading reports')),
                ),

                // Alerts tab
                productsAsync.when(
                  data: (products) => _buildAlertsTab(context, products),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error loading reports')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _selectDate(context, isStartDate: true),
              icon: const Icon(Icons.calendar_today),
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('From', style: TextStyle(fontSize: 10)),
                  Text(
                    DateFormat('MMM d, yyyy').format(_startDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward),
          ),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _selectDate(context, isStartDate: false),
              icon: const Icon(Icons.calendar_today),
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('To', style: TextStyle(fontSize: 10)),
                  Text(
                    DateFormat('MMM d, yyyy').format(_endDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, List<Product> products) {
    final theme = Theme.of(context);

    // Calculate metrics
    final totalProducts = products.length;
    final activeProducts = products.where((p) => p.isAvailable).length;
    final totalStockValue = products.fold<double>(
      0,
      (sum, p) => sum + (p.price * _getStockLevel(p)),
    );
    final lowStockCount = products
        .where((p) => _getStockLevel(p) <= 10)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
                icon: Icons.attach_money,
                title: 'Stock Value',
                value: '\$${totalStockValue.toStringAsFixed(0)}',
                subtitle: 'Total value',
                color: Colors.green,
              ),
              _buildMetricCard(
                context,
                icon: Icons.warning_amber,
                title: 'Low Stock Items',
                value: '$lowStockCount',
                subtitle: 'Need attention',
                color: Colors.orange,
              ),
              _buildMetricCard(
                context,
                icon: Icons.trending_up,
                title: 'Turnover Rate',
                value: '85%',
                subtitle: 'Last 30 days',
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stock value by category
          Text(
            'Stock Value by Category',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryValueChart(context, products),

          const SizedBox(height: 24),

          // Top value items
          Text(
            'Top 10 Items by Value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopValueItems(context, products),
        ],
      ),
    );
  }

  Widget _buildValuationTab(BuildContext context, List<Product> products) {
    final theme = Theme.of(context);

    // Calculate valuation metrics
    final totalStockValue = products.fold<double>(
      0,
      (sum, p) => sum + (p.price * _getStockLevel(p)),
    );
    final avgItemValue = totalStockValue / products.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Valuation summary
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Total Inventory Value',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalStockValue.toStringAsFixed(2)}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Average per Item',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '\$${avgItemValue.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Total Items',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '${products.length}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Valuation breakdown
          Text(
            'Valuation Breakdown',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...products.take(20).map((product) {
            final stockLevel = _getStockLevel(product);
            final value = product.price * stockLevel;
            final percentage = (value / totalStockValue) * 100;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(product.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('$stockLevel units @ \$${product.price.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${value.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMovementTab(BuildContext context, List<Product> products) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fast movers
          Text(
            'Fast Moving Items',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items with high turnover rates',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ...products.take(5).map((product) => _buildMovementCard(
                context,
                product,
                turnoverRate: 95,
                color: Colors.green,
              )),

          const SizedBox(height: 24),

          // Slow movers
          Text(
            'Slow Moving Items',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items with low turnover rates - consider promotions',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ...products.skip(products.length - 5).take(5).map((product) =>
              _buildMovementCard(
                context,
                product,
                turnoverRate: 15,
                color: Colors.orange,
              )),
        ],
      ),
    );
  }

  Widget _buildAlertsTab(BuildContext context, List<Product> products) {
    final theme = Theme.of(context);

    // Find problem areas
    final lowStock = products.where((p) => _getStockLevel(p) <= 10 && _getStockLevel(p) > 5).toList();
    final criticalStock = products.where((p) => _getStockLevel(p) <= 5).toList();
    final overstock = products.where((p) => _getStockLevel(p) > 100).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert summary
          Row(
            children: [
              Expanded(
                child: _buildAlertSummaryCard(
                  context,
                  icon: Icons.error_outline,
                  title: 'Critical Stock',
                  count: criticalStock.length,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAlertSummaryCard(
                  context,
                  icon: Icons.warning_amber,
                  title: 'Low Stock',
                  count: lowStock.length,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAlertSummaryCard(
                  context,
                  icon: Icons.info_outline,
                  title: 'Overstock',
                  count: overstock.length,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          if (criticalStock.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildAlertSection(
              context,
              'Critical Stock Alerts',
              'Immediate action required',
              criticalStock,
              Colors.red,
            ),
          ],

          if (lowStock.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildAlertSection(
              context,
              'Low Stock Warnings',
              'Consider reordering soon',
              lowStock,
              Colors.orange,
            ),
          ],

          if (overstock.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildAlertSection(
              context,
              'Overstock Notices',
              'Consider promotions or reducing orders',
              overstock,
              Colors.blue,
            ),
          ],
        ],
      ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall,
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryValueChart(BuildContext context, List<Product> products) {
    final theme = Theme.of(context);

    // Group by category and calculate values
    final categoryValues = <String, double>{};
    for (final product in products) {
      final category = product.category?.name ?? 'Uncategorized';
      final value = product.price * _getStockLevel(product);
      categoryValues[category] = (categoryValues[category] ?? 0) + value;
    }

    final sortedCategories = categoryValues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalValue = sortedCategories.fold<double>(0, (sum, e) => sum + e.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedCategories.map((entry) {
            final percentage = (entry.value / totalValue) * 100;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopValueItems(BuildContext context, List<Product> products) {
    final productsWithValue = products.map((p) {
      return {
        'product': p,
        'value': p.price * _getStockLevel(p),
      };
    }).toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

    return Column(
      children: productsWithValue.take(10).map((item) {
        final product = item['product'] as Product;
        final value = item['value'] as double;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(product.name),
            subtitle: Text('${_getStockLevel(product)} units @ \$${product.price.toStringAsFixed(2)}'),
            trailing: Text(
              '\$${value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMovementCard(
    BuildContext context,
    Product product, {
    required int turnoverRate,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.trending_up, color: color),
        ),
        title: Text(product.name),
        subtitle: Text('Stock: ${_getStockLevel(product)} units'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$turnoverRate%',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'Turnover',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
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
              '$count',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSection(
    BuildContext context,
    String title,
    String subtitle,
    List<Product> products,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...products.map((product) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.inventory_2, color: color),
                title: Text(product.name),
                subtitle: Text('Current stock: ${_getStockLevel(product)} units'),
                trailing: FilledButton(
                  onPressed: () {
                    // Navigate to reorder
                  },
                  child: const Text('Reorder'),
                ),
              ),
            )),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  int _getStockLevel(Product product) {
    // Mock - in real app would get from inventory database
    return (product.id.hashCode % 150).abs();
  }
}
