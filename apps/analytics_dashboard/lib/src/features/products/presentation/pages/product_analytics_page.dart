import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Product Analytics Page
///
/// Features:
/// - Best/worst sellers ranking
/// - Product performance trends
/// - Category performance comparison
/// - Product profitability analysis
/// - Low stock performers
class ProductAnalyticsPage extends ConsumerStatefulWidget {
  const ProductAnalyticsPage({super.key});

  @override
  ConsumerState<ProductAnalyticsPage> createState() =>
      _ProductAnalyticsPageState();
}

class _ProductAnalyticsPageState extends ConsumerState<ProductAnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Performance'),
            Tab(text: 'Categories'),
            Tab(text: 'Profitability'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPerformanceTab(theme),
          _buildCategoriesTab(theme),
          _buildProfitabilityTab(theme),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Best Sellers
        Text(
          'Top Performing Products',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildProductRankingCard(
          theme,
          'Best Sellers',
          [
            {
              'name': 'Classic Burger',
              'sales': 1245,
              'revenue': 12450.0,
              'trend': 12.5
            },
            {
              'name': 'Margherita Pizza',
              'sales': 1089,
              'revenue': 10890.0,
              'trend': 8.3
            },
            {
              'name': 'Caesar Salad',
              'sales': 876,
              'revenue': 7884.0,
              'trend': 5.1
            },
            {
              'name': 'Chicken Wings',
              'sales': 734,
              'revenue': 8808.0,
              'trend': 15.2
            },
            {
              'name': 'Fish & Chips',
              'sales': 689,
              'revenue': 9635.0,
              'trend': 4.7
            },
          ],
          Colors.green,
        ),
        const SizedBox(height: 24),

        // Worst Performers
        Text(
          'Products Needing Attention',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildProductRankingCard(
          theme,
          'Low Performers',
          [
            {
              'name': 'Vegan Wrap',
              'sales': 45,
              'revenue': 405.0,
              'trend': -15.2
            },
            {
              'name': 'Quinoa Bowl',
              'sales': 52,
              'revenue': 572.0,
              'trend': -12.8
            },
            {
              'name': 'Kale Smoothie',
              'sales': 67,
              'revenue': 402.0,
              'trend': -8.5
            },
          ],
          Colors.red,
        ),
        const SizedBox(height: 24),

        // Product Trends Chart
        Text(
          'Sales Trends (Last 7 Days)',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: theme.textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Classic Burger
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 165),
                        FlSpot(1, 178),
                        FlSpot(2, 172),
                        FlSpot(3, 185),
                        FlSpot(4, 168),
                        FlSpot(5, 195),
                        FlSpot(6, 182),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                    // Margherita Pizza
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 145),
                        FlSpot(1, 152),
                        FlSpot(2, 158),
                        FlSpot(3, 162),
                        FlSpot(4, 155),
                        FlSpot(5, 170),
                        FlSpot(6, 165),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                    // Caesar Salad
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 118),
                        FlSpot(1, 125),
                        FlSpot(2, 122),
                        FlSpot(3, 130),
                        FlSpot(4, 128),
                        FlSpot(5, 135),
                        FlSpot(6, 128),
                      ],
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(theme, Colors.blue, 'Classic Burger'),
            const SizedBox(width: 24),
            _buildLegendItem(theme, Colors.green, 'Margherita Pizza'),
            const SizedBox(width: 24),
            _buildLegendItem(theme, Colors.orange, 'Caesar Salad'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Category Performance Cards
        Text(
          'Category Performance',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                theme,
                'Entrees',
                845,
                15420.0,
                12.5,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCategoryCard(
                theme,
                'Beverages',
                1234,
                4936.0,
                8.3,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                theme,
                'Appetizers',
                567,
                5103.0,
                -4.2,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCategoryCard(
                theme,
                'Desserts',
                423,
                3807.0,
                6.7,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Category Comparison Chart
        Text(
          'Revenue by Category',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20000,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${(value / 1000).toStringAsFixed(0)}k',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final categories = ['Entrees', 'Beverages', 'Appetizers', 'Desserts'];
                          if (value.toInt() >= 0 && value.toInt() < categories.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                categories[value.toInt()],
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 15420,
                          color: Colors.blue,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 4936,
                          color: Colors.green,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 5103,
                          color: Colors.orange,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: 3807,
                          color: Colors.purple,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Items per Category
        Text(
          'Items per Category',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Active Items'), numeric: true),
              DataColumn(label: Text('Avg. Price'), numeric: true),
              DataColumn(label: Text('Total Sales'), numeric: true),
            ],
            rows: [
              _buildCategoryRow('Entrees', 28, 18.24, 845),
              _buildCategoryRow('Beverages', 45, 4.00, 1234),
              _buildCategoryRow('Appetizers', 22, 9.00, 567),
              _buildCategoryRow('Desserts', 18, 9.00, 423),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfitabilityTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profitability Overview
        Text(
          'Profitability Analysis',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                theme,
                'Avg. Profit Margin',
                '42.5%',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                theme,
                'Cost of Goods',
                '\$7,245',
                Icons.shopping_cart,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Most Profitable Products
        Text(
          'Most Profitable Products',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Revenue'), numeric: true),
              DataColumn(label: Text('Cost'), numeric: true),
              DataColumn(label: Text('Profit'), numeric: true),
              DataColumn(label: Text('Margin'), numeric: true),
            ],
            rows: [
              _buildProfitabilityRow('Classic Burger', 12450.0, 4982.0, 7468.0, 60.0),
              _buildProfitabilityRow('Fish & Chips', 9635.0, 3854.0, 5781.0, 60.0),
              _buildProfitabilityRow('Margherita Pizza', 10890.0, 5445.0, 5445.0, 50.0),
              _buildProfitabilityRow('Caesar Salad', 7884.0, 3942.0, 3942.0, 50.0),
              _buildProfitabilityRow('Chicken Wings', 8808.0, 5285.0, 3523.0, 40.0),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Profit Margin Distribution
        Text(
          'Profit Margin Distribution',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMarginDistributionRow(theme, 'High (>50%)', 45, Colors.green),
                const SizedBox(height: 12),
                _buildMarginDistributionRow(theme, 'Medium (30-50%)', 35, Colors.orange),
                const SizedBox(height: 12),
                _buildMarginDistributionRow(theme, 'Low (<30%)', 20, Colors.red),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Low Stock Performers
        Text(
          'Products with Low Stock Impact',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLowStockItem(theme, 'Salmon Fillet', 12, 234, 2808.0),
                const Divider(),
                _buildLowStockItem(theme, 'Ribeye Steak', 8, 156, 4680.0),
                const Divider(),
                _buildLowStockItem(theme, 'Lobster Tail', 5, 89, 3560.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductRankingCard(
    ThemeData theme,
    String title,
    List<Map<String, dynamic>> products,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...products.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${product['sales']} sales • ${NumberFormat.currency(symbol: '\$').format(product['revenue'])}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (product['trend'] > 0 ? Colors.green : Colors.red)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            product['trend'] > 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 14,
                            color: product['trend'] > 0 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product['trend'].abs()}%',
                            style: TextStyle(
                              color:
                                  product['trend'] > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    ThemeData theme,
    String name,
    int sales,
    double revenue,
    double trend,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.category,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (trend > 0 ? Colors.green : Colors.red).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend > 0 ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: trend > 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trend.abs()}%',
                        style: TextStyle(
                          color: trend > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$sales sales',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat.currency(symbol: '\$').format(revenue),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildCategoryRow(String name, int items, double avgPrice, int sales) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(items.toString())),
        DataCell(Text(NumberFormat.currency(symbol: '\$').format(avgPrice))),
        DataCell(Text(sales.toString())),
      ],
    );
  }

  Widget _buildMetricCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildProfitabilityRow(
    String product,
    double revenue,
    double cost,
    double profit,
    double margin,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(product)),
        DataCell(Text(NumberFormat.currency(symbol: '\$').format(revenue))),
        DataCell(Text(NumberFormat.currency(symbol: '\$').format(cost))),
        DataCell(Text(NumberFormat.currency(symbol: '\$').format(profit))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getMarginColor(margin).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${margin.toStringAsFixed(0)}%',
              style: TextStyle(
                color: _getMarginColor(margin),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getMarginColor(double margin) {
    if (margin >= 50) return Colors.green;
    if (margin >= 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMarginDistributionRow(
    ThemeData theme,
    String label,
    int percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '$percentage%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLowStockItem(
    ThemeData theme,
    String name,
    int stock,
    int sales,
    double revenue,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.warning, color: Colors.red),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('$stock items remaining'),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$sales sales',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            NumberFormat.currency(symbol: '\$').format(revenue),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
