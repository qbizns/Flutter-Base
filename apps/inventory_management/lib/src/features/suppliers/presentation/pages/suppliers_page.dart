import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Suppliers Management Page
///
/// Features:
/// - List of all suppliers
/// - Add/edit supplier information
/// - Contact details management
/// - Supplier performance tracking
/// - Payment terms
/// - Active/inactive status
class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  String _searchQuery = '';
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock data - in real app would use provider
    final allSuppliers = _getMockSuppliers();
    final filteredSuppliers = _filterSuppliers(allSuppliers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: Icon(_showInactive ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showInactive = !_showInactive;
              });
            },
            tooltip: _showInactive ? 'Hide Inactive' : 'Show Inactive',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh suppliers
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(context),

          // Suppliers list
          Expanded(
            child: _buildSuppliersList(context, filteredSuppliers),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showSupplierDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search suppliers...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildSuppliersList(BuildContext context, List<Supplier> suppliers) {
    final theme = Theme.of(context);

    if (suppliers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No suppliers found',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new supplier to get started',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        return _buildSupplierCard(context, suppliers[index]);
      },
    );
  }

  Widget _buildSupplierCard(BuildContext context, Supplier supplier) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showSupplierDialog(context, supplier: supplier);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                supplier.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: supplier.isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                supplier.isActive ? 'Active' : 'Inactive',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: supplier.isActive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          supplier.category,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Contact information
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      icon: Icons.person,
                      label: 'Contact',
                      value: supplier.contactPerson,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      icon: Icons.phone,
                      label: 'Phone',
                      value: supplier.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                icon: Icons.email,
                label: 'Email',
                value: supplier.email,
              ),
              if (supplier.address.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  icon: Icons.location_on,
                  label: 'Address',
                  value: supplier.address,
                ),
              ],

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Business details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Terms',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        supplier.paymentTerms,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Lead Time',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        supplier.leadTimeDays,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Orders',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${supplier.totalOrders}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSupplierDialog(BuildContext context, {Supplier? supplier}) {
    showDialog(
      context: context,
      builder: (context) => _SupplierDialog(supplier: supplier),
    );
  }

  List<Supplier> _filterSuppliers(List<Supplier> suppliers) {
    var filtered = suppliers;

    // Filter by active status
    if (!_showInactive) {
      filtered = filtered.where((s) => s.isActive).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((supplier) {
        return supplier.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            supplier.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            supplier.contactPerson.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  // Mock data
  List<Supplier> _getMockSuppliers() {
    return [
      Supplier(
        id: '1',
        name: 'Fresh Foods Supplier',
        category: 'Produce & Vegetables',
        contactPerson: 'John Smith',
        phone: '+1 (555) 123-4567',
        email: 'john@freshfoods.com',
        address: '123 Market St, San Francisco, CA 94102',
        paymentTerms: 'Net 30',
        leadTimeDays: '2-3 days',
        isActive: true,
        totalOrders: 45,
      ),
      Supplier(
        id: '2',
        name: 'Beverage Distributors',
        category: 'Beverages',
        contactPerson: 'Sarah Johnson',
        phone: '+1 (555) 234-5678',
        email: 'sarah@beverages.com',
        address: '456 Distribution Ave, Oakland, CA 94607',
        paymentTerms: 'Net 15',
        leadTimeDays: '1-2 days',
        isActive: true,
        totalOrders: 67,
      ),
      Supplier(
        id: '3',
        name: 'Meat & Poultry Co',
        category: 'Meat & Protein',
        contactPerson: 'Mike Brown',
        phone: '+1 (555) 345-6789',
        email: 'mike@meatco.com',
        address: '789 Industrial Rd, San Jose, CA 95112',
        paymentTerms: 'Net 30',
        leadTimeDays: '3-5 days',
        isActive: true,
        totalOrders: 32,
      ),
      Supplier(
        id: '4',
        name: 'Bakery Supplies Inc',
        category: 'Bakery & Bread',
        contactPerson: 'Emily Davis',
        phone: '+1 (555) 456-7890',
        email: 'emily@bakerysupplies.com',
        address: '321 Baker St, Berkeley, CA 94704',
        paymentTerms: 'Net 7',
        leadTimeDays: '1 day',
        isActive: false,
        totalOrders: 12,
      ),
    ];
  }
}

// Supplier Dialog
class _SupplierDialog extends StatefulWidget {
  const _SupplierDialog({this.supplier});

  final Supplier? supplier;

  @override
  State<_SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends State<_SupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _paymentTermsController;
  late TextEditingController _leadTimeController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final supplier = widget.supplier;
    _nameController = TextEditingController(text: supplier?.name ?? '');
    _categoryController = TextEditingController(text: supplier?.category ?? '');
    _contactPersonController = TextEditingController(text: supplier?.contactPerson ?? '');
    _phoneController = TextEditingController(text: supplier?.phone ?? '');
    _emailController = TextEditingController(text: supplier?.email ?? '');
    _addressController = TextEditingController(text: supplier?.address ?? '');
    _paymentTermsController = TextEditingController(text: supplier?.paymentTerms ?? 'Net 30');
    _leadTimeController = TextEditingController(text: supplier?.leadTimeDays ?? '2-3 days');
    _isActive = supplier?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _paymentTermsController.dispose();
    _leadTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Supplier' : 'Add Supplier'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Supplier Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter supplier name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _contactPersonController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Person *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _paymentTermsController,
                        decoration: const InputDecoration(
                          labelText: 'Payment Terms',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _leadTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Lead Time',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  subtitle: const Text('Supplier can be used for new orders'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (isEdit)
          TextButton(
            onPressed: () {
              // Delete supplier
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Supplier deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit ? 'Supplier updated' : 'Supplier added'),
                  backgroundColor: Colors.green,
                ),
              );
              // In real app: save supplier
            }
          },
          child: Text(isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}

// Data class
class Supplier {
  final String id;
  final String name;
  final String category;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String paymentTerms;
  final String leadTimeDays;
  final bool isActive;
  final int totalOrders;

  Supplier({
    required this.id,
    required this.name,
    required this.category,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.paymentTerms,
    required this.leadTimeDays,
    required this.isActive,
    required this.totalOrders,
  });
}
