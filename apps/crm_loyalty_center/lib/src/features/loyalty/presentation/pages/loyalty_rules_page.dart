import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loyalty Rules Page
///
/// Configure loyalty program rules, points, tiers, and rewards.
/// Features:
/// - Points earning rules
/// - Tier configuration (Bronze, Silver, Gold)
/// - Reward redemption rules
/// - Birthday rewards
/// - Special event bonuses
class LoyaltyRulesPage extends ConsumerWidget {
  const LoyaltyRulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Program Rules'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Points Earning Rules
          Text(
            'Points Earning Rules',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRuleCard(
            theme,
            'Purchase Points',
            'Earn 1 point for every \$1 spent',
            Icons.shopping_cart,
            Colors.green,
            true,
          ),
          const SizedBox(height: 12),
          _buildRuleCard(
            theme,
            'Sign-Up Bonus',
            'Get 100 points when joining',
            Icons.person_add,
            Colors.blue,
            true,
          ),
          const SizedBox(height: 12),
          _buildRuleCard(
            theme,
            'Birthday Reward',
            'Receive 200 bonus points on birthday',
            Icons.cake,
            Colors.pink,
            true,
          ),
          const SizedBox(height: 12),
          _buildRuleCard(
            theme,
            'Referral Bonus',
            '500 points for each successful referral',
            Icons.people,
            Colors.purple,
            true,
          ),
          const SizedBox(height: 24),

          // Tier System
          Text(
            'Loyalty Tiers',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTierCard(
            theme,
            'Bronze',
            '0 - 499 points',
            ['5% discount on orders', 'Access to exclusive deals'],
            Colors.brown,
          ),
          const SizedBox(height: 12),
          _buildTierCard(
            theme,
            'Silver',
            '500 - 1,499 points',
            ['10% discount on orders', 'Free delivery', 'Priority support'],
            Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildTierCard(
            theme,
            'Gold',
            '1,500+ points',
            ['15% discount on orders', 'Free delivery', 'Birthday gift', 'VIP support'],
            Colors.amber,
          ),
          const SizedBox(height: 24),

          // Redemption Rules
          Text(
            'Redemption Options',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('100 points = \$1 discount'),
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.local_shipping),
                  title: const Text('750 points = Free delivery'),
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restaurant),
                  title: const Text('1000 points = Free item'),
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Rule'),
      ),
    );
  }

  Widget _buildRuleCard(
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Switch(
          value: isActive,
          onChanged: (value) {},
        ),
      ),
    );
  }

  Widget _buildTierCard(
    ThemeData theme,
    String tier,
    String range,
    List<String> benefits,
    Color color,
  ) {
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.star, color: color, size: 32),
        title: Text(
          tier,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(range),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Benefits:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...benefits.map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: color),
                          const SizedBox(width: 8),
                          Expanded(child: Text(benefit)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
