import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pos_core/pos_core.dart';

/// POS Terminal Page
///
/// Main cashier interface for processing orders and payments.
/// Features:
/// - Active orders display
/// - Quick order selection
/// - Order details view
/// - Process payment button
/// - Quick actions (refund, void, etc.)
class PosTerminalPage extends ConsumerStatefulWidget {
  const PosTerminalPage({super.key});

  @override
  ConsumerState<PosTerminalPage> createState() => _PosTerminalPageState();
}

class _PosTerminalPageState extends ConsumerState<PosTerminalPage> {
  Order? _selectedOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(ordersProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Terminal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('/transactions');
            },
            tooltip: 'Transaction History',
          ),
          IconButton(
            icon: const Icon(Icons.payments),
            onPressed: () {
              context.push('/cash-drawer');
            },
            tooltip: 'Cash Drawer',
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          final activeOrders = orders
              .where((o) => o.status == OrderStatus.ready || o.status == OrderStatus.preparing)
              .toList();

          return Row(
            children: [
              // Left: Orders list
              Expanded(
                flex: 2,
                child: _buildOrdersList(theme, activeOrders),
              ),

              // Right: Order details and payment
              Expanded(
                flex: 3,
                child: _selectedOrder != null
                    ? _buildOrderDetails(theme, _selectedOrder!)
                    : _buildEmptyState(theme),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading orders')),
      ),
    );
  }

  Widget _buildOrdersList(ThemeData theme, List<Order> orders) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Active Orders',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('${orders.length}'),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active orders',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final isSelected = _selectedOrder?.id == order.id;

                      return Card(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              _selectedOrder = order;
                            });
                          },
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                order.orderNumber,
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            'Order #${order.orderNumber}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${order.items.length} items • ${_formatOrderType(order.orderType)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${order.total.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('HH:mm').format(order.createdAt),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(ThemeData theme, Order order) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Order #${order.orderNumber}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text(_getStatusLabel(order.status)),
                      backgroundColor: _getStatusColor(order.status),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _getOrderTypeIcon(order.orderType),
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatOrderType(order.orderType),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, HH:mm').format(order.createdAt),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Order items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantity}x',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  title: Text(item.productName),
                  trailing: Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),

          // Order summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', order.subtotal),
                const SizedBox(height: 8),
                _buildSummaryRow('Tax', order.tax),
                const Divider(height: 24),
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

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showSplitBillDialog(context, order);
                    },
                    icon: const Icon(Icons.call_split),
                    label: const Text('Split Bill'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () {
                      context.push('/payment', extra: order);
                    },
                    icon: const Icon(Icons.payments),
                    label: const Text('Process Payment'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Select an order to process',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showSplitBillDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Split Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Split Evenly'),
              subtitle: const Text('Divide total equally'),
              onTap: () {
                Navigator.pop(context);
                context.push('/split-bill', extra: {'order': order, 'type': 'even'});
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Split by Item'),
              subtitle: const Text('Each person pays for their items'),
              onTap: () {
                Navigator.pop(context);
                context.push('/split-bill', extra: {'order': order, 'type': 'item'});
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Custom Split'),
              subtitle: const Text('Manual amount entry'),
              onTap: () {
                Navigator.pop(context);
                context.push('/split-bill', extra: {'order': order, 'type': 'custom'});
              },
            ),
          ],
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

  String _formatOrderType(String orderType) {
    switch (orderType.toLowerCase()) {
      case 'dinein':
        return 'Dine In';
      case 'takeaway':
        return 'Takeaway';
      case 'delivery':
        return 'Delivery';
      default:
        return orderType;
    }
  }

  IconData _getOrderTypeIcon(String orderType) {
    switch (orderType.toLowerCase()) {
      case 'dinein':
        return Icons.restaurant;
      case 'takeaway':
        return Icons.shopping_bag;
      case 'delivery':
        return Icons.delivery_dining;
      default:
        return Icons.receipt;
    }
  }

  String _getStatusLabel(OrderStatus status) {
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.withOpacity(0.2);
      case OrderStatus.preparing:
        return Colors.blue.withOpacity(0.2);
      case OrderStatus.ready:
        return Colors.green.withOpacity(0.2);
      case OrderStatus.completed:
        return Colors.grey.withOpacity(0.2);
      case OrderStatus.cancelled:
        return Colors.red.withOpacity(0.2);
    }
  }
}
