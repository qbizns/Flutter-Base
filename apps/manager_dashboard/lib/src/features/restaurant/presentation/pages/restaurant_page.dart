import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../widgets/floor_plan_view.dart';
import '../widgets/tables_list_view.dart';
import '../widgets/kitchen_stations_view.dart';

/// Restaurant Page - Comprehensive restaurant management
///
/// Features:
/// - Floor plan designer with drag-drop tables
/// - Table management (add, edit, delete)
/// - Table status overview
/// - Kitchen stations configuration
/// - Reservations calendar
class RestaurantPage extends ConsumerStatefulWidget {
  const RestaurantPage({super.key});

  @override
  ConsumerState<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends ConsumerState<RestaurantPage>
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
                  icon: Icon(Icons.grid_on),
                  text: 'Floor Plan',
                ),
                Tab(
                  icon: Icon(Icons.table_restaurant),
                  text: 'Tables',
                ),
                Tab(
                  icon: Icon(Icons.kitchen),
                  text: 'Kitchen Stations',
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                FloorPlanView(),
                TablesListView(),
                KitchenStationsView(),
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
            Icons.restaurant,
            size: OdooIconSizes.xl,
            color: OdooColors.primary,
          ),
          const SizedBox(width: OdooSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Restaurant Management',
                style: OdooTypography.pageTitle.copyWith(
                  color: OdooColors.textPrimary,
                ),
              ),
              Text(
                'Manage floor plan, tables, and kitchen stations',
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Quick Stats
          _buildQuickStat(
            icon: Icons.table_restaurant,
            label: 'Tables',
            value: '15',
            color: OdooColors.primary,
          ),
          const SizedBox(width: OdooSpacing.xl),
          _buildQuickStat(
            icon: Icons.event_seat,
            label: 'Available',
            value: '8',
            color: OdooColors.success,
          ),
          const SizedBox(width: OdooSpacing.xl),
          _buildQuickStat(
            icon: Icons.kitchen,
            label: 'Stations',
            value: '4',
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
