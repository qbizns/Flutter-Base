import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../providers/settings_providers.dart';

/// Notification Settings View
///
/// Contains:
/// - Push notifications toggle
/// - Sound alerts toggle
/// - Email notifications toggle
/// - Notification types configuration
class NotificationSettingsView extends ConsumerWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notificationSettings = settings.notificationSettings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Notification Settings Card
          _buildCard(
            title: 'General Notifications',
            icon: Icons.notifications_outlined,
            children: [
              SwitchListTile(
                value: notificationSettings.pushNotificationsEnabled,
                onChanged: (value) {
                  _updateNotificationSettings(
                    ref,
                    pushNotificationsEnabled: value,
                  );
                },
                title: Text(
                  'Push Notifications',
                  style: OdooTypography.labelLarge,
                ),
                subtitle: Text(
                  'Receive push notifications on this device',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
                activeColor: OdooColors.primary,
                secondary: Icon(
                  Icons.notifications_active,
                  color: notificationSettings.pushNotificationsEnabled
                      ? OdooColors.primary
                      : OdooColors.gray400,
                ),
              ),
              const Divider(),
              SwitchListTile(
                value: notificationSettings.soundEnabled,
                onChanged: notificationSettings.pushNotificationsEnabled
                    ? (value) {
                        _updateNotificationSettings(
                          ref,
                          soundEnabled: value,
                        );
                      }
                    : null,
                title: Text(
                  'Sound Alerts',
                  style: OdooTypography.labelLarge,
                ),
                subtitle: Text(
                  'Play sound for notifications',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
                activeColor: OdooColors.primary,
                secondary: Icon(
                  Icons.volume_up,
                  color: notificationSettings.soundEnabled &&
                          notificationSettings.pushNotificationsEnabled
                      ? OdooColors.primary
                      : OdooColors.gray400,
                ),
              ),
              const Divider(),
              SwitchListTile(
                value: notificationSettings.emailNotificationsEnabled,
                onChanged: (value) {
                  _updateNotificationSettings(
                    ref,
                    emailNotificationsEnabled: value,
                  );
                },
                title: Text(
                  'Email Notifications',
                  style: OdooTypography.labelLarge,
                ),
                subtitle: Text(
                  'Receive notifications via email',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
                activeColor: OdooColors.primary,
                secondary: Icon(
                  Icons.email_outlined,
                  color: notificationSettings.emailNotificationsEnabled
                      ? OdooColors.primary
                      : OdooColors.gray400,
                ),
              ),
            ],
          ),

          const SizedBox(height: OdooSpacing.lg),

          // Notification Types Card
          _buildCard(
            title: 'Notification Types',
            icon: Icons.category_outlined,
            children: [
              Text(
                'Choose which types of notifications you want to receive',
                style: OdooTypography.bodyMedium.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
              const SizedBox(height: OdooSpacing.lg),
              _buildNotificationTypeItem(
                ref,
                title: 'New Orders',
                subtitle: 'Get notified when new orders are placed',
                icon: Icons.shopping_cart_outlined,
                value: notificationSettings.newOrderNotifications,
                enabled: notificationSettings.pushNotificationsEnabled,
                onChanged: (value) {
                  _updateNotificationSettings(
                    ref,
                    newOrderNotifications: value,
                  );
                },
              ),
              const Divider(),
              _buildNotificationTypeItem(
                ref,
                title: 'Low Stock Alerts',
                subtitle: 'Receive alerts when products are running low',
                icon: Icons.inventory_2_outlined,
                value: notificationSettings.lowStockNotifications,
                enabled: notificationSettings.pushNotificationsEnabled,
                onChanged: (value) {
                  _updateNotificationSettings(
                    ref,
                    lowStockNotifications: value,
                  );
                },
              ),
              const Divider(),
              _buildNotificationTypeItem(
                ref,
                title: 'Daily Reports',
                subtitle: 'Receive daily sales and performance reports',
                icon: Icons.assessment_outlined,
                value: notificationSettings.dailyReportNotifications,
                enabled: notificationSettings.emailNotificationsEnabled,
                onChanged: (value) {
                  _updateNotificationSettings(
                    ref,
                    dailyReportNotifications: value,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: OdooSpacing.lg),

          // Information Card
          _buildInfoBox(
            'Notification permissions may need to be granted in your device settings. Email notifications will be sent to ${settings.contactEmail.isEmpty ? 'the configured email address' : settings.contactEmail}.',
            Icons.info_outline,
            OdooColors.info,
          ),

          const SizedBox(height: OdooSpacing.lg),

          // Test Notification Button
          _buildCard(
            title: 'Test Notifications',
            icon: Icons.bug_report_outlined,
            children: [
              Text(
                'Send a test notification to verify your settings',
                style: OdooTypography.bodyMedium.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
              const SizedBox(height: OdooSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: notificationSettings.pushNotificationsEnabled
                      ? () => _sendTestNotification(context)
                      : null,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Test Notification'),
                  style: FilledButton.styleFrom(
                    backgroundColor: OdooColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: OdooSpacing.md,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        side: BorderSide(
          color: OdooColors.border,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: OdooIconSizes.lg,
                  color: OdooColors.primary,
                ),
                const SizedBox(width: OdooSpacing.md),
                Text(
                  title,
                  style: OdooTypography.cardTitle.copyWith(
                    color: OdooColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: OdooSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: OdooSpacing.lg),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypeItem(
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      title: Text(
        title,
        style: OdooTypography.labelLarge,
      ),
      subtitle: Text(
        subtitle,
        style: OdooTypography.bodySmall.copyWith(
          color: OdooColors.textSecondary,
        ),
      ),
      activeColor: OdooColors.primary,
      secondary: Icon(
        icon,
        color: value && enabled ? OdooColors.primary : OdooColors.gray400,
      ),
    );
  }

  Widget _buildInfoBox(String message, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: OdooIconSizes.lg,
          ),
          const SizedBox(width: OdooSpacing.md),
          Expanded(
            child: Text(
              message,
              style: OdooTypography.bodySmall.copyWith(
                color: OdooColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateNotificationSettings(
    WidgetRef ref, {
    bool? pushNotificationsEnabled,
    bool? soundEnabled,
    bool? emailNotificationsEnabled,
    bool? newOrderNotifications,
    bool? lowStockNotifications,
    bool? dailyReportNotifications,
  }) {
    final currentSettings = ref.read(settingsProvider).notificationSettings;
    final updatedSettings = currentSettings.copyWith(
      pushNotificationsEnabled: pushNotificationsEnabled,
      soundEnabled: soundEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
      newOrderNotifications: newOrderNotifications,
      lowStockNotifications: lowStockNotifications,
      dailyReportNotifications: dailyReportNotifications,
    );
    ref.read(settingsProvider.notifier).updateNotificationSettings(updatedSettings);
  }

  void _sendTestNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: Colors.white,
            ),
            const SizedBox(width: OdooSpacing.md),
            const Expanded(
              child: Text('Test notification sent successfully!'),
            ),
          ],
        ),
        backgroundColor: OdooColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
