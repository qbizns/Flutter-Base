import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Devices Dashboard - Device inventory and status monitoring
class DevicesDashboardPage extends ConsumerStatefulWidget {
  const DevicesDashboardPage({super.key});

  @override
  ConsumerState<DevicesDashboardPage> createState() => _DevicesDashboardPageState();
}

class _DevicesDashboardPageState extends ConsumerState<DevicesDashboardPage> {
  String _selectedType = 'All';
  String _selectedStatus = 'All';
  String _selectedLocation = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock device data
    final devices = [
      Device('DEV001', 'POS-Downtown-01', DeviceType.posTerminal, DeviceStatus.online, 'Downtown Branch', '2.5.1', 98.5, DateTime.now().subtract(const Duration(minutes: 2))),
      Device('DEV002', 'POS-Downtown-02', DeviceType.posTerminal, DeviceStatus.online, 'Downtown Branch', '2.5.1', 97.8, DateTime.now().subtract(const Duration(minutes: 1))),
      Device('DEV003', 'KDS-Downtown-01', DeviceType.kitchenDisplay, DeviceStatus.online, 'Downtown Branch', '2.5.0', 99.2, DateTime.now().subtract(const Duration(seconds: 30))),
      Device('DEV004', 'PMT-Downtown-01', DeviceType.paymentTerminal, DeviceStatus.offline, 'Downtown Branch', '1.8.5', 0, DateTime.now().subtract(const Duration(hours: 2))),
      Device('DEV005', 'POS-Westside-01', DeviceType.posTerminal, DeviceStatus.online, 'Westside Mall', '2.5.1', 96.5, DateTime.now().subtract(const Duration(minutes: 5))),
      Device('DEV006', 'KIOSK-Airport-01', DeviceType.kiosk, DeviceStatus.warning, 'Airport Terminal', '2.4.8', 75.2, DateTime.now().subtract(const Duration(minutes: 10))),
      Device('DEV007', 'SCAN-Brooklyn-01', DeviceType.scanner, DeviceStatus.online, 'Brooklyn Heights', '1.9.2', 98.0, DateTime.now().subtract(const Duration(minutes: 3))),
      Device('DEV008', 'PRNT-Queens-01', DeviceType.printer, DeviceStatus.error, 'Queens Plaza', '3.1.0', 45.0, DateTime.now().subtract(const Duration(hours: 1))),
    ];

    // Apply filters
    final filteredDevices = devices.where((d) {
      if (_selectedType != 'All' && d.type.name != _selectedType.toLowerCase().replaceAll(' ', '')) return false;
      if (_selectedStatus != 'All' && d.status.name != _selectedStatus.toLowerCase()) return false;
      if (_selectedLocation != 'All' && d.location != _selectedLocation) return false;
      return true;
    }).toList();

    final onlineCount = devices.where((d) => d.status == DeviceStatus.online).length;
    final offlineCount = devices.where((d) => d.status == DeviceStatus.offline).length;
    final warningCount = devices.where((d) => d.status == DeviceStatus.warning).length;
    final errorCount = devices.where((d) => d.status == DeviceStatus.error).length;
    final avgHealth = devices.where((d) => d.status != DeviceStatus.offline).fold<double>(0, (sum, d) => sum + d.health) / (devices.length - offlineCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
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
                              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Online', style: TextStyle(color: Colors.green.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('$onlineCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          Text('${((onlineCount / devices.length) * 100).toStringAsFixed(1)}% uptime', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
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
                              Icon(Icons.cloud_off, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Offline', style: TextStyle(color: Colors.red.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('$offlineCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                          Text('Needs attention', style: TextStyle(fontSize: 12, color: Colors.red.shade700.withOpacity(0.7))),
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
                              Text('Warnings', style: TextStyle(color: Colors.orange.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('$warningCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                          Text('Low health', style: TextStyle(fontSize: 12, color: Colors.orange.shade700.withOpacity(0.7))),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.health_and_safety, color: theme.colorScheme.onPrimaryContainer, size: 20),
                              const SizedBox(width: 8),
                              Text('Avg Health', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${avgHealth.toStringAsFixed(1)}%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                          Text('System-wide', style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7))),
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
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Device Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'POS Terminal', 'Kitchen Display', 'Payment Terminal', 'Kiosk', 'Scanner', 'Printer']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedType = value!),
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
                    items: ['All', 'Online', 'Offline', 'Warning', 'Error']
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedStatus = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Downtown Branch', 'Westside Mall', 'Airport Terminal', 'Brooklyn Heights', 'Queens Plaza']
                        .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedLocation = value!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Devices list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDevices.length,
              itemBuilder: (context, index) {
                final device = filteredDevices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(device.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getDeviceTypeIcon(device.type), color: _getStatusColor(device.status), size: 24),
                    ),
                    title: Row(
                      children: [
                        Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(device.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(device.status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                device.status.name.toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(device.status)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('${device.id} • ${device.type.displayName} • ${device.location}'),
                    trailing: device.status != DeviceStatus.offline
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${device.health.toStringAsFixed(0)}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _getHealthColor(device.health))),
                              Text('Health', style: theme.textTheme.bodySmall),
                            ],
                          )
                        : Icon(Icons.cloud_off, color: Colors.red.shade700),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.badge, 'Device ID', device.id),
                            _buildInfoRow(Icons.label, 'Name', device.name),
                            _buildInfoRow(Icons.devices, 'Type', device.type.displayName),
                            _buildInfoRow(Icons.location_on, 'Location', device.location),
                            _buildInfoRow(Icons.info, 'Firmware', device.firmwareVersion),
                            _buildInfoRow(Icons.circle, 'Status', device.status.name.toUpperCase()),
                            if (device.status != DeviceStatus.offline) ...[
                              _buildInfoRow(Icons.health_and_safety, 'Health', '${device.health.toStringAsFixed(1)}%'),
                              _buildInfoRow(Icons.access_time, 'Last Seen', _formatLastSeen(device.lastSeen)),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.settings, size: 18),
                                    label: const Text('Configure'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.analytics, size: 18),
                                    label: const Text('Diagnostics'),
                                  ),
                                ),
                                if (device.status == DeviceStatus.offline) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text('Reconnect'),
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
        label: const Text('Add Device'),
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

  Color _getStatusColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online: return Colors.green;
      case DeviceStatus.offline: return Colors.red;
      case DeviceStatus.warning: return Colors.orange;
      case DeviceStatus.error: return Colors.red;
    }
  }

  Color _getHealthColor(double health) {
    if (health >= 90) return Colors.green;
    if (health >= 75) return Colors.orange;
    return Colors.red;
  }

  IconData _getDeviceTypeIcon(DeviceType type) {
    switch (type) {
      case DeviceType.posTerminal: return Icons.point_of_sale;
      case DeviceType.kitchenDisplay: return Icons.restaurant;
      case DeviceType.paymentTerminal: return Icons.credit_card;
      case DeviceType.kiosk: return Icons.tablet_mac;
      case DeviceType.scanner: return Icons.qr_code_scanner;
      case DeviceType.printer: return Icons.print;
    }
  }

  String _formatLastSeen(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Models
class Device {
  final String id;
  final String name;
  final DeviceType type;
  final DeviceStatus status;
  final String location;
  final String firmwareVersion;
  final double health;
  final DateTime lastSeen;

  Device(this.id, this.name, this.type, this.status, this.location, this.firmwareVersion, this.health, this.lastSeen);
}

enum DeviceType {
  posTerminal('POS Terminal'),
  kitchenDisplay('Kitchen Display'),
  paymentTerminal('Payment Terminal'),
  kiosk('Self-Service Kiosk'),
  scanner('Handheld Scanner'),
  printer('Receipt Printer');

  final String displayName;
  const DeviceType(this.displayName);
}

enum DeviceStatus { online, offline, warning, error }
