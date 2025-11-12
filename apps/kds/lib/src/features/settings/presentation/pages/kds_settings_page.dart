/// KDS Settings Page
/// Configuration page following Odoo settings patterns
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../../../../data/models/kds_preferences.dart';
import '../../../../data/services/kds_preferences_service.dart';
import '../../../../data/services/sound_notification_service.dart';

/// KDS Settings Page
/// Comprehensive settings following Odoo configuration patterns
class KdsSettingsPage extends ConsumerWidget {
  const KdsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(currentPreferencesProvider);

    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: VodoColors.primary,
        foregroundColor: VodoColors.textOnPrimary,
        title: const Text(
          'KDS Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          // Reset to defaults button
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _showResetDialog(context, ref),
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: ListView(
        padding: VodoDimensions.paddingMd,
        children: [
          // Display Settings
          _buildSectionHeader('Display Settings', Icons.display_settings),
          _buildDisplaySettings(context, ref, preferences),

          const SizedBox(height: VodoDimensions.spacingLg),

          // Timer Settings
          _buildSectionHeader('Timer Settings', Icons.timer),
          _buildTimerSettings(context, ref, preferences),

          const SizedBox(height: VodoDimensions.spacingLg),

          // Sound Settings
          _buildSectionHeader('Sound & Notifications', Icons.volume_up),
          _buildSoundSettings(context, ref, preferences),

          const SizedBox(height: VodoDimensions.spacingLg),

          // Animation Settings
          _buildSectionHeader('Animations', Icons.animation),
          _buildAnimationSettings(context, ref, preferences),

          const SizedBox(height: VodoDimensions.spacingLg),

          // Filter Settings
          _buildSectionHeader('Order Filters', Icons.filter_alt),
          _buildFilterSettings(context, ref, preferences),

          const SizedBox(height: VodoDimensions.spacingLg),

          // Advanced Settings
          _buildSectionHeader('Advanced', Icons.settings),
          _buildAdvancedSettings(context, ref, preferences),

          const SizedBox(height: VodoDimensions.spacingXl),

          // Version info
          _buildVersionInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VodoDimensions.spacingSm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: VodoColors.primary),
          const SizedBox(width: VodoDimensions.spacingSm),
          Text(
            title,
            style: VodoTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: VodoColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings(
    BuildContext context,
    WidgetRef ref,
    KdsPreferences prefs,
  ) {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Column(
        children: [
          // View Mode
          _buildDropdownTile(
            title: 'View Mode',
            subtitle: 'Choose display layout',
            value: prefs.viewMode,
            items: KdsViewMode.values,
            onChanged: (mode) {
              ref.read(currentPreferencesProvider.notifier).setViewMode(mode!);
            },
            itemBuilder: (mode) => mode.displayName,
          ),

          const Divider(height: 1),

          // Grid Columns (only for grid view)
          if (prefs.viewMode == KdsViewMode.grid) ...[
            _buildSliderTile(
              title: 'Grid Columns',
              subtitle: '${prefs.gridColumns} columns',
              value: prefs.gridColumns.toDouble(),
              min: 1,
              max: 6,
              divisions: 5,
              onChanged: (value) {
                final updated = prefs.copyWith(gridColumns: value.toInt());
                ref.read(currentPreferencesProvider.notifier).update(updated);
              },
            ),
            const Divider(height: 1),
          ],

          // Auto Refresh
          _buildSwitchTile(
            title: 'Auto Refresh',
            subtitle: 'Automatically refresh display',
            value: prefs.autoRefresh,
            onChanged: (value) {
              final updated = prefs.copyWith(autoRefresh: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),

          if (prefs.autoRefresh) ...[
            const Divider(height: 1),
            _buildSliderTile(
              title: 'Refresh Interval',
              subtitle: '${prefs.autoRefreshSeconds} seconds',
              value: prefs.autoRefreshSeconds.toDouble(),
              min: 10,
              max: 120,
              divisions: 11,
              onChanged: (value) {
                final updated =
                    prefs.copyWith(autoRefreshSeconds: value.toInt());
                ref.read(currentPreferencesProvider.notifier).update(updated);
              },
            ),
          ],

          const Divider(height: 1),

          // Show Completed Orders
          _buildSwitchTile(
            title: 'Show Completed Orders',
            subtitle: 'Display orders after completion',
            value: prefs.showCompletedOrders,
            onChanged: (value) {
              final updated = prefs.copyWith(showCompletedOrders: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),

          if (prefs.showCompletedOrders) ...[
            const Divider(height: 1),
            _buildSliderTile(
              title: 'Display Duration',
              subtitle: '${prefs.completedOrdersDisplaySeconds} seconds',
              value: prefs.completedOrdersDisplaySeconds.toDouble(),
              min: 60,
              max: 600,
              divisions: 9,
              onChanged: (value) {
                final updated = prefs.copyWith(
                  completedOrdersDisplaySeconds: value.toInt(),
                );
                ref.read(currentPreferencesProvider.notifier).update(updated);
              },
            ),
          ],

          const Divider(height: 1),

          // Group Items by Category
          _buildSwitchTile(
            title: 'Group Items by Category',
            subtitle: 'Organize items by category',
            value: prefs.groupItemsByCategory,
            onChanged: (value) {
              final updated = prefs.copyWith(groupItemsByCategory: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSettings(
    BuildContext context,
    WidgetRef ref,
    KdsPreferences prefs,
  ) {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Column(
        children: [
          // Normal Threshold
          _buildSliderTile(
            title: 'Normal Threshold',
            subtitle: '${prefs.normalThresholdMinutes} minutes (Green → Yellow)',
            value: prefs.normalThresholdMinutes.toDouble(),
            min: 5,
            max: 30,
            divisions: 25,
            onChanged: (value) {
              final newNormal = value.toInt();
              if (newNormal < prefs.warningThresholdMinutes) {
                ref
                    .read(currentPreferencesProvider.notifier)
                    .setTimerThresholds(
                      newNormal,
                      prefs.warningThresholdMinutes,
                    );
              }
            },
          ),

          const Divider(height: 1),

          // Warning Threshold
          _buildSliderTile(
            title: 'Warning Threshold',
            subtitle: '${prefs.warningThresholdMinutes} minutes (Yellow → Red)',
            value: prefs.warningThresholdMinutes.toDouble(),
            min: 10,
            max: 60,
            divisions: 50,
            onChanged: (value) {
              final newWarning = value.toInt();
              if (newWarning > prefs.normalThresholdMinutes) {
                ref
                    .read(currentPreferencesProvider.notifier)
                    .setTimerThresholds(
                      prefs.normalThresholdMinutes,
                      newWarning,
                    );
              }
            },
          ),

          const Divider(height: 1),

          // Show Timer Icon
          _buildSwitchTile(
            title: 'Show Timer Icon',
            subtitle: 'Display timer icon on orders',
            value: prefs.showTimerIcon,
            onChanged: (value) {
              final updated = prefs.copyWith(showTimerIcon: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),

          const Divider(height: 1),

          // Show Warning Indicator
          _buildSwitchTile(
            title: 'Show Warning Indicator',
            subtitle: 'Display warning icon for delayed orders',
            value: prefs.showWarningIndicator,
            onChanged: (value) {
              final updated = prefs.copyWith(showWarningIndicator: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSettings(
    BuildContext context,
    WidgetRef ref,
    KdsPreferences prefs,
  ) {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Column(
        children: [
          // Sound Enabled
          _buildSwitchTile(
            title: 'Enable Sound',
            subtitle: 'Play notification sounds',
            value: prefs.soundEnabled,
            onChanged: (value) {
              ref.read(currentPreferencesProvider.notifier).setSoundEnabled(value);
              // Also update sound service
              ref.read(soundNotificationServiceProvider).setEnabled(value);
            },
          ),

          if (prefs.soundEnabled) ...[
            const Divider(height: 1),

            // Volume
            _buildSliderTile(
              title: 'Volume',
              subtitle: '${(prefs.soundVolume * 100).toInt()}%',
              value: prefs.soundVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (value) {
                ref.read(currentPreferencesProvider.notifier).setSoundVolume(value);
                // Also update sound service
                ref.read(soundNotificationServiceProvider).setVolume(value);
              },
            ),

            const Divider(height: 1),

            // Test Sound Button
            Padding(
              padding: VodoDimensions.paddingMd,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(soundNotificationServiceProvider)
                        .playNewOrderSound(priority: OrderPriority.normal);
                  },
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Test Sound'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VodoColors.primary,
                    foregroundColor: VodoColors.textOnPrimary,
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // Priority Sounds
            _buildSwitchTile(
              title: 'Normal Priority Sounds',
              subtitle: 'Play sound for normal orders',
              value: prefs.normalPrioritySound,
              onChanged: (value) {
                final updated = prefs.copyWith(normalPrioritySound: value);
                ref.read(currentPreferencesProvider.notifier).update(updated);
              },
            ),

            const Divider(height: 1),

            _buildSwitchTile(
              title: 'High Priority Sounds',
              subtitle: 'Play sound for high priority orders',
              value: prefs.highPrioritySound,
              onChanged: (value) {
                final updated = prefs.copyWith(highPrioritySound: value);
                ref.read(currentPreferencesProvider.notifier).update(updated);
              },
            ),

            const Divider(height: 1),

            _buildSwitchTile(
              title: 'Urgent Priority Sounds',
              subtitle: 'Play sound for urgent orders',
              value: prefs.urgentPrioritySound,
              onChanged: (value) {
                final updated = prefs.copyWith(urgentPrioritySound: value);
                ref.read(currentPreferencesProvider.notifier).update(updated);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimationSettings(
    BuildContext context,
    WidgetRef ref,
    KdsPreferences prefs,
  ) {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Column(
        children: [
          // Animations Enabled
          _buildSwitchTile(
            title: 'Enable Animations',
            subtitle: 'Show animated transitions',
            value: prefs.animationsEnabled,
            onChanged: (value) {
              ref
                  .read(currentPreferencesProvider.notifier)
                  .setAnimationsEnabled(value);
            },
          ),

          if (prefs.animationsEnabled) ...[
            const Divider(height: 1),

            _buildSwitchTile(
              title: 'Entrance Animations',
              subtitle: 'Animate new orders sliding in',
              value: prefs.entranceAnimations,
              onChanged: (value) {
                final updated = prefs.copyWith(entranceAnimations: value);
                ref.read(currentPreferencesProvider.notifier).update(updated);
              },
            ),

            const Divider(height: 1),

            _buildSwitchTile(
              title: 'Status Change Animations',
              subtitle: 'Highlight orders when status changes',
              value: prefs.statusChangeAnimations,
              onChanged: (value) {
                final updated = prefs.copyWith(statusChangeAnimations: value);
                ref.read(currentPreferencesProvider.notifier).update(updated);
              },
            ),

            const Divider(height: 1),

            _buildSwitchTile(
              title: 'New Order Alerts',
              subtitle: 'Pulsing glow for new orders',
              value: prefs.newOrderAlerts,
              onChanged: (value) {
                final updated = prefs.copyWith(newOrderAlerts: value);
                ref.read(currentPreferencesProvider.notifier).update(updated);
              },
            ),

            const Divider(height: 1),

            _buildSwitchTile(
              title: 'Bump Animations',
              subtitle: 'Animate order completion',
              value: prefs.bumpAnimations,
              onChanged: (value) {
                final updated = prefs.copyWith(bumpAnimations: value);
                ref.read(currentPreferencesProvider.notifier).update(updated);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSettings(
    BuildContext context,
    WidgetRef ref,
    KdsPreferences prefs,
  ) {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Show New Orders',
            subtitle: 'Display orders in New status',
            value: prefs.showNewOrders,
            onChanged: (value) {
              final updated = prefs.copyWith(showNewOrders: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),

          const Divider(height: 1),

          _buildSwitchTile(
            title: 'Show Preparing Orders',
            subtitle: 'Display orders in Preparing status',
            value: prefs.showPreparingOrders,
            onChanged: (value) {
              final updated = prefs.copyWith(showPreparingOrders: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),

          const Divider(height: 1),

          _buildSwitchTile(
            title: 'Show Ready Orders',
            subtitle: 'Display orders in Ready status',
            value: prefs.showReadyOrders,
            onChanged: (value) {
              final updated = prefs.copyWith(showReadyOrders: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),

          const Divider(height: 1),

          _buildSwitchTile(
            title: 'Show Done Orders',
            subtitle: 'Display completed orders',
            value: prefs.showDoneOrders,
            onChanged: (value) {
              final updated = prefs.copyWith(showDoneOrders: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings(
    BuildContext context,
    WidgetRef ref,
    KdsPreferences prefs,
  ) {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Column(
        children: [
          // Max Visible Orders
          _buildSliderTile(
            title: 'Max Visible Orders',
            subtitle: '${prefs.maxVisibleOrders} orders',
            value: prefs.maxVisibleOrders.toDouble(),
            min: 10,
            max: 200,
            divisions: 19,
            onChanged: (value) {
              final updated = prefs.copyWith(maxVisibleOrders: value.toInt());
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),

          const Divider(height: 1),

          // Real-Time Updates
          _buildSwitchTile(
            title: 'Real-Time Updates',
            subtitle: 'Enable WebSocket connection',
            value: prefs.enableRealTimeUpdates,
            onChanged: (value) {
              final updated = prefs.copyWith(enableRealTimeUpdates: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),

          const Divider(height: 1),

          // Haptic Feedback
          _buildSwitchTile(
            title: 'Haptic Feedback',
            subtitle: 'Vibrate on interactions',
            value: prefs.hapticFeedback,
            onChanged: (value) {
              final updated = prefs.copyWith(hapticFeedback: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),

          const Divider(height: 1),

          // Text Scale
          _buildSliderTile(
            title: 'Text Scale',
            subtitle: '${(prefs.textScale * 100).toInt()}%',
            value: prefs.textScale,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            onChanged: (value) {
              final updated = prefs.copyWith(textScale: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),

          const Divider(height: 1),

          // Debug Mode
          _buildSwitchTile(
            title: 'Debug Mode',
            subtitle: 'Show debug information',
            value: prefs.enableDebugMode,
            onChanged: (value) {
              final updated = prefs.copyWith(enableDebugMode: value);
              ref.read(currentPreferencesProvider.notifier).update(updated);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: VodoTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: VodoTextStyles.bodySmall.copyWith(
          color: VodoColors.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: VodoColors.primary,
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: VodoTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: VodoTextStyles.bodySmall.copyWith(
              color: VodoColors.textSecondary,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: VodoColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile<T>({
    required String title,
    required String subtitle,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemBuilder,
  }) {
    return ListTile(
      title: Text(
        title,
        style: VodoTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: VodoTextStyles.bodySmall.copyWith(
              color: VodoColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: VodoDimensions.borderRadiusSm,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemBuilder(item)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Padding(
        padding: VodoDimensions.paddingMd,
        child: Column(
          children: [
            const Icon(
              Icons.info_outline,
              size: 32,
              color: VodoColors.primary,
            ),
            const SizedBox(height: VodoDimensions.spacingSm),
            Text(
              'Kitchen Display System',
              style: VodoTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: VodoTextStyles.bodySmall.copyWith(
                color: VodoColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Following Odoo KDS Patterns 100%',
              style: VodoTextStyles.caption.copyWith(
                color: VodoColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(currentPreferencesProvider.notifier).reset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: VodoColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VodoColors.danger,
              foregroundColor: VodoColors.textOnPrimary,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// Add OrderPriority enum for sound service
enum OrderPriority {
  normal,
  high,
  urgent;
}
