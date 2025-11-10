import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Sales Analytics Page
///
/// Features:
/// - Sales by time period
/// - Sales by category
/// - Payment method breakdown
/// - Hourly sales pattern
/// - Day of week analysis
class SalesAnalyticsPage extends ConsumerStatefulWidget {
  const SalesAnalyticsPage({super.key});

  @override
  ConsumerState<SalesAnalyticsPage> createState() => _SalesAnalyticsPageState();
}

class _SalesAnalyticsPageState extends ConsumerState<SalesAnalyticsPage>
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
        title: const Text('Sales Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'Breakdown'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(theme),
          _buildTrendsTab(theme),
          _buildBreakdownTab(theme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sales summary cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                theme,
                'Today\'s Sales',
                '\$2,458.50',
                Icons.today,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                theme,
                'This Week',
                '\$12,458.00',
                Icons.date_range,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                theme,
                'This Month',
                '\$48,925.00',
                Icons.calendar_month,
                Colors.purple,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Sales by category pie chart
        _buildCategoryBreakdown(theme),

        const SizedBox(height: 24),

        // Payment methods
        _buildPaymentMethodsChart(theme),
      ],
    );
  }

  Widget _buildTrendsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hourly sales pattern
        _buildHourlySalesChart(theme),

        const SizedBox(height: 24),

        // Day of week analysis
        _buildDayOfWeekChart(theme),
      ],
    );
  }

  Widget _buildBreakdownTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top selling hours
        _buildTopSellingHours(theme),

        const SizedBox(height: 24),

        // Sales by day of week
        _buildSalesByDayTable(theme),
      ],
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
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
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales by Category',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        sections: [
                          PieChartSectionData(
                            value: 35,
                            title: '35%',
                            color: Colors.blue,
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: 28,
                            title: '28%',
                            color: Colors.green,
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: 22,
                            title: '22%',
                            color: Colors.orange,
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: 15,
                            title: '15%',
                            color: Colors.purple,
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(theme, 'Entrees', '\$17,123', Colors.blue),
                      _buildLegendItem(theme, 'Beverages', '\$13,699', Colors.green),
                      _buildLegendItem(theme, 'Appetizers', '\$10,763', Colors.orange),
                      _buildLegendItem(theme, 'Desserts', '\$7,340', Colors.purple),
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

  Widget _buildLegendItem(ThemeData theme, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsChart(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Methods',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildPaymentBar(theme, 'Credit/Debit Card', 0.52, Colors.blue, '\$25,441'),
            _buildPaymentBar(theme, 'Cash', 0.28, Colors.green, '\$13,699'),
            _buildPaymentBar(theme, 'Digital Wallet', 0.15, Colors.purple, '\$7,340'),
            _buildPaymentBar(theme, 'Gift Card', 0.05, Colors.orange, '\$2,447'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBar(
    ThemeData theme,
    String label,
    double percentage,
    Color color,
    String amount,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '$amount (${(percentage * 100).toInt()}%)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlySalesChart(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hourly Sales Pattern',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 200,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final hours = ['9', '10', '11', '12', '1', '2', '3', '4', '5', '6', '7', '8'];
                          if (value.toInt() >= 0 && value.toInt() < hours.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                hours[value.toInt()],
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 45, color: theme.colorScheme.primary)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 65, color: theme.colorScheme.primary)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 125, color: theme.colorScheme.primary)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 180, color: theme.colorScheme.primary)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 155, color: theme.colorScheme.primary)]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 140, color: theme.colorScheme.primary)]),
                    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 110, color: theme.colorScheme.primary)]),
                    BarChartGroupData(x: 7, barRods: [BarChartRodData(toY: 95, color: theme.colorScheme.primary)]),
                    BarChartGroupData(x: 8, barRods: [BarChartRodData(toY: 165, color: theme.colorScheme.primary)]),
                    BarChartGroupData(x: 9, barRods: [BarChartRodData(toY: 185, color: theme.colorScheme.primary)]),
                    BarChartGroupData(x: 10, barRods: [BarChartRodData(toY: 120, color: theme.colorScheme.primary)]),
                    BarChartGroupData(x: 11, barRods: [BarChartRodData(toY: 75, color: theme.colorScheme.primary)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayOfWeekChart(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales by Day of Week',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 3000,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[value.toInt()],
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1850, color: Colors.blue, width: 30)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1920, color: Colors.blue, width: 30)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2100, color: Colors.blue, width: 30)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 1980, color: Colors.blue, width: 30)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 2250, color: Colors.blue, width: 30)]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 2850, color: Colors.green, width: 30)]),
                    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 2650, color: Colors.green, width: 30)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingHours(ThemeData theme) {
    final hours = [
      {'time': '6:00 PM - 7:00 PM', 'sales': '\$2,850', 'orders': 45},
      {'time': '7:00 PM - 8:00 PM', 'sales': '\$2,680', 'orders': 42},
      {'time': '12:00 PM - 1:00 PM', 'sales': '\$2,420', 'orders': 58},
      {'time': '1:00 PM - 2:00 PM', 'sales': '\$2,180', 'orders': 52},
      {'time': '8:00 PM - 9:00 PM', 'sales': '\$1,950', 'orders': 38},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Selling Hours',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...hours.map((hour) {
              return ListTile(
                title: Text(
                  hour['time'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${hour['orders']} orders'),
                trailing: Text(
                  hour['sales'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesByDayTable(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Breakdown',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Day')),
                DataColumn(label: Text('Orders')),
                DataColumn(label: Text('Revenue')),
                DataColumn(label: Text('Avg. Order')),
              ],
              rows: [
                _buildDataRow('Monday', 142, 1850.00),
                _buildDataRow('Tuesday', 156, 1920.00),
                _buildDataRow('Wednesday', 168, 2100.00),
                _buildDataRow('Thursday', 159, 1980.00),
                _buildDataRow('Friday', 185, 2250.00),
                _buildDataRow('Saturday', 218, 2850.00),
                _buildDataRow('Sunday', 198, 2650.00),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String day, int orders, double revenue) {
    return DataRow(
      cells: [
        DataCell(Text(day)),
        DataCell(Text('$orders')),
        DataCell(Text('\$${revenue.toStringAsFixed(2)}')),
        DataCell(Text('\$${(revenue / orders).toStringAsFixed(2)}')),
      ],
    );
  }
}
