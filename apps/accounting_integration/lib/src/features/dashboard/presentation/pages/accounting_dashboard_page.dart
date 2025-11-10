import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Accounting Dashboard - Sync status and financial overview
class AccountingDashboardPage extends ConsumerWidget {
  const AccountingDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock accounting data
    final connections = [
      AccountingConnection('QuickBooks Online', AccountingProvider.quickbooks, ConnectionStatus.connected, DateTime.now().subtract(const Duration(minutes: 15)), 1245, 0, 98.5),
      AccountingConnection('Xero', AccountingProvider.xero, ConnectionStatus.connected, DateTime.now().subtract(const Duration(hours: 1)), 856, 3, 99.2),
      AccountingConnection('Sage Intacct', AccountingProvider.sage, ConnectionStatus.disconnected, null, 0, 0, 0),
    ];

    final recentSyncs = [
      SyncLog('SYNC001', DateTime.now().subtract(const Duration(minutes: 15)), AccountingProvider.quickbooks, SyncType.sales, 45, 0, SyncStatus.completed),
      SyncLog('SYNC002', DateTime.now().subtract(const Duration(minutes: 30)), AccountingProvider.quickbooks, SyncType.expenses, 28, 0, SyncStatus.completed),
      SyncLog('SYNC003', DateTime.now().subtract(const Duration(hours: 1)), AccountingProvider.xero, SyncType.invoices, 32, 3, SyncStatus.partial),
      SyncLog('SYNC004', DateTime.now().subtract(const Duration(hours: 2)), AccountingProvider.xero, SyncType.payments, 18, 0, SyncStatus.completed),
    ];

    final totalSynced = connections.fold<int>(0, (sum, c) => sum + c.recordsSynced);
    final totalErrors = connections.fold<int>(0, (sum, c) => sum + c.errors);
    final connectedCount = connections.where((c) => c.status == ConnectionStatus.connected).length;
    final avgHealth = connections.where((c) => c.status == ConnectionStatus.connected).fold<double>(0, (sum, c) => sum + c.syncHealth) / connectedCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Accounting Integration')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(
            children: [
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
                            Icon(Icons.link, color: theme.colorScheme.onPrimaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text('Connected', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$connectedCount/${connections.length}',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                        ),
                        Text('Systems', style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sync, color: theme.colorScheme.onSecondaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text('Records Synced', style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.decimalPattern().format(totalSynced),
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer),
                        ),
                        Text('Today', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: totalErrors > 0 ? Colors.orange.shade50 : Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(totalErrors > 0 ? Icons.warning : Icons.check_circle, color: totalErrors > 0 ? Colors.orange.shade700 : Colors.green.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Sync Errors', style: TextStyle(color: totalErrors > 0 ? Colors.orange.shade700 : Colors.green.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalErrors',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: totalErrors > 0 ? Colors.orange.shade700 : Colors.green.shade700),
                        ),
                        Text('Needs review', style: TextStyle(fontSize: 12, color: (totalErrors > 0 ? Colors.orange.shade700 : Colors.green.shade700).withOpacity(0.7))),
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
                            Icon(Icons.health_and_safety, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Sync Health', style: TextStyle(color: Colors.blue.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${avgHealth.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                        ),
                        Text('Average', style: TextStyle(fontSize: 12, color: Colors.blue.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Connected Systems
          Text('Connected Systems', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...connections.map((connection) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getProviderColor(connection.provider).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getProviderIcon(connection.provider), color: _getProviderColor(connection.provider), size: 28),
              ),
              title: Row(
                children: [
                  Text(connection.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(connection.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      connection.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(connection.status),
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: connection.status == ConnectionStatus.connected
                  ? Text('${NumberFormat.decimalPattern().format(connection.recordsSynced)} records • Last sync ${_formatTime(connection.lastSync!)} • ${connection.syncHealth.toStringAsFixed(1)}% health')
                  : const Text('Not connected'),
              trailing: connection.status == ConnectionStatus.connected
                  ? CircularProgressIndicator(
                      value: connection.syncHealth / 100,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor(connection.syncHealth)),
                    )
                  : null,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (connection.status == ConnectionStatus.connected) ...[
                        _buildInfoRow('Provider', connection.provider.name.toUpperCase()),
                        _buildInfoRow('Records Synced', NumberFormat.decimalPattern().format(connection.recordsSynced)),
                        _buildInfoRow('Sync Errors', '${connection.errors}'),
                        _buildInfoRow('Sync Health', '${connection.syncHealth.toStringAsFixed(1)}%'),
                        if (connection.lastSync != null)
                          _buildInfoRow('Last Sync', DateFormat('MMM dd, yyyy h:mm a').format(connection.lastSync!)),
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
                              child: FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.sync, size: 18),
                                label: const Text('Sync Now'),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        _buildInfoRow('Status', 'Disconnected'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.link, size: 18),
                          label: const Text('Connect'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 24),

          // Recent Syncs
          Text('Recent Sync Activity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: recentSyncs.asMap().entries.map((entry) {
                final index = entry.key;
                final sync = entry.value;
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getSyncStatusColor(sync.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getSyncTypeIcon(sync.type), color: _getSyncStatusColor(sync.status), size: 20),
                      ),
                      title: Row(
                        children: [
                          Text(sync.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(width: 8),
                          Text('• ${sync.type.name.toUpperCase()}', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getSyncStatusColor(sync.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sync.status.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _getSyncStatusColor(sync.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text('${sync.provider.name} • ${_formatTime(sync.timestamp)} • ${sync.recordsProcessed} records${sync.errors > 0 ? ' • ${sync.errors} errors' : ''}'),
                      trailing: Icon(
                        sync.status == SyncStatus.completed ? Icons.check_circle : (sync.status == SyncStatus.partial ? Icons.warning : Icons.error),
                        color: _getSyncStatusColor(sync.status),
                      ),
                    ),
                    if (index < recentSyncs.length - 1) const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.sync),
        label: const Text('Sync All'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _getProviderColor(AccountingProvider provider) {
    switch (provider) {
      case AccountingProvider.quickbooks: return Colors.green;
      case AccountingProvider.xero: return Colors.blue;
      case AccountingProvider.sage: return Colors.orange;
    }
  }

  IconData _getProviderIcon(AccountingProvider provider) {
    switch (provider) {
      case AccountingProvider.quickbooks: return Icons.account_balance;
      case AccountingProvider.xero: return Icons.calculate;
      case AccountingProvider.sage: return Icons.business;
    }
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected: return Colors.green;
      case ConnectionStatus.disconnected: return Colors.grey;
      case ConnectionStatus.error: return Colors.red;
    }
  }

  Color _getHealthColor(double health) {
    if (health >= 95) return Colors.green;
    if (health >= 85) return Colors.orange;
    return Colors.red;
  }

  Color _getSyncStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.completed: return Colors.green;
      case SyncStatus.partial: return Colors.orange;
      case SyncStatus.failed: return Colors.red;
    }
  }

  IconData _getSyncTypeIcon(SyncType type) {
    switch (type) {
      case SyncType.sales: return Icons.shopping_cart;
      case SyncType.expenses: return Icons.money_off;
      case SyncType.invoices: return Icons.receipt;
      case SyncType.payments: return Icons.payment;
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
class AccountingConnection {
  final String name;
  final AccountingProvider provider;
  final ConnectionStatus status;
  final DateTime? lastSync;
  final int recordsSynced;
  final int errors;
  final double syncHealth;

  AccountingConnection(this.name, this.provider, this.status, this.lastSync, this.recordsSynced, this.errors, this.syncHealth);
}

class SyncLog {
  final String id;
  final DateTime timestamp;
  final AccountingProvider provider;
  final SyncType type;
  final int recordsProcessed;
  final int errors;
  final SyncStatus status;

  SyncLog(this.id, this.timestamp, this.provider, this.type, this.recordsProcessed, this.errors, this.status);
}

enum AccountingProvider { quickbooks, xero, sage }
enum ConnectionStatus { connected, disconnected, error }
enum SyncStatus { completed, partial, failed }
enum SyncType { sales, expenses, invoices, payments }
