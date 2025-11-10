import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Account Page
///
/// User account management and order history.
/// Features:
/// - User profile information
/// - Order history with status
/// - Saved addresses
/// - Saved payment methods
/// - Account settings
/// - Loyalty points/rewards
class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock order history
  final List<PastOrder> _orderHistory = [
    PastOrder(
      id: '12345',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      items: 3,
      total: 46.00,
      status: 'Delivered',
    ),
    PastOrder(
      id: '12344',
      date: DateTime.now().subtract(const Duration(days: 2)),
      items: 2,
      total: 32.50,
      status: 'Delivered',
    ),
    PastOrder(
      id: '12343',
      date: DateTime.now().subtract(const Duration(days: 5)),
      items: 4,
      total: 58.99,
      status: 'Delivered',
    ),
  ];

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
      body: CustomScrollView(
        slivers: [
          // App bar with profile
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.surface,
                        child: Text(
                          'JD',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'john.doe@example.com',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Orders'),
                Tab(text: 'Profile'),
                Tab(text: 'Rewards'),
              ],
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersTab(theme),
                _buildProfileTab(theme),
                _buildRewardsTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(ThemeData theme) {
    if (_orderHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orderHistory.length,
      itemBuilder: (context, index) {
        final order = _orderHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              'Order #${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(DateFormat('MMM dd, yyyy - h:mm a').format(order.date)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${order.items} items'),
                    const SizedBox(width: 8),
                    Text('•'),
                    const SizedBox(width: 8),
                    Text(
                      NumberFormat.currency(symbol: '\$').format(order.total),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              // Navigate to order details
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Personal Information
        Text(
          'Personal Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Name'),
                subtitle: const Text('John Doe'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: const Text('john.doe@example.com'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: const Text('+1 (555) 123-4567'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Saved Addresses
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved Addresses',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                subtitle: const Text('123 Main St, San Francisco, CA 94102'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('Work'),
                subtitle: const Text('456 Market St, San Francisco, CA 94103'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Settings
        Text(
          'Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive order updates'),
                value: true,
                onChanged: (value) {},
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.email),
                title: const Text('Email Notifications'),
                subtitle: const Text('Promotions and updates'),
                value: false,
                onChanged: (value) {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: const Text('English'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Logout button
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Loyalty card
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loyalty Points',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            '1,250',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: 0.75,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: theme.colorScheme.onPrimaryContainer.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '250 points to next reward',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Available rewards
        Text(
          'Available Rewards',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildRewardCard(
          theme,
          '10% Off Next Order',
          '500 points',
          'Valid for 30 days',
          Icons.discount,
          true,
        ),
        const SizedBox(height: 12),
        _buildRewardCard(
          theme,
          'Free Delivery',
          '750 points',
          'Valid for 60 days',
          Icons.delivery_dining,
          true,
        ),
        const SizedBox(height: 12),
        _buildRewardCard(
          theme,
          'Free Dessert',
          '1000 points',
          'Valid for 90 days',
          Icons.cake,
          true,
        ),
        const SizedBox(height: 12),
        _buildRewardCard(
          theme,
          '\$25 Off',
          '2000 points',
          'Minimum order \$50',
          Icons.card_giftcard,
          false,
        ),
        const SizedBox(height: 24),

        // Referral program
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.people, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Refer a Friend',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Give \$10, Get \$10',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Share Referral Code'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard(
    ThemeData theme,
    String title,
    String points,
    String description,
    IconData icon,
    bool canClaim,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: canClaim
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: canClaim
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: canClaim ? null : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(description),
          ],
        ),
        trailing: canClaim
            ? FilledButton(
                onPressed: () {},
                child: Text(points),
              )
            : Text(
                points,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
      ),
    );
  }
}

// Models
class PastOrder {
  final String id;
  final DateTime date;
  final int items;
  final double total;
  final String status;

  PastOrder({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
  });
}
