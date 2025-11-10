import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Stores Dashboard - Multi-store overview and management
class StoresDashboardPage extends ConsumerWidget {
  const StoresDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock store data
    final stores = [
      Store('ST001', 'Downtown Branch', '123 Main St, New York, NY', StoreStatus.active, 15420.50, 145, 8, DateTime.now().subtract(const Duration(hours: 2)), 98.5),
      Store('ST002', 'Westside Mall', '456 Mall Ave, New York, NY', StoreStatus.active, 12890.75, 132, 6, DateTime.now().subtract(const Duration(hours: 1)), 97.2),
      Store('ST003', 'Airport Terminal', '789 Airport Rd, New York, NY', StoreStatus.active, 18650.00, 198, 10, DateTime.now().subtract(const Duration(minutes: 30)), 99.1),
      Store('ST004', 'Brooklyn Heights', '321 Heights Blvd, Brooklyn, NY', StoreStatus.active, 9845.25, 98, 5, DateTime.now().subtract(const Duration(hours: 3)), 96.8),
      Store('ST005', 'Queens Plaza', '654 Plaza Dr, Queens, NY', StoreStatus.maintenance, 0, 0, 4, DateTime.now().subtract(const Duration(days: 1)), 0),
      Store('ST006', 'Staten Island', '987 Island Way, Staten Island, NY', StoreStatus.active, 7230.50, 78, 4, DateTime.now().subtract(const Duration(hours: 4)), 95.5),
    ];

    final activeStores = stores.where((s) => s.status == StoreStatus.active).length;
    final totalRevenue = stores.fold<double>(0, (sum, s) => sum + s.todayRevenue);
    final totalOrders = stores.fold<int>(0, (sum, s) => sum + s.todayOrders);
    final avgSystemHealth = stores.where((s) => s.status == StoreStatus.active).fold<double>(0, (sum, s) => sum + s.systemHealth) / activeStores;

    return Scaffold(
      appBar: AppBar(title: const Text('Stores Overview')),
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
                            Icon(Icons.store, color: theme.colorScheme.onPrimaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text('Active Stores', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$activeStores/${stores.length}',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                        ),
                        Text('Locations', style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7))),
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
                            Icon(Icons.attach_money, color: theme.colorScheme.onSecondaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text('Total Revenue', style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalRevenue),
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
                  color: theme.colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt_long, color: theme.colorScheme.onTertiaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text('Total Orders', style: TextStyle(color: theme.colorScheme.onTertiaryContainer)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.decimalPattern().format(totalOrders),
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onTertiaryContainer),
                        ),
                        Text('Today', style: TextStyle(fontSize: 12, color: theme.colorScheme.onTertiaryContainer.withOpacity(0.7))),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.health_and_safety, color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('System Health', style: TextStyle(color: Colors.green.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${avgSystemHealth.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        ),
                        Text('Average', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stores grid
          Text('Store Locations', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return _buildStoreCard(theme, store);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Store'),
      ),
    );
  }

  Widget _buildStoreCard(ThemeData theme, Store store) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(store.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.store, color: _getStatusColor(store.status), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          store.id,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(store.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      store.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(store.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                store.address,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 2),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(store.todayRevenue),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Orders', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 2),
                        Text(
                          '${store.todayOrders}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Staff', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.people, size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${store.activeStaff}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (store.status == StoreStatus.active)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Health', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 2),
                          Text(
                            '${store.systemHealth.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: store.systemHealth >= 98 ? Colors.green : (store.systemHealth >= 95 ? Colors.orange : Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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
}

// Models
class Store {
  final String id;
  final String name;
  final String address;
  final StoreStatus status;
  final double todayRevenue;
  final int todayOrders;
  final int activeStaff;
  final DateTime lastSync;
  final double systemHealth;

  Store(this.id, this.name, this.address, this.status, this.todayRevenue, this.todayOrders, this.activeStaff, this.lastSync, this.systemHealth);
}

enum StoreStatus { active, inactive, maintenance }
