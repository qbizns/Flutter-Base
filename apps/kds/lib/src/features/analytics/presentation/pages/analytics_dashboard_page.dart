/// Analytics Dashboard Page
/// Kitchen performance analytics following Odoo dashboard patterns
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../../../../data/models/preparation_metrics.dart';
import '../../../../data/services/kitchen_analytics_service.dart';
import '../widgets/kpi_card.dart';
import '../widgets/simple_bar_chart.dart';

/// Analytics Dashboard Page
class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState<AnalyticsDashboardPage> createState() =>
      _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState
    extends ConsumerState<AnalyticsDashboardPage> {
  AnalyticsTimeRange _selectedRange = AnalyticsTimeRange.today;

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(currentMetricsProvider);
    final snapshot = ref.watch(performanceSnapshotProvider);
    final hourlyData = ref.watch(hourlyBreakdownProvider);

    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: VodoColors.primary,
        foregroundColor: VodoColors.textOnPrimary,
        title: const Text(
          'Kitchen Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          // Time range selector
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showTimeRangeDialog,
            tooltip: 'Time Range',
          ),

          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(currentMetricsProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentMetricsProvider);
        },
        child: SingleChildScrollView(
          padding: VodoDimensions.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time range indicator
              _buildTimeRangeIndicator(),

              const SizedBox(height: VodoDimensions.spacingMd),

              // Performance overview
              _buildPerformanceOverview(metrics),

              const SizedBox(height: VodoDimensions.spacingMd),

              // KPI Grid
              _buildKpiGrid(metrics, snapshot),

              const SizedBox(height: VodoDimensions.spacingMd),

              // Hourly orders chart
              _buildHourlyOrdersChart(hourlyData),

              const SizedBox(height: VodoDimensions.spacingMd),

              // Station performance
              _buildStationPerformance(metrics),

              const SizedBox(height: VodoDimensions.spacingMd),

              // Category performance
              _buildCategoryPerformance(metrics),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeIndicator() {
    return Container(
      padding: VodoDimensions.paddingSm,
      decoration: BoxDecoration(
        color: VodoColors.backgroundPrimary,
        borderRadius: VodoDimensions.borderRadiusSm,
        border: Border.all(color: VodoColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 16,
            color: VodoColors.primary,
          ),
          const SizedBox(width: VodoDimensions.spacingSm),
          Text(
            'Period: ${_selectedRange.displayName}',
            style: VodoTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _showTimeRangeDialog,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview(KitchenMetrics metrics) {
    return PerformanceRatingCard(
      title: 'Overall Performance',
      score: metrics.overallEfficiency,
      rating: metrics.performanceRating.displayName,
      emoji: metrics.performanceRating.emoji,
      color: metrics.performanceRating.color,
    );
  }

  Widget _buildKpiGrid(KitchenMetrics metrics, PerformanceSnapshot snapshot) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.3,
          crossAxisSpacing: VodoDimensions.spacingMd,
          mainAxisSpacing: VodoDimensions.spacingMd,
          children: [
            KpiCard(
              title: 'Total Orders',
              value: metrics.totalOrders.toString(),
              subtitle: '${_selectedRange.displayName}',
              icon: Icons.receipt_long,
              color: VodoColors.primary,
            ),
            KpiCard(
              title: 'Completed',
              value: metrics.completedOrders.toString(),
              subtitle: '${(metrics.completionRate * 100).toStringAsFixed(0)}% completion rate',
              icon: Icons.check_circle,
              color: VodoColors.success,
            ),
            KpiCard(
              title: 'Avg Prep Time',
              value: '${metrics.averagePreparationTime.toStringAsFixed(1)}m',
              subtitle: 'Per item',
              icon: Icons.timer,
              color: VodoColors.info,
            ),
            KpiCard(
              title: 'Delayed',
              value: metrics.delayedOrders.toString(),
              subtitle: '${(metrics.delayedOrders / metrics.totalOrders * 100).toStringAsFixed(0)}% of orders',
              icon: Icons.warning,
              color: VodoColors.danger,
            ),
            KpiCard(
              title: 'On-Time Rate',
              value: '${(metrics.onTimeRate * 100).toStringAsFixed(0)}%',
              subtitle: 'Orders within target time',
              icon: Icons.schedule,
              color: VodoColors.success,
            ),
            KpiCard(
              title: 'Avg Wait Time',
              value: '${metrics.averageWaitTime.toStringAsFixed(1)}m',
              subtitle: 'Order to completion',
              icon: Icons.hourglass_bottom,
              color: VodoColors.warning,
            ),
            KpiCard(
              title: 'Orders/Hour',
              value: metrics.ordersPerHour.toStringAsFixed(1),
              subtitle: 'Throughput rate',
              icon: Icons.speed,
              color: VodoColors.accent,
            ),
            KpiCard(
              title: 'Active Now',
              value: snapshot.activeOrders.toString(),
              subtitle: '${snapshot.pendingOrders} pending',
              icon: Icons.restaurant,
              color: VodoColors.primary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildHourlyOrdersChart(List<HourlyMetrics> hourlyData) {
    // Filter to show only hours with activity
    final activeHours = hourlyData.where((h) => h.orderCount > 0).toList();

    if (activeHours.isEmpty) {
      return const SizedBox.shrink();
    }

    final chartData = activeHours.map((h) {
      return BarChartData(
        label: _formatHour(h.hour),
        value: h.orderCount.toDouble(),
        color: h.delayedCount > h.completedCount / 2
            ? VodoColors.danger
            : VodoColors.success,
      );
    }).toList();

    return SimpleBarChart(
      title: 'Orders by Hour',
      subtitle: 'Distribution throughout the day',
      data: chartData,
      barColor: VodoColors.primary,
      showLabels: true,
    );
  }

  Widget _buildStationPerformance(KitchenMetrics metrics) {
    if (metrics.stationMetrics.isEmpty) {
      return const SizedBox.shrink();
    }

    final chartData = metrics.stationMetrics.map((station) {
      return BarChartData(
        label: station.stationName,
        value: station.efficiencyScore,
        color: station.performanceRating.color,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Station Performance',
          style: VodoTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: VodoDimensions.spacingSm),
        HorizontalBarChart(
          title: 'Efficiency Score by Station',
          data: chartData,
          barColor: VodoColors.primary,
        ),
        const SizedBox(height: VodoDimensions.spacingMd),

        // Station details cards
        ...metrics.stationMetrics.map((station) {
          return Padding(
            padding: const EdgeInsets.only(bottom: VodoDimensions.spacingMd),
            child: _buildStationCard(station),
          );
        }),
      ],
    );
  }

  Widget _buildStationCard(StationMetrics station) {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Container(
        padding: VodoDimensions.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: station.performanceRating.color.withOpacity(0.1),
                    borderRadius: VodoDimensions.borderRadiusSm,
                  ),
                  child: Icon(
                    Icons.kitchen,
                    color: station.performanceRating.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: VodoDimensions.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.stationName,
                        style: VodoTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${station.efficiencyScore.toStringAsFixed(0)}% efficiency • ${station.performanceRating.displayName}',
                        style: VodoTextStyles.bodySmall.copyWith(
                          color: station.performanceRating.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: VodoDimensions.spacingMd),

            // Metrics grid
            Row(
              children: [
                Expanded(
                  child: _buildStationMetric(
                    'Orders',
                    station.totalOrders.toString(),
                    Icons.receipt,
                  ),
                ),
                Expanded(
                  child: _buildStationMetric(
                    'Completed',
                    '${(station.completionRate * 100).toStringAsFixed(0)}%',
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStationMetric(
                    'Avg Time',
                    '${station.averagePreparationTime.toStringAsFixed(1)}m',
                    Icons.timer,
                  ),
                ),
                Expanded(
                  child: _buildStationMetric(
                    'Delayed',
                    station.delayedOrders.toString(),
                    Icons.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: VodoColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: VodoTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: VodoTextStyles.caption.copyWith(
            color: VodoColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPerformance(KitchenMetrics metrics) {
    if (metrics.categoryMetrics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Performance',
          style: VodoTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: VodoDimensions.spacingSm),
        Card(
          elevation: VodoDimensions.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: VodoDimensions.borderRadiusMd,
          ),
          child: Container(
            padding: VodoDimensions.paddingMd,
            child: Column(
              children: metrics.categoryMetrics.map((category) {
                return _buildCategoryRow(category);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(CategoryMetrics category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VodoDimensions.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category name and stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.categoryName,
                style: VodoTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${category.totalItems} items • ${category.averagePreparationTime.toStringAsFixed(1)}m avg',
                style: VodoTextStyles.bodySmall.copyWith(
                  color: VodoColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: category.completionRate,
              backgroundColor: VodoColors.backgroundSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(
                category.delayRate > 0.2
                    ? VodoColors.danger
                    : VodoColors.success,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12a';
    if (hour < 12) return '${hour}a';
    if (hour == 12) return '12p';
    return '${hour - 12}p';
  }

  void _showTimeRangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Time Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AnalyticsTimeRange.values.map((range) {
            return RadioListTile<AnalyticsTimeRange>(
              title: Text(range.displayName),
              value: range,
              groupValue: _selectedRange,
              onChanged: (value) {
                setState(() {
                  _selectedRange = value!;
                });
                Navigator.pop(context);
                ref.invalidate(currentMetricsProvider);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
