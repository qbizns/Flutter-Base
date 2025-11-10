import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Purchase Orders - Manage procurement and purchase orders
class PurchaseOrdersPage extends ConsumerStatefulWidget {
  const PurchaseOrdersPage({super.key});

  @override
  ConsumerState<PurchaseOrdersPage> createState() => _PurchaseOrdersPageState();
}

class _PurchaseOrdersPageState extends ConsumerState<PurchaseOrdersPage> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final purchaseOrders = [
      PurchaseOrder('PO-2024-001', 'Fresh Foods Suppliers', DateTime.now().subtract(const Duration(days: 1)), DateTime.now().add(const Duration(days: 7)), 4520.50, POStatus.approved, 12),
      PurchaseOrder('PO-2024-002', 'Beverage Distributors Inc', DateTime.now().subtract(const Duration(hours: 5)), DateTime.now().add(const Duration(days: 5)), 3240.75, POStatus.pending, 8),
      PurchaseOrder('PO-2024-003', 'Restaurant Equipment Co', DateTime.now().subtract(const Duration(days: 3)), DateTime.now().subtract(const Duration(days: 1)), 12890.00, POStatus.received, 4),
      PurchaseOrder('PO-2024-004', 'Packaging Solutions', DateTime.now(), DateTime.now().add(const Duration(days: 3)), 1850.25, POStatus.draft, 18),
      PurchaseOrder('PO-2024-005', 'Office Supplies Direct', DateTime.now().subtract(const Duration(days: 5)), DateTime.now().subtract(const Duration(days: 2)), 680.50, POStatus.cancelled, 6),
    ];

    final filteredOrders = purchaseOrders.where((po) {
      if (_selectedStatus != 'All' && po.status.name != _selectedStatus.toLowerCase()) return false;
      return true;
    }).toList();

    final draftCount = purchaseOrders.where((po) => po.status == POStatus.draft).length;
    final pendingCount = purchaseOrders.where((po) => po.status == POStatus.pending).length;
    final approvedCount = purchaseOrders.where((po) => po.status == POStatus.approved).length;
    final totalValue = filteredOrders.fold<double>(0, (sum, po) => sum + po.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Orders')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.drafts, color: Colors.grey.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$draftCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          Text('Draft', style: theme.textTheme.bodySmall),
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
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$approvedCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          Text('Approved', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.attach_money, color: theme.colorScheme.onPrimaryContainer, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalValue),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                          ),
                          Text('Total Value', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: ['All', 'Draft', 'Pending', 'Approved', 'Received', 'Cancelled']
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final po = filteredOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(po.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.shopping_cart, color: _getStatusColor(po.status), size: 20),
                    ),
                    title: Row(
                      children: [
                        Text(po.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(po.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            po.status.name.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(po.status)),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('${po.vendor} • ${po.itemCount} items • Due: ${DateFormat('MMM dd').format(po.expectedDate)}'),
                    trailing: Text(
                      NumberFormat.currency(symbol: '\$').format(po.amount),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow('PO Number', po.id),
                            _buildInfoRow('Vendor', po.vendor),
                            _buildInfoRow('Items', '${po.itemCount}'),
                            _buildInfoRow('Amount', NumberFormat.currency(symbol: '\$').format(po.amount)),
                            _buildInfoRow('Order Date', DateFormat('MMM dd, yyyy').format(po.orderDate)),
                            _buildInfoRow('Expected Date', DateFormat('MMM dd, yyyy').format(po.expectedDate)),
                            _buildInfoRow('Status', po.status.name.toUpperCase()),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (po.status == POStatus.draft) ...[
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.send, size: 18),
                                      label: const Text('Submit'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Edit'),
                                    ),
                                  ),
                                ] else if (po.status == POStatus.pending) ...[
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Approve'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.close, size: 18),
                                      label: const Text('Reject'),
                                    ),
                                  ),
                                ] else if (po.status == POStatus.approved) ...[
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.inventory, size: 18),
                                      label: const Text('Receive'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.download, size: 18),
                                      label: const Text('Download'),
                                    ),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.visibility, size: 18),
                                      label: const Text('View Details'),
                                    ),
                                  ),
                                ],
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
        label: const Text('New PO'),
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

  Color _getStatusColor(POStatus status) {
    switch (status) {
      case POStatus.draft: return Colors.grey;
      case POStatus.pending: return Colors.orange;
      case POStatus.approved: return Colors.green;
      case POStatus.received: return Colors.blue;
      case POStatus.cancelled: return Colors.red;
    }
  }
}

class PurchaseOrder {
  final String id;
  final String vendor;
  final DateTime orderDate;
  final DateTime expectedDate;
  final double amount;
  final POStatus status;
  final int itemCount;

  PurchaseOrder(this.id, this.vendor, this.orderDate, this.expectedDate, this.amount, this.status, this.itemCount);
}

enum POStatus { draft, pending, approved, received, cancelled }
