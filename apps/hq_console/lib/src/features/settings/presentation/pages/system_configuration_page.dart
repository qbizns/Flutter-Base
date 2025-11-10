import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// System Configuration - HQ-wide settings and integrations
class SystemConfigurationPage extends ConsumerStatefulWidget {
  const SystemConfigurationPage({super.key});

  @override
  ConsumerState<SystemConfigurationPage> createState() => _SystemConfigurationPageState();
}

class _SystemConfigurationPageState extends ConsumerState<SystemConfigurationPage> with SingleTickerProviderStateMixin {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Configuration'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'General', icon: Icon(Icons.settings)),
            Tab(text: 'Integrations', icon: Icon(Icons.extension)),
            Tab(text: 'Security', icon: Icon(Icons.security)),
            Tab(text: 'Backup', icon: Icon(Icons.backup)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // General Settings tab
          _buildGeneralTab(theme),

          // Integrations tab
          _buildIntegrationsTab(theme),

          // Security tab
          _buildSecurityTab(theme),

          // Backup tab
          _buildBackupTab(theme),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Business Information', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSettingField('Company Name', 'SmartPOS Corporation'),
                _buildSettingField('Tax ID', 'XX-XXXXXXX'),
                _buildSettingField('Primary Address', '123 Corporate Blvd, New York, NY 10001'),
                _buildSettingField('Support Email', 'support@smartpos.com'),
                _buildSettingField('Support Phone', '+1 (800) 555-SMART'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text('Operating Hours', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSettingField('Default Opening', '9:00 AM'),
                _buildSettingField('Default Closing', '9:00 PM'),
                _buildSettingField('Timezone', 'America/New_York (EST)'),
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
                _buildSettingField('Default Currency', 'USD (\$)'),
                _buildSettingField('Tax Rate', '8.875%'),
                _buildSettingField('Payment Processing', 'Stripe'),
                _buildSettingField('Settlement Frequency', 'Daily'),
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
                icon: const Icon(Icons.restore),
                label: const Text('Reset to Defaults'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntegrationsTab(ThemeData theme) {
    final integrations = [
      Integration('Stripe', 'Payment processing gateway', IntegrationStatus.connected, Icons.credit_card, Colors.purple, DateTime.now().subtract(const Duration(minutes: 5))),
      Integration('Square', 'Point of sale integration', IntegrationStatus.connected, Icons.square, Colors.black, DateTime.now().subtract(const Duration(minutes: 12))),
      Integration('QuickBooks', 'Accounting software', IntegrationStatus.connected, Icons.calculate, Colors.green, DateTime.now().subtract(const Duration(hours: 2))),
      Integration('Mailchimp', 'Email marketing platform', IntegrationStatus.disconnected, Icons.email, Colors.orange, null),
      Integration('Twilio', 'SMS notifications', IntegrationStatus.connected, Icons.sms, Colors.red, DateTime.now().subtract(const Duration(minutes: 8))),
      Integration('Shopify', 'E-commerce platform', IntegrationStatus.error, Icons.shopping_bag, Colors.green.shade700, DateTime.now().subtract(const Duration(days: 1))),
    ];

    final connectedCount = integrations.where((i) => i.status == IntegrationStatus.connected).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.extension, size: 48, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Integrations',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$connectedCount/${integrations.length}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text('Installed Integrations', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...integrations.map((integration) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: integration.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(integration.icon, color: integration.color, size: 28),
            ),
            title: Row(
              children: [
                Text(integration.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getIntegrationStatusColor(integration.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    integration.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getIntegrationStatusColor(integration.status),
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(integration.description),
                if (integration.lastSync != null)
                  Text(
                    'Last synced ${_formatLastSync(integration.lastSync!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (integration.status == IntegrationStatus.connected) ...[
                      _buildInfoRow(Icons.check_circle, 'Status', 'Connected and syncing'),
                      if (integration.lastSync != null)
                        _buildInfoRow(Icons.schedule, 'Last Sync', _formatLastSync(integration.lastSync!)),
                      _buildInfoRow(Icons.security, 'Authentication', 'OAuth 2.0'),
                    ] else if (integration.status == IntegrationStatus.error) ...[
                      _buildInfoRow(Icons.error, 'Status', 'Connection error'),
                      _buildInfoRow(Icons.warning, 'Error', 'API key expired or invalid'),
                    ] else ...[
                      _buildInfoRow(Icons.info, 'Status', 'Not configured'),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (integration.status != IntegrationStatus.disconnected) ...[
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
                              icon: const Icon(Icons.sync, size: 18),
                              label: const Text('Sync Now'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Disconnect'),
                          ),
                        ] else ...[
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.link, size: 18),
                              label: const Text('Connect'),
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
    );
  }

  Widget _buildSecurityTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Access Control', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSwitchSetting('Two-Factor Authentication', 'Require 2FA for all admin accounts', true),
                _buildSwitchSetting('Password Expiry', 'Force password change every 90 days', true),
                _buildSwitchSetting('IP Whitelist', 'Restrict access to approved IP addresses', false),
                _buildSwitchSetting('Session Timeout', 'Auto-logout after 30 minutes of inactivity', true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text('Audit & Compliance', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSwitchSetting('Audit Logging', 'Log all system and user activities', true),
                _buildSwitchSetting('Data Encryption', 'Encrypt sensitive data at rest', true),
                _buildSwitchSetting('PCI Compliance', 'Enable PCI-DSS compliance mode', true),
                _buildSwitchSetting('GDPR Mode', 'Enable GDPR data protection features', false),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text('API Security', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSettingField('API Version', 'v2.5.0'),
                _buildSettingField('API Key', '••••••••••••••••sk_live_abc123'),
                _buildSettingField('Webhook Secret', '••••••••••••••••whsec_xyz789'),
                _buildSettingField('Rate Limit', '1000 requests/hour'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Regenerate API Key'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Logs'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackupTab(ThemeData theme) {
    final backups = [
      Backup('backup_2024_11_10_03_00', DateTime(2024, 11, 10, 3, 0), 2.4, BackupStatus.completed),
      Backup('backup_2024_11_09_03_00', DateTime(2024, 11, 9, 3, 0), 2.3, BackupStatus.completed),
      Backup('backup_2024_11_08_03_00', DateTime(2024, 11, 8, 3, 0), 2.3, BackupStatus.completed),
      Backup('backup_2024_11_07_03_00', DateTime(2024, 11, 7, 3, 0), 2.2, BackupStatus.completed),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Backup Settings', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSwitchSetting('Automatic Backups', 'Run daily backups at 3:00 AM', true),
                _buildSwitchSetting('Cloud Sync', 'Sync backups to AWS S3', true),
                _buildSwitchSetting('Backup Encryption', 'Encrypt backup files', true),
                const Divider(height: 32),
                _buildSettingField('Retention Period', '30 days'),
                _buildSettingField('Backup Location', 's3://smartpos-backups/production/'),
                _buildSettingField('Last Backup', 'Nov 10, 2024 at 3:00 AM'),
                _buildSettingField('Next Backup', 'Nov 11, 2024 at 3:00 AM'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.backup),
                label: const Text('Backup Now'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.restore),
                label: const Text('Restore Backup'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text('Recent Backups', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...backups.map((backup) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getBackupStatusColor(backup.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                backup.status == BackupStatus.completed ? Icons.check_circle : Icons.schedule,
                color: _getBackupStatusColor(backup.status),
              ),
            ),
            title: Text(backup.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            subtitle: Text('${backup.size.toStringAsFixed(1)} GB • ${backup.timestamp.month}/${backup.timestamp.day}/${backup.timestamp.year} at ${backup.timestamp.hour}:${backup.timestamp.minute.toString().padLeft(2, '0')}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  tooltip: 'Download',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.restore),
                  tooltip: 'Restore',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSettingField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(String title, String subtitle, bool value) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: (newValue) {},
      contentPadding: EdgeInsets.zero,
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

  Color _getIntegrationStatusColor(IntegrationStatus status) {
    switch (status) {
      case IntegrationStatus.connected: return Colors.green;
      case IntegrationStatus.disconnected: return Colors.grey;
      case IntegrationStatus.error: return Colors.red;
    }
  }

  Color _getBackupStatusColor(BackupStatus status) {
    switch (status) {
      case BackupStatus.completed: return Colors.green;
      case BackupStatus.inProgress: return Colors.blue;
      case BackupStatus.failed: return Colors.red;
    }
  }

  String _formatLastSync(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

// Models
class Integration {
  final String name;
  final String description;
  final IntegrationStatus status;
  final IconData icon;
  final Color color;
  final DateTime? lastSync;

  Integration(this.name, this.description, this.status, this.icon, this.color, this.lastSync);
}

class Backup {
  final String id;
  final DateTime timestamp;
  final double size;
  final BackupStatus status;

  Backup(this.id, this.timestamp, this.size, this.status);
}

enum IntegrationStatus { connected, disconnected, error }
enum BackupStatus { completed, inProgress, failed }
