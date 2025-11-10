import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

/// Financial Reports - Export and analyze financial data
class FinancialReportsPage extends ConsumerWidget {
  const FinancialReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock report data
    final reports = [
      FinancialReport('Profit & Loss', ReportType.profitLoss, ReportPeriod.monthly, DateTime(2024, 11, 1), DateTime(2024, 11, 30), ReportStatus.ready, DateTime.now().subtract(const Duration(hours: 2))),
      FinancialReport('Balance Sheet', ReportType.balanceSheet, ReportPeriod.quarterly, DateTime(2024, 7, 1), DateTime(2024, 9, 30), ReportStatus.ready, DateTime.now().subtract(const Duration(days: 1))),
      FinancialReport('Cash Flow', ReportType.cashFlow, ReportPeriod.monthly, DateTime(2024, 11, 1), DateTime(2024, 11, 30), ReportStatus.generating, null),
      FinancialReport('Tax Summary', ReportType.tax, ReportPeriod.quarterly, DateTime(2024, 7, 1), DateTime(2024, 9, 30), ReportStatus.ready, DateTime.now().subtract(const Duration(days: 5))),
      FinancialReport('General Ledger', ReportType.generalLedger, ReportPeriod.annual, DateTime(2024, 1, 1), DateTime(2024, 12, 31), ReportStatus.scheduled, null),
    ];

    // Mock financial summary
    final summary = {
      'revenue': 145680.50,
      'expenses': 89420.25,
      'profit': 56260.25,
      'profitMargin': 38.6,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
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
                            Icon(Icons.trending_up, color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Revenue', style: TextStyle(color: Colors.green.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(summary['revenue']),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        ),
                        Text('This month', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
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
                            Icon(Icons.trending_down, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Expenses', style: TextStyle(color: Colors.red.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(summary['expenses']),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                        ),
                        Text('This month', style: TextStyle(fontSize: 12, color: Colors.red.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                            Icon(Icons.account_balance, color: theme.colorScheme.onPrimaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text('Net Profit', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(summary['profit']),
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
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.percent, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Margin', style: TextStyle(color: Colors.blue.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${summary['profitMargin']}%',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                        ),
                        Text('Profit margin', style: TextStyle(fontSize: 12, color: Colors.blue.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Revenue vs Expenses Chart
          Text('Revenue vs Expenses', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last 6 Months', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20000,
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
                                const months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'];
                                if (value.toInt() >= 0 && value.toInt() < months.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(months[value.toInt()], style: const TextStyle(fontSize: 12)),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 20000,
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
                        maxX: 5,
                        minY: 0,
                        maxY: 160000,
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 118500),
                              FlSpot(1, 132200),
                              FlSpot(2, 125800),
                              FlSpot(3, 138400),
                              FlSpot(4, 142100),
                              FlSpot(5, 145680),
                            ],
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.1),
                            ),
                          ),
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 75200),
                              FlSpot(1, 82100),
                              FlSpot(2, 78500),
                              FlSpot(3, 85900),
                              FlSpot(4, 87200),
                              FlSpot(5, 89420),
                            ],
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.red.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Revenue', Colors.green),
                      const SizedBox(width: 24),
                      _buildLegendItem('Expenses', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Available Reports
          Text('Available Reports', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...reports.map((report) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getReportTypeColor(report.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getReportTypeIcon(report.type), color: _getReportTypeColor(report.type), size: 20),
              ),
              title: Row(
                children: [
                  Text(report.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(report.status),
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text('${report.period.name.toUpperCase()} • ${DateFormat('MMM dd').format(report.startDate)} - ${DateFormat('MMM dd, yyyy').format(report.endDate)}'),
              trailing: report.status == ReportStatus.ready
                  ? Icon(Icons.download, color: theme.colorScheme.primary)
                  : (report.status == ReportStatus.generating
                      ? const CircularProgressIndicator()
                      : Icon(Icons.schedule, color: Colors.grey.shade400)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('Report Type', report.name),
                      _buildInfoRow('Period', report.period.name.toUpperCase()),
                      _buildInfoRow('Start Date', DateFormat('MMM dd, yyyy').format(report.startDate)),
                      _buildInfoRow('End Date', DateFormat('MMM dd, yyyy').format(report.endDate)),
                      _buildInfoRow('Status', report.status.name.toUpperCase()),
                      if (report.generatedAt != null)
                        _buildInfoRow('Generated', DateFormat('MMM dd, yyyy h:mm a').format(report.generatedAt!)),
                      const SizedBox(height: 16),
                      if (report.status == ReportStatus.ready) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text('PDF'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text('Excel'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.send, size: 18),
                                label: const Text('Email'),
                              ),
                            ),
                          ],
                        ),
                      ] else if (report.status == ReportStatus.scheduled) ...[
                        FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Generate Now'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.profitLoss: return Colors.green;
      case ReportType.balanceSheet: return Colors.blue;
      case ReportType.cashFlow: return Colors.purple;
      case ReportType.tax: return Colors.orange;
      case ReportType.generalLedger: return Colors.grey;
    }
  }

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.profitLoss: return Icons.trending_up;
      case ReportType.balanceSheet: return Icons.account_balance;
      case ReportType.cashFlow: return Icons.water_drop;
      case ReportType.tax: return Icons.receipt;
      case ReportType.generalLedger: return Icons.book;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.ready: return Colors.green;
      case ReportStatus.generating: return Colors.blue;
      case ReportStatus.scheduled: return Colors.orange;
    }
  }
}

// Models
class FinancialReport {
  final String name;
  final ReportType type;
  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final ReportStatus status;
  final DateTime? generatedAt;

  FinancialReport(this.name, this.type, this.period, this.startDate, this.endDate, this.status, this.generatedAt);
}

enum ReportType { profitLoss, balanceSheet, cashFlow, tax, generalLedger }
enum ReportPeriod { monthly, quarterly, annual }
enum ReportStatus { ready, generating, scheduled }
