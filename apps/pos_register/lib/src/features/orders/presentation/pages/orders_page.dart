import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import 'package:pos_ui/pos_ui.dart';

/// Orders history page
class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  OrderStatus? _selectedStatus;
  OrderType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider(
      status: _selectedStatus,
      type: _selectedType,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(ordersProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters
          if (_selectedStatus != null || _selectedType != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 20),
                  const SizedBox(width: 8),
                  const Text('Filters:'),
                  const SizedBox(width: 8),
                  if (_selectedStatus != null)
                    Chip(
                      label: Text(_selectedStatus!.name),
                      onDeleted: () {
                        setState(() => _selectedStatus = null);
                      },
                    ),
                  if (_selectedType != null) ...[
                    const SizedBox(width: 4),
                    Chip(
                      label: Text(_getOrderTypeLabel(_selectedType!)),
                      onDeleted: () {
                        setState(() => _selectedType = null);
                      },
                    ),
                  ],
                ],
              ),
            ),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OrderCard(
                        order: order,
                        onTap: () => _showOrderDetails(order),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading orders: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Orders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Status Filter
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (_) {
                    setState(() => _selectedStatus = null);
                    Navigator.pop(context);
                  },
                ),
                ...OrderStatus.values.map((status) {
                  return FilterChip(
                    label: Text(status.name),
                    selected: _selectedStatus == status,
                    onSelected: (_) {
                      setState(() => _selectedStatus = status);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Type Filter
            const Text('Order Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedType == null,
                  onSelected: (_) {
                    setState(() => _selectedType = null);
                    Navigator.pop(context);
                  },
                ),
                ...OrderType.values.map((type) {
                  return FilterChip(
                    label: Text(_getOrderTypeLabel(type)),
                    selected: _selectedType == type,
                    onSelected: (_) {
                      setState(() => _selectedType = type);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _OrderDetailsSheet(
          order: order,
          scrollController: scrollController,
        ),
      ),
    );
  }

  String _getOrderTypeLabel(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return 'Dine In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
      case OrderType.driveThru:
        return 'Drive-Thru';
      case OrderType.online:
        return 'Online';
    }
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  const _OrderDetailsSheet({
    required this.order,
    required this.scrollController,
  });

  final Order order;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Handle
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: theme.dividerColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getOrderTypeLabel(order.orderType),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        const Divider(),

        // Content
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Order Items
              const Text(
                'Order Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderItemTile(
                      item: item,
                      showQuantityControls: false,
                    ),
                  )),

              const Divider(height: 32),

              // Order Summary
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Subtotal', order.subtotal),
              if (order.discountAmount > 0)
                _buildSummaryRow('Discount', -order.discountAmount),
              _buildSummaryRow('Tax', order.taxAmount),
              if (order.tipAmount > 0) _buildSummaryRow('Tip', order.tipAmount),
              const Divider(height: 24),
              _buildSummaryRow('Total', order.total, bold: true),

              if (order.tableName != null) ...[
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.table_restaurant),
                  title: const Text('Table'),
                  trailing: Text(order.tableName!),
                  contentPadding: EdgeInsets.zero,
                ),
              ],

              if (order.paymentMethod != null) ...[
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Payment Method'),
                  trailing: Text(order.paymentMethod!),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getOrderTypeLabel(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return 'Dine In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
      case OrderType.driveThru:
        return 'Drive-Thru';
      case OrderType.online:
        return 'Online';
    }
  }
}
