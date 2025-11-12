/// Station Selector Widget
/// Horizontal station switcher following Odoo KDS patterns
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

import '../../../../data/models/kitchen_station.dart';

/// Station selector
/// Horizontal scrollable list of station chips
class StationSelector extends StatelessWidget {
  final List<KitchenStation> stations;
  final KitchenStation selectedStation;
  final ValueChanged<KitchenStation> onStationSelected;

  const StationSelector({
    super.key,
    required this.stations,
    required this.selectedStation,
    required this.onStationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stations.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: VodoDimensions.spacingSm),
        itemBuilder: (context, index) {
          final station = stations[index];
          final isSelected = station.id == selectedStation.id;

          return _StationChip(
            station: station,
            isSelected: isSelected,
            onTap: () => onStationSelected(station),
          );
        },
      ),
    );
  }
}

/// Station chip
class _StationChip extends StatelessWidget {
  final KitchenStation station;
  final bool isSelected;
  final VoidCallback onTap;

  const _StationChip({
    required this.station,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: VodoDimensions.borderRadiusSm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: VodoDimensions.spacingMd,
          vertical: VodoDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? VodoColors.textOnPrimary
              : VodoColors.textOnPrimary.withOpacity(0.2),
          borderRadius: VodoDimensions.borderRadiusSm,
          border: Border.all(
            color: isSelected
                ? VodoColors.textOnPrimary
                : VodoColors.textOnPrimary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              station.stationIcon,
              size: 20,
              color: isSelected
                  ? station.color
                  : VodoColors.textOnPrimary,
            ),
            const SizedBox(width: VodoDimensions.spacingXs),
            Text(
              station.name,
              style: VodoTextStyles.bodyMedium.copyWith(
                color: isSelected
                    ? station.color
                    : VodoColors.textOnPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
