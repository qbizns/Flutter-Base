import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

/// Dashboard Home Page - Main overview screen
///
/// Features:
/// - Key metrics cards (sales, orders, avg order value)
/// - Today's performance summary
/// - Quick access to reports
/// - Recent orders list
/// - Top selling products
class DashboardHomePage extends ConsumerWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(ordersProvider());
    final productsAsync = ref.watch(productsProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(ordersProvider);
              ref.invalidate(productsProvider);
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ordersProvider);
          ref.invalidate(productsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text(
                'Welcome back!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Here\'s what\'s happening today',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Key metrics cards
              ordersAsync.when(
                data: (orders) => _buildMetricsGrid(context, orders),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),

              // Quick actions
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context),

              const SizedBox(height: 32),

              // Recent orders and top products side by side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent orders
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Orders',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/orders'),
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ordersAsync.when(
                          data: (orders) => _buildRecentOrders(context, orders),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const Text('Error loading orders'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Top products
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Top Selling Items',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/products'),
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        productsAsync.when(
                          data: (products) => _buildTopProducts(context, products),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const Text('Error loading products'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, List<Order> orders) {
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

    final avgOrderValue = todayOrders.isEmpty
        ? 0.0
        : totalSales / todayOrders.length;

    final completedOrders = todayOrders
        .where((o) => o.status == OrderStatus.completed)
        .length;

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
          title: 'Today\'s Sales',
          value: '\$${totalSales.toStringAsFixed(2)}',
          subtitle: '${todayOrders.length} orders',
          color: Colors.green,
        ),
        _buildMetricCard(
          context,
          icon: Icons.receipt_long,
          title: 'Orders',
          value: '${todayOrders.length}',
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
          icon: Icons.star,
          title: 'Top Item',
          value: _getTopProduct(todayOrders),
          subtitle: _getTopProductCount(todayOrders),
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
                const Spacer(),
                Icon(
                  Icons.more_vert,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
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

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            context,
            icon: Icons.assessment,
            label: 'Sales Report',
            onTap: () => context.go('/sales'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            context,
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
            onTap: () => context.go('/inventory'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            context,
            icon: Icons.people_outline,
            label: 'Staff',
            onTap: () => context.go('/staff'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            context,
            icon: Icons.download,
            label: 'Export Data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context, List<Order> allOrders) {
    final recentOrders = allOrders.take(5).toList();

    if (recentOrders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No recent orders',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Column(
      children: recentOrders.map((order) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order.status).withOpacity(0.1),
              child: Icon(
                _getStatusIcon(order.status),
                color: _getStatusColor(order.status),
              ),
            ),
            title: Text('Order #${order.orderNumber}'),
            subtitle: Text(
              '${_formatTime(order.createdAt)} • ${order.items.length} items',
            ),
            trailing: Text(
              '\$${order.total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopProducts(BuildContext context, List<Product> products) {
    // In a real app, this would be sorted by actual sales data
    final topProducts = products.take(5).toList();

    if (topProducts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No products available',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Column(
      children: topProducts.asMap().entries.map((entry) {
        final index = entry.key;
        final product = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            title: Text(product.name),
            subtitle: Text(product.category?.name ?? 'No category'),
            trailing: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getTopProduct(List<Order> orders) {
    if (orders.isEmpty) return 'N/A';

    // Count product occurrences
    final productCounts = <String, int>{};
    for (final order in orders) {
      for (final item in order.items) {
        productCounts[item.productName] =
            (productCounts[item.productName] ?? 0) + item.quantity;
      }
    }

    if (productCounts.isEmpty) return 'N/A';

    // Find top product
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
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.check_circle;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
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
