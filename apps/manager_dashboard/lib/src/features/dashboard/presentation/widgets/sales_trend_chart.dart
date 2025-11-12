import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';

/// Sales Trend Chart Widget
///
/// Displays a line chart showing sales trend over the last 7 days
class SalesTrendChart extends StatelessWidget {
  const SalesTrendChart({
    required this.salesData,
    super.key,
  });

  final List<DailySales> salesData;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Trend (Last 7 Days)',
              style: OdooTypography.cardTitle.copyWith(
                color: OdooColors.textPrimary,
              ),
            ),
            const SizedBox(height: OdooSpacing.xl),
            SizedBox(
              height: 250,
              child: salesData.isEmpty
                  ? _buildEmptyState()
                  : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: OdooColors.gray400,
          ),
          const SizedBox(height: OdooSpacing.md),
          Text(
            'No sales data available',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final maxY = salesData.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final minY = salesData.map((e) => e.amount).reduce((a, b) => a < b ? a : b);
    final yInterval = (maxY - minY) / 5;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval > 0 ? yInterval : 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: OdooColors.gray200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= salesData.length) {
                  return const SizedBox.shrink();
                }
                final date = salesData[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('E').format(date), // Mon, Tue, etc.
                    style: OdooTypography.bodySmall.copyWith(
                      color: OdooColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: yInterval > 0 ? yInterval : 100,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: OdooColors.border, width: 1),
            left: BorderSide(color: OdooColors.border, width: 1),
          ),
        ),
        minX: 0,
        maxX: (salesData.length - 1).toDouble(),
        minY: minY > 0 ? 0 : minY,
        maxY: maxY * 1.1, // Add 10% padding at top
        lineBarsData: [
          LineChartBarData(
            spots: salesData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.amount);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                OdooColors.secondary,
                OdooColors.secondary.withOpacity(0.7),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: OdooColors.secondary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  OdooColors.secondary.withOpacity(0.2),
                  OdooColors.secondary.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => OdooColors.gray800,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = salesData[spot.x.toInt()].date;
                return LineTooltipItem(
                  '${DateFormat('MMM d').format(date)}\n\$${spot.y.toStringAsFixed(2)}',
                  OdooTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

/// Daily Sales Data Model
class DailySales {
  final DateTime date;
  final double amount;

  DailySales({
    required this.date,
    required this.amount,
  });
}
