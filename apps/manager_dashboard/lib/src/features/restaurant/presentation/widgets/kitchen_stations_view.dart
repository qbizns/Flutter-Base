import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/restaurant_table.dart';
import '../../providers/restaurant_providers.dart';
import 'kitchen_station_form_dialog.dart';

/// Kitchen Stations View - Manage kitchen stations and their configurations
class KitchenStationsView extends ConsumerWidget {
  const KitchenStationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(kitchenStationsProvider);

    return Column(
      children: [
        // Toolbar
        _buildToolbar(context, ref, stations.length),

        // Stations Grid
        Expanded(
          child: stations.isEmpty
              ? _buildEmptyState(context, ref)
              : _buildStationsGrid(context, ref, stations),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref, int count) {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Row(
        children: [
          Text(
            '$count kitchen stations',
            style: OdooTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: OdooSpacing.md),
          Text(
            'Drag to reorder stations',
            style: OdooTypography.bodySmall.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _showAddStationDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Station'),
          ),
        ],
      ),
    );
  }

  Widget _buildStationsGrid(
    BuildContext context,
    WidgetRef ref,
    List<KitchenStation> stations,
  ) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      itemCount: stations.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(kitchenStationsProvider.notifier).reorderStations(
              oldIndex,
              newIndex,
            );
      },
      itemBuilder: (context, index) {
        final station = stations[index];
        return _buildStationCard(context, ref, station, key: ValueKey(station.id));
      },
    );
  }

  Widget _buildStationCard(
    BuildContext context,
    WidgetRef ref,
    KitchenStation station, {
    required Key key,
  }) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: OdooSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: station.color,
              width: 4,
            ),
          ),
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        ),
        child: Padding(
          padding: const EdgeInsets.all(OdooSpacing.lg),
          child: Row(
            children: [
              // Drag Handle
              ReorderableDragStartListener(
                index: station.orderPosition,
                child: Container(
                  padding: const EdgeInsets.all(OdooSpacing.sm),
                  decoration: BoxDecoration(
                    color: OdooColors.gray100,
                    borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                  ),
                  child: Icon(
                    Icons.drag_indicator,
                    color: OdooColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: OdooSpacing.lg),

              // Station Icon
              Container(
                padding: const EdgeInsets.all(OdooSpacing.lg),
                decoration: BoxDecoration(
                  color: station.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                ),
                child: Icon(
                  Icons.kitchen,
                  size: OdooIconSizes.xl,
                  color: station.color,
                ),
              ),
              const SizedBox(width: OdooSpacing.lg),

              // Station Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          station.name,
                          style: OdooTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: OdooSpacing.md),
                        if (!station.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: OdooSpacing.sm,
                              vertical: OdooSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: OdooColors.gray400.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(
                                OdooSpacing.radiusStandard,
                              ),
                            ),
                            child: Text(
                              'INACTIVE',
                              style: OdooTypography.labelSmall.copyWith(
                                color: OdooColors.gray400,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: OdooSpacing.xs),
                    Text(
                      station.description,
                      style: OdooTypography.bodyMedium.copyWith(
                        color: OdooColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: OdooSpacing.md),

                    // Categories chips
                    Wrap(
                      spacing: OdooSpacing.sm,
                      runSpacing: OdooSpacing.sm,
                      children: station.categories.map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OdooSpacing.sm,
                            vertical: OdooSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: station.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              OdooSpacing.radiusStandard,
                            ),
                            border: Border.all(
                              color: station.color.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            category,
                            style: OdooTypography.bodySmall.copyWith(
                              color: station.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  // Active toggle
                  Switch(
                    value: station.isActive,
                    onChanged: (value) {
                      ref
                          .read(kitchenStationsProvider.notifier)
                          .toggleStationActive(station.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${station.name} ${value ? "activated" : "deactivated"}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: OdooSpacing.sm),

                  // Edit button
                  IconButton(
                    onPressed: () => _showEditStationDialog(
                      context,
                      ref,
                      station,
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit',
                    color: OdooColors.primary,
                  ),

                  // Delete button
                  IconButton(
                    onPressed: () => _confirmDeleteStation(
                      context,
                      ref,
                      station,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
                    color: OdooColors.danger,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.kitchen,
            size: 80,
            color: OdooColors.gray400,
          ),
          const SizedBox(height: OdooSpacing.lg),
          Text(
            'No kitchen stations yet',
            style: OdooTypography.titleLarge.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.sm),
          Text(
            'Create your first kitchen station to organize orders',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.xl),
          FilledButton.icon(
            onPressed: () => _showAddStationDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add First Station'),
          ),
        ],
      ),
    );
  }

  // Dialog Actions

  Future<void> _showAddStationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<KitchenStation>(
      context: context,
      builder: (context) => const KitchenStationFormDialog(),
    );

    if (result != null && context.mounted) {
      ref.read(kitchenStationsProvider.notifier).addStation(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.name} added successfully'),
          backgroundColor: OdooColors.success,
        ),
      );
    }
  }

  Future<void> _showEditStationDialog(
    BuildContext context,
    WidgetRef ref,
    KitchenStation station,
  ) async {
    final result = await showDialog<KitchenStation>(
      context: context,
      builder: (context) => KitchenStationFormDialog(station: station),
    );

    if (result != null && context.mounted) {
      ref
          .read(kitchenStationsProvider.notifier)
          .updateStation(station.id, result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.name} updated successfully'),
          backgroundColor: OdooColors.success,
        ),
      );
    }
  }

  Future<void> _confirmDeleteStation(
    BuildContext context,
    WidgetRef ref,
    KitchenStation station,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: OdooColors.danger,
            ),
            const SizedBox(width: OdooSpacing.md),
            const Text('Delete Station'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete ${station.name}?',
              style: OdooTypography.bodyLarge,
            ),
            const SizedBox(height: OdooSpacing.lg),
            Container(
              padding: const EdgeInsets.all(OdooSpacing.md),
              decoration: BoxDecoration(
                color: OdooColors.dangerLight,
                borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                border: Border.all(
                  color: OdooColors.danger,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.kitchen,
                    color: station.color,
                    size: OdooIconSizes.lg,
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: OdooTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: OdooColors.danger,
                          ),
                        ),
                        Text(
                          '${station.categories.length} categories',
                          style: OdooTypography.bodySmall.copyWith(
                            color: OdooColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OdooSpacing.lg),
            Text(
              'This will affect order routing to this station. This action cannot be undone.',
              style: OdooTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: OdooColors.textSecondary,
              ),
            ),
          ],
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(kitchenStationsProvider.notifier).deleteStation(station.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${station.name} deleted'),
          backgroundColor: OdooColors.danger,
        ),
      );
    }
  }
}
