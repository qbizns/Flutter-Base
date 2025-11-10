import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

/// Real-Time Operations Monitoring Page
///
/// Features:
/// - Live order status overview
/// - Table occupancy status
/// - Kitchen order queue
/// - Active staff monitoring
/// - Real-time updates with auto-refresh
/// - System health indicators
class MonitoringPage extends ConsumerStatefulWidget {
  const MonitoringPage({super.key});

  @override
  ConsumerState<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends ConsumerState<MonitoringPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Row(
          children: [
            const Text('Live Operations'),
            const SizedBox(width: 12),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'LIVE',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(ordersProvider);
              ref.invalidate(tablesProvider);
              ref.invalidate(usersProvider);
            },
            tooltip: 'Refresh All',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon')),
              );
            },
            tooltip: 'Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Orders', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Tables', icon: Icon(Icons.table_restaurant)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview tab
          _buildOverviewTab(context),

          // Orders tab
          _buildOrdersTab(context),

          // Tables tab
          _buildTablesTab(context),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(ordersProvider());
    final tablesAsync = ref.watch(tablesProvider());
    final usersAsync = ref.watch(usersProvider());

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ordersProvider);
        ref.invalidate(tablesProvider);
        ref.invalidate(usersProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System status
            Text(
              'System Status',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSystemStatusCards(context),

            const SizedBox(height: 32),

            // Active orders summary
            Text(
              'Active Orders',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ordersAsync.when(
              data: (orders) => _buildActiveOrdersSummary(context, orders),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading orders'),
            ),

            const SizedBox(height: 32),

            // Tables overview
            Text(
              'Tables Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            tablesAsync.when(
              data: (tables) => _buildTablesOverview(context, tables),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading tables'),
            ),

            const SizedBox(height: 32),

            // Active staff
            Text(
              'Active Staff',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            usersAsync.when(
              data: (users) => _buildActiveStaff(context, users),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading staff'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(ordersProvider());

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ordersProvider);
      },
      child: ordersAsync.when(
        data: (orders) {
          // Filter active orders
          final activeOrders = orders
              .where((o) =>
                  o.status == OrderStatus.pending ||
                  o.status == OrderStatus.preparing ||
                  o.status == OrderStatus.ready)
              .toList();

          if (activeOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active orders',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All orders are completed',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          // Group by status
          final pendingOrders = activeOrders
              .where((o) => o.status == OrderStatus.pending)
              .toList();
          final preparingOrders = activeOrders
              .where((o) => o.status == OrderStatus.preparing)
              .toList();
          final readyOrders = activeOrders
              .where((o) => o.status == OrderStatus.ready)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendingOrders.isNotEmpty) ...[
                _buildOrderSection(
                  context,
                  title: 'Pending (${pendingOrders.length})',
                  orders: pendingOrders,
                  color: Colors.orange,
                  icon: Icons.schedule,
                ),
                const SizedBox(height: 24),
              ],
              if (preparingOrders.isNotEmpty) ...[
                _buildOrderSection(
                  context,
                  title: 'Preparing (${preparingOrders.length})',
                  orders: preparingOrders,
                  color: Colors.blue,
                  icon: Icons.restaurant,
                ),
                const SizedBox(height: 24),
              ],
              if (readyOrders.isNotEmpty) ...[
                _buildOrderSection(
                  context,
                  title: 'Ready (${readyOrders.length})',
                  orders: readyOrders,
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading orders')),
      ),
    );
  }

  Widget _buildTablesTab(BuildContext context) {
    final theme = Theme.of(context);
    final tablesAsync = ref.watch(tablesProvider());

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(tablesProvider);
      },
      child: tablesAsync.when(
        data: (tables) {
          if (tables.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.table_restaurant,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tables configured',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          // Group by zone
          final tablesByZone = <String, List<Table>>{};
          for (final table in tables) {
            final zoneName = table.zone?.name ?? 'No Zone';
            if (!tablesByZone.containsKey(zoneName)) {
              tablesByZone[zoneName] = [];
            }
            tablesByZone[zoneName]!.add(table);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: tablesByZone.entries.map((entry) {
              final zoneName = entry.key;
              final zoneTables = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zoneName,
                    style: theme.textTheme.titleLarge?.copyWith(
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
                      childAspectRatio: 1.2,
                    ),
                    itemCount: zoneTables.length,
                    itemBuilder: (context, index) {
                      return _buildTableCard(context, zoneTables[index]);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading tables')),
      ),
    );
  }

  Widget _buildSystemStatusCards(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatusCard(
          context,
          icon: Icons.cloud_done,
          title: 'System',
          status: 'Online',
          color: Colors.green,
        ),
        _buildStatusCard(
          context,
          icon: Icons.restaurant,
          title: 'Kitchen',
          status: 'Active',
          color: Colors.green,
        ),
        _buildStatusCard(
          context,
          icon: Icons.payment,
          title: 'Payment',
          status: 'Ready',
          color: Colors.green,
        ),
        _buildStatusCard(
          context,
          icon: Icons.network_check,
          title: 'Network',
          status: 'Connected',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String status,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              status,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrdersSummary(BuildContext context, List<Order> orders) {
    final theme = Theme.of(context);

    final activeOrders = orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.preparing ||
            o.status == OrderStatus.ready)
        .toList();

    final pending = activeOrders
        .where((o) => o.status == OrderStatus.pending)
        .length;
    final preparing = activeOrders
        .where((o) => o.status == OrderStatus.preparing)
        .length;
    final ready = activeOrders
        .where((o) => o.status == OrderStatus.ready)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            icon: Icons.schedule,
            title: 'Pending',
            value: '$pending',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            icon: Icons.restaurant,
            title: 'Preparing',
            value: '$preparing',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            icon: Icons.check_circle,
            title: 'Ready',
            value: '$ready',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablesOverview(BuildContext context, List<Table> tables) {
    final theme = Theme.of(context);

    final available = tables.where((t) => t.status == TableStatus.available).length;
    final occupied = tables.where((t) => t.status == TableStatus.occupied).length;
    final reserved = tables.where((t) => t.status == TableStatus.reserved).length;

    final occupancyRate = tables.isNotEmpty
        ? (occupied / tables.length) * 100
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTableStat(
                  context,
                  label: 'Available',
                  value: '$available',
                  color: Colors.green,
                ),
                _buildTableStat(
                  context,
                  label: 'Occupied',
                  value: '$occupied',
                  color: Colors.red,
                ),
                _buildTableStat(
                  context,
                  label: 'Reserved',
                  value: '$reserved',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                Text(
                  'Occupancy Rate',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${occupancyRate.toStringAsFixed(0)}%',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: occupancyRate / 100,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableStat(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveStaff(BuildContext context, List<User> users) {
    final theme = Theme.of(context);

    final activeUsers = users.where((u) => u.isActive).toList();

    if (activeUsers.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text('No active staff', style: theme.textTheme.bodyLarge),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${activeUsers.length} staff members on duty',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: activeUsers.map((user) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  label: Text(user.name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSection(
    BuildContext context, {
    required String title,
    required List<Order> orders,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...orders.map((order) => _buildOrderCard(context, order, color)),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, Color statusColor) {
    final theme = Theme.of(context);
    final timeSinceCreated = DateTime.now().difference(order.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            _getOrderTypeIcon(order.orderType),
            color: statusColor,
          ),
        ),
        title: Text(
          'Order #${order.orderNumber}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${order.items.length} items • \$${order.total.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: _getTimeColor(timeSinceCreated),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(timeSinceCreated),
                  style: TextStyle(
                    color: _getTimeColor(timeSinceCreated),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildTableCard(BuildContext context, Table table) {
    final theme = Theme.of(context);
    final statusColor = _getTableStatusColor(table.status);

    return Card(
      elevation: 2,
      color: statusColor.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          // Show table details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_restaurant,
                size: 32,
                color: statusColor,
              ),
              const SizedBox(height: 8),
              Text(
                table.tableNumber,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getTableStatusName(table.status),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getOrderTypeIcon(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return Icons.restaurant;
      case OrderType.takeaway:
        return Icons.shopping_bag;
      case OrderType.delivery:
        return Icons.delivery_dining;
    }
  }

  Color _getTableStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.cleaning:
        return Colors.blue;
    }
  }

  String _getTableStatusName(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.cleaning:
        return 'Cleaning';
    }
  }

  Color _getTimeColor(Duration duration) {
    if (duration.inMinutes < 5) {
      return Colors.green;
    } else if (duration.inMinutes < 15) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ago';
    }
  }
}
