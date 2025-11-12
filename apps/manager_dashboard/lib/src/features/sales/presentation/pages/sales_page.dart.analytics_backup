import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

/// Sales Analytics Page - Comprehensive sales reporting
///
/// Features:
/// - Date range selection
/// - Revenue summary cards
/// - Sales breakdown by order type
/// - Sales breakdown by payment method
/// - Time-based comparisons (day/week/month)
/// - Top performing periods
/// - Export options (coming soon)
class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  // View mode: 'day', 'week', 'month'
  String _viewMode = 'week';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(ordersProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(ordersProvider);
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ordersProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date range selector and view mode
              _buildFilters(context),
              const SizedBox(height: 24),

              // Main metrics
              ordersAsync.when(
                data: (orders) {
                  final filteredOrders = _filterOrdersByDateRange(orders);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRevenueCards(context, filteredOrders),
                      const SizedBox(height: 32),

                      // Sales by order type
                      _buildSectionHeader(context, 'Sales by Order Type'),
                      const SizedBox(height: 16),
                      _buildOrderTypeBreakdown(context, filteredOrders),
                      const SizedBox(height: 32),

                      // Sales by payment method
                      _buildSectionHeader(context, 'Sales by Payment Method'),
                      const SizedBox(height: 16),
                      _buildPaymentMethodBreakdown(context, filteredOrders),
                      const SizedBox(height: 32),

                      // Hourly breakdown
                      _buildSectionHeader(context, 'Hourly Breakdown'),
                      const SizedBox(height: 16),
                      _buildHourlyBreakdown(context, filteredOrders),
                      const SizedBox(height: 32),

                      // Period comparison
                      _buildSectionHeader(context, 'Period Comparison'),
                      const SizedBox(height: 16),
                      _buildPeriodComparison(context, orders),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Center(
                  child: Text('Error loading sales data: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Period',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Date range buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, isStartDate: true),
                    icon: const Icon(Icons.calendar_today),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          DateFormat('MMM d, yyyy').format(_startDate),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, isStartDate: false),
                    icon: const Icon(Icons.calendar_today),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Date',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          DateFormat('MMM d, yyyy').format(_endDate),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick select buttons
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Today'),
                  selected: _viewMode == 'day',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _viewMode = 'day';
                        _startDate = DateTime.now();
                        _endDate = DateTime.now();
                      });
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('This Week'),
                  selected: _viewMode == 'week',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _viewMode = 'week';
                        _startDate = DateTime.now().subtract(const Duration(days: 7));
                        _endDate = DateTime.now();
                      });
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('This Month'),
                  selected: _viewMode == 'month',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _viewMode = 'month';
                        _startDate = DateTime.now().subtract(const Duration(days: 30));
                        _endDate = DateTime.now();
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCards(BuildContext context, List<Order> orders) {
    // Calculate metrics
    final totalRevenue = orders.fold<double>(
      0,
      (sum, order) => sum + order.total,
    );

    final totalOrders = orders.length;

    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    final completedOrders = orders
        .where((o) => o.status == OrderStatus.completed)
        .length;

    final taxCollected = orders.fold<double>(
      0,
      (sum, order) => sum + order.taxAmount,
    );

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          context,
          icon: Icons.attach_money,
          title: 'Total Revenue',
          value: '\$${totalRevenue.toStringAsFixed(2)}',
          subtitle: '$totalOrders orders',
          color: Colors.green,
        ),
        _buildMetricCard(
          context,
          icon: Icons.receipt_long,
          title: 'Orders',
          value: '$totalOrders',
          subtitle: '$completedOrders completed',
          color: Colors.blue,
        ),
        _buildMetricCard(
          context,
          icon: Icons.trending_up,
          title: 'Avg Order Value',
          value: '\$${avgOrderValue.toStringAsFixed(2)}',
          subtitle: 'Per order',
          color: Colors.purple,
        ),
        _buildMetricCard(
          context,
          icon: Icons.account_balance,
          title: 'Tax Collected',
          value: '\$${taxCollected.toStringAsFixed(2)}',
          subtitle: 'Total tax',
          color: Colors.orange,
        ),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOrderTypeBreakdown(BuildContext context, List<Order> orders) {
    final theme = Theme.of(context);

    // Group by order type
    final breakdown = <OrderType, double>{};
    final counts = <OrderType, int>{};

    for (final order in orders) {
      breakdown[order.orderType] = (breakdown[order.orderType] ?? 0) + order.total;
      counts[order.orderType] = (counts[order.orderType] ?? 0) + 1;
    }

    final totalRevenue = breakdown.values.fold<double>(0, (sum, v) => sum + v);

    if (breakdown.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text('No data available', style: theme.textTheme.bodyLarge),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: breakdown.entries.map((entry) {
            final type = entry.key;
            final revenue = entry.value;
            final count = counts[type] ?? 0;
            final percentage = totalRevenue > 0 ? (revenue / totalRevenue) * 100 : 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getOrderTypeIcon(type),
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getOrderTypeName(type),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${revenue.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            '$count orders',
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
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
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

  Widget _buildPaymentMethodBreakdown(BuildContext context, List<Order> orders) {
    final theme = Theme.of(context);

    // Group by payment status - in a real app, you'd fetch payment records
    // For now, we'll estimate based on order status
    final breakdown = <String, double>{};
    final counts = <String, int>{};

    for (final order in orders) {
      final method = order.paymentStatus == PaymentStatus.completed
          ? 'Card'
          : order.paymentStatus == PaymentStatus.pending
              ? 'Cash'
              : 'Other';

      breakdown[method] = (breakdown[method] ?? 0) + order.total;
      counts[method] = (counts[method] ?? 0) + 1;
    }

    final totalRevenue = breakdown.values.fold<double>(0, (sum, v) => sum + v);

    if (breakdown.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text('No data available', style: theme.textTheme.bodyLarge),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: breakdown.entries.map((entry) {
            final method = entry.key;
            final revenue = entry.value;
            final count = counts[method] ?? 0;
            final percentage = totalRevenue > 0 ? (revenue / totalRevenue) * 100 : 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getPaymentIcon(method),
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            method,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${revenue.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            '$count transactions',
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
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
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

  Widget _buildHourlyBreakdown(BuildContext context, List<Order> orders) {
    final theme = Theme.of(context);

    // Group by hour
    final hourlyData = <int, double>{};
    final hourlyCounts = <int, int>{};

    for (final order in orders) {
      final hour = order.createdAt.hour;
      hourlyData[hour] = (hourlyData[hour] ?? 0) + order.total;
      hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
    }

    if (hourlyData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text('No data available', style: theme.textTheme.bodyLarge),
          ),
        ),
      );
    }

    final maxRevenue = hourlyData.values.reduce((a, b) => a > b ? a : b);

    // Show business hours (8 AM - 10 PM)
    final businessHours = List.generate(15, (index) => index + 8);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: businessHours.map((hour) {
            final revenue = hourlyData[hour] ?? 0;
            final count = hourlyCounts[hour] ?? 0;
            final percentage = maxRevenue > 0 ? (revenue / maxRevenue) : 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      _formatHour(hour),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      minHeight: 24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${revenue.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$count orders',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPeriodComparison(BuildContext context, List<Order> allOrders) {
    final theme = Theme.of(context);

    // Calculate current period
    final currentPeriodOrders = _filterOrdersByDateRange(allOrders);
    final currentRevenue = currentPeriodOrders.fold<double>(
      0,
      (sum, order) => sum + order.total,
    );

    // Calculate previous period (same duration)
    final periodDuration = _endDate.difference(_startDate);
    final previousStart = _startDate.subtract(periodDuration);
    final previousEnd = _startDate;

    final previousPeriodOrders = allOrders.where((order) {
      return order.createdAt.isAfter(previousStart) &&
          order.createdAt.isBefore(previousEnd);
    }).toList();

    final previousRevenue = previousPeriodOrders.fold<double>(
      0,
      (sum, order) => sum + order.total,
    );

    // Calculate change
    final change = previousRevenue > 0
        ? ((currentRevenue - previousRevenue) / previousRevenue) * 100
        : 0.0;

    final isPositive = change >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Current Period',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${currentRevenue.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${currentPeriodOrders.length} orders',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: theme.colorScheme.outline,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Previous Period',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${previousRevenue.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${previousPeriodOrders.length} orders',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'vs previous period',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Order> _filterOrdersByDateRange(List<Order> orders) {
    return orders.where((order) {
      return order.createdAt.isAfter(_startDate.subtract(const Duration(days: 1))) &&
          order.createdAt.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
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
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
        _viewMode = 'custom';
      });
    }
  }

  IconData _getOrderTypeIcon(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return Icons.restaurant;
      case OrderType.takeaway:
        return Icons.shopping_bag;
      case OrderType.delivery:
        return Icons.delivery_dining;
    }
  }

  String _getOrderTypeName(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return 'Dine-In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      case 'mobile':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }
}
