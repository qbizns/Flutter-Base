import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Firmware Updates - Manage firmware versions and updates
class FirmwareUpdatesPage extends ConsumerWidget {
  const FirmwareUpdatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final firmwareVersions = [
      FirmwareVersion('2.5.2', DeviceType.posTerminal, DateTime.now().subtract(const Duration(days: 2)), FirmwareStatus.latest, 0, 8, 'Security patches and performance improvements'),
      FirmwareVersion('2.5.1', DeviceType.posTerminal, DateTime.now().subtract(const Duration(days: 15)), FirmwareStatus.stable, 5, 8, 'Bug fixes and UI enhancements'),
      FirmwareVersion('2.5.0', DeviceType.kitchenDisplay, DateTime.now().subtract(const Duration(days: 8)), FirmwareStatus.stable, 3, 3, 'New order display features'),
      FirmwareVersion('1.9.0', DeviceType.paymentTerminal, DateTime.now().subtract(const Duration(hours: 12)), FirmwareStatus.beta, 0, 4, 'Enhanced payment processing'),
      FirmwareVersion('1.8.5', DeviceType.paymentTerminal, DateTime.now().subtract(const Duration(days: 30)), FirmwareStatus.outdated, 2, 4, 'Previous stable version'),
    ];

    final updateQueue = [
      UpdateTask('UPD001', '2.5.2', 'POS-Downtown-01', UpdateStatus.scheduled, 0, DateTime.now().add(const Duration(hours: 2))),
      UpdateTask('UPD002', '2.5.2', 'POS-Downtown-02', UpdateStatus.scheduled, 0, DateTime.now().add(const Duration(hours: 2))),
      UpdateTask('UPD003', '2.5.2', 'POS-Westside-01', UpdateStatus.inProgress, 45, null),
      UpdateTask('UPD004', '2.5.1', 'POS-Brooklyn-01', UpdateStatus.completed, 100, null),
      UpdateTask('UPD005', '2.5.1', 'POS-Queens-01', UpdateStatus.failed, 75, null),
    ];

    final scheduledCount = updateQueue.where((u) => u.status == UpdateStatus.scheduled).length;
    final inProgressCount = updateQueue.where((u) => u.status == UpdateStatus.inProgress).length;
    final completedCount = updateQueue.where((u) => u.status == UpdateStatus.completed).length;
    final failedCount = updateQueue.where((u) => u.status == UpdateStatus.failed).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Firmware Updates')),
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
                        Icon(Icons.schedule, color: Colors.orange.shade700, size: 28),
                        const SizedBox(height: 8),
                        Text('$scheduledCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                        Text('Scheduled', style: theme.textTheme.bodySmall),
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
                        Icon(Icons.downloading, color: Colors.blue.shade700, size: 28),
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

          // Available Firmware Versions
          Text('Available Firmware', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...firmwareVersions.map((firmware) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getFirmwareStatusColor(firmware.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.system_update, color: _getFirmwareStatusColor(firmware.status), size: 20),
              ),
              title: Row(
                children: [
                  Text('Version ${firmware.version}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getFirmwareStatusColor(firmware.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      firmware.status.displayName,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getFirmwareStatusColor(firmware.status)),
                    ),
                  ),
                ],
              ),
              subtitle: Text('${firmware.deviceType.displayName} • ${DateFormat('MMM dd, yyyy').format(firmware.releaseDate)} • ${firmware.installedCount}/${firmware.totalDevices} devices'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Version', firmware.version),
                      _buildInfoRow('Device Type', firmware.deviceType.displayName),
                      _buildInfoRow('Status', firmware.status.displayName),
                      _buildInfoRow('Release Date', DateFormat('MMM dd, yyyy').format(firmware.releaseDate)),
                      _buildInfoRow('Installed', '${firmware.installedCount}/${firmware.totalDevices} devices'),
                      const SizedBox(height: 12),
                      Text('Release Notes:', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(firmware.releaseNotes),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (firmware.status == FirmwareStatus.latest || firmware.status == FirmwareStatus.stable) ...[
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.upload, size: 18),
                                label: const Text('Deploy to Devices'),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Download'),
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
          const SizedBox(height: 24),

          // Update Queue
          Text('Update Queue', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...updateQueue.map((update) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getUpdateStatusColor(update.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getUpdateStatusIcon(update.status), color: _getUpdateStatusColor(update.status), size: 20),
              ),
              title: Row(
                children: [
                  Text('${update.deviceName} → v${update.version}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getUpdateStatusColor(update.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      update.status.displayName,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getUpdateStatusColor(update.status)),
                    ),
                  ),
                ],
              ),
              subtitle: update.scheduledTime != null
                  ? Text('Scheduled: ${DateFormat('h:mm a').format(update.scheduledTime!)}')
                  : (update.status == UpdateStatus.inProgress ? Text('${update.progress}% complete') : null),
              trailing: update.status == UpdateStatus.inProgress
                  ? SizedBox(
                      width: 50,
                      child: LinearProgressIndicator(value: update.progress / 100),
                    )
                  : null,
            ),
          )),
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

  Color _getFirmwareStatusColor(FirmwareStatus status) {
    switch (status) {
      case FirmwareStatus.latest: return Colors.green;
      case FirmwareStatus.stable: return Colors.blue;
      case FirmwareStatus.beta: return Colors.orange;
      case FirmwareStatus.outdated: return Colors.grey;
    }
  }

  Color _getUpdateStatusColor(UpdateStatus status) {
    switch (status) {
      case UpdateStatus.scheduled: return Colors.orange;
      case UpdateStatus.inProgress: return Colors.blue;
      case UpdateStatus.completed: return Colors.green;
      case UpdateStatus.failed: return Colors.red;
    }
  }

  IconData _getUpdateStatusIcon(UpdateStatus status) {
    switch (status) {
      case UpdateStatus.scheduled: return Icons.schedule;
      case UpdateStatus.inProgress: return Icons.downloading;
      case UpdateStatus.completed: return Icons.check_circle;
      case UpdateStatus.failed: return Icons.error;
    }
  }
}

// Models
class FirmwareVersion {
  final String version;
  final DeviceType deviceType;
  final DateTime releaseDate;
  final FirmwareStatus status;
  final int installedCount;
  final int totalDevices;
  final String releaseNotes;

  FirmwareVersion(this.version, this.deviceType, this.releaseDate, this.status, this.installedCount, this.totalDevices, this.releaseNotes);
}

class UpdateTask {
  final String id;
  final String version;
  final String deviceName;
  final UpdateStatus status;
  final int progress;
  final DateTime? scheduledTime;

  UpdateTask(this.id, this.version, this.deviceName, this.status, this.progress, this.scheduledTime);
}

enum DeviceType {
  posTerminal('POS Terminal'),
  kitchenDisplay('Kitchen Display'),
  paymentTerminal('Payment Terminal');

  final String displayName;
  const DeviceType(this.displayName);
}

enum FirmwareStatus {
  latest('LATEST'),
  stable('STABLE'),
  beta('BETA'),
  outdated('OUTDATED');

  final String displayName;
  const FirmwareStatus(this.displayName);
}

enum UpdateStatus {
  scheduled('SCHEDULED'),
  inProgress('IN PROGRESS'),
  completed('COMPLETED'),
  failed('FAILED');

  final String displayName;
  const UpdateStatus(this.displayName);
}
