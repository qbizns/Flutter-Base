import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

/// Staff Management Page - Employee management and performance
///
/// Features:
/// - Staff list with roles and status
/// - Performance metrics per staff member
/// - Shift schedules (placeholder)
/// - Time tracking overview
/// - Filter by role and status
/// - Add/edit staff (placeholders)
class StaffPage extends ConsumerStatefulWidget {
  const StaffPage({super.key});

  @override
  ConsumerState<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends ConsumerState<StaffPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserRole? _selectedRole;
  String _searchQuery = '';

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
    final usersAsync = ref.watch(usersProvider());
    final ordersAsync = ref.watch(ordersProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(usersProvider);
              ref.invalidate(ordersProvider);
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add staff feature coming soon')),
              );
            },
            tooltip: 'Add Staff',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Performance', icon: Icon(Icons.analytics)),
            Tab(text: 'Schedules', icon: Icon(Icons.calendar_today)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filter bar
          _buildSearchBar(context),

          // Role filter
          _buildRoleFilter(context),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview tab
                RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(usersProvider);
                  },
                  child: usersAsync.when(
                    data: (users) => _buildOverviewTab(context, users),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Error loading staff')),
                  ),
                ),

                // Performance tab
                RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(usersProvider);
                    ref.invalidate(ordersProvider);
                  },
                  child: usersAsync.when(
                    data: (users) => ordersAsync.when(
                      data: (orders) =>
                          _buildPerformanceTab(context, users, orders),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Center(child: Text('Error loading orders')),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Error loading staff')),
                  ),
                ),

                // Schedules tab
                _buildSchedulesTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search staff...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildRoleFilter(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('All Roles'),
            selected: _selectedRole == null,
            onSelected: (selected) {
              setState(() {
                _selectedRole = null;
              });
            },
          ),
          const SizedBox(width: 8),
          ...UserRole.values.map((role) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_getRoleName(role)),
                  selected: _selectedRole == role,
                  avatar: Icon(
                    _getRoleIcon(role),
                    size: 18,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedRole = selected ? role : null;
                    });
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, List<User> users) {
    final theme = Theme.of(context);
    final filteredUsers = _filterUsers(users);

    // Calculate metrics
    final activeStaff = filteredUsers.where((u) => u.isActive).length;
    final totalStaff = filteredUsers.length;

    // Group by role
    final roleBreakdown = <UserRole, int>{};
    for (final user in filteredUsers) {
      roleBreakdown[user.role] = (roleBreakdown[user.role] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                context,
                icon: Icons.people,
                title: 'Total Staff',
                value: '$totalStaff',
                subtitle: '$activeStaff active',
                color: Colors.blue,
              ),
              _buildMetricCard(
                context,
                icon: Icons.schedule,
                title: 'On Duty',
                value: '$activeStaff',
                subtitle: 'Currently working',
                color: Colors.green,
              ),
              _buildMetricCard(
                context,
                icon: Icons.star,
                title: 'Top Performer',
                value: filteredUsers.isNotEmpty ? filteredUsers.first.name : 'N/A',
                subtitle: 'This month',
                color: Colors.amber,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Role breakdown
          Text(
            'Staff by Role',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRoleBreakdown(context, roleBreakdown, totalStaff),

          const SizedBox(height: 32),

          // Staff list
          Text(
            'Staff Members',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStaffList(context, filteredUsers),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(
    BuildContext context,
    List<User> users,
    List<Order> orders,
  ) {
    final theme = Theme.of(context);
    final filteredUsers = _filterUsers(users);

    // Calculate performance metrics
    final performanceData = _calculatePerformanceData(filteredUsers, orders);

    if (performanceData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No performance data available',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: performanceData.length,
      itemBuilder: (context, index) {
        final data = performanceData[index];
        final rank = index + 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getRankColor(rank).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(rank),
                  ),
                ),
              ),
            ),
            title: Text(
              data.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getRoleIcon(data.role),
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(_getRoleName(data.role)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMetricChip(
                      context,
                      icon: Icons.receipt_long,
                      label: '${data.ordersHandled} orders',
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      context,
                      icon: Icons.attach_money,
                      label: '\$${data.revenue.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${data.avgOrderValue.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Avg Order',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSchedulesTab(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder for schedules
    final today = DateTime.now();
    final weekDays = List.generate(7, (index) {
      return today.add(Duration(days: index - today.weekday + 1));
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Schedule',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Week selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      // Previous week
                    },
                  ),
                  Text(
                    '${DateFormat('MMM d').format(weekDays.first)} - ${DateFormat('MMM d, yyyy').format(weekDays.last)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      // Next week
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Day cards
          ...weekDays.map((day) {
            final isToday = day.day == today.day &&
                day.month == today.month &&
                day.year == today.year;

            return Card(
              color: isToday
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surface,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE').format(day),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? theme.colorScheme.onPrimaryContainer
                                    : null,
                              ),
                            ),
                            Text(
                              DateFormat('MMM d').format(day),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isToday
                                    ? theme.colorScheme.onPrimaryContainer
                                        .withOpacity(0.7)
                                    : theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Today',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Placeholder shifts
                    _buildShiftRow(
                      context,
                      time: '9:00 AM - 5:00 PM',
                      name: 'Morning Shift',
                      staffCount: 5,
                    ),
                    const SizedBox(height: 8),
                    _buildShiftRow(
                      context,
                      time: '5:00 PM - 11:00 PM',
                      name: 'Evening Shift',
                      staffCount: 4,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
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

  Widget _buildRoleBreakdown(
    BuildContext context,
    Map<UserRole, int> roleBreakdown,
    int totalStaff,
  ) {
    final theme = Theme.of(context);

    if (roleBreakdown.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text('No data available', style: theme.textTheme.bodyLarge),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: roleBreakdown.entries.map((entry) {
            final role = entry.key;
            final count = entry.value;
            final percentage = totalStaff > 0 ? (count / totalStaff) * 100 : 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getRoleIcon(role),
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getRoleName(role),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$count ${count == 1 ? 'person' : 'people'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStaffList(BuildContext context, List<User> users) {
    final theme = Theme.of(context);

    if (users.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text('No staff members found', style: theme.textTheme.bodyLarge),
          ),
        ),
      );
    }

    return Column(
      children: users.map((user) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(user.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getRoleIcon(user.role),
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(_getRoleName(user.role)),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.isActive ? 'Active' : 'Inactive',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: user.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildShiftRow(
    BuildContext context, {
    required String time,
    required String name,
    required int staffCount,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                time,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$staffCount staff',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  List<User> _filterUsers(List<User> users) {
    var filtered = users;

    // Apply role filter
    if (_selectedRole != null) {
      filtered = filtered.where((user) => user.role == _selectedRole).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  List<StaffPerformanceData> _calculatePerformanceData(
    List<User> users,
    List<Order> orders,
  ) {
    final performanceMap = <String, StaffPerformanceData>{};

    // Initialize with all users
    for (final user in users) {
      performanceMap[user.id] = StaffPerformanceData(
        id: user.id,
        name: user.name,
        role: user.role,
        ordersHandled: 0,
        revenue: 0,
        avgOrderValue: 0,
      );
    }

    // Calculate from orders (using createdBy as staff reference)
    // In a real app, you'd have explicit staff assignment on orders
    for (final order in orders) {
      if (order.createdBy != null && performanceMap.containsKey(order.createdBy)) {
        performanceMap[order.createdBy]!.ordersHandled++;
        performanceMap[order.createdBy]!.revenue += order.total;
      }
    }

    // Calculate averages
    for (final data in performanceMap.values) {
      if (data.ordersHandled > 0) {
        data.avgOrderValue = data.revenue / data.ordersHandled;
      }
    }

    // Sort by revenue
    final sorted = performanceMap.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return sorted.where((data) => data.ordersHandled > 0).toList();
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.cashier:
        return 'Cashier';
      case UserRole.waiter:
        return 'Waiter';
      case UserRole.kitchen:
        return 'Kitchen Staff';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.manager:
        return Icons.business;
      case UserRole.cashier:
        return Icons.point_of_sale;
      case UserRole.waiter:
        return Icons.restaurant;
      case UserRole.kitchen:
        return Icons.restaurant_menu;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}

// Data class
class StaffPerformanceData {
  final String id;
  final String name;
  final UserRole role;
  int ordersHandled;
  double revenue;
  double avgOrderValue;

  StaffPerformanceData({
    required this.id,
    required this.name,
    required this.role,
    required this.ordersHandled,
    required this.revenue,
    required this.avgOrderValue,
  });
}
