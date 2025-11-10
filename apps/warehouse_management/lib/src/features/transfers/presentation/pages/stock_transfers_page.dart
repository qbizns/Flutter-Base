import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Stock Transfers - Inter-warehouse inventory transfers
class StockTransfersPage extends ConsumerStatefulWidget {
  const StockTransfersPage({super.key});

  @override
  ConsumerState<StockTransfersPage> createState() => _StockTransfersPageState();
}

class _StockTransfersPageState extends ConsumerState<StockTransfersPage> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock transfer data
    final transfers = [
      StockTransfer(
        'TRF001',
        'Central Warehouse',
        'North Distribution Center',
        TransferStatus.pending,
        [
          TransferItem('SKU001', 'Fresh Salmon Fillet', 50),
          TransferItem('SKU002', 'Organic Tomatoes', 100),
        ],
        DateTime.now(),
        null,
        null,
        'John Smith',
      ),
      StockTransfer(
        'TRF002',
        'Central Warehouse',
        'South Distribution Center',
        TransferStatus.inTransit,
        [
          TransferItem('SKU005', 'Takeout Containers', 200),
          TransferItem('SKU006', 'Paper Napkins', 300),
        ],
        DateTime.now().subtract(const Duration(hours: 3)),
        DateTime.now().subtract(const Duration(hours: 1)),
        DateTime.now().add(const Duration(hours: 2)),
        'Sarah Johnson',
      ),
      StockTransfer(
        'TRF003',
        'North Distribution Center',
        'Central Warehouse',
        TransferStatus.completed,
        [
          TransferItem('SKU007', 'Cleaning Spray', 25),
        ],
        DateTime.now().subtract(const Duration(days: 2)),
        DateTime.now().subtract(const Duration(days: 2, hours: -2)),
        null,
        'Mike Davis',
      ),
      StockTransfer(
        'TRF004',
        'Central Warehouse',
        'North Distribution Center',
        TransferStatus.cancelled,
        [
          TransferItem('SKU004', 'Sparkling Water', 100),
        ],
        DateTime.now().subtract(const Duration(days: 5)),
        null,
        null,
        'Emily Brown',
      ),
      StockTransfer(
        'TRF005',
        'South Distribution Center',
        'Central Warehouse',
        TransferStatus.inTransit,
        [
          TransferItem('SKU003', 'Premium Coffee Beans', 40),
          TransferItem('SKU001', 'Fresh Salmon Fillet', 30),
        ],
        DateTime.now().subtract(const Duration(hours: 6)),
        DateTime.now().subtract(const Duration(hours: 4)),
        DateTime.now().add(const Duration(hours: 1)),
        'David Wilson',
      ),
    ];

    // Apply filters
    final filteredTransfers = transfers.where((transfer) {
      if (_selectedStatus != 'All' && transfer.status.name != _selectedStatus.toLowerCase().replaceAll(' ', '')) return false;
      return true;
    }).toList();

    final pendingCount = transfers.where((t) => t.status == TransferStatus.pending).length;
    final inTransitCount = transfers.where((t) => t.status == TransferStatus.inTransit).length;
    final completedCount = transfers.where((t) => t.status == TransferStatus.completed).length;
    final cancelledCount = transfers.where((t) => t.status == TransferStatus.cancelled).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Transfers')),
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
                          Icon(Icons.pending, color: Colors.orange.shade700, size: 28),
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
                          Icon(Icons.local_shipping, color: Colors.blue.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$inTransitCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                          Text('In Transit', style: theme.textTheme.bodySmall),
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
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.cancel, color: Colors.grey.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$cancelledCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          Text('Cancelled', style: theme.textTheme.bodySmall),
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
              items: ['All', 'Pending', 'In Transit', 'Completed', 'Cancelled']
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
          ),
          const SizedBox(height: 16),

          // Transfers list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTransfers.length,
              itemBuilder: (context, index) {
                final transfer = filteredTransfers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transfer.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.compare_arrows, color: _getStatusColor(transfer.status), size: 24),
                    ),
                    title: Row(
                      children: [
                        Text(transfer.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(transfer.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            transfer.status.displayName,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(transfer.status)),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${transfer.sourceLocation} → ${transfer.destinationLocation}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${transfer.items.length} items • Created ${DateFormat('MMM dd, h:mm a').format(transfer.createdAt)}',
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
                            _buildInfoRow('Transfer ID', transfer.id),
                            _buildInfoRow('Source', transfer.sourceLocation),
                            _buildInfoRow('Destination', transfer.destinationLocation),
                            _buildInfoRow('Status', transfer.status.displayName),
                            _buildInfoRow('Created By', transfer.createdBy),
                            _buildInfoRow('Created', DateFormat('MMM dd, yyyy h:mm a').format(transfer.createdAt)),
                            if (transfer.shippedAt != null)
                              _buildInfoRow('Shipped', DateFormat('MMM dd, yyyy h:mm a').format(transfer.shippedAt!)),
                            if (transfer.estimatedArrival != null)
                              _buildInfoRow('ETA', DateFormat('MMM dd, yyyy h:mm a').format(transfer.estimatedArrival!)),
                            const SizedBox(height: 16),
                            Text('Items (${transfer.items.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            ...transfer.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
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
                                  Text('Qty: ${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (transfer.status == TransferStatus.pending) ...([
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.local_shipping, size: 18),
                                      label: const Text('Ship'),
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
                                if (transfer.status == TransferStatus.inTransit) ...([
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.check_circle, size: 18),
                                      label: const Text('Receive'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.location_on, size: 18),
                                      label: const Text('Track'),
                                    ),
                                  ),
                                ]),
                                if (transfer.status == TransferStatus.completed) ...([
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.print, size: 18),
                                      label: const Text('Print Report'),
                                    ),
                                  ),
                                ]),
                                if (transfer.status == TransferStatus.cancelled) ...([
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Delete'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Transfer'),
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

  Color _getStatusColor(TransferStatus status) {
    switch (status) {
      case TransferStatus.pending: return Colors.orange;
      case TransferStatus.inTransit: return Colors.blue;
      case TransferStatus.completed: return Colors.green;
      case TransferStatus.cancelled: return Colors.grey;
    }
  }
}

// Models
class StockTransfer {
  final String id;
  final String sourceLocation;
  final String destinationLocation;
  final TransferStatus status;
  final List<TransferItem> items;
  final DateTime createdAt;
  final DateTime? shippedAt;
  final DateTime? estimatedArrival;
  final String createdBy;

  StockTransfer(
    this.id,
    this.sourceLocation,
    this.destinationLocation,
    this.status,
    this.items,
    this.createdAt,
    this.shippedAt,
    this.estimatedArrival,
    this.createdBy,
  );
}

class TransferItem {
  final String sku;
  final String productName;
  final int quantity;

  TransferItem(this.sku, this.productName, this.quantity);
}

enum TransferStatus {
  pending('PENDING'),
  inTransit('IN TRANSIT'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  final String displayName;
  const TransferStatus(this.displayName);
}
