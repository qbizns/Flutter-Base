import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Distribution & Fulfillment - Outbound orders and deliveries
class DistributionPage extends ConsumerStatefulWidget {
  const DistributionPage({super.key});

  @override
  ConsumerState<DistributionPage> createState() => _DistributionPageState();
}

class _DistributionPageState extends ConsumerState<DistributionPage> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock distribution data
    final orders = [
      DistributionOrder(
        'ORD001',
        'Downtown Branch',
        OrderStatus.pending,
        OrderPriority.high,
        [
          OrderItem('SKU001', 'Fresh Salmon Fillet', 30, 0, 0),
          OrderItem('SKU002', 'Organic Tomatoes', 50, 0, 0),
          OrderItem('SKU004', 'Sparkling Water', 100, 0, 0),
        ],
        DateTime.now(),
        DateTime.now().add(const Duration(hours: 4)),
        null,
        null,
        'Central Warehouse',
      ),
      DistributionOrder(
        'ORD002',
        'Brooklyn Heights',
        OrderStatus.picking,
        OrderPriority.medium,
        [
          OrderItem('SKU005', 'Takeout Containers', 200, 150, 0),
          OrderItem('SKU006', 'Paper Napkins', 300, 200, 0),
        ],
        DateTime.now().subtract(const Duration(hours: 1)),
        DateTime.now().add(const Duration(hours: 2)),
        DateTime.now().subtract(const Duration(minutes: 30)),
        null,
        'North Distribution Center',
      ),
      DistributionOrder(
        'ORD003',
        'Queens Plaza',
        OrderStatus.packing,
        OrderPriority.high,
        [
          OrderItem('SKU003', 'Premium Coffee Beans', 20, 20, 15),
          OrderItem('SKU007', 'Cleaning Spray', 40, 40, 30),
        ],
        DateTime.now().subtract(const Duration(hours: 3)),
        DateTime.now().add(const Duration(hours: 1)),
        DateTime.now().subtract(const Duration(hours: 2)),
        null,
        'South Distribution Center',
      ),
      DistributionOrder(
        'ORD004',
        'Westside Mall',
        OrderStatus.shipped,
        OrderPriority.medium,
        [
          OrderItem('SKU001', 'Fresh Salmon Fillet', 25, 25, 25),
          OrderItem('SKU002', 'Organic Tomatoes', 40, 40, 40),
        ],
        DateTime.now().subtract(const Duration(hours: 8)),
        DateTime.now().add(const Duration(hours: 1)),
        DateTime.now().subtract(const Duration(hours: 6)),
        DateTime.now().subtract(const Duration(hours: 4)),
        'Central Warehouse',
      ),
      DistributionOrder(
        'ORD005',
        'Airport Terminal',
        OrderStatus.delivered,
        OrderPriority.low,
        [
          OrderItem('SKU004', 'Sparkling Water', 80, 80, 80),
          OrderItem('SKU005', 'Takeout Containers', 150, 150, 150),
        ],
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().subtract(const Duration(hours: 12)),
        DateTime.now().subtract(const Duration(hours: 20)),
        DateTime.now().subtract(const Duration(hours: 18)),
        'North Distribution Center',
      ),
      DistributionOrder(
        'ORD006',
        'Downtown Branch',
        OrderStatus.cancelled,
        OrderPriority.low,
        [
          OrderItem('SKU008', 'Fresh Orange Juice', 60, 0, 0),
        ],
        DateTime.now().subtract(const Duration(days: 2)),
        DateTime.now().subtract(const Duration(days: 2, hours: -4)),
        null,
        null,
        'Central Warehouse',
      ),
    ];

    // Apply filters
    final filteredOrders = orders.where((order) {
      if (_selectedStatus != 'All' && order.status.name != _selectedStatus.toLowerCase()) return false;
      return true;
    }).toList();

    final pendingCount = orders.where((o) => o.status == OrderStatus.pending).length;
    final pickingCount = orders.where((o) => o.status == OrderStatus.picking).length;
    final packingCount = orders.where((o) => o.status == OrderStatus.packing).length;
    final shippedCount = orders.where((o) => o.status == OrderStatus.shipped).length;
    final deliveredCount = orders.where((o) => o.status == OrderStatus.delivered).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Distribution & Fulfillment')),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.hourglass_empty, color: Colors.orange.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$pendingCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                          Text('Pending', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_basket, color: Colors.blue.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$pickingCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                          Text('Picking', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.purple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2, color: Colors.purple.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$packingCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                          Text('Packing', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.local_shipping, color: Colors.teal.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$shippedCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
                          Text('Shipped', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$deliveredCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          Text('Delivered', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: ['All', 'Pending', 'Picking', 'Packing', 'Shipped', 'Delivered', 'Cancelled']
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
          ),
          const SizedBox(height: 16),

          // Orders list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.assignment, color: _getStatusColor(order.status), size: 24),
                    ),
                    title: Row(
                      children: [
                        Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status.displayName,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(order.status)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(order.priority).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.priority.displayName,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getPriorityColor(order.priority)),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('To: ${order.destination}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          '${order.warehouse} • Due: ${DateFormat('MMM dd, h:mm a').format(order.dueDate)}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Order ID', order.id),
                            _buildInfoRow('Destination', order.destination),
                            _buildInfoRow('Warehouse', order.warehouse),
                            _buildInfoRow('Status', order.status.displayName),
                            _buildInfoRow('Priority', order.priority.displayName),
                            _buildInfoRow('Created', DateFormat('MMM dd, yyyy h:mm a').format(order.createdAt)),
                            _buildInfoRow('Due', DateFormat('MMM dd, yyyy h:mm a').format(order.dueDate)),
                            if (order.pickedAt != null)
                              _buildInfoRow('Picked', DateFormat('MMM dd, yyyy h:mm a').format(order.pickedAt!)),
                            if (order.shippedAt != null)
                              _buildInfoRow('Shipped', DateFormat('MMM dd, yyyy h:mm a').format(order.shippedAt!)),
                            const SizedBox(height: 16),
                            Text('Items (${order.items.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            ...order.items.map((item) {
                              final pickProgress = item.orderedQuantity > 0 ? (item.pickedQuantity / item.orderedQuantity * 100).round() : 0;
                              final packProgress = item.orderedQuantity > 0 ? (item.packedQuantity / item.orderedQuantity * 100).round() : 0;

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                                Text(item.sku, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Ordered', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                              Text('${item.orderedQuantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          if (item.pickedQuantity > 0) ...[
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Picked', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                                Text('${item.pickedQuantity} ($pickProgress%)', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                              ],
                                            ),
                                          ],
                                          if (item.packedQuantity > 0) ...[
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Packed', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                                Text('${item.packedQuantity} ($packProgress%)', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (order.status == OrderStatus.picking && item.pickedQuantity < item.orderedQuantity) ...[
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: pickProgress / 100,
                                          backgroundColor: theme.colorScheme.surfaceVariant,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                        ),
                                      ],
                                      if (order.status == OrderStatus.packing && item.packedQuantity < item.orderedQuantity) ...[
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: packProgress / 100,
                                          backgroundColor: theme.colorScheme.surfaceVariant,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (order.status == OrderStatus.pending) ...([
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.play_arrow, size: 18),
                                      label: const Text('Start Picking'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.cancel, size: 18),
                                      label: const Text('Cancel'),
                                    ),
                                  ),
                                ]),
                                if (order.status == OrderStatus.picking) ...([
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.scanner, size: 18),
                                      label: const Text('Scan Items'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Complete'),
                                    ),
                                  ),
                                ]),
                                if (order.status == OrderStatus.packing) ...([
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.inventory_2, size: 18),
                                      label: const Text('Pack Items'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.local_shipping, size: 18),
                                      label: const Text('Ship'),
                                    ),
                                  ),
                                ]),
                                if (order.status == OrderStatus.shipped) ...([
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.location_on, size: 18),
                                      label: const Text('Track'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.print, size: 18),
                                      label: const Text('BOL'),
                                    ),
                                  ),
                                ]),
                                if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) ...([
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.print, size: 18),
                                      label: const Text('Print Report'),
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.picking: return Colors.blue;
      case OrderStatus.packing: return Colors.purple;
      case OrderStatus.shipped: return Colors.teal;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return Colors.grey;
    }
  }

  Color _getPriorityColor(OrderPriority priority) {
    switch (priority) {
      case OrderPriority.high: return Colors.red;
      case OrderPriority.medium: return Colors.orange;
      case OrderPriority.low: return Colors.blue;
    }
  }
}

// Models
class DistributionOrder {
  final String id;
  final String destination;
  final OrderStatus status;
  final OrderPriority priority;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime dueDate;
  final DateTime? pickedAt;
  final DateTime? shippedAt;
  final String warehouse;

  DistributionOrder(
    this.id,
    this.destination,
    this.status,
    this.priority,
    this.items,
    this.createdAt,
    this.dueDate,
    this.pickedAt,
    this.shippedAt,
    this.warehouse,
  );
}

class OrderItem {
  final String sku;
  final String productName;
  final int orderedQuantity;
  final int pickedQuantity;
  final int packedQuantity;

  OrderItem(
    this.sku,
    this.productName,
    this.orderedQuantity,
    this.pickedQuantity,
    this.packedQuantity,
  );
}

enum OrderStatus {
  pending('PENDING'),
  picking('PICKING'),
  packing('PACKING'),
  shipped('SHIPPED'),
  delivered('DELIVERED'),
  cancelled('CANCELLED');

  final String displayName;
  const OrderStatus(this.displayName);
}

enum OrderPriority {
  high('HIGH'),
  medium('MEDIUM'),
  low('LOW');

  final String displayName;
  const OrderPriority(this.displayName);
}
