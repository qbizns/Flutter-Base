import 'package:equatable/equatable.dart';

/// Zone/Section entity representing an area in the restaurant.
///
/// Zones are used to organize tables into sections like
/// "Main Floor", "Patio", "VIP Section", etc.
class Zone extends Equatable {
  const Zone({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.iconName,
    this.isActive = true,
    this.sortOrder = 0,
    this.tableCount = 0,
  });

  /// Unique identifier
  final String id;

  /// Zone name (e.g., "Main Floor", "Patio")
  final String name;

  /// Description
  final String? description;

  /// Color hex code for visualization
  final String? color;

  /// Icon name for display
  final String? iconName;

  /// Whether zone is active
  final bool isActive;

  /// Sort order for display
  final int sortOrder;

  /// Number of tables in this zone
  final int tableCount;

  /// Copy with method
  Zone copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? iconName,
    bool? isActive,
    int? sortOrder,
    int? tableCount,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      tableCount: tableCount ?? this.tableCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        color,
        iconName,
        isActive,
        sortOrder,
        tableCount,
      ];
}
