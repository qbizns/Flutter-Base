import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Device Provisioning - Setup and configure new devices
class DeviceProvisioningPage extends ConsumerWidget {
  const DeviceProvisioningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final provisioningQueue = [
      ProvisioningTask('PROV001', 'POS-Queens-02', DeviceType.posTerminal, ProvisioningStatus.inProgress, 65, 'Queens Plaza'),
      ProvisioningTask('PROV002', 'KDS-Brooklyn-02', DeviceType.kitchenDisplay, ProvisioningStatus.pending, 0, 'Brooklyn Heights'),
      ProvisioningTask('PROV003', 'PMT-Airport-02', DeviceType.paymentTerminal, ProvisioningStatus.pending, 0, 'Airport Terminal'),
      ProvisioningTask('PROV004', 'KIOSK-Westside-02', DeviceType.kiosk, ProvisioningStatus.completed, 100, 'Westside Mall'),
      ProvisioningTask('PROV005', 'POS-Downtown-03', DeviceType.posTerminal, ProvisioningStatus.failed, 45, 'Downtown Branch'),
    ];

    final pendingCount = provisioningQueue.where((p) => p.status == ProvisioningStatus.pending).length;
    final inProgressCount = provisioningQueue.where((p) => p.status == ProvisioningStatus.inProgress).length;
    final completedCount = provisioningQueue.where((p) => p.status == ProvisioningStatus.completed).length;
    final failedCount = provisioningQueue.where((p) => p.status == ProvisioningStatus.failed).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Device Provisioning')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(
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
                        Icon(Icons.sync, color: Colors.blue.shade700, size: 28),
                        const SizedBox(height: 8),
                        Text('$inProgressCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                        Text('In Progress', style: theme.textTheme.bodySmall),
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
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700, size: 28),
                        const SizedBox(height: 8),
                        Text('$failedCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                        Text('Failed', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Provisioning Queue', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...provisioningQueue.map((task) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getDeviceTypeIcon(task.deviceType), color: _getStatusColor(task.status), size: 20),
              ),
              title: Row(
                children: [
                  Text(task.deviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.status.displayName,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(task.status)),
                    ),
                  ),
                ],
              ),
              subtitle: Text('${task.id} • ${task.deviceType.displayName} • ${task.location}'),
              trailing: task.status == ProvisioningStatus.inProgress
                  ? SizedBox(
                      width: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${task.progress}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(value: task.progress / 100),
                        ],
                      ),
                    )
                  : Icon(_getStatusIcon(task.status), color: _getStatusColor(task.status)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('Task ID', task.id),
                      _buildInfoRow('Device Name', task.deviceName),
                      _buildInfoRow('Device Type', task.deviceType.displayName),
                      _buildInfoRow('Location', task.location),
                      _buildInfoRow('Status', task.status.displayName),
                      if (task.status == ProvisioningStatus.inProgress) ...[
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Progress: ${task.progress}%', style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: task.progress / 100,
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              minHeight: 8,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (task.status == ProvisioningStatus.pending) ...[
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: const Text('Start'),
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
                          ] else if (task.status == ProvisioningStatus.inProgress) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('View Details'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.stop, size: 18),
                                label: const Text('Abort'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          ] else if (task.status == ProvisioningStatus.failed) ...[
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Retry'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.error, size: 18),
                                label: const Text('View Errors'),
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: const Text('View Report'),
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
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Provisioning'),
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

  Color _getStatusColor(ProvisioningStatus status) {
    switch (status) {
      case ProvisioningStatus.pending: return Colors.orange;
      case ProvisioningStatus.inProgress: return Colors.blue;
      case ProvisioningStatus.completed: return Colors.green;
      case ProvisioningStatus.failed: return Colors.red;
    }
  }

  IconData _getStatusIcon(ProvisioningStatus status) {
    switch (status) {
      case ProvisioningStatus.pending: return Icons.schedule;
      case ProvisioningStatus.inProgress: return Icons.sync;
      case ProvisioningStatus.completed: return Icons.check_circle;
      case ProvisioningStatus.failed: return Icons.error;
    }
  }

  IconData _getDeviceTypeIcon(DeviceType type) {
    switch (type) {
      case DeviceType.posTerminal: return Icons.point_of_sale;
      case DeviceType.kitchenDisplay: return Icons.restaurant;
      case DeviceType.paymentTerminal: return Icons.credit_card;
      case DeviceType.kiosk: return Icons.tablet_mac;
    }
  }
}

// Models
class ProvisioningTask {
  final String id;
  final String deviceName;
  final DeviceType deviceType;
  final ProvisioningStatus status;
  final int progress;
  final String location;

  ProvisioningTask(this.id, this.deviceName, this.deviceType, this.status, this.progress, this.location);
}

enum DeviceType {
  posTerminal('POS Terminal'),
  kitchenDisplay('Kitchen Display'),
  paymentTerminal('Payment Terminal'),
  kiosk('Self-Service Kiosk');

  final String displayName;
  const DeviceType(this.displayName);
}

enum ProvisioningStatus {
  pending('PENDING'),
  inProgress('IN PROGRESS'),
  completed('COMPLETED'),
  failed('FAILED');

  final String displayName;
  const ProvisioningStatus(this.displayName);
}
