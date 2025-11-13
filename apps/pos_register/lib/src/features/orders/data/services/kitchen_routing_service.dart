/// Kitchen Routing Service
/// Routes order items to appropriate kitchen stations (Odoo pattern)
library;

import 'package:pos_core/pos_core.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

/// Kitchen station types
enum KitchenStation {
  /// Hot food preparation (grill, fryer, etc.)
  hot,

  /// Cold food preparation (salads, sandwiches)
  cold,

  /// Beverage station (coffee, drinks)
  beverage,

  /// Dessert station
  dessert,

  /// Bar (alcoholic beverages)
  bar,
}

/// Kitchen ticket for a group of items
class KitchenTicket {
  final String id;
  final String orderId;
  final String orderNumber;
  final KitchenStation station;
  final List<OrderItem> items;
  final OrderType orderType;
  final String? tableName;
  final String? notes;
  final DateTime createdAt;
  final TicketStatus status;
  final int? priorityLevel;

  KitchenTicket({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.station,
    required this.items,
    required this.orderType,
    this.tableName,
    this.notes,
    required this.createdAt,
    this.status = TicketStatus.pending,
    this.priorityLevel,
  });

  KitchenTicket copyWith({
    TicketStatus? status,
    int? priorityLevel,
  }) {
    return KitchenTicket(
      id: id,
      orderId: orderId,
      orderNumber: orderNumber,
      station: station,
      items: items,
      orderType: orderType,
      tableName: tableName,
      notes: notes,
      createdAt: createdAt,
      status: status ?? this.status,
      priorityLevel: priorityLevel ?? this.priorityLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'order_number': orderNumber,
      'station': station.name,
      'items': items.map((item) => {
            'id': item.id,
            'product_name': item.productName,
            'quantity': item.quantity,
            'notes': item.notes,
            'modifiers': item.selectedModifiers
                .map((m) => {
                      'name': m.modifierName,
                      'quantity': m.quantity,
                    })
                .toList(),
          }).toList(),
      'order_type': orderType.name,
      'table_name': tableName,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'priority_level': priorityLevel,
    };
  }
}

/// Ticket status for kitchen display
enum TicketStatus {
  /// Ticket received, not started
  pending,

  /// Kitchen is preparing
  preparing,

  /// Item ready for pickup/serving
  ready,

  /// Completed/served
  completed,

  /// Cancelled
  cancelled,
}

/// Kitchen routing service following Odoo POS pattern
///
/// Routes order items to appropriate kitchen stations based on:
/// - Product category
/// - Product type
/// - Custom routing rules
class KitchenRoutingService {
  final WebSocketChannel? _wsChannel;
  final Map<String, KitchenStation> _categoryRouting;

  KitchenRoutingService({
    WebSocketChannel? wsChannel,
    Map<String, KitchenStation>? categoryRouting,
  })  : _wsChannel = wsChannel,
        _categoryRouting = categoryRouting ?? _defaultCategoryRouting;

  /// Default category to station routing
  static final Map<String, KitchenStation> _defaultCategoryRouting = {
    // Beverages
    'beverages': KitchenStation.beverage,
    'coffee': KitchenStation.beverage,
    'tea': KitchenStation.beverage,
    'juices': KitchenStation.beverage,
    'smoothies': KitchenStation.beverage,
    'soft_drinks': KitchenStation.beverage,

    // Hot food
    'hot_meals': KitchenStation.hot,
    'grilled': KitchenStation.hot,
    'fried': KitchenStation.hot,
    'burgers': KitchenStation.hot,
    'pizza': KitchenStation.hot,
    'pasta': KitchenStation.hot,
    'hot_entrees': KitchenStation.hot,

    // Cold food
    'salads': KitchenStation.cold,
    'sandwiches': KitchenStation.cold,
    'wraps': KitchenStation.cold,
    'cold_appetizers': KitchenStation.cold,

    // Desserts
    'desserts': KitchenStation.dessert,
    'cakes': KitchenStation.dessert,
    'ice_cream': KitchenStation.dessert,
    'pastries': KitchenStation.dessert,

    // Bar
    'alcoholic_beverages': KitchenStation.bar,
    'cocktails': KitchenStation.bar,
    'beer': KitchenStation.bar,
    'wine': KitchenStation.bar,
  };

  /// Route order to kitchen stations
  /// Returns list of kitchen tickets (one per station)
  List<KitchenTicket> routeOrder({
    required Order order,
    int? priorityLevel,
  }) {
    // Group items by station
    final Map<KitchenStation, List<OrderItem>> itemsByStation = {};

    for (final item in order.items) {
      final station = _determineStation(item);

      if (!itemsByStation.containsKey(station)) {
        itemsByStation[station] = [];
      }
      itemsByStation[station]!.add(item);
    }

    // Create tickets for each station
    final tickets = <KitchenTicket>[];
    int ticketIndex = 1;

    for (final entry in itemsByStation.entries) {
      final station = entry.key;
      final items = entry.value;

      final ticket = KitchenTicket(
        id: '${order.id}-$ticketIndex',
        orderId: order.id,
        orderNumber: order.orderNumber,
        station: station,
        items: items,
        orderType: order.orderType,
        tableName: order.tableName,
        notes: order.notes,
        createdAt: DateTime.now(),
        priorityLevel: priorityLevel ?? _calculatePriority(order.orderType),
      );

      tickets.add(ticket);
      ticketIndex++;
    }

    return tickets;
  }

  /// Send ticket to kitchen via WebSocket
  Future<bool> sendToKitchen(KitchenTicket ticket) async {
    if (_wsChannel == null) {
      print('WebSocket not connected - ticket queued locally');
      return false;
    }

    try {
      final message = jsonEncode({
        'type': 'kitchen_ticket',
        'action': 'create',
        'data': ticket.toJson(),
      });

      _wsChannel.sink.add(message);
      return true;
    } catch (e) {
      print('Error sending to kitchen: $e');
      return false;
    }
  }

  /// Update ticket status
  Future<bool> updateTicketStatus(
    String ticketId,
    TicketStatus newStatus,
  ) async {
    if (_wsChannel == null) {
      return false;
    }

    try {
      final message = jsonEncode({
        'type': 'kitchen_ticket',
        'action': 'update_status',
        'data': {
          'ticket_id': ticketId,
          'status': newStatus.name,
          'updated_at': DateTime.now().toIso8601String(),
        },
      });

      _wsChannel.sink.add(message);
      return true;
    } catch (e) {
      print('Error updating ticket status: $e');
      return false;
    }
  }

  /// Determine kitchen station for an item
  KitchenStation _determineStation(OrderItem item) {
    // Check if category ID has a mapping
    if (item.categoryId != null) {
      final categoryKey = item.categoryId!.toLowerCase();
      if (_categoryRouting.containsKey(categoryKey)) {
        return _categoryRouting[categoryKey]!;
      }
    }

    // Fallback: analyze product name for keywords
    final productName = item.productName.toLowerCase();

    // Beverage keywords
    if (productName.contains('coffee') ||
        productName.contains('tea') ||
        productName.contains('juice') ||
        productName.contains('soda') ||
        productName.contains('drink')) {
      return KitchenStation.beverage;
    }

    // Dessert keywords
    if (productName.contains('cake') ||
        productName.contains('ice cream') ||
        productName.contains('dessert') ||
        productName.contains('pie')) {
      return KitchenStation.dessert;
    }

    // Bar keywords
    if (productName.contains('beer') ||
        productName.contains('wine') ||
        productName.contains('cocktail') ||
        productName.contains('whiskey') ||
        productName.contains('vodka')) {
      return KitchenStation.bar;
    }

    // Cold food keywords
    if (productName.contains('salad') ||
        productName.contains('sandwich') ||
        productName.contains('wrap') ||
        productName.contains('cold')) {
      return KitchenStation.cold;
    }

    // Default to hot station for everything else
    return KitchenStation.hot;
  }

  /// Calculate priority based on order type
  /// Lower number = higher priority
  int _calculatePriority(OrderType orderType) {
    switch (orderType) {
      case OrderType.driveThru:
        return 1; // Highest priority
      case OrderType.takeaway:
        return 2;
      case OrderType.delivery:
        return 3;
      case OrderType.dineIn:
        return 4;
      case OrderType.online:
        return 5; // Lowest priority
    }
  }

  /// Get station display name
  static String getStationDisplayName(KitchenStation station) {
    switch (station) {
      case KitchenStation.hot:
        return 'Hot Kitchen';
      case KitchenStation.cold:
        return 'Cold Kitchen';
      case KitchenStation.beverage:
        return 'Beverage Station';
      case KitchenStation.dessert:
        return 'Dessert Station';
      case KitchenStation.bar:
        return 'Bar';
    }
  }

  /// Get station icon
  static String getStationIcon(KitchenStation station) {
    switch (station) {
      case KitchenStation.hot:
        return '🔥';
      case KitchenStation.cold:
        return '🥗';
      case KitchenStation.beverage:
        return '☕';
      case KitchenStation.dessert:
        return '🍰';
      case KitchenStation.bar:
        return '🍺';
    }
  }

  /// Close WebSocket connection
  void dispose() {
    _wsChannel?.sink.close();
  }
}
