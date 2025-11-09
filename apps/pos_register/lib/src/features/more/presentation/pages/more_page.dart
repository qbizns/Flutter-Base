import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

/// More/Settings page with user profile, settings, and admin options
class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: userAsync.when(
        data: (user) => ListView(
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              color: theme.colorScheme.primaryContainer,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                  if (user.role != null) ...{
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        user.role!.name[0].toUpperCase() + user.role!.name.substring(1),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  },
                ],
              ),
            ),

            const SizedBox(height: 8),

            // POS Settings Section
            _buildSectionHeader(context, 'POS Settings'),
            _buildSettingsTile(
              context,
              icon: Icons.receipt_long,
              title: 'Receipt Printer',
              subtitle: 'Configure receipt printer settings',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.print,
              title: 'Kitchen Printer',
              subtitle: 'Configure kitchen printer settings',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.point_of_sale,
              title: 'Cash Drawer',
              subtitle: 'Configure cash drawer settings',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.payment,
              title: 'Payment Terminal',
              subtitle: 'Configure payment terminal',
              onTap: () => _showComingSoon(context),
            ),

            const Divider(height: 1),

            // App Settings Section
            _buildSectionHeader(context, 'App Settings'),
            _buildSettingsTile(
              context,
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: 'Change app appearance',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English (US)',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () => _showComingSoon(context),
            ),

            const Divider(height: 1),

            // Data & Reports Section
            _buildSectionHeader(context, 'Data & Reports'),
            _buildSettingsTile(
              context,
              icon: Icons.analytics_outlined,
              title: 'Sales Reports',
              subtitle: 'View sales analytics and reports',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.inventory_outlined,
              title: 'Inventory',
              subtitle: 'Manage product inventory',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.cloud_sync,
              title: 'Sync Status',
              subtitle: 'Last synced: Just now',
              onTap: () => _showComingSoon(context),
            ),

            const Divider(height: 1),

            // Account Section
            _buildSectionHeader(context, 'Account'),
            _buildSettingsTile(
              context,
              icon: Icons.business,
              title: 'Business Info',
              subtitle: 'Manage business details',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.store,
              title: 'Branch Settings',
              subtitle: 'Configure branch details',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.people_outline,
              title: 'Staff Management',
              subtitle: 'Manage staff and permissions',
              onTap: () => _showComingSoon(context),
            ),

            const Divider(height: 1),

            // Support Section
            _buildSectionHeader(context, 'Support'),
            _buildSettingsTile(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and tutorials',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () => _showAboutDialog(context),
            ),

            const SizedBox(height: 16),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () => _handleLogout(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error loading user data: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About SmartPOS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version: 1.0.0'),
            const SizedBox(height: 8),
            const Text('Build: 100'),
            const SizedBox(height: 16),
            Text(
              'SmartPOS is a modern, cloud-based point of sale system designed for restaurants and retail businesses.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
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

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final result = await ref.read(logoutUseCaseProvider)();
        await result.when(
          success: (_) {
            // Navigation will be handled by auth state change
            if (context.mounted) {
              context.go('/login');
            }
          },
          failure: (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logout failed: ${error.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
