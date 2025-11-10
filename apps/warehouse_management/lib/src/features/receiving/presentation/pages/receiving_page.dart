import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Receiving & Putaway - Inbound stock processing
class ReceivingPage extends ConsumerStatefulWidget {
  const ReceivingPage({super.key});

  @override
  ConsumerState<ReceivingPage> createState() => _ReceivingPageState();
}

class _ReceivingPageState extends ConsumerState<ReceivingPage> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock receiving data
    final receivings = [
      ReceivingOrder(
        'RCV001',
        'PO-2024-145',
        'Fresh Foods Suppliers',
        ReceivingStatus.expected,
        [
          ReceivingItem('SKU001', 'Fresh Salmon Fillet', 100, 0, 0, 'A1-B2'),
          ReceivingItem('SKU002', 'Organic Tomatoes', 200, 0, 0, 'A2-C3'),
        ],
        DateTime.now().add(const Duration(hours: 3)),
        null,
        null,
        'Central Warehouse',
      ),
      ReceivingOrder(
        'RCV002',
        'PO-2024-148',
        'Premium Beverages Co',
        ReceivingStatus.receiving,
        [
          ReceivingItem('SKU004', 'Sparkling Water', 500, 350, 0, 'B3-D1'),
          ReceivingItem('SKU008', 'Fresh Orange Juice', 120, 80, 0, 'B3-D2'),
        ],
        DateTime.now().subtract(const Duration(hours: 1)),
        DateTime.now().subtract(const Duration(minutes: 30)),
        null,
        'Central Warehouse',
      ),
      ReceivingOrder(
        'RCV003',
        'PO-2024-142',
        'Office Supplies Inc',
        ReceivingStatus.putaway,
        [
          ReceivingItem('SKU005', 'Takeout Containers', 1000, 1000, 800, 'C1-A1'),
          ReceivingItem('SKU006', 'Paper Napkins', 1500, 1500, 1200, 'C1-A2'),
        ],
        DateTime.now().subtract(const Duration(hours: 4)),
        DateTime.now().subtract(const Duration(hours: 3)),
        DateTime.now().subtract(const Duration(hours: 2)),
        'North Distribution Center',
      ),
      ReceivingOrder(
        'RCV004',
        'PO-2024-139',
        'Fresh Foods Suppliers',
        ReceivingStatus.completed,
        [
          ReceivingItem('SKU003', 'Premium Coffee Beans', 80, 80, 80, 'A1-C4'),
        ],
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().subtract(const Duration(days: 1, hours: -1)),
        DateTime.now().subtract(const Duration(days: 1, hours: -2)),
        'South Distribution Center',
      ),
      ReceivingOrder(
        'RCV005',
        'PO-2024-151',
        'Cleaning Solutions Ltd',
        ReceivingStatus.discrepancy,
        [
          ReceivingItem('SKU007', 'Cleaning Spray', 100, 85, 0, 'D2-B3'),
          ReceivingItem('SKU009', 'Floor Cleaner', 50, 45, 0, 'D2-B4'),
        ],
        DateTime.now().subtract(const Duration(hours: 2)),
        DateTime.now().subtract(const Duration(hours: 1)),
        null,
        'Central Warehouse',
      ),
    ];

    // Apply filters
    final filteredReceivings = receivings.where((receiving) {
      if (_selectedStatus != 'All' && receiving.status.name != _selectedStatus.toLowerCase()) return false;
      return true;
    }).toList();

    final expectedCount = receivings.where((r) => r.status == ReceivingStatus.expected).length;
    final receivingCount = receivings.where((r) => r.status == ReceivingStatus.receiving).length;
    final putawayCount = receivings.where((r) => r.status == ReceivingStatus.putaway).length;
    final completedCount = receivings.where((r) => r.status == ReceivingStatus.completed).length;
    final discrepancyCount = receivings.where((r) => r.status == ReceivingStatus.discrepancy).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Receiving & Putaway')),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.schedule, color: Colors.blue.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$expectedCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                          Text('Expected', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.inventory, color: Colors.orange.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$receivingCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                          Text('Receiving', style: theme.textTheme.bodySmall),
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
                          Icon(Icons.move_to_inbox, color: Colors.purple.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$putawayCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                          Text('Putaway', style: theme.textTheme.bodySmall),
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
                          Text('$completedCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          Text('Completed', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.warning, color: Colors.red.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$discrepancyCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                          Text('Discrepancy', style: theme.textTheme.bodySmall),
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
              items: ['All', 'Expected', 'Receiving', 'Putaway', 'Completed', 'Discrepancy']
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
          ),
          const SizedBox(height: 16),

          // Receiving list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredReceivings.length,
              itemBuilder: (context, index) {
                final receiving = filteredReceivings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(receiving.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.local_shipping, color: _getStatusColor(receiving.status), size: 24),
                    ),
                    title: Row(
                      children: [
                        Text(receiving.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(receiving.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            receiving.status.displayName,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(receiving.status)),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('PO: ${receiving.purchaseOrderId} • ${receiving.supplier}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          '${receiving.location} • ETA: ${DateFormat('MMM dd, h:mm a').format(receiving.expectedArrival)}',
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
                            _buildInfoRow('Receiving ID', receiving.id),
                            _buildInfoRow('Purchase Order', receiving.purchaseOrderId),
                            _buildInfoRow('Supplier', receiving.supplier),
                            _buildInfoRow('Location', receiving.location),
                            _buildInfoRow('Status', receiving.status.displayName),
                            _buildInfoRow('Expected', DateFormat('MMM dd, yyyy h:mm a').format(receiving.expectedArrival)),
                            if (receiving.arrivedAt != null)
                              _buildInfoRow('Arrived', DateFormat('MMM dd, yyyy h:mm a').format(receiving.arrivedAt!)),
                            if (receiving.completedAt != null)
                              _buildInfoRow('Completed', DateFormat('MMM dd, yyyy h:mm a').format(receiving.completedAt!)),
                            const SizedBox(height: 16),
                            Text('Items (${receiving.items.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            ...receiving.items.map((item) {
                              final hasDiscrepancy = item.receivedQuantity > 0 && item.receivedQuantity != item.expectedQuantity;
                              return Card(
                                color: hasDiscrepancy ? Colors.red.shade50 : null,
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
                                          if (hasDiscrepancy)
                                            Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Expected', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                              Text('${item.expectedQuantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          if (item.receivedQuantity > 0) ...[
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Received', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                                Text(
                                                  '${item.receivedQuantity}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: hasDiscrepancy ? Colors.red : Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (item.putawayQuantity > 0) ...[
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Put Away', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                                Text('${item.putawayQuantity}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                                              ],
                                            ),
                                          ],
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Location', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                              Text(item.location, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (hasDiscrepancy) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Discrepancy: ${item.receivedQuantity - item.expectedQuantity > 0 ? '+' : ''}${item.receivedQuantity - item.expectedQuantity} units',
                                          style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w500),
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
                                if (receiving.status == ReceivingStatus.expected) ...([
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Start Receiving'),
                                    ),
                                  ),
                                ]),
                                if (receiving.status == ReceivingStatus.receiving) ...([
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
                                      icon: const Icon(Icons.check_circle, size: 18),
                                      label: const Text('Complete'),
                                    ),
                                  ),
                                ]),
                                if (receiving.status == ReceivingStatus.putaway) ...([
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.move_to_inbox, size: 18),
                                      label: const Text('Putaway'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.print, size: 18),
                                      label: const Text('Labels'),
                                    ),
                                  ),
                                ]),
                                if (receiving.status == ReceivingStatus.discrepancy) ...([
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.warning, size: 18),
                                      label: const Text('Resolve'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.report, size: 18),
                                      label: const Text('Report'),
                                    ),
                                  ),
                                ]),
                                if (receiving.status == ReceivingStatus.completed) ...([
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.print, size: 18),
                                      label: const Text('Print Receipt'),
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

  Color _getStatusColor(ReceivingStatus status) {
    switch (status) {
      case ReceivingStatus.expected: return Colors.blue;
      case ReceivingStatus.receiving: return Colors.orange;
      case ReceivingStatus.putaway: return Colors.purple;
      case ReceivingStatus.completed: return Colors.green;
      case ReceivingStatus.discrepancy: return Colors.red;
    }
  }
}

// Models
class ReceivingOrder {
  final String id;
  final String purchaseOrderId;
  final String supplier;
  final ReceivingStatus status;
  final List<ReceivingItem> items;
  final DateTime expectedArrival;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final String location;

  ReceivingOrder(
    this.id,
    this.purchaseOrderId,
    this.supplier,
    this.status,
    this.items,
    this.expectedArrival,
    this.arrivedAt,
    this.completedAt,
    this.location,
  );
}

class ReceivingItem {
  final String sku;
  final String productName;
  final int expectedQuantity;
  final int receivedQuantity;
  final int putawayQuantity;
  final String location;

  ReceivingItem(
    this.sku,
    this.productName,
    this.expectedQuantity,
    this.receivedQuantity,
    this.putawayQuantity,
    this.location,
  );
}

enum ReceivingStatus {
  expected('EXPECTED'),
  receiving('RECEIVING'),
  putaway('PUTAWAY'),
  completed('COMPLETED'),
  discrepancy('DISCREPANCY');

  final String displayName;
  const ReceivingStatus(this.displayName);
}
