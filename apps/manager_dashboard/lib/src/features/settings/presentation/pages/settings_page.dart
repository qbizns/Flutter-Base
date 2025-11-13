import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../providers/settings_providers.dart';
import '../widgets/general_settings_view.dart';
import '../widgets/api_settings_view.dart';
import '../widgets/appearance_settings_view.dart';
import '../widgets/business_settings_view.dart';
import '../widgets/tax_settings_view.dart';
import '../widgets/receipt_settings_view.dart';
import '../widgets/notification_settings_view.dart';

/// Settings Page - Comprehensive settings management
///
/// Features:
/// - Tab-based navigation for different settings sections
/// - General, API, Appearance, Business, Tax, Receipt, Notifications
/// - Save/Reset buttons with confirmation
/// - Follows Odoo design guidelines
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OdooColors.backgroundLight,
      child: Column(
        children: [
          // Header with title and actions
          _buildHeader(),

          // Tab Bar
          _buildTabBar(),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                GeneralSettingsView(),
                ApiSettingsView(),
                AppearanceSettingsView(),
                BusinessSettingsView(),
                TaxSettingsView(),
                ReceiptSettingsView(),
                NotificationSettingsView(),
              ],
            ),
          ),

          // Bottom action bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.xl,
        vertical: OdooSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.settings_outlined,
            size: OdooIconSizes.xl,
            color: OdooColors.primary,
          ),
          const SizedBox(width: OdooSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: OdooTypography.pageTitle.copyWith(
                  color: OdooColors.textPrimary,
                ),
              ),
              Text(
                'Configure your restaurant settings',
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: OdooColors.primary,
        labelColor: OdooColors.primary,
        unselectedLabelColor: OdooColors.textSecondary,
        labelStyle: OdooTypography.labelLarge,
        unselectedLabelStyle: OdooTypography.labelLarge,
        tabs: const [
          Tab(
            icon: Icon(Icons.info_outline),
            text: 'General',
          ),
          Tab(
            icon: Icon(Icons.api),
            text: 'API',
          ),
          Tab(
            icon: Icon(Icons.palette_outlined),
            text: 'Appearance',
          ),
          Tab(
            icon: Icon(Icons.business_outlined),
            text: 'Business',
          ),
          Tab(
            icon: Icon(Icons.receipt_long_outlined),
            text: 'Tax',
          ),
          Tab(
            icon: Icon(Icons.print_outlined),
            text: 'Receipt',
          ),
          Tab(
            icon: Icon(Icons.notifications_outlined),
            text: 'Notifications',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Reset button
          OutlinedButton.icon(
            onPressed: _isSaving ? null : _handleReset,
            icon: const Icon(Icons.restore),
            label: const Text('Reset to Defaults'),
            style: OutlinedButton.styleFrom(
              foregroundColor: OdooColors.danger,
              padding: const EdgeInsets.symmetric(
                horizontal: OdooSpacing.xl,
                vertical: OdooSpacing.md,
              ),
            ),
          ),
          const SizedBox(width: OdooSpacing.md),

          // Save button
          FilledButton.icon(
            onPressed: _isSaving ? null : _handleSave,
            icon: _isSaving
                ? SizedBox(
                    width: OdooIconSizes.sm,
                    height: OdooIconSizes.sm,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
            style: FilledButton.styleFrom(
              backgroundColor: OdooColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: OdooSpacing.xl,
                vertical: OdooSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      final success = await settingsNotifier.saveSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: OdooSpacing.md),
                Text(
                  success
                      ? 'Settings saved successfully'
                      : 'Failed to save settings',
                ),
              ],
            ),
            backgroundColor: success ? OdooColors.success : OdooColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: OdooSpacing.md),
                Expanded(
                  child: Text('Error: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: OdooColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: OdooColors.warning,
            ),
            const SizedBox(width: OdooSpacing.md),
            const Text('Reset Settings'),
          ],
        ),
        content: Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
          style: OdooTypography.bodyLarge,
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: OdooColors.danger,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(settingsProvider.notifier).resetToDefaults();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                const SizedBox(width: OdooSpacing.md),
                const Text('Settings reset to defaults'),
              ],
            ),
            backgroundColor: OdooColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
          ),
        );
      }
    }
  }
}
