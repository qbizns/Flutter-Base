import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// System Dashboard Page
///
/// Features:
/// - System health overview
/// - Active users
/// - Recent activity
/// - Quick stats
/// - System alerts
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh dashboard
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // System Health
          _buildSystemHealth(theme),

          const SizedBox(height: 24),

          // Quick Stats
          _buildQuickStats(theme),

          const SizedBox(height: 24),

          // Recent Activity & System Alerts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildRecentActivity(theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSystemAlerts(theme),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Active Apps Status
          _buildAppsStatus(theme),
        ],
      ),
    );
  }

  Widget _buildSystemHealth(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Health',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    theme,
                    'CPU Usage',
                    45,
                    Icons.memory,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHealthMetric(
                    theme,
                    'Memory',
                    68,
                    Icons.storage,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHealthMetric(
                    theme,
                    'Disk Space',
                    32,
                    Icons.folder,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHealthMetric(
                    theme,
                    'Database',
                    25,
                    Icons.dns,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(
    ThemeData theme,
    String label,
    int percentage,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            Icon(icon, size: 32, color: color),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Total Users',
            '47',
            Icons.people,
            theme.colorScheme.primary,
            '+5 this week',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Active Sessions',
            '23',
            Icons.person,
            Colors.green,
            'Currently online',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Today\'s Orders',
            '156',
            Icons.receipt,
            Colors.blue,
            '+12% vs yesterday',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            'System Uptime',
            '99.9%',
            Icons.check_circle,
            Colors.green,
            'Last 30 days',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    final activities = _getMockActivities();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...activities.map((activity) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: activity['color'].withOpacity(0.2),
                  child: Icon(
                    activity['icon'],
                    color: activity['color'],
                    size: 20,
                  ),
                ),
                title: Text(activity['title']),
                subtitle: Text(activity['subtitle']),
                trailing: Text(
                  activity['time'],
                  style: theme.textTheme.bodySmall,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemAlerts(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Alerts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAlertItem(
              theme,
              'Low Stock Warning',
              '5 items below threshold',
              Colors.orange,
              Icons.warning,
            ),
            _buildAlertItem(
              theme,
              'Backup Needed',
              'Last backup: 3 days ago',
              Colors.red,
              Icons.backup,
            ),
            _buildAlertItem(
              theme,
              'Update Available',
              'Version 2.0.1 ready',
              Colors.blue,
              Icons.system_update,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.notifications),
              label: const Text('View All Alerts'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(
    ThemeData theme,
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsStatus(ThemeData theme) {
    final apps = [
      {'name': 'KDS App', 'status': 'Online', 'users': 8},
      {'name': 'Waiter App', 'status': 'Online', 'users': 12},
      {'name': 'Customer Kiosk', 'status': 'Online', 'users': 3},
      {'name': 'Manager Dashboard', 'status': 'Online', 'users': 2},
      {'name': 'Inventory Management', 'status': 'Online', 'users': 1},
      {'name': 'Order Display', 'status': 'Online', 'users': 0},
      {'name': 'Delivery Management', 'status': 'Online', 'users': 4},
      {'name': 'Customer App', 'status': 'Online', 'users': 45},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apps Status',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2,
              ),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              app['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${app['users']} users',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockActivities() {
    return [
      {
        'icon': Icons.person_add,
        'color': Colors.green,
        'title': 'New user created',
        'subtitle': 'Jane Doe added by John Smith',
        'time': '5m ago',
      },
      {
        'icon': Icons.shopping_cart,
        'color': Colors.blue,
        'title': 'Order completed',
        'subtitle': 'Order #1234 processed',
        'time': '15m ago',
      },
      {
        'icon': Icons.settings,
        'color': Colors.orange,
        'title': 'Settings updated',
        'subtitle': 'Tax rate changed to 8%',
        'time': '1h ago',
      },
      {
        'icon': Icons.backup,
        'color': Colors.purple,
        'title': 'System backup',
        'subtitle': 'Database backed up successfully',
        'time': '2h ago',
      },
    ];
  }
}
