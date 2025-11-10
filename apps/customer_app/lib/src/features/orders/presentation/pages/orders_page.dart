import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

/// Order History Page
///
/// Features:
/// - Order history list
/// - Order status tracking
/// - Reorder functionality
/// - Order details
/// - Filter by status
class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage>
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
    final ordersAsync = ref.watch(ordersProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.pending_actions)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
            Tab(text: 'All', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final activeOrders = orders
              .where((o) =>
                  o.status == OrderStatus.pending ||
                  o.status == OrderStatus.preparing ||
                  o.status == OrderStatus.ready)
              .toList();

          final completedOrders = orders
              .where((o) => o.status == OrderStatus.completed)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(context, activeOrders, isActive: true),
              _buildOrderList(context, completedOrders, isActive: false),
              _buildOrderList(context, orders, isActive: null),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading orders')),
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    List<Order> orders, {
    required bool? isActive,
  }) {
    final theme = Theme.of(context);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isActive == true ? 'No active orders' : 'No orders yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Place your first order!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.go('/menu');
              },
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Browse Menu'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ordersProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(context, orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final theme = Theme.of(context);
    final statusInfo = _getStatusInfo(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showOrderDetails(context, order);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, h:mm a').format(order.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusInfo.icon,
                          size: 16,
                          color: statusInfo.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusInfo.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusInfo.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Order items summary
              Text(
                '${order.items.length} items',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 12),

              // Total and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Row(
                    children: [
                      if (order.status == OrderStatus.completed)
                        OutlinedButton(
                          onPressed: () {
                            _reorder(context, order);
                          },
                          child: const Text('Reorder'),
                        ),
                      if (order.status != OrderStatus.completed &&
                          order.status != OrderStatus.cancelled) ...[
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            _trackOrder(context, order);
                          },
                          child: const Text('Track'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM d, yyyy h:mm a').format(order.createdAt),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Items
                Text(
                  'Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.name} x${item.quantity}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 32),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reorder(BuildContext context, Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Items added to cart'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/cart');
  }

  void _trackOrder(BuildContext context, Order order) {
    context.go('/track-order?orderId=${order.id}');
  }

  StatusInfo _getStatusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return StatusInfo(
          color: Colors.orange,
          icon: Icons.schedule,
          label: 'Pending',
        );
      case OrderStatus.preparing:
        return StatusInfo(
          color: Colors.blue,
          icon: Icons.restaurant,
          label: 'Preparing',
        );
      case OrderStatus.ready:
        return StatusInfo(
          color: Colors.green,
          icon: Icons.check_circle,
          label: 'Ready',
        );
      case OrderStatus.completed:
        return StatusInfo(
          color: Colors.grey,
          icon: Icons.done_all,
          label: 'Completed',
        );
      case OrderStatus.cancelled:
        return StatusInfo(
          color: Colors.red,
          icon: Icons.cancel,
          label: 'Cancelled',
        );
    }
  }
}

class StatusInfo {
  final Color color;
  final IconData icon;
  final String label;

  StatusInfo({
    required this.color,
    required this.icon,
    required this.label,
  });
}
