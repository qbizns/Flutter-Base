import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

/// Analytics - Queue performance metrics and insights
class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock analytics data
    final hourlyData = [
      HourlyMetric(8, 12, 8.5),
      HourlyMetric(9, 28, 12.3),
      HourlyMetric(10, 45, 18.5),
      HourlyMetric(11, 58, 22.8),
      HourlyMetric(12, 72, 28.2),
      HourlyMetric(13, 65, 25.5),
      HourlyMetric(14, 52, 20.8),
      HourlyMetric(15, 38, 15.2),
      HourlyMetric(16, 42, 18.5),
      HourlyMetric(17, 35, 14.8),
    ];

    final serviceTypeData = [
      ServiceTypeMetric('General Inquiry', 145, 8.5, 91.2),
      ServiceTypeMetric('Order Pickup', 112, 5.2, 96.8),
      ServiceTypeMetric('Returns', 78, 12.8, 85.5),
      ServiceTypeMetric('Technical Support', 45, 18.5, 88.3),
      ServiceTypeMetric('Catering Services', 32, 15.2, 92.5),
      ServiceTypeMetric('Loyalty Program', 28, 6.8, 94.8),
    ];

    final totalTickets = serviceTypeData.fold<int>(0, (sum, s) => sum + s.tickets);
    final avgWaitTime = hourlyData.fold<double>(0, (sum, h) => sum + h.avgWaitTime) / hourlyData.length;
    final avgServiceTime = serviceTypeData.fold<double>(0, (sum, s) => sum + s.avgServiceTime) / serviceTypeData.length;
    final avgSatisfaction = serviceTypeData.fold<double>(0, (sum, s) => sum + s.satisfaction) / serviceTypeData.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(
            children: [
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
                            Icon(Icons.confirmation_number, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Total Tickets', style: TextStyle(color: Colors.blue.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$totalTickets', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                        Text('Today', style: TextStyle(fontSize: 12, color: Colors.blue.shade700.withOpacity(0.7))),
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
                            Icon(Icons.access_time, color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Avg Wait Time', style: TextStyle(color: Colors.orange.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${avgWaitTime.toStringAsFixed(1)} min', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                        Text('Average', style: TextStyle(fontSize: 12, color: Colors.orange.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.purple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.speed, color: Colors.purple.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Avg Service Time', style: TextStyle(color: Colors.purple.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${avgServiceTime.toStringAsFixed(1)} min', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                        Text('Per ticket', style: TextStyle(fontSize: 12, color: Colors.purple.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                            Icon(Icons.star, color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Satisfaction', style: TextStyle(color: Colors.green.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${avgSatisfaction.toStringAsFixed(1)}%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                        Text('Customer rating', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Hourly Traffic Chart
          Text('Hourly Traffic & Wait Times', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 12, height: 12, color: Colors.blue, margin: const EdgeInsets.only(right: 8)),
                      const Text('Tickets', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 24),
                      Container(width: 12, height: 12, color: Colors.orange, margin: const EdgeInsets.only(right: 8)),
                      const Text('Avg Wait Time (min)', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}h', style: const TextStyle(fontSize: 10));
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                              },
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: hourlyData.map((h) => FlSpot(h.hour.toDouble(), h.tickets.toDouble())).toList(),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                          LineChartBarData(
                            spots: hourlyData.map((h) => FlSpot(h.hour.toDouble(), h.avgWaitTime)).toList(),
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
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

          // Service Type Distribution
          Text('Service Type Performance', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Ticket Distribution', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: serviceTypeData.map((s) {
                                final percentage = (s.tickets / totalTickets * 100);
                                return PieChartSectionData(
                                  value: s.tickets.toDouble(),
                                  title: '${percentage.toStringAsFixed(0)}%',
                                  color: _getServiceTypeColor(serviceTypeData.indexOf(s)),
                                  radius: 80,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...serviceTypeData.map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getServiceTypeColor(serviceTypeData.indexOf(s)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(s.type, style: const TextStyle(fontSize: 12))),
                              Text('${s.tickets}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Service Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        ...serviceTypeData.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(s.type, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  Text('${s.tickets} tickets', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Avg Service Time', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                        const SizedBox(height: 4),
                                        Text('${s.avgServiceTime.toStringAsFixed(1)} min', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Satisfaction', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                        const SizedBox(height: 4),
                                        Text('${s.satisfaction.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: s.satisfaction / 100,
                                backgroundColor: theme.colorScheme.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  s.satisfaction >= 90 ? Colors.green : (s.satisfaction >= 80 ? Colors.orange : Colors.red),
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Peak Hours Analysis
          Text('Peak Hours Analysis', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildPeakHourCard('Peak Traffic', '12:00 PM', '72 tickets', Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPeakHourCard('Longest Wait', '12:00 PM', '28.2 min', Colors.orange),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPeakHourCard('Quietest Hour', '8:00 AM', '12 tickets', Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPeakHourCard('Shortest Wait', '8:00 AM', '8.5 min', Colors.purple),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakHourCard(String label, String time, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(time, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getServiceTypeColor(int index) {
    final colors = [Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.teal, Colors.pink];
    return colors[index % colors.length];
  }
}

// Models
class HourlyMetric {
  final int hour;
  final int tickets;
  final double avgWaitTime;

  HourlyMetric(this.hour, this.tickets, this.avgWaitTime);
}

class ServiceTypeMetric {
  final String type;
  final int tickets;
  final double avgServiceTime;
  final double satisfaction;

  ServiceTypeMetric(this.type, this.tickets, this.avgServiceTime, this.satisfaction);
}
