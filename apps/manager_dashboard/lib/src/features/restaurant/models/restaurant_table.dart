import 'package:flutter/material.dart';

/// Table status in the restaurant
enum TableStatus {
  available,
  occupied,
  reserved,
  cleaning,
}

/// Table shape for floor plan visualization
enum TableShape {
  square,
  rectangle,
  circle,
  roundedRectangle,
}

/// Restaurant Table Model
class RestaurantTable {
  final String id;
  final String name;
  final int capacity;
  final TableStatus status;
  final TableShape shape;

  // Floor plan position (in percentage of container size)
  final double positionX;
  final double positionY;

  // Size (in pixels)
  final double width;
  final double height;

  // Optional fields
  final String? section; // e.g., "Main Hall", "Patio", "VIP"
  final String? currentOrderId;
  final DateTime? reservationTime;
  final String? reservationName;
  final String? notes;

  const RestaurantTable({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
    this.shape = TableShape.square,
    this.positionX = 0,
    this.positionY = 0,
    this.width = 100,
    this.height = 100,
    this.section,
    this.currentOrderId,
    this.reservationTime,
    this.reservationName,
    this.notes,
  });

  RestaurantTable copyWith({
    String? id,
    String? name,
    int? capacity,
    TableStatus? status,
    TableShape? shape,
    double? positionX,
    double? positionY,
    double? width,
    double? height,
    String? section,
    String? currentOrderId,
    DateTime? reservationTime,
    String? reservationName,
    String? notes,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      shape: shape ?? this.shape,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      width: width ?? this.width,
      height: height ?? this.height,
      section: section ?? this.section,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      reservationTime: reservationTime ?? this.reservationTime,
      reservationName: reservationName ?? this.reservationName,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'status': status.name,
      'shape': shape.name,
      'position_x': positionX,
      'position_y': positionY,
      'width': width,
      'height': height,
      'section': section,
      'current_order_id': currentOrderId,
      'reservation_time': reservationTime?.toIso8601String(),
      'reservation_name': reservationName,
      'notes': notes,
    };
  }

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as String,
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      status: TableStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TableStatus.available,
      ),
      shape: TableShape.values.firstWhere(
        (e) => e.name == json['shape'],
        orElse: () => TableShape.square,
      ),
      positionX: (json['position_x'] as num?)?.toDouble() ?? 0,
      positionY: (json['position_y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 100,
      height: (json['height'] as num?)?.toDouble() ?? 100,
      section: json['section'] as String?,
      currentOrderId: json['current_order_id'] as String?,
      reservationTime: json['reservation_time'] != null
          ? DateTime.parse(json['reservation_time'] as String)
          : null,
      reservationName: json['reservation_name'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// Kitchen Station Model
class KitchenStation {
  final String id;
  final String name;
  final String description;
  final Color color;
  final List<String> categories; // Product categories this station handles
  final bool isActive;
  final int orderPosition;

  const KitchenStation({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.categories,
    this.isActive = true,
    this.orderPosition = 0,
  });

  KitchenStation copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
    List<String>? categories,
    bool? isActive,
    int? orderPosition,
  }) {
    return KitchenStation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      categories: categories ?? this.categories,
      isActive: isActive ?? this.isActive,
      orderPosition: orderPosition ?? this.orderPosition,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'categories': categories,
      'is_active': isActive,
      'order_position': orderPosition,
    };
  }

  factory KitchenStation.fromJson(Map<String, dynamic> json) {
    return KitchenStation(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      color: Color(json['color'] as int),
      categories: List<String>.from(json['categories'] as List),
      isActive: json['is_active'] as bool? ?? true,
      orderPosition: json['order_position'] as int? ?? 0,
    );
  }
}
