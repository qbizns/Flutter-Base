import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Driver Management Page
///
/// Features:
/// - Driver list with status
/// - Driver performance metrics
/// - Active deliveries per driver
/// - Driver availability management
/// - Add/edit drivers
class DriversPage extends ConsumerStatefulWidget {
  const DriversPage({super.key});

  @override
  ConsumerState<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends ConsumerState<DriversPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock driver data
    final allDrivers = _getMockDrivers();
    final activeDrivers = allDrivers.where((d) => d.status == DriverStatus.active).toList();
    final offlineDrivers = allDrivers.where((d) => d.status == DriverStatus.offline).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active (${activeDrivers.length})', icon: Icon(Icons.delivery_dining)),
            Tab(text: 'Offline (${offlineDrivers.length})', icon: Icon(Icons.person_off)),
            Tab(text: 'All (${allDrivers.length})', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDriverList(context, activeDrivers),
          _buildDriverList(context, offlineDrivers),
          _buildDriverList(context, allDrivers),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showDriverDialog(context);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Driver'),
      ),
    );
  }

  Widget _buildDriverList(BuildContext context, List<Driver> drivers) {
    final theme = Theme.of(context);

    if (drivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No drivers',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        return _buildDriverCard(context, drivers[index]);
      },
    );
  }

  Widget _buildDriverCard(BuildContext context, Driver driver) {
    final theme = Theme.of(context);
    final statusInfo = _getStatusInfo(driver.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showDriverDetails(context, driver);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          driver.name.substring(0, 1).toUpperCase(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: statusInfo.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Driver info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              statusInfo.icon,
                              size: 16,
                              color: statusInfo.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusInfo.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: statusInfo.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Rating
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          driver.rating.toStringAsFixed(1),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    context,
                    icon: Icons.local_shipping,
                    label: 'Active',
                    value: '${driver.activeDeliveries}',
                  ),
                  _buildStat(
                    context,
                    icon: Icons.check_circle,
                    label: 'Completed',
                    value: '${driver.totalDeliveries}',
                  ),
                  _buildStat(
                    context,
                    icon: Icons.attach_money,
                    label: 'Earnings',
                    value: '\$${driver.totalEarnings.toStringAsFixed(0)}',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Contact info
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    driver.phone,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.directions_car,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    driver.vehicle,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showDriverDetails(BuildContext context, Driver driver) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(driver.name),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Status', _getStatusInfo(driver.status).label),
                _buildDetailRow('Phone', driver.phone),
                _buildDetailRow('Vehicle', driver.vehicle),
                _buildDetailRow('License', driver.licenseNumber),
                _buildDetailRow('Rating', '${driver.rating.toStringAsFixed(1)} ⭐'),
                const Divider(),
                Text(
                  'Performance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Active Deliveries', '${driver.activeDeliveries}'),
                _buildDetailRow('Total Deliveries', '${driver.totalDeliveries}'),
                _buildDetailRow('Total Earnings', '\$${driver.totalEarnings.toStringAsFixed(2)}'),
                _buildDetailRow('Joined', DateFormat('MMM d, yyyy').format(driver.joinedDate)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showDriverDialog(context, driver: driver);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDriverDialog(BuildContext context, {Driver? driver}) {
    showDialog(
      context: context,
      builder: (context) => _DriverDialog(driver: driver),
    );
  }

  DriverStatusInfo _getStatusInfo(DriverStatus status) {
    switch (status) {
      case DriverStatus.active:
        return DriverStatusInfo(
          color: Colors.green,
          icon: Icons.check_circle,
          label: 'Active',
        );
      case DriverStatus.onDelivery:
        return DriverStatusInfo(
          color: Colors.blue,
          icon: Icons.local_shipping,
          label: 'On Delivery',
        );
      case DriverStatus.offline:
        return DriverStatusInfo(
          color: Colors.grey,
          icon: Icons.person_off,
          label: 'Offline',
        );
    }
  }

  List<Driver> _getMockDrivers() {
    return [
      Driver(
        id: '1',
        name: 'Alex Driver',
        phone: '+1 (555) 123-4567',
        vehicle: 'Toyota Camry',
        licenseNumber: 'DL-12345',
        status: DriverStatus.active,
        rating: 4.8,
        activeDeliveries: 2,
        totalDeliveries: 156,
        totalEarnings: 1234.50,
        joinedDate: DateTime(2023, 1, 15),
      ),
      Driver(
        id: '2',
        name: 'Sam Wilson',
        phone: '+1 (555) 234-5678',
        vehicle: 'Honda Civic',
        licenseNumber: 'DL-23456',
        status: DriverStatus.onDelivery,
        rating: 4.9,
        activeDeliveries: 1,
        totalDeliveries: 203,
        totalEarnings: 1876.25,
        joinedDate: DateTime(2022, 10, 20),
      ),
      Driver(
        id: '3',
        name: 'Chris Taylor',
        phone: '+1 (555) 345-6789',
        vehicle: 'Ford Focus',
        licenseNumber: 'DL-34567',
        status: DriverStatus.active,
        rating: 4.7,
        activeDeliveries: 0,
        totalDeliveries: 98,
        totalEarnings: 890.00,
        joinedDate: DateTime(2023, 5, 10),
      ),
      Driver(
        id: '4',
        name: 'Jamie Lee',
        phone: '+1 (555) 456-7890',
        vehicle: 'Nissan Altima',
        licenseNumber: 'DL-45678',
        status: DriverStatus.offline,
        rating: 4.6,
        activeDeliveries: 0,
        totalDeliveries: 67,
        totalEarnings: 567.75,
        joinedDate: DateTime(2023, 8, 1),
      ),
    ];
  }
}

// Driver Dialog
class _DriverDialog extends StatefulWidget {
  const _DriverDialog({this.driver});

  final Driver? driver;

  @override
  State<_DriverDialog> createState() => _DriverDialogState();
}

class _DriverDialogState extends State<_DriverDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _vehicleController;
  late TextEditingController _licenseController;

  @override
  void initState() {
    super.initState();
    final driver = widget.driver;
    _nameController = TextEditingController(text: driver?.name ?? '');
    _phoneController = TextEditingController(text: driver?.phone ?? '');
    _vehicleController = TextEditingController(text: driver?.vehicle ?? '');
    _licenseController = TextEditingController(text: driver?.licenseNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.driver != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Driver' : 'Add Driver'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter driver name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vehicleController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter vehicle';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License Number *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter license number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
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
                  content: Text(isEdit ? 'Driver updated' : 'Driver added'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: Text(isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}

// Data classes
enum DriverStatus { active, onDelivery, offline }

class Driver {
  final String id;
  final String name;
  final String phone;
  final String vehicle;
  final String licenseNumber;
  final DriverStatus status;
  final double rating;
  final int activeDeliveries;
  final int totalDeliveries;
  final double totalEarnings;
  final DateTime joinedDate;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.licenseNumber,
    required this.status,
    required this.rating,
    required this.activeDeliveries,
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.joinedDate,
  });
}

class DriverStatusInfo {
  final Color color;
  final IconData icon;
  final String label;

  DriverStatusInfo({
    required this.color,
    required this.icon,
    required this.label,
  });
}
