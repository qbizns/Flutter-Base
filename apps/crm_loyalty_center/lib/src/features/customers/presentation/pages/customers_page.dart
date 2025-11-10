import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Customers Page
///
/// Customer relationship management with profiles and segmentation.
/// Features:
/// - Customer database with search and filters
/// - Customer segments (VIP, Regular, At-Risk, New)
/// - Customer lifetime value (CLV)
/// - Purchase history and behavior
/// - Contact information management
/// - Tags and notes
class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  CustomerSegment? _selectedSegment;

  // Mock customer data
  final List<Customer> _customers = [
    Customer(
      id: '1',
      name: 'Sarah Johnson',
      email: 'sarah.j@example.com',
      phone: '+1 (555) 123-4567',
      segment: CustomerSegment.vip,
      lifetimeValue: 2450.50,
      totalOrders: 45,
      loyaltyPoints: 1850,
      tier: LoyaltyTier.gold,
      joinedDate: DateTime(2024, 1, 15),
      lastOrderDate: DateTime.now().subtract(const Duration(days: 2)),
      averageOrderValue: 54.45,
      tags: ['Vegetarian', 'Weekend Regular'],
    ),
    Customer(
      id: '2',
      name: 'Michael Chen',
      email: 'm.chen@example.com',
      phone: '+1 (555) 234-5678',
      segment: CustomerSegment.regular,
      lifetimeValue: 892.30,
      totalOrders: 18,
      loyaltyPoints: 650,
      tier: LoyaltyTier.silver,
      joinedDate: DateTime(2024, 3, 22),
      lastOrderDate: DateTime.now().subtract(const Duration(days: 7)),
      averageOrderValue: 49.57,
      tags: ['Lunch Orders'],
    ),
    Customer(
      id: '3',
      name: 'Emily Rodriguez',
      email: 'emily.r@example.com',
      phone: '+1 (555) 345-6789',
      segment: CustomerSegment.atRisk,
      lifetimeValue: 1205.75,
      totalOrders: 28,
      loyaltyPoints: 320,
      tier: LoyaltyTier.bronze,
      joinedDate: DateTime(2024, 2, 8),
      lastOrderDate: DateTime.now().subtract(const Duration(days: 45)),
      averageOrderValue: 43.06,
      tags: ['Dinner Regular'],
    ),
    Customer(
      id: '4',
      name: 'David Kim',
      email: 'd.kim@example.com',
      phone: '+1 (555) 456-7890',
      segment: CustomerSegment.newCustomer,
      lifetimeValue: 125.50,
      totalOrders: 3,
      loyaltyPoints: 75,
      tier: LoyaltyTier.bronze,
      joinedDate: DateTime.now().subtract(const Duration(days: 15)),
      lastOrderDate: DateTime.now().subtract(const Duration(days: 5)),
      averageOrderValue: 41.83,
      tags: ['Mobile App'],
    ),
  ];

  List<Customer> get _filteredCustomers {
    var customers = _customers;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      customers = customers.where((customer) {
        return customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            customer.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            customer.phone.contains(_searchQuery);
      }).toList();
    }

    // Segment filter
    if (_selectedSegment != null) {
      customers = customers.where((c) => c.segment == _selectedSegment).toList();
    }

    return customers;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Customers'),
            Tab(text: 'Segments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCustomersTab(theme),
          _buildSegmentsTab(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
    );
  }

  Widget _buildCustomersTab(ThemeData theme) {
    return Column(
      children: [
        // Search and filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search customers...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSegmentFilter(null, 'All', theme),
                    _buildSegmentFilter(CustomerSegment.vip, 'VIP', theme),
                    _buildSegmentFilter(CustomerSegment.regular, 'Regular', theme),
                    _buildSegmentFilter(CustomerSegment.atRisk, 'At Risk', theme),
                    _buildSegmentFilter(CustomerSegment.newCustomer, 'New', theme),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Statistics cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Total Customers',
                  '${_customers.length}',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Total CLV',
                  NumberFormat.currency(symbol: '\$').format(
                    _customers.fold<double>(0, (sum, c) => sum + c.lifetimeValue),
                  ),
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Customer list
        Expanded(
          child: _filteredCustomers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No customers found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = _filteredCustomers[index];
                    return _buildCustomerCard(theme, customer);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSegmentsTab(ThemeData theme) {
    final segments = {
      CustomerSegment.vip: _customers.where((c) => c.segment == CustomerSegment.vip).toList(),
      CustomerSegment.regular: _customers.where((c) => c.segment == CustomerSegment.regular).toList(),
      CustomerSegment.atRisk: _customers.where((c) => c.segment == CustomerSegment.atRisk).toList(),
      CustomerSegment.newCustomer: _customers.where((c) => c.segment == CustomerSegment.newCustomer).toList(),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Customer Segments',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSegmentCard(
          theme,
          'VIP Customers',
          segments[CustomerSegment.vip]!.length,
          'High-value customers with frequent orders',
          Colors.purple,
          Icons.star,
          segments[CustomerSegment.vip]!,
        ),
        const SizedBox(height: 12),
        _buildSegmentCard(
          theme,
          'Regular Customers',
          segments[CustomerSegment.regular]!.length,
          'Consistent customers with moderate spending',
          Colors.blue,
          Icons.people,
          segments[CustomerSegment.regular]!,
        ),
        const SizedBox(height: 12),
        _buildSegmentCard(
          theme,
          'At-Risk Customers',
          segments[CustomerSegment.atRisk]!.length,
          'Customers who haven\'t ordered recently',
          Colors.orange,
          Icons.warning,
          segments[CustomerSegment.atRisk]!,
        ),
        const SizedBox(height: 12),
        _buildSegmentCard(
          theme,
          'New Customers',
          segments[CustomerSegment.newCustomer]!.length,
          'Recently joined customers',
          Colors.green,
          Icons.new_releases,
          segments[CustomerSegment.newCustomer]!,
        ),
      ],
    );
  }

  Widget _buildSegmentFilter(CustomerSegment? segment, String label, ThemeData theme) {
    final isSelected = _selectedSegment == segment;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSegment = selected ? segment : null;
          });
        },
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(ThemeData theme, Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showCustomerDetails(context, customer),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _getSegmentColor(customer.segment).withOpacity(0.2),
                child: Text(
                  customer.name.split(' ').map((n) => n[0]).join(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getSegmentColor(customer.segment),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTierColor(customer.tier).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            customer.tier.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getTierColor(customer.tier),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${customer.totalOrders} orders',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.attach_money,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(customer.lifetimeValue),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentCard(
    ThemeData theme,
    String title,
    int count,
    String description,
    Color color,
    IconData icon,
    List<Customer> customers,
  ) {
    final avgCLV = customers.isEmpty
        ? 0.0
        : customers.fold<double>(0, (sum, c) => sum + c.lifetimeValue) / customers.length;

    return Card(
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Avg. CLV',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(avgCLV),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(
                            customers.fold<double>(0, (sum, c) => sum + c.lifetimeValue),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (customers.isNotEmpty) ...[
                  const Divider(height: 24),
                  ...customers.take(3).map((customer) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          child: Text(
                            customer.name.split(' ').map((n) => n[0]).join(),
                            style: TextStyle(color: color, fontSize: 12),
                          ),
                        ),
                        title: Text(customer.name),
                        subtitle: Text(
                          '${customer.totalOrders} orders',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Text(
                          NumberFormat.currency(symbol: '\$').format(customer.lifetimeValue),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSegmentColor(CustomerSegment segment) {
    switch (segment) {
      case CustomerSegment.vip:
        return Colors.purple;
      case CustomerSegment.regular:
        return Colors.blue;
      case CustomerSegment.atRisk:
        return Colors.orange;
      case CustomerSegment.newCustomer:
        return Colors.green;
    }
  }

  Color _getTierColor(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return Colors.brown;
      case LoyaltyTier.silver:
        return Colors.grey;
      case LoyaltyTier.gold:
        return Colors.amber;
    }
  }

  void _showCustomerDetails(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _getSegmentColor(customer.segment).withOpacity(0.2),
                    child: Text(
                      customer.name.split(' ').map((n) => n[0]).join(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getSegmentColor(customer.segment),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(customer.email),
                        Text(customer.phone),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDetailRow('Segment', customer.segment.name.toUpperCase()),
              _buildDetailRow('Tier', customer.tier.name.toUpperCase()),
              _buildDetailRow('Total Orders', customer.totalOrders.toString()),
              _buildDetailRow(
                'Lifetime Value',
                NumberFormat.currency(symbol: '\$').format(customer.lifetimeValue),
              ),
              _buildDetailRow(
                'Avg. Order Value',
                NumberFormat.currency(symbol: '\$').format(customer.averageOrderValue),
              ),
              _buildDetailRow('Loyalty Points', customer.loyaltyPoints.toString()),
              _buildDetailRow(
                'Joined',
                DateFormat('MMM dd, yyyy').format(customer.joinedDate),
              ),
              _buildDetailRow(
                'Last Order',
                DateFormat('MMM dd, yyyy').format(customer.lastOrderDate),
              ),
              if (customer.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Tags',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: customer.tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Customer'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Models
class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final CustomerSegment segment;
  final double lifetimeValue;
  final int totalOrders;
  final int loyaltyPoints;
  final LoyaltyTier tier;
  final DateTime joinedDate;
  final DateTime lastOrderDate;
  final double averageOrderValue;
  final List<String> tags;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.segment,
    required this.lifetimeValue,
    required this.totalOrders,
    required this.loyaltyPoints,
    required this.tier,
    required this.joinedDate,
    required this.lastOrderDate,
    required this.averageOrderValue,
    required this.tags,
  });
}

enum CustomerSegment {
  vip,
  regular,
  atRisk,
  newCustomer,
}

enum LoyaltyTier {
  bronze,
  silver,
  gold,
}
