/// Active Orders Page
/// Shows all active orders for the current waiter
/// Following Odoo POS order tracking patterns
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/waiter_models.dart';
import '../../data/providers.dart';

/// Active Orders Page
/// List of all orders currently being handled
class ActiveOrdersPage extends ConsumerWidget {
  const ActiveOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeOrdersAsync = ref.watch(activeOrdersProvider);
    final currentWaiter = ref.watch(currentWaiterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active Orders'),
            if (currentWaiter != null)
              Text(
                currentWaiter.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(activeOrdersProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: activeOrdersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load orders',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(activeOrdersProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active orders',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Orders will appear here when you start taking them',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Group orders by status
          final ordersByStatus = _groupOrdersByStatus(orders);

          return DefaultTabController(
            length: ordersByStatus.length,
            child: Column(
              children: [
                // Status tabs
                TabBar(
                  isScrollable: true,
                  tabs: ordersByStatus.entries.map((entry) {
                    final status = entry.key;
                    final statusOrders = entry.value;

                    return Tab(
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_getStatusText(status)),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${statusOrders.length}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                // Order lists
                Expanded(
                  child: TabBarView(
                    children: ordersByStatus.values.map((statusOrders) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: statusOrders.length,
                        itemBuilder: (context, index) {
                          final order = statusOrders[index];
                          return _OrderCard(
                            order: order,
                            onTap: () {
                              context.push('/table/${order.tableId}/current-order');
                            },
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Group orders by status
  Map<TableOrderStatus, List<TableOrder>> _groupOrdersByStatus(
    List<TableOrder> orders,
  ) {
    final grouped = <TableOrderStatus, List<TableOrder>>{};

    for (final order in orders) {
      grouped.putIfAbsent(order.status, () => []).add(order);
    }

    // Sort by status priority
    final sorted = Map.fromEntries(
      grouped.entries.toList()
        ..sort((a, b) => _getStatusPriority(a.key).compareTo(
              _getStatusPriority(b.key),
            )),
    );

    return sorted;
  }

  /// Get status priority for sorting
  int _getStatusPriority(TableOrderStatus status) {
    switch (status) {
      case TableOrderStatus.draft:
        return 1;
      case TableOrderStatus.sent:
        return 2;
      case TableOrderStatus.preparing:
        return 3;
      case TableOrderStatus.ready:
        return 4;
      case TableOrderStatus.served:
        return 5;
      case TableOrderStatus.paid:
        return 6;
      case TableOrderStatus.cancelled:
        return 7;
    }
  }

  Color _getStatusColor(TableOrderStatus status) {
    switch (status) {
      case TableOrderStatus.draft:
        return Colors.grey;
      case TableOrderStatus.sent:
        return Colors.blue;
      case TableOrderStatus.preparing:
        return Colors.orange;
      case TableOrderStatus.ready:
        return Colors.green;
      case TableOrderStatus.served:
        return Colors.teal;
      case TableOrderStatus.paid:
        return Colors.purple;
      case TableOrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(TableOrderStatus status) {
    switch (status) {
      case TableOrderStatus.draft:
        return 'Draft';
      case TableOrderStatus.sent:
        return 'Sent';
      case TableOrderStatus.preparing:
        return 'Preparing';
      case TableOrderStatus.ready:
        return 'Ready';
      case TableOrderStatus.served:
        return 'Served';
      case TableOrderStatus.paid:
        return 'Paid';
      case TableOrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Order card widget
class _OrderCard extends StatelessWidget {
  final TableOrder order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusColor = _getStatusColor(order.status);
    final elapsed = DateTime.now().difference(order.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Table info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.table_restaurant,
                              size: 20,
                              color: statusColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              order.tableName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${order.orderNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Order details
              Row(
                children: [
                  // Guest count
                  if (order.guestCount != null)
                    _InfoChip(
                      icon: Icons.person,
                      label: '${order.guestCount}',
                    ),
                  if (order.guestCount != null) const SizedBox(width: 8),

                  // Item count
                  _InfoChip(
                    icon: Icons.shopping_cart,
                    label: '${order.items.length} items',
                  ),
                  const SizedBox(width: 8),

                  // Time elapsed
                  _InfoChip(
                    icon: Icons.access_time,
                    label: _formatDuration(elapsed),
                    color: elapsed.inMinutes > 30
                        ? Colors.red
                        : colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const Spacer(),

                  // Total amount
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),

              // Item summary
              if (order.items.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: order.items.take(3).map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}x ${item.productName}',
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  }).toList()
                    ..addAll([
                      if (order.items.length > 3)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${order.items.length - 3} more',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TableOrderStatus status) {
    switch (status) {
      case TableOrderStatus.draft:
        return Colors.grey;
      case TableOrderStatus.sent:
        return Colors.blue;
      case TableOrderStatus.preparing:
        return Colors.orange;
      case TableOrderStatus.ready:
        return Colors.green;
      case TableOrderStatus.served:
        return Colors.teal;
      case TableOrderStatus.paid:
        return Colors.purple;
      case TableOrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

/// Info chip widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface.withOpacity(0.6);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: effectiveColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: effectiveColor,
          ),
        ),
      ],
    );
  }
}
