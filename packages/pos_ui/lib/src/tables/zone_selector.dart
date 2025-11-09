import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Chip widget for selecting zones.
class ZoneChip extends StatelessWidget {
  const ZoneChip({
    required this.zone,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final Zone zone;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text('${zone.name} (${zone.tableCount})'),
      selected: selected,
      onSelected: (_) => onTap?.call(),
      avatar: zone.iconName != null
          ? Icon(
              _getIconData(zone.iconName!),
              size: 18,
            )
          : null,
      backgroundColor: zone.color != null ? _parseColor(zone.color!) : null,
      selectedColor:
          zone.color != null ? _parseColor(zone.color!) : theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'outdoor_grill':
        return Icons.outdoor_grill;
      case 'star':
        return Icons.star;
      default:
        return Icons.location_on;
    }
  }
}

/// Horizontal scrollable list of zone chips.
class ZoneSelector extends StatelessWidget {
  const ZoneSelector({
    required this.zones,
    this.selectedZoneId,
    this.onZoneTap,
    this.showAllOption = true,
    super.key,
  });

  final List<Zone> zones;
  final String? selectedZoneId;
  final void Function(Zone?)? onZoneTap;
  final bool showAllOption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (showAllOption) ...[
            FilterChip(
              label: const Text('All Zones'),
              selected: selectedZoneId == null,
              onSelected: (_) => onZoneTap?.call(null),
              avatar: const Icon(Icons.grid_view, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          ...zones.map(
            (zone) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ZoneChip(
                zone: zone,
                selected: zone.id == selectedZoneId,
                onTap: () => onZoneTap?.call(zone),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Table status filter chips.
class TableStatusFilter extends StatelessWidget {
  const TableStatusFilter({
    this.selectedStatus,
    this.onStatusTap,
    super.key,
  });

  final TableStatus? selectedStatus;
  final void Function(TableStatus?)? onStatusTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedStatus == null,
            onSelected: (_) => onStatusTap?.call(null),
          ),
          const SizedBox(width: 8),
          ...TableStatus.values.map(
            (status) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_getStatusText(status)),
                selected: status == selectedStatus,
                onSelected: (_) => onStatusTap?.call(status),
                avatar: Icon(_getStatusIcon(status), size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(TableStatus status) {
    return status.name[0].toUpperCase() + status.name.substring(1);
  }

  IconData _getStatusIcon(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Icons.check_circle_outline;
      case TableStatus.occupied:
        return Icons.event_seat;
      case TableStatus.reserved:
        return Icons.bookmark_outline;
      case TableStatus.cleaning:
        return Icons.cleaning_services_outlined;
      case TableStatus.blocked:
        return Icons.block;
    }
  }
}
