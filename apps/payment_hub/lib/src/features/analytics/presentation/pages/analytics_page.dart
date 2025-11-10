import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

/// Analytics Page - Payment analytics and insights
class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock analytics data
    final stats = {
      'totalVolume': 145680.75,
      'totalTransactions': 2845,
      'avgTransaction': 51.20,
      'successRate': 97.8,
      'totalFees': 4370.42,
      'refundRate': 2.3,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: theme.colorScheme.onPrimaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text('Total Volume', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(stats['totalVolume']),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                        ),
                        Text('This month', style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt_long, color: theme.colorScheme.onSecondaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text('Transactions', style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.decimalPattern().format(stats['totalTransactions']),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer),
                        ),
                        Text('This month', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: theme.colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: theme.colorScheme.onTertiaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text('Avg Transaction', style: TextStyle(color: theme.colorScheme.onTertiaryContainer)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(stats['avgTransaction']),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onTertiaryContainer),
                        ),
                        Text('Per order', style: TextStyle(fontSize: 12, color: theme.colorScheme.onTertiaryContainer.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Success Rate', style: TextStyle(color: Colors.green.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats['successRate']}%',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        ),
                        Text('Transaction success', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.money_off, color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Total Fees', style: TextStyle(color: Colors.orange.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(stats['totalFees']),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                        ),
                        Text('${((stats['totalFees'] as double) / (stats['totalVolume'] as double) * 100).toStringAsFixed(2)}% rate', style: TextStyle(fontSize: 12, color: Colors.orange.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.keyboard_return, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Refund Rate', style: TextStyle(color: Colors.red.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats['refundRate']}%',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                        ),
                        Text('Of transactions', style: TextStyle(fontSize: 12, color: Colors.red.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Transaction Volume Chart
          Text('Transaction Volume', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Last 7 Days', style: theme.textTheme.titleMedium),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Volume', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 16),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Count', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5000,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: theme.colorScheme.outlineVariant,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                if (value.toInt() >= 0 && value.toInt() < days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(days[value.toInt()], style: const TextStyle(fontSize: 12)),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 5000,
                              reservedSize: 50,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  '\$${(value / 1000).toStringAsFixed(0)}k',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 6,
                        minY: 0,
                        maxY: 25000,
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 18500),
                              FlSpot(1, 21200),
                              FlSpot(2, 19800),
                              FlSpot(3, 23400),
                              FlSpot(4, 22100),
                              FlSpot(5, 20500),
                              FlSpot(6, 24300),
                            ],
                            isCurved: true,
                            color: theme.colorScheme.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Provider Distribution
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pie chart
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Provider Distribution', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.purple,
                                  value: 62,
                                  title: '62%',
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: Colors.black,
                                  value: 32,
                                  title: '32%',
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: 6,
                                  title: '6%',
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLegendItem('Stripe', Colors.purple),
                            _buildLegendItem('Square', Colors.black),
                            _buildLegendItem('Clover', Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Payment Methods
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Methods', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      const methods = ['Card', 'Wallet', 'Cash'];
                                      if (value.toInt() >= 0 && value.toInt() < methods.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(methods[value.toInt()], style: const TextStyle(fontSize: 12)),
                                        );
                                      }
                                      return const Text('');
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    interval: 25,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      return Text('${value.toInt()}%', style: const TextStyle(fontSize: 12));
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 25,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: theme.colorScheme.outlineVariant,
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 68,
                                      color: theme.colorScheme.primary,
                                      width: 40,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 24,
                                      color: theme.colorScheme.secondary,
                                      width: 40,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 2,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 8,
                                      color: theme.colorScheme.tertiary,
                                      width: 40,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Transaction Status
          Text('Transaction Status', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStatusRow(theme, 'Completed', 2782, 97.8, Colors.green),
                  const SizedBox(height: 12),
                  _buildStatusRow(theme, 'Pending', 28, 1.0, Colors.orange),
                  const SizedBox(height: 12),
                  _buildStatusRow(theme, 'Failed', 35, 1.2, Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusRow(ThemeData theme, String label, int count, double percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            label == 'Completed' ? Icons.check : (label == 'Pending' ? Icons.hourglass_empty : Icons.error),
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.decimalPattern().format(count),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ],
    );
  }
}
