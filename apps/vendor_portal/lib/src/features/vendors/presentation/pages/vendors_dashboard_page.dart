import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Vendors Dashboard - Supplier directory and management
class VendorsDashboardPage extends ConsumerStatefulWidget {
  const VendorsDashboardPage({super.key});

  @override
  ConsumerState<VendorsDashboardPage> createState() => _VendorsDashboardPageState();
}

class _VendorsDashboardPageState extends ConsumerState<VendorsDashboardPage> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock vendor data
    final vendors = [
      Vendor('VEN001', 'Fresh Foods Suppliers', VendorCategory.food, VendorStatus.active, 'contact@freshfoods.com', '+1 (555) 100-1000', 'Net 30', 4.8, 142, 45280.50),
      Vendor('VEN002', 'Beverage Distributors Inc', VendorCategory.beverage, VendorStatus.active, 'sales@bevdist.com', '+1 (555) 200-2000', 'Net 60', 4.5, 98, 32150.75),
      Vendor('VEN003', 'Restaurant Equipment Co', VendorCategory.equipment, VendorStatus.active, 'info@restequip.com', '+1 (555) 300-3000', 'Net 30', 4.9, 24, 18920.00),
      Vendor('VEN004', 'Packaging Solutions', VendorCategory.packaging, VendorStatus.active, 'hello@packagesol.com', '+1 (555) 400-4000', 'COD', 4.2, 56, 12450.25),
      Vendor('VEN005', 'Office Supplies Direct', VendorCategory.supplies, VendorStatus.active, 'support@officesupply.com', '+1 (555) 500-5000', 'Net 30', 4.6, 38, 8920.50),
      Vendor('VEN006', 'Cleaning Services Pro', VendorCategory.cleaning, VendorStatus.pending, 'contact@cleanpro.com', '+1 (555) 600-6000', 'Net 30', 0, 0, 0),
      Vendor('VEN007', 'Seasonal Produce Co', VendorCategory.food, VendorStatus.inactive, 'info@seasonalproduce.com', '+1 (555) 700-7000', 'Net 30', 3.8, 24, 5680.00),
    ];

    // Apply filters
    final filteredVendors = vendors.where((v) {
      if (_selectedCategory != 'All' && v.category.name != _selectedCategory.toLowerCase()) return false;
      if (_selectedStatus != 'All' && v.status.name != _selectedStatus.toLowerCase()) return false;
      return true;
    }).toList();

    final activeVendors = vendors.where((v) => v.status == VendorStatus.active).length;
    final pendingVendors = vendors.where((v) => v.status == VendorStatus.pending).length;
    final totalSpend = vendors.where((v) => v.status == VendorStatus.active).fold<double>(0, (sum, v) => sum + v.totalSpend);
    final avgRating = vendors.where((v) => v.status == VendorStatus.active && v.rating > 0).fold<double>(0, (sum, v) => sum + v.rating) / activeVendors;

    return Scaffold(
      appBar: AppBar(title: const Text('Vendors')),
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
                              Icon(Icons.business, color: theme.colorScheme.onPrimaryContainer, size: 20),
                              const SizedBox(width: 8),
                              Text('Active Vendors', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$activeVendors',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                          ),
                          Text('Suppliers', style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7))),
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
                              Icon(Icons.pending, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Pending', style: TextStyle(color: Colors.orange.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$pendingVendors',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                          ),
                          Text('Awaiting approval', style: TextStyle(fontSize: 12, color: Colors.orange.shade700.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: theme.colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.attach_money, color: theme.colorScheme.onSecondaryContainer, size: 20),
                              const SizedBox(width: 8),
                              Text('Total Spend', style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalSpend),
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer),
                          ),
                          Text('This year', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7))),
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
                              Icon(Icons.star, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Avg Rating', style: TextStyle(color: Colors.green.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                          ),
                          Text('Out of 5.0', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
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
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Food', 'Beverage', 'Equipment', 'Packaging', 'Supplies', 'Cleaning']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value!),
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
                    items: ['All', 'Active', 'Pending', 'Inactive']
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedStatus = value!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Vendors list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredVendors.length,
              itemBuilder: (context, index) {
                final vendor = filteredVendors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(vendor.category).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getCategoryIcon(vendor.category), color: _getCategoryColor(vendor.category), size: 24),
                    ),
                    title: Row(
                      children: [
                        Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(vendor.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vendor.status.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(vendor.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('${vendor.id} • ${vendor.category.name.toUpperCase()} • ${vendor.paymentTerms}'),
                    trailing: vendor.status == VendorStatus.active
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    vendor.rating.toStringAsFixed(1),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                '${vendor.orderCount} orders',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          )
                        : null,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.badge, 'Vendor ID', vendor.id),
                            _buildInfoRow(Icons.business, 'Name', vendor.name),
                            _buildInfoRow(Icons.category, 'Category', vendor.category.name.toUpperCase()),
                            _buildInfoRow(Icons.email, 'Email', vendor.email),
                            _buildInfoRow(Icons.phone, 'Phone', vendor.phone),
                            _buildInfoRow(Icons.payment, 'Payment Terms', vendor.paymentTerms),
                            if (vendor.status == VendorStatus.active) ...[
                              _buildInfoRow(Icons.star, 'Rating', '${vendor.rating.toStringAsFixed(1)} / 5.0'),
                              _buildInfoRow(Icons.shopping_cart, 'Total Orders', '${vendor.orderCount}'),
                              _buildInfoRow(Icons.attach_money, 'Total Spend', NumberFormat.currency(symbol: '\$').format(vendor.totalSpend)),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (vendor.status == VendorStatus.pending) ...[
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
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Edit'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.history, size: 18),
                                      label: const Text('History'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.message, size: 18),
                                      label: const Text('Contact'),
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
        label: const Text('Add Vendor'),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 2,
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(VendorCategory category) {
    switch (category) {
      case VendorCategory.food: return Colors.green;
      case VendorCategory.beverage: return Colors.blue;
      case VendorCategory.equipment: return Colors.orange;
      case VendorCategory.packaging: return Colors.purple;
      case VendorCategory.supplies: return Colors.teal;
      case VendorCategory.cleaning: return Colors.indigo;
    }
  }

  IconData _getCategoryIcon(VendorCategory category) {
    switch (category) {
      case VendorCategory.food: return Icons.restaurant;
      case VendorCategory.beverage: return Icons.local_drink;
      case VendorCategory.equipment: return Icons.kitchen;
      case VendorCategory.packaging: return Icons.inventory_2;
      case VendorCategory.supplies: return Icons.business_center;
      case VendorCategory.cleaning: return Icons.cleaning_services;
    }
  }

  Color _getStatusColor(VendorStatus status) {
    switch (status) {
      case VendorStatus.active: return Colors.green;
      case VendorStatus.pending: return Colors.orange;
      case VendorStatus.inactive: return Colors.grey;
    }
  }
}

// Models
class Vendor {
  final String id;
  final String name;
  final VendorCategory category;
  final VendorStatus status;
  final String email;
  final String phone;
  final String paymentTerms;
  final double rating;
  final int orderCount;
  final double totalSpend;

  Vendor(this.id, this.name, this.category, this.status, this.email, this.phone, this.paymentTerms, this.rating, this.orderCount, this.totalSpend);
}

enum VendorCategory { food, beverage, equipment, packaging, supplies, cleaning }
enum VendorStatus { active, pending, inactive }
