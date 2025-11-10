import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// System Settings Page
///
/// Features:
/// - General settings
/// - Restaurant information
/// - Business hours
/// - Tax and currency
/// - Payment methods
/// - Email and notifications
/// - API configuration
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: const Text('System Settings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Business'),
            Tab(text: 'Payment'),
            Tab(text: 'Notifications'),
            Tab(text: 'Advanced'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralSettings(theme),
          _buildBusinessSettings(theme),
          _buildPaymentSettings(theme),
          _buildNotificationSettings(theme),
          _buildAdvancedSettings(theme),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingCard(
          theme,
          title: 'Restaurant Information',
          children: [
            _buildTextField('Restaurant Name', 'SmartPOS Restaurant'),
            const SizedBox(height: 16),
            _buildTextField('Address', '123 Main St, City, State 12345'),
            const SizedBox(height: 16),
            _buildTextField('Phone', '+1 234 567 8900'),
            const SizedBox(height: 16),
            _buildTextField('Email', 'info@smartpos.com'),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingCard(
          theme,
          title: 'Regional Settings',
          children: [
            _buildDropdown('Language', 'English', ['English', 'Spanish', 'French']),
            const SizedBox(height: 16),
            _buildDropdown('Currency', 'USD (\$)', ['USD (\$)', 'EUR (€)', 'GBP (£)']),
            const SizedBox(height: 16),
            _buildDropdown('Timezone', 'America/New_York', [
              'America/New_York',
              'America/Los_Angeles',
              'America/Chicago',
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildBusinessSettings(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingCard(
          theme,
          title: 'Business Hours',
          children: [
            ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(day),
                    ),
                    Expanded(
                      child: _buildTextField('Open', '09:00 AM', dense: true),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField('Close', '10:00 PM', dense: true),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text('Saturday'),
                  ),
                  Expanded(
                    child: _buildTextField('Open', '10:00 AM', dense: true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('Close', '11:00 PM', dense: true),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text('Sunday'),
                ),
                Expanded(
                  child: _buildTextField('Open', '11:00 AM', dense: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('Close', '09:00 PM', dense: true),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingCard(
          theme,
          title: 'Tax Configuration',
          children: [
            _buildTextField('Tax Rate (%)', '8.00'),
            const SizedBox(height: 16),
            _buildTextField('Tax ID Number', '12-3456789'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include tax in prices'),
              subtitle: const Text('Show prices with tax included'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSettings(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingCard(
          theme,
          title: 'Payment Methods',
          children: [
            SwitchListTile(
              title: const Text('Cash'),
              subtitle: const Text('Accept cash payments'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Credit/Debit Card'),
              subtitle: const Text('Accept card payments'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Digital Wallet'),
              subtitle: const Text('Apple Pay, Google Pay'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Gift Cards'),
              subtitle: const Text('Accept gift card payments'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingCard(
          theme,
          title: 'Payment Gateway',
          children: [
            _buildDropdown(
              'Provider',
              'Stripe',
              ['Stripe', 'Square', 'PayPal'],
            ),
            const SizedBox(height: 16),
            _buildTextField('API Key', '••••••••••••••••'),
            const SizedBox(height: 16),
            _buildTextField('Secret Key', '••••••••••••••••'),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingCard(
          theme,
          title: 'Email Notifications',
          children: [
            SwitchListTile(
              title: const Text('New Orders'),
              subtitle: const Text('Notify when new orders are placed'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Low Stock Alerts'),
              subtitle: const Text('Notify when inventory is low'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Daily Reports'),
              subtitle: const Text('Receive daily sales reports'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingCard(
          theme,
          title: 'SMS Notifications',
          children: [
            SwitchListTile(
              title: const Text('Order Updates'),
              subtitle: const Text('Send SMS to customers'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Delivery Updates'),
              subtitle: const Text('Notify customers about delivery'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingCard(
          theme,
          title: 'Push Notifications',
          children: [
            SwitchListTile(
              title: const Text('Enable Push Notifications'),
              subtitle: const Text('Send notifications to mobile apps'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingCard(
          theme,
          title: 'API Configuration',
          children: [
            _buildTextField('API Base URL', 'https://api.smartpos.com'),
            const SizedBox(height: 16),
            _buildTextField('API Version', 'v1'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable API Access'),
              subtitle: const Text('Allow external API access'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingCard(
          theme,
          title: 'Database',
          children: [
            ListTile(
              title: const Text('Backup Database'),
              subtitle: const Text('Last backup: 2 hours ago'),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating backup...')),
                  );
                },
                child: const Text('Backup Now'),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Restore Database'),
              subtitle: const Text('Restore from backup'),
              trailing: ElevatedButton(
                onPressed: () {
                  _showRestoreDialog(context);
                },
                child: const Text('Restore'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingCard(
          theme,
          title: 'Maintenance',
          children: [
            SwitchListTile(
              title: const Text('Maintenance Mode'),
              subtitle: const Text('Disable access for maintenance'),
              value: false,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Clear Cache'),
              subtitle: const Text('Clear application cache'),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                },
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingCard(
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, {bool dense = false}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: dense,
      ),
      controller: TextEditingController(text: value),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: (value) {},
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Database'),
        content: const Text(
          'Are you sure you want to restore the database? '
          'This will replace all current data with the backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restoring database...')),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
