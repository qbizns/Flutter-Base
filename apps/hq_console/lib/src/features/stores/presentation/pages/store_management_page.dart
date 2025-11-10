import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Store Management - Individual store configuration and details
class StoreManagementPage extends ConsumerStatefulWidget {
  const StoreManagementPage({super.key});

  @override
  ConsumerState<StoreManagementPage> createState() => _StoreManagementPageState();
}

class _StoreManagementPageState extends ConsumerState<StoreManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock store details
    final storeDetails = StoreDetails(
      id: 'ST001',
      name: 'Downtown Branch',
      address: '123 Main St, New York, NY 10001',
      phone: '+1 (555) 123-4567',
      email: 'downtown@smartpos.com',
      manager: 'John Smith',
      status: StoreStatus.active,
      openingHours: '9:00 AM - 9:00 PM',
      timezone: 'America/New_York',
      taxRate: 8.875,
      currency: 'USD',
      devices: [
        Device('POS-001', 'Main Register', DeviceType.pos, DeviceStatus.online, DateTime.now().subtract(const Duration(minutes: 5))),
        Device('POS-002', 'Counter 2', DeviceType.pos, DeviceStatus.online, DateTime.now().subtract(const Duration(minutes: 2))),
        Device('KDS-001', 'Kitchen Display', DeviceType.kds, DeviceStatus.online, DateTime.now().subtract(const Duration(minutes: 1))),
        Device('PMT-001', 'Payment Terminal', DeviceType.payment, DeviceStatus.offline, DateTime.now().subtract(const Duration(hours: 2))),
      ],
      staff: [
        StaffMember('EMP001', 'John Smith', 'Manager', StaffStatus.active, 'john.smith@smartpos.com', '+1 (555) 111-2222'),
        StaffMember('EMP002', 'Sarah Johnson', 'Cashier', StaffStatus.active, 'sarah.j@smartpos.com', '+1 (555) 222-3333'),
        StaffMember('EMP003', 'Mike Wilson', 'Kitchen Staff', StaffStatus.active, 'mike.w@smartpos.com', '+1 (555) 333-4444'),
        StaffMember('EMP004', 'Emily Davis', 'Server', StaffStatus.onLeave, 'emily.d@smartpos.com', '+1 (555) 444-5555'),
      ],
      recentActivity: [
        Activity('System updated to v2.5.0', DateTime.now().subtract(const Duration(hours: 2)), ActivityType.system),
        Activity('New staff member added: Emily Davis', DateTime.now().subtract(const Duration(days: 1)), ActivityType.staff),
        Activity('Inventory sync completed', DateTime.now().subtract(const Duration(days: 1, hours: 5)), ActivityType.inventory),
        Activity('Daily settlement processed', DateTime.now().subtract(const Duration(days: 2)), ActivityType.financial),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(storeDetails.name),
            Text(
              storeDetails.id,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(storeDetails.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getStatusIcon(storeDetails.status), size: 16, color: _getStatusColor(storeDetails.status)),
                const SizedBox(width: 6),
                Text(
                  storeDetails.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(storeDetails.status),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details', icon: Icon(Icons.info_outline)),
            Tab(text: 'Devices', icon: Icon(Icons.devices)),
            Tab(text: 'Staff', icon: Icon(Icons.people_outline)),
            Tab(text: 'Activity', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Details tab
          _buildDetailsTab(theme, storeDetails),

          // Devices tab
          _buildDevicesTab(theme, storeDetails.devices),

          // Staff tab
          _buildStaffTab(theme, storeDetails.staff),

          // Activity tab
          _buildActivityTab(theme, storeDetails.recentActivity),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(ThemeData theme, StoreDetails store) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Store Information', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(Icons.store, 'Store Name', store.name),
                _buildInfoRow(Icons.tag, 'Store ID', store.id),
                _buildInfoRow(Icons.location_on, 'Address', store.address),
                _buildInfoRow(Icons.phone, 'Phone', store.phone),
                _buildInfoRow(Icons.email, 'Email', store.email),
                _buildInfoRow(Icons.person, 'Manager', store.manager),
                _buildInfoRow(Icons.schedule, 'Hours', store.openingHours),
                _buildInfoRow(Icons.access_time, 'Timezone', store.timezone),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text('Financial Settings', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(Icons.monetization_on, 'Currency', store.currency),
                _buildInfoRow(Icons.receipt, 'Tax Rate', '${store.taxRate}%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit),
                label: const Text('Edit Details'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete),
                label: const Text('Close Store'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDevicesTab(ThemeData theme, List<Device> devices) {
    final onlineDevices = devices.where((d) => d.status == DeviceStatus.online).length;
    final offlineDevices = devices.where((d) => d.status == DeviceStatus.offline).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '$onlineDevices',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                      ),
                      Text('Online', style: theme.textTheme.bodySmall),
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
                      Icon(Icons.error, color: Colors.red.shade700, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '$offlineDevices',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                      ),
                      Text('Offline', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text('Devices', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...devices.map((device) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getDeviceStatusColor(device.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getDeviceIcon(device.type), color: _getDeviceStatusColor(device.status)),
            ),
            title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${device.id} • ${device.type.name.toUpperCase()}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDeviceStatusColor(device.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    device.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getDeviceStatusColor(device.status),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatLastSeen(device.lastSeen),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildStaffTab(ThemeData theme, List<StaffMember> staff) {
    final activeStaff = staff.where((s) => s.status == StaffStatus.active).length;
    final onLeave = staff.where((s) => s.status == StaffStatus.onLeave).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.people, color: theme.colorScheme.onPrimaryContainer, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '$activeStaff',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                      ),
                      Text('Active Staff', style: theme.textTheme.bodySmall),
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
                      Icon(Icons.beach_access, color: Colors.orange.shade700, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '$onLeave',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                      ),
                      Text('On Leave', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text('Staff Members', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...staff.map((member) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getStaffStatusColor(member.status).withOpacity(0.2),
              child: Text(
                member.name.split(' ').map((n) => n[0]).take(2).join(),
                style: TextStyle(fontWeight: FontWeight.bold, color: _getStaffStatusColor(member.status)),
              ),
            ),
            title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${member.role} • ${member.id}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStaffStatusColor(member.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                member.status.name.toUpperCase().replaceAll('_', ' '),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getStaffStatusColor(member.status),
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email, 'Email', member.email),
                    _buildInfoRow(Icons.phone, 'Phone', member.phone),
                    _buildInfoRow(Icons.work, 'Role', member.role),
                    const SizedBox(height: 12),
                    Row(
                      children: [
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
                            icon: const Icon(Icons.schedule, size: 18),
                            label: const Text('Schedule'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActivityTab(ThemeData theme, List<Activity> activities) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Recent Activity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...activities.map((activity) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getActivityColor(activity.type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getActivityIcon(activity.type), color: _getActivityColor(activity.type), size: 20),
            ),
            title: Text(activity.description),
            subtitle: Text(DateFormat('MMM dd, yyyy h:mm a').format(activity.timestamp)),
            trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          ),
        )),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
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

  Color _getStatusColor(StoreStatus status) {
    switch (status) {
      case StoreStatus.active: return Colors.green;
      case StoreStatus.inactive: return Colors.grey;
      case StoreStatus.maintenance: return Colors.orange;
    }
  }

  IconData _getStatusIcon(StoreStatus status) {
    switch (status) {
      case StoreStatus.active: return Icons.check_circle;
      case StoreStatus.inactive: return Icons.cancel;
      case StoreStatus.maintenance: return Icons.build;
    }
  }

  Color _getDeviceStatusColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online: return Colors.green;
      case DeviceStatus.offline: return Colors.red;
      case DeviceStatus.maintenance: return Colors.orange;
    }
  }

  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.pos: return Icons.point_of_sale;
      case DeviceType.kds: return Icons.restaurant;
      case DeviceType.payment: return Icons.credit_card;
    }
  }

  Color _getStaffStatusColor(StaffStatus status) {
    switch (status) {
      case StaffStatus.active: return Colors.green;
      case StaffStatus.onLeave: return Colors.orange;
      case StaffStatus.inactive: return Colors.grey;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.system: return Colors.blue;
      case ActivityType.staff: return Colors.purple;
      case ActivityType.inventory: return Colors.orange;
      case ActivityType.financial: return Colors.green;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.system: return Icons.settings;
      case ActivityType.staff: return Icons.people;
      case ActivityType.inventory: return Icons.inventory;
      case ActivityType.financial: return Icons.attach_money;
    }
  }

  String _formatLastSeen(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Models
class StoreDetails {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String manager;
  final StoreStatus status;
  final String openingHours;
  final String timezone;
  final double taxRate;
  final String currency;
  final List<Device> devices;
  final List<StaffMember> staff;
  final List<Activity> recentActivity;

  StoreDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.manager,
    required this.status,
    required this.openingHours,
    required this.timezone,
    required this.taxRate,
    required this.currency,
    required this.devices,
    required this.staff,
    required this.recentActivity,
  });
}

class Device {
  final String id;
  final String name;
  final DeviceType type;
  final DeviceStatus status;
  final DateTime lastSeen;

  Device(this.id, this.name, this.type, this.status, this.lastSeen);
}

class StaffMember {
  final String id;
  final String name;
  final String role;
  final StaffStatus status;
  final String email;
  final String phone;

  StaffMember(this.id, this.name, this.role, this.status, this.email, this.phone);
}

class Activity {
  final String description;
  final DateTime timestamp;
  final ActivityType type;

  Activity(this.description, this.timestamp, this.type);
}

enum StoreStatus { active, inactive, maintenance }
enum DeviceStatus { online, offline, maintenance }
enum DeviceType { pos, kds, payment }
enum StaffStatus { active, onLeave, inactive }
enum ActivityType { system, staff, inventory, financial }
