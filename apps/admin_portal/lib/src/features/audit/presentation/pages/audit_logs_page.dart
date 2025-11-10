import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/audit_log.dart';

/// Audit Logs Page
///
/// Features:
/// - View all system changes
/// - Filter by user, action, entity
/// - Search logs
/// - Export logs
/// - Log details view
class AuditLogsPage extends ConsumerStatefulWidget {
  const AuditLogsPage({super.key});

  @override
  ConsumerState<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends ConsumerState<AuditLogsPage> {
  String _searchQuery = '';
  String? _selectedAction;
  String? _selectedEntity;
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logs = _getMockLogs();
    final filteredLogs = _filterLogs(logs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              _showExportDialog(context);
            },
            tooltip: 'Export Logs',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh logs
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          _buildFilters(theme),

          // Statistics
          _buildStatistics(theme, logs),

          const SizedBox(height: 16),

          // Logs list
          Expanded(
            child: _buildLogsList(theme, filteredLogs),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (range != null) {
                    setState(() {
                      _dateRange = range;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _dateRange != null
                      ? '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'
                      : 'Date Range',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedAction,
                  decoration: const InputDecoration(
                    labelText: 'Action',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Actions')),
                    ...AuditAction.values.map((action) {
                      return DropdownMenuItem(
                        value: action.label,
                        child: Text(action.label),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedAction = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedEntity,
                  decoration: const InputDecoration(
                    labelText: 'Entity',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Entities')),
                    DropdownMenuItem(value: 'User', child: Text('User')),
                    DropdownMenuItem(value: 'Order', child: Text('Order')),
                    DropdownMenuItem(value: 'Product', child: Text('Product')),
                    DropdownMenuItem(value: 'Settings', child: Text('Settings')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedEntity = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(ThemeData theme, List<AuditLog> logs) {
    final todayLogs = logs.where((log) {
      final today = DateTime.now();
      return log.timestamp.year == today.year &&
          log.timestamp.month == today.month &&
          log.timestamp.day == today.day;
    }).length;

    final criticalLogs = logs.where((log) {
      return log.action == 'Deleted' || log.action == 'Restored';
    }).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              theme,
              'Total Logs',
              '${logs.length}',
              Icons.article,
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              'Today',
              '$todayLogs',
              Icons.today,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              'Critical',
              '$criticalLogs',
              Icons.warning,
              Colors.orange,
            ),
          ),
        ],
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
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList(ThemeData theme, List<AuditLog> logs) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text('No logs found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogCard(theme, log);
      },
    );
  }

  Widget _buildLogCard(ThemeData theme, AuditLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActionColor(log.action).withOpacity(0.2),
          child: Icon(
            _getActionIcon(log.action),
            color: _getActionColor(log.action),
            size: 20,
          ),
        ),
        title: Text(
          '${log.userName} ${_getActionText(log.action)} ${log.entity}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (log.description != null) Text(log.description!),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, y HH:mm:ss').format(log.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Icon(Icons.computer, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  log.ipAddress,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            _showLogDetails(context, log);
          },
        ),
      ),
    );
  }

  void _showLogDetails(BuildContext context, AuditLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Details'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailRow('User', log.userName),
              _buildDetailRow('Action', log.action),
              _buildDetailRow('Entity', '${log.entity} (${log.entityId})'),
              _buildDetailRow(
                'Timestamp',
                DateFormat('MMM d, y HH:mm:ss').format(log.timestamp),
              ),
              _buildDetailRow('IP Address', log.ipAddress),
              if (log.description != null)
                _buildDetailRow('Description', log.description!),
              if (log.metadata != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Metadata:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...log.metadata!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${entry.key}: ${entry.value}'),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Audit Logs'),
        content: const Text('Select export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting to CSV...')),
              );
              Navigator.pop(context);
            },
            child: const Text('Export CSV'),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting to JSON...')),
              );
              Navigator.pop(context);
            },
            child: const Text('Export JSON'),
          ),
        ],
      ),
    );
  }

  List<AuditLog> _filterLogs(List<AuditLog> logs) {
    var filtered = logs;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((log) {
        return log.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            log.entity.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (log.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    if (_selectedAction != null) {
      filtered = filtered.where((log) => log.action == _selectedAction).toList();
    }

    if (_selectedEntity != null) {
      filtered = filtered.where((log) => log.entity == _selectedEntity).toList();
    }

    if (_dateRange != null) {
      filtered = filtered.where((log) {
        return log.timestamp.isAfter(_dateRange!.start) &&
            log.timestamp.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'Created':
        return Icons.add_circle;
      case 'Updated':
        return Icons.edit;
      case 'Deleted':
        return Icons.delete;
      case 'Logged In':
        return Icons.login;
      case 'Logged Out':
        return Icons.logout;
      case 'Exported':
        return Icons.file_download;
      case 'Backed Up':
        return Icons.backup;
      case 'Restored':
        return Icons.restore;
      default:
        return Icons.info;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'Created':
        return Colors.green;
      case 'Updated':
        return Colors.blue;
      case 'Deleted':
        return Colors.red;
      case 'Logged In':
        return Colors.teal;
      case 'Logged Out':
        return Colors.grey;
      case 'Exported':
        return Colors.purple;
      case 'Backed Up':
        return Colors.orange;
      case 'Restored':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getActionText(String action) {
    final auditAction = AuditAction.values.firstWhere(
      (a) => a.label == action,
      orElse: () => AuditAction.update,
    );
    return auditAction.pastTense;
  }

  List<AuditLog> _getMockLogs() {
    final now = DateTime.now();
    return [
      AuditLog(
        id: '1',
        timestamp: now.subtract(const Duration(minutes: 5)),
        userId: '1',
        userName: 'John Smith',
        action: 'Created',
        entity: 'User',
        entityId: '8',
        description: 'Created new user: Jane Doe',
        ipAddress: '192.168.1.100',
      ),
      AuditLog(
        id: '2',
        timestamp: now.subtract(const Duration(minutes: 15)),
        userId: '2',
        userName: 'Sarah Johnson',
        action: 'Updated',
        entity: 'Product',
        entityId: '42',
        description: 'Updated product price: Burger ($12.99 → $13.99)',
        metadata: {'old_price': 12.99, 'new_price': 13.99},
        ipAddress: '192.168.1.101',
      ),
      AuditLog(
        id: '3',
        timestamp: now.subtract(const Duration(hours: 1)),
        userId: '1',
        userName: 'John Smith',
        action: 'Deleted',
        entity: 'Order',
        entityId: '1234',
        description: 'Deleted cancelled order',
        ipAddress: '192.168.1.100',
      ),
      AuditLog(
        id: '4',
        timestamp: now.subtract(const Duration(hours: 2)),
        userId: '3',
        userName: 'Mike Wilson',
        action: 'Logged In',
        entity: 'System',
        entityId: 'login',
        description: 'User logged in',
        ipAddress: '192.168.1.102',
      ),
      AuditLog(
        id: '5',
        timestamp: now.subtract(const Duration(hours: 3)),
        userId: '1',
        userName: 'John Smith',
        action: 'Updated',
        entity: 'Settings',
        entityId: 'system',
        description: 'Updated tax rate from 7% to 8%',
        metadata: {'setting': 'tax_rate', 'old_value': 7, 'new_value': 8},
        ipAddress: '192.168.1.100',
      ),
    ];
  }
}
