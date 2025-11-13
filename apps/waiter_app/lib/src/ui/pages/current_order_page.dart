/// Current Order Page
/// Shows current order for a table with ability to add/modify items
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import '../../data/models/waiter_models.dart';
import '../../data/providers.dart';

/// Current Order Page
/// Display and modify current order for a table
class CurrentOrderPage extends ConsumerWidget {
  const CurrentOrderPage({
    super.key,
    required this.tableId,
  });

  final String tableId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get current order for table
    final ordersAsync = ref.watch(tableOrdersProvider(tableId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Table $tableId - Current Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () {
              context.push('/table/$tableId/order');
            },
            tooltip: 'Add Items',
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () {
              // TODO: Add order notes
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add notes feature')),
              );
            },
            tooltip: 'Add Notes',
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Error loading order', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return _buildEmptyState(context);
          }

          // Get the active order (first pending or preparing order)
          final currentOrder = orders.firstWhere(
            (o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.preparing,
            orElse: () => orders.first,
          );

          return _buildOrderContent(context, ref, currentOrder);
        },
      ),
      bottomNavigationBar: ordersAsync.when(
        data: (orders) => orders.isNotEmpty
            ? _buildBottomActions(context, orders.first)
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 80,
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Order',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Table is empty',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.push('/table/$tableId/order');
            },
            icon: const Icon(Icons.add),
            label: const Text('Start Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderContent(
    BuildContext context,
    WidgetRef ref,
    Order order,
  ) {
    return Column(
      children: [
        // Order header with total and status
        _buildOrderHeader(context, order),

        const Divider(height: 1),

        // Order items list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: order.items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return _buildOrderItem(context, ref, order.items[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderHeader(BuildContext context, Order order) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
                  '${order.items.length} items',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Chip(
                label: Text(
                  order.status.name.toUpperCase(),
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _getStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    WidgetRef ref,
    OrderItem item,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Text(
          '${item.quantity}x',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        item.productName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: item.selectedModifiers.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                ...item.selectedModifiers.map((modifier) => Text(
                      '+ ${modifier.name}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    )),
                if (item.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note: ${item.notes}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ],
            )
          : item.notes != null
              ? Text(
                  'Note: ${item.notes}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.secondary,
                  ),
                )
              : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${item.total.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, Order order) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/table/$tableId/order');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Items'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () {
                  context.push('/table/$tableId/checkout');
                },
                icon: const Icon(Icons.payment),
                label: Text('Checkout - \$${order.total.toStringAsFixed(2)}'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
