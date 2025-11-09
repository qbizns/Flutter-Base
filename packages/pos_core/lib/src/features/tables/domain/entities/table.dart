import 'package:equatable/equatable.dart';

/// Table entity representing a physical table in the restaurant.
class Table extends Equatable {
  const Table({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
    this.number,
    this.zoneId,
    this.zoneName,
    this.shape = TableShape.rectangle,
    this.position,
    this.currentOrderId,
    this.assignedTo,
    this.isActive = true,
    this.sortOrder = 0,
  });

  /// Unique identifier
  final String id;

  /// Table name (e.g., "Table 1", "VIP 3")
  final String name;

  /// Table number (optional, may differ from name)
  final int? number;

  /// Maximum number of guests
  final int capacity;

  /// Current status
  final TableStatus status;

  /// Zone/section ID
  final String? zoneId;

  /// Zone/section name
  final String? zoneName;

  /// Table shape for visualization
  final TableShape shape;

  /// Position on floor map (x, y coordinates)
  final TablePosition? position;

  /// Current active order ID
  final String? currentOrderId;

  /// Staff member assigned to this table
  final String? assignedTo;

  /// Whether table is active/available for use
  final bool isActive;

  /// Sort order for display
  final int sortOrder;

  /// Check if table is available
  bool get isAvailable => status == TableStatus.available;

  /// Check if table is occupied
  bool get isOccupied => status == TableStatus.occupied;

  /// Check if table has an active order
  bool get hasActiveOrder => currentOrderId != null;

  /// Copy with method
  Table copyWith({
    String? id,
    String? name,
    int? number,
    int? capacity,
    TableStatus? status,
    String? zoneId,
    String? zoneName,
    TableShape? shape,
    TablePosition? position,
    String? currentOrderId,
    String? assignedTo,
    bool? isActive,
    int? sortOrder,
  }) {
    return Table(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      shape: shape ?? this.shape,
      position: position ?? this.position,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      assignedTo: assignedTo ?? this.assignedTo,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        number,
        capacity,
        status,
        zoneId,
        zoneName,
        shape,
        position,
        currentOrderId,
        assignedTo,
        isActive,
        sortOrder,
      ];
}

/// Table status enumeration
enum TableStatus {
  /// Table is available for seating
  available,

  /// Table is occupied with guests
  occupied,

  /// Table is reserved for future seating
  reserved,

  /// Table is being cleaned
  cleaning,

  /// Table is blocked/unavailable
  blocked,
}

/// Table shape for floor map visualization
enum TableShape {
  rectangle,
  square,
  circle,
  oval,
}

/// Table position on floor map
class TablePosition extends Equatable {
  const TablePosition({
    required this.x,
    required this.y,
    this.width = 100,
    this.height = 100,
    this.rotation = 0,
  });

  /// X coordinate
  final double x;

  /// Y coordinate
  final double y;

  /// Width (for rectangle/square)
  final double width;

  /// Height (for rectangle/square)
  final double height;

  /// Rotation in degrees
  final double rotation;

  TablePosition copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
  }) {
    return TablePosition(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  List<Object?> get props => [x, y, width, height, rotation];
}
