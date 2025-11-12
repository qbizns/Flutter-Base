import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

import '../widgets/kpi_card.dart';
import '../widgets/sales_trend_chart.dart';
import '../widgets/top_products_chart.dart';
import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';

/// Dashboard Home Page - Main overview screen with Odoo design
///
/// Features:
/// - KPI cards (Today's Sales, Orders, Active Tables, Top Product)
/// - Sales trend chart (last 7 days)
/// - Top products pie chart
/// - Recent orders table
class DashboardHomePage extends ConsumerWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider());
    final productsAsync = ref.watch(productsProvider());

    return Container(
      color: OdooColors.backgroundLight,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ordersProvider);
          ref.invalidate(productsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(OdooSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text(
                'Welcome back!',
                style: OdooTypography.pageTitle.copyWith(
                  color: OdooColors.textPrimary,
                ),
              ),
              const SizedBox(height: OdooSpacing.xs),
              Text(
                'Here\'s what\'s happening with your restaurant today',
                style: OdooTypography.bodyLarge.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
              const SizedBox(height: OdooSpacing.xl),

              // KPI Cards
              ordersAsync.when(
                data: (orders) => _buildKpiCards(context, orders),
                loading: () => _buildKpiCardsLoading(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: OdooSpacing.xl),

              // Charts Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sales Trend Chart
                  Expanded(
                    flex: 2,
                    child: SalesTrendChart(
                      salesData: _getMockSalesData(),
                    ),
                  ),
                  const SizedBox(width: OdooSpacing.lg),
                  // Top Products Chart
                  Expanded(
                    child: productsAsync.when(
                      data: (products) => TopProductsChart(
                        products: _getTopProductsSalesData(products),
                      ),
                      loading: () => const Card(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(48),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: OdooSpacing.xl),

              // Recent Orders Table
              Text(
                'Recent Orders',
                style: OdooTypography.cardTitle.copyWith(
                  color: OdooColors.textPrimary,
                ),
              ),
              const SizedBox(height: OdooSpacing.md),
              ordersAsync.when(
                data: (orders) => _buildRecentOrdersTable(context, orders),
                loading: () => _buildTableLoading(),
                error: (_, __) => const Text('Error loading orders'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCards(BuildContext context, List<Order> orders) {
    // Calculate today's metrics
    final today = DateTime.now();
    final todayOrders = orders.where((order) {
      return order.createdAt.year == today.year &&
          order.createdAt.month == today.month &&
          order.createdAt.day == today.day;
    }).toList();

    final totalSales = todayOrders.fold<double>(
      0,
      (sum, order) => sum + order.total,
    );

    final topProduct = _getTopProduct(todayOrders);
    final topProductCount = _getTopProductCount(todayOrders);

    // Mock active tables data (would come from backend in real app)
    const activeTables = 8;
    const totalTables = 15;

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: OdooSpacing.lg,
      mainAxisSpacing: OdooSpacing.lg,
      childAspectRatio: 1.4,
      children: [
        KpiCard(
          title: 'Today\'s Sales',
          value: '\$${totalSales.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          subtitle: '${todayOrders.length} orders',
          trend: '+12.5%',
          trendUp: true,
          color: OdooColors.success,
          onTap: () => context.go('/sales'),
        ),
        KpiCard(
          title: 'Orders Today',
          value: '${todayOrders.length}',
          icon: Icons.receipt_long_outlined,
          subtitle: 'Last hour: 8',
          trend: '+8.2%',
          trendUp: true,
          color: OdooColors.info,
          onTap: () => context.go('/sales'),
        ),
        KpiCard(
          title: 'Active Tables',
          value: '$activeTables/$totalTables',
          icon: Icons.restaurant_outlined,
          subtitle: '${totalTables - activeTables} available',
          color: OdooColors.warning,
          onTap: () => context.go('/restaurant'),
        ),
        KpiCard(
          title: 'Top Product',
          value: topProduct,
          icon: Icons.star_outline,
          subtitle: topProductCount,
          color: OdooColors.primary,
          onTap: () => context.go('/products'),
        ),
      ],
    );
  }

  Widget _buildKpiCardsLoading() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: OdooSpacing.lg,
      mainAxisSpacing: OdooSpacing.lg,
      childAspectRatio: 1.4,
      children: List.generate(
        4,
        (index) => const Card(
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildRecentOrdersTable(BuildContext context, List<Order> allOrders) {
    final recentOrders = allOrders.take(10).toList();

    if (recentOrders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(OdooSpacing.xxl),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: OdooColors.gray400,
                ),
                const SizedBox(height: OdooSpacing.md),
                Text(
                  'No recent orders',
                  style: OdooTypography.titleMedium.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: OdooSpacing.md,
                horizontal: OdooSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: OdooColors.gray50,
                borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ORDER #',
                      style: OdooTypography.tableHeader.copyWith(
                        color: OdooColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'TIME',
                      style: OdooTypography.tableHeader.copyWith(
                        color: OdooColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'TABLE',
                      style: OdooTypography.tableHeader.copyWith(
                        color: OdooColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ITEMS',
                      style: OdooTypography.tableHeader.copyWith(
                        color: OdooColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'STATUS',
                      style: OdooTypography.tableHeader.copyWith(
                        color: OdooColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'AMOUNT',
                      style: OdooTypography.tableHeader.copyWith(
                        color: OdooColors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: OdooSpacing.sm),

            // Table Rows
            ...recentOrders.map((order) => _buildOrderRow(context, order)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(BuildContext context, Order order) {
    final statusColor = _getStatusColor(order.status);

    return InkWell(
      onTap: () {
        // TODO: Navigate to order details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order #${order.orderNumber} details')),
        );
      },
      borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: OdooSpacing.md,
          horizontal: OdooSpacing.lg,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: OdooColors.border,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '#${order.orderNumber}',
                style: OdooTypography.tableCell.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatTime(order.createdAt),
                style: OdooTypography.tableCell,
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(
                    Icons.table_restaurant,
                    size: OdooIconSizes.sm,
                    color: OdooColors.textSecondary,
                  ),
                  const SizedBox(width: OdooSpacing.xs),
                  Text(
                    'Table ${(order.id.hashCode % 20) + 1}',
                    style: OdooTypography.tableCell,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${order.items.length} items',
                style: OdooTypography.tableCell,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: OdooSpacing.sm,
                  vertical: OdooSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(OdooSpacing.radiusStandard),
                ),
                child: Text(
                  _getStatusText(order.status),
                  style: OdooTypography.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: OdooTypography.tableCell.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableLoading() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.xxl),
        child: Center(
          child: CircularProgressIndicator(
            color: OdooColors.primary,
          ),
        ),
      ),
    );
  }

  // Mock data generators

  List<DailySales> _getMockSalesData() {
    // Generate mock sales data for last 7 days
    final today = DateTime.now();
    return List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      final amount = 500 + (index * 150) + (index % 2 * 200);
      return DailySales(date: date, amount: amount.toDouble());
    });
  }

  List<ProductSales> _getTopProductsSalesData(List<Product> products) {
    // Convert products to sales data (mock)
    return products.take(5).toList().asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      final quantity = 50 - (index * 8);
      final sales = product.price * quantity;
      return ProductSales(
        name: product.name,
        quantity: quantity,
        sales: sales,
      );
    }).toList();
  }

  String _getTopProduct(List<Order> orders) {
    if (orders.isEmpty) return 'N/A';

    final productCounts = <String, int>{};
    for (final order in orders) {
      for (final item in order.items) {
        productCounts[item.productName] =
            (productCounts[item.productName] ?? 0) + item.quantity;
      }
    }

    if (productCounts.isEmpty) return 'N/A';

    final topProduct = productCounts.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return topProduct.key;
  }

  String _getTopProductCount(List<Order> orders) {
    if (orders.isEmpty) return '0 sold';

    final productCounts = <String, int>{};
    for (final order in orders) {
      for (final item in order.items) {
        productCounts[item.productName] =
            (productCounts[item.productName] ?? 0) + item.quantity;
      }
    }

    if (productCounts.isEmpty) return '0 sold';

    final topCount = productCounts.values.reduce((a, b) => a > b ? a : b);
    return '$topCount sold';
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return OdooColors.statusPending;
      case OrderStatus.preparing:
        return OdooColors.statusInProgress;
      case OrderStatus.ready:
        return OdooColors.statusConfirmed;
      case OrderStatus.completed:
        return OdooColors.statusCompleted;
      case OrderStatus.cancelled:
        return OdooColors.statusCancelled;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }
}
