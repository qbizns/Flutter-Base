import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../widgets/team_members_view.dart';
import '../widgets/roles_permissions_view.dart';
import '../widgets/shift_schedule_view.dart';
import '../widgets/activity_logs_view.dart';

/// Staff Management Page - Comprehensive employee management
///
/// Features:
/// - Team members management (CRUD)
/// - Roles and permissions matrix
/// - Shift scheduling and assignments
/// - Activity logs and audit trail
class StaffPage extends ConsumerStatefulWidget {
  const StaffPage({super.key});

  @override
  ConsumerState<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends ConsumerState<StaffPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          // Toolbar
          _buildToolbar(),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: OdooColors.primary,
              unselectedLabelColor: OdooColors.textSecondary,
              indicatorColor: OdooColors.primary,
              indicatorWeight: 3,
              labelStyle: OdooTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.people),
                  text: 'Team Members',
                ),
                Tab(
                  icon: Icon(Icons.admin_panel_settings),
                  text: 'Roles & Permissions',
                ),
                Tab(
                  icon: Icon(Icons.calendar_month),
                  text: 'Shift Schedule',
                ),
                Tab(
                  icon: Icon(Icons.history),
                  text: 'Activity Logs',
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                TeamMembersView(),
                RolesPermissionsView(),
                ShiftScheduleView(),
                ActivityLogsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
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
            Icons.people,
            size: OdooIconSizes.xl,
            color: OdooColors.primary,
          ),
          const SizedBox(width: OdooSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Management',
                style: OdooTypography.pageTitle.copyWith(
                  color: OdooColors.textPrimary,
                ),
              ),
              Text(
                'Manage team members, roles, and schedules',
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Quick Stats
          _buildQuickStat(
            icon: Icons.people,
            label: 'Team',
            value: '24',
            color: OdooColors.primary,
          ),
          const SizedBox(width: OdooSpacing.xl),
          _buildQuickStat(
            icon: Icons.check_circle,
            label: 'Active',
            value: '20',
            color: OdooColors.success,
          ),
          const SizedBox(width: OdooSpacing.xl),
          _buildQuickStat(
            icon: Icons.event_available,
            label: 'On Duty',
            value: '12',
            color: OdooColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.lg,
        vertical: OdooSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: OdooIconSizes.md,
            color: color,
          ),
          const SizedBox(width: OdooSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: OdooTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
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
}
