import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Inventory Dashboard - Stock levels and warehouse inventory
class InventoryDashboardPage extends ConsumerStatefulWidget {
  const InventoryDashboardPage({super.key});

  @override
  ConsumerState<InventoryDashboardPage> createState() => _InventoryDashboardPageState();
}

class _InventoryDashboardPageState extends ConsumerState<InventoryDashboardPage> {
  String _selectedLocation = 'All';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock inventory data
    final inventory = [
      InventoryItem('SKU001', 'Fresh Salmon Fillet', 'Central Warehouse', 245, 50, 200, StockStatus.healthy, DateTime.now().add(const Duration(days: 5))),
      InventoryItem('SKU002', 'Organic Tomatoes', 'Central Warehouse', 18, 100, 300, StockStatus.low, DateTime.now().add(const Duration(days: 3))),
      InventoryItem('SKU003', 'Premium Coffee Beans', 'North Distribution Center', 0, 25, 100, StockStatus.outOfStock, null),
      InventoryItem('SKU004', 'Sparkling Water', 'Central Warehouse', 520, 50, 200, StockStatus.overstocked, DateTime.now().add(const Duration(days: 120))),
      InventoryItem('SKU005', 'Takeout Containers', 'South Distribution Center', 850, 150, 500, StockStatus.healthy, null),
      InventoryItem('SKU006', 'Paper Napkins', 'Central Warehouse', 45, 200, 600, StockStatus.low, null),
      InventoryItem('SKU007', 'Cleaning Spray', 'North Distribution Center', 82, 30, 100, StockStatus.healthy, DateTime.now().add(const Duration(days: 15))),
    ];

    // Apply filters
    final filteredInventory = inventory.where((item) {
      if (_selectedLocation != 'All' && item.location != _selectedLocation) return false;
      if (_selectedStatus != 'All' && item.status.name != _selectedStatus.toLowerCase().replaceAll(' ', '')) return false;
      return true;
    }).toList();

    final totalItems = inventory.length;
    final lowStockCount = inventory.where((i) => i.status == StockStatus.low).length;
    final outOfStockCount = inventory.where((i) => i.status == StockStatus.outOfStock).length;
    final totalValue = inventory.fold<double>(0, (sum, i) => sum + (i.quantity * 25.0)); // Mock pricing

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.inventory_2, color: theme.colorScheme.onPrimaryContainer, size: 20),
                              const SizedBox(width: 8),
                              Text('Total Items', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('$totalItems', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                          Text('SKUs in system', style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7))),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Low Stock', style: TextStyle(color: Colors.orange.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('$lowStockCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                          Text('Need reorder', style: TextStyle(fontSize: 12, color: Colors.orange.shade700.withOpacity(0.7))),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Out of Stock', style: TextStyle(color: Colors.red.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('$outOfStockCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                          Text('Critical', style: TextStyle(fontSize: 12, color: Colors.red.shade700.withOpacity(0.7))),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.attach_money, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Total Value', style: TextStyle(color: Colors.green.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalValue),
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                          ),
                          Text('Inventory value', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Central Warehouse', 'North Distribution Center', 'South Distribution Center']
                        .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedLocation = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Healthy', 'Low', 'Out Of Stock', 'Overstocked']
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedStatus = value!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Inventory list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredInventory.length,
              itemBuilder: (context, index) {
                final item = filteredInventory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.inventory_2, color: _getStatusColor(item.status), size: 24),
                    ),
                    title: Row(
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.status.displayName,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(item.status)),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('${item.sku} • ${item.location} • Qty: ${item.quantity}'),
                    trailing: Text(
                      '${item.quantity}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getStatusColor(item.status)),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow('SKU', item.sku),
                            _buildInfoRow('Product', item.name),
                            _buildInfoRow('Location', item.location),
                            _buildInfoRow('Current Quantity', '${item.quantity}'),
                            _buildInfoRow('Reorder Point', '${item.reorderPoint}'),
                            _buildInfoRow('Reorder Quantity', '${item.reorderQuantity}'),
                            _buildInfoRow('Status', item.status.displayName),
                            if (item.expiryDate != null)
                              _buildInfoRow('Expiry Date', DateFormat('MMM dd, yyyy').format(item.expiryDate!)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (item.status == StockStatus.low || item.status == StockStatus.outOfStock) ...[
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                                      label: const Text('Reorder'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Adjust'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.swap_horiz, size: 18),
                                    label: const Text('Transfer'),
                                  ),
                                ),
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

  Color _getStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.healthy: return Colors.green;
      case StockStatus.low: return Colors.orange;
      case StockStatus.outOfStock: return Colors.red;
      case StockStatus.overstocked: return Colors.blue;
    }
  }
}

// Models
class InventoryItem {
  final String sku;
  final String name;
  final String location;
  final int quantity;
  final int reorderPoint;
  final int reorderQuantity;
  final StockStatus status;
  final DateTime? expiryDate;

  InventoryItem(this.sku, this.name, this.location, this.quantity, this.reorderPoint, this.reorderQuantity, this.status, this.expiryDate);
}

enum StockStatus {
  healthy('HEALTHY'),
  low('LOW STOCK'),
  outOfStock('OUT OF STOCK'),
  overstocked('OVERSTOCKED');

  final String displayName;
  const StockStatus(this.displayName);
}
