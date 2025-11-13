import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

/// Customer selection dialog for POS
class CustomerSelectDialog extends ConsumerStatefulWidget {
  const CustomerSelectDialog({super.key});

  @override
  ConsumerState<CustomerSelectDialog> createState() =>
      _CustomerSelectDialogState();

  static Future<Customer?> show(BuildContext context) {
    return showDialog<Customer>(
      context: context,
      builder: (context) => const CustomerSelectDialog(),
    );
  }
}

class _CustomerSelectDialogState extends ConsumerState<CustomerSelectDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Integrate with customers provider when available
    // For now, using mock data
    final customers = _getMockCustomers();

    final filteredCustomers = customers.where((customer) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return customer.name.toLowerCase().contains(query) ||
          (customer.phone?.toLowerCase().contains(query) ?? false) ||
          (customer.email?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.person_search, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Select Customer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            const SizedBox(height: 16),

            // Walk-in customer option
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.directions_walk, color: Colors.grey),
              ),
              title: const Text(
                'Walk-in Customer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('No customer info needed'),
              onTap: () => Navigator.of(context).pop(),
              tileColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),

            const Divider(),
            const SizedBox(height: 8),

            // Customer list
            Expanded(
              child: filteredCustomers.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      itemCount: filteredCustomers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              customer.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            customer.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (customer.phone != null)
                                Text(customer.phone!),
                              if (customer.email != null)
                                Text(
                                  customer.email!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: customer.loyaltyPoints > 0
                              ? Chip(
                                  label: Text('${customer.loyaltyPoints} pts'),
                                  backgroundColor: Colors.green.shade50,
                                  labelStyle: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(customer),
                        );
                      },
                    ),
            ),

            // Add new customer button
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showAddCustomerDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Add New Customer'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No customers found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    // TODO: Implement add customer dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add customer feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<Customer> _getMockCustomers() {
    return [
      Customer(
        id: 'c1',
        name: 'John Doe',
        phone: '+1 234-567-8900',
        email: 'john.doe@example.com',
        loyaltyPoints: 150,
        totalOrders: 25,
        totalSpent: 850.50,
      ),
      Customer(
        id: 'c2',
        name: 'Jane Smith',
        phone: '+1 234-567-8901',
        email: 'jane.smith@example.com',
        loyaltyPoints: 200,
        totalOrders: 30,
        totalSpent: 1200.00,
      ),
      Customer(
        id: 'c3',
        name: 'Bob Johnson',
        phone: '+1 234-567-8902',
        email: 'bob.j@example.com',
        loyaltyPoints: 75,
        totalOrders: 12,
        totalSpent: 450.25,
      ),
      Customer(
        id: 'c4',
        name: 'Alice Williams',
        phone: '+1 234-567-8903',
        loyaltyPoints: 300,
        totalOrders: 45,
        totalSpent: 2100.75,
      ),
      Customer(
        id: 'c5',
        name: 'Charlie Brown',
        phone: '+1 234-567-8904',
        email: 'charlie@example.com',
        loyaltyPoints: 50,
        totalOrders: 8,
        totalSpent: 320.00,
      ),
    ];
  }
}

/// Simple customer model for POS
class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final int loyaltyPoints;
  final int totalOrders;
  final double totalSpent;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.loyaltyPoints = 0,
    this.totalOrders = 0,
    this.totalSpent = 0,
  });
}
