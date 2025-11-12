/// Kitchen Station Model
/// Station/prep area configuration for KDS
/// Following Odoo KDS station patterns 100%
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'kitchen_station.freezed.dart';
part 'kitchen_station.g.dart';

/// Kitchen station types
enum StationType {
  @JsonValue('all')
  all,

  @JsonValue('hot')
  hot,

  @JsonValue('cold')
  cold,

  @JsonValue('grill')
  grill,

  @JsonValue('fryer')
  fryer,

  @JsonValue('prep')
  prep,

  @JsonValue('dessert')
  dessert,

  @JsonValue('bar')
  bar,

  @JsonValue('expo')
  expo,
}

/// Kitchen station
@freezed
class KitchenStation with _$KitchenStation {
  const KitchenStation._();

  const factory KitchenStation({
    required String id,
    required String name,
    required StationType type,
    @Default([]) List<String> categoryIds,
    @Default(true) bool isActive,
    @Default(0) int displayOrder,
    String? description,
    String? colorCode,
    IconData? icon,
  }) = _KitchenStation;

  factory KitchenStation.fromJson(Map<String, dynamic> json) =>
      _$KitchenStationFromJson(json);

  /// Get station color
  Color get color {
    if (colorCode != null) {
      return Color(int.parse(colorCode!.replaceFirst('#', '0xFF')));
    }
    return _getDefaultColor();
  }

  Color _getDefaultColor() {
    switch (type) {
      case StationType.all:
        return const Color(0xFF714B67); // Vodo primary
      case StationType.hot:
        return const Color(0xFFE74C3C); // Red
      case StationType.cold:
        return const Color(0xFF3498DB); // Blue
      case StationType.grill:
        return const Color(0xFFE67E22); // Orange
      case StationType.fryer:
        return const Color(0xFFF39C12); // Yellow-orange
      case StationType.prep:
        return const Color(0xFF16A085); // Teal
      case StationType.dessert:
        return const Color(0xFFE91E63); // Pink
      case StationType.bar:
        return const Color(0xFF9B59B6); // Purple
      case StationType.expo:
        return const Color(0xFF34495E); // Dark gray
    }
  }

  /// Get station icon
  IconData get stationIcon {
    if (icon != null) return icon!;

    switch (type) {
      case StationType.all:
        return Icons.restaurant;
      case StationType.hot:
        return Icons.local_fire_department;
      case StationType.cold:
        return Icons.ac_unit;
      case StationType.grill:
        return Icons.outdoor_grill;
      case StationType.fryer:
        return Icons.set_meal;
      case StationType.prep:
        return Icons.cut;
      case StationType.dessert:
        return Icons.cake;
      case StationType.bar:
        return Icons.local_bar;
      case StationType.expo:
        return Icons.done_all;
    }
  }
}

/// Predefined stations following Odoo KDS
class DefaultKitchenStations {
  static final List<KitchenStation> stations = [
    const KitchenStation(
      id: 'all',
      name: 'All Orders',
      type: StationType.all,
      displayOrder: 0,
      description: 'View all orders across all stations',
    ),
    const KitchenStation(
      id: 'grill',
      name: 'Grill Station',
      type: StationType.grill,
      categoryIds: ['burgers', 'steaks', 'chicken'],
      displayOrder: 1,
      description: 'Grilled items',
      colorCode: '#E67E22',
    ),
    const KitchenStation(
      id: 'fryer',
      name: 'Fryer Station',
      type: StationType.fryer,
      categoryIds: ['fries', 'fried_chicken', 'nuggets'],
      displayOrder: 2,
      description: 'Fried items',
      colorCode: '#F39C12',
    ),
    const KitchenStation(
      id: 'cold',
      name: 'Cold Prep',
      type: StationType.cold,
      categoryIds: ['salads', 'sandwiches', 'wraps'],
      displayOrder: 3,
      description: 'Cold preparation items',
      colorCode: '#3498DB',
    ),
    const KitchenStation(
      id: 'hot',
      name: 'Hot Prep',
      type: StationType.hot,
      categoryIds: ['pasta', 'soups', 'entrees'],
      displayOrder: 4,
      description: 'Hot preparation items',
      colorCode: '#E74C3C',
    ),
    const KitchenStation(
      id: 'dessert',
      name: 'Dessert Station',
      type: StationType.dessert,
      categoryIds: ['desserts', 'sweets', 'pastries'],
      displayOrder: 5,
      description: 'Desserts and sweets',
      colorCode: '#E91E63',
    ),
    const KitchenStation(
      id: 'bar',
      name: 'Bar',
      type: StationType.bar,
      categoryIds: ['drinks', 'cocktails', 'beverages'],
      displayOrder: 6,
      description: 'Bar and beverages',
      colorCode: '#9B59B6',
    ),
    const KitchenStation(
      id: 'expo',
      name: 'Expo',
      type: StationType.expo,
      displayOrder: 7,
      description: 'Order expediting and quality check',
      colorCode: '#34495E',
    ),
  ];

  static KitchenStation get defaultStation => stations.first;

  static KitchenStation? getStationById(String id) {
    try {
      return stations.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<KitchenStation> getActiveStations() {
    return stations.where((s) => s.isActive).toList();
  }
}

/// Station type extensions
extension StationTypeExtension on StationType {
  String get displayName {
    switch (this) {
      case StationType.all:
        return 'All';
      case StationType.hot:
        return 'Hot';
      case StationType.cold:
        return 'Cold';
      case StationType.grill:
        return 'Grill';
      case StationType.fryer:
        return 'Fryer';
      case StationType.prep:
        return 'Prep';
      case StationType.dessert:
        return 'Dessert';
      case StationType.bar:
        return 'Bar';
      case StationType.expo:
        return 'Expo';
    }
  }
}
