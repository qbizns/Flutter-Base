import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

/// Device Diagnostics - System health and performance monitoring
class DeviceDiagnosticsPage extends ConsumerWidget {
  const DeviceDiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock diagnostics data
    final systemMetrics = SystemMetrics(
      cpuUsage: 45.2,
      memoryUsage: 62.8,
      diskUsage: 58.5,
      networkLatency: 12,
      batteryLevel: 85,
      temperature: 42,
    );

    final alerts = [
      DeviceAlert('ALT001', 'High Memory Usage', AlertSeverity.warning, 'POS-Downtown-01', 'Memory usage at 89%', DateTime.now().subtract(const Duration(minutes: 15))),
      DeviceAlert('ALT002', 'Device Offline', AlertSeverity.critical, 'PMT-Downtown-01', 'No heartbeat for 2 hours', DateTime.now().subtract(const Duration(hours: 2))),
      DeviceAlert('ALT003', 'Low Battery', AlertSeverity.warning, 'SCAN-Brooklyn-01', 'Battery at 18%', DateTime.now().subtract(const Duration(minutes: 30))),
      DeviceAlert('ALT004', 'Firmware Outdated', AlertSeverity.info, 'KDS-Westside-01', 'Running version 2.4.8', DateTime.now().subtract(const Duration(days: 1))),
    ];

    final criticalCount = alerts.where((a) => a.severity == AlertSeverity.critical).length;
    final warningCount = alerts.where((a) => a.severity == AlertSeverity.warning).length;
    final infoCount = alerts.where((a) => a.severity == AlertSeverity.info).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Device Diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Alert summary cards
          Row(
            children: [
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
                            Text('Critical', style: TextStyle(color: Colors.red.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$criticalCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                        Text('Immediate action', style: TextStyle(fontSize: 12, color: Colors.red.shade700.withOpacity(0.7))),
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
                        Text('Review soon', style: TextStyle(fontSize: 12, color: Colors.orange.shade700.withOpacity(0.7))),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Info', style: TextStyle(color: Colors.blue.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$infoCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                        Text('Informational', style: TextStyle(fontSize: 12, color: Colors.blue.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // System Performance Metrics
          Text('System Performance', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildMetricRow(theme, 'CPU Usage', systemMetrics.cpuUsage, Icons.memory, '%'),
                  const SizedBox(height: 16),
                  _buildMetricRow(theme, 'Memory Usage', systemMetrics.memoryUsage, Icons.storage, '%'),
                  const SizedBox(height: 16),
                  _buildMetricRow(theme, 'Disk Usage', systemMetrics.diskUsage, Icons.sd_card, '%'),
                  const SizedBox(height: 16),
                  _buildMetricRow(theme, 'Network Latency', systemMetrics.networkLatency.toDouble(), Icons.network_check, 'ms'),
                  const SizedBox(height: 16),
                  _buildMetricRow(theme, 'Battery Level', systemMetrics.batteryLevel.toDouble(), Icons.battery_charging_full, '%'),
                  const SizedBox(height: 16),
                  _buildMetricRow(theme, 'Temperature', systemMetrics.temperature.toDouble(), Icons.thermostat, '°C'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Alerts
          Text('Recent Alerts', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...alerts.map((alert) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getAlertColor(alert.severity).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getAlertIcon(alert.severity), color: _getAlertColor(alert.severity), size: 20),
              ),
              title: Row(
                children: [
                  Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getAlertColor(alert.severity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      alert.severity.displayName,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getAlertColor(alert.severity)),
                    ),
                  ),
                ],
              ),
              subtitle: Text('${alert.deviceName} • ${alert.description} • ${_formatTime(alert.timestamp)}'),
              trailing: IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () {},
                tooltip: 'Acknowledge',
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMetricRow(ThemeData theme, String label, double value, IconData icon, String unit) {
    final Color color = value >= 80 ? Colors.red : (value >= 60 ? Colors.orange : Colors.green);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: unit == 'ms' ? (value > 100 ? 1.0 : value / 100) : (value > 100 ? 1.0 : value / 100),
          backgroundColor: theme.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical: return Colors.red;
      case AlertSeverity.warning: return Colors.orange;
      case AlertSeverity.info: return Colors.blue;
    }
  }

  IconData _getAlertIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical: return Icons.error;
      case AlertSeverity.warning: return Icons.warning;
      case AlertSeverity.info: return Icons.info;
    }
  }

  String _formatTime(DateTime dateTime) {
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
class SystemMetrics {
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final int networkLatency;
  final int batteryLevel;
  final int temperature;

  SystemMetrics({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.networkLatency,
    required this.batteryLevel,
    required this.temperature,
  });
}

class DeviceAlert {
  final String id;
  final String title;
  final AlertSeverity severity;
  final String deviceName;
  final String description;
  final DateTime timestamp;

  DeviceAlert(this.id, this.title, this.severity, this.deviceName, this.description, this.timestamp);
}

enum AlertSeverity {
  critical('CRITICAL'),
  warning('WARNING'),
  info('INFO');

  final String displayName;
  const AlertSeverity(this.displayName);
}
