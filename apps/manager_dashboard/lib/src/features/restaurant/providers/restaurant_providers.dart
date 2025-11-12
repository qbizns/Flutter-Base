import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/restaurant_table.dart';
import '../../../ui/theme/odoo_colors.dart';

/// Provider for restaurant tables
///
/// TODO: Replace with real API integration
/// GET /api/v1/tables - List all tables
/// POST /api/v1/tables - Create table
/// PATCH /api/v1/tables/:id - Update table
/// DELETE /api/v1/tables/:id - Delete table
final tablesProvider = StateNotifierProvider<TablesNotifier, List<RestaurantTable>>((ref) {
  return TablesNotifier();
});

class TablesNotifier extends StateNotifier<List<RestaurantTable>> {
  TablesNotifier() : super(_generateMockTables());

  static List<RestaurantTable> _generateMockTables() {
    return [
      // Main Hall
      const RestaurantTable(
        id: '1',
        name: 'Table 1',
        capacity: 4,
        status: TableStatus.available,
        shape: TableShape.square,
        positionX: 10,
        positionY: 10,
        width: 100,
        height: 100,
        section: 'Main Hall',
      ),
      const RestaurantTable(
        id: '2',
        name: 'Table 2',
        capacity: 4,
        status: TableStatus.occupied,
        shape: TableShape.square,
        positionX: 30,
        positionY: 10,
        width: 100,
        height: 100,
        section: 'Main Hall',
        currentOrderId: 'order-123',
      ),
      const RestaurantTable(
        id: '3',
        name: 'Table 3',
        capacity: 6,
        status: TableStatus.reserved,
        shape: TableShape.rectangle,
        positionX: 50,
        positionY: 10,
        width: 150,
        height: 100,
        section: 'Main Hall',
        reservationName: 'John Doe',
      ),
      const RestaurantTable(
        id: '4',
        name: 'Table 4',
        capacity: 2,
        status: TableStatus.available,
        shape: TableShape.circle,
        positionX: 10,
        positionY: 35,
        width: 80,
        height: 80,
        section: 'Main Hall',
      ),
      const RestaurantTable(
        id: '5',
        name: 'Table 5',
        capacity: 4,
        status: TableStatus.cleaning,
        shape: TableShape.square,
        positionX: 30,
        positionY: 35,
        width: 100,
        height: 100,
        section: 'Main Hall',
      ),

      // Patio
      const RestaurantTable(
        id: '6',
        name: 'Table 6',
        capacity: 4,
        status: TableStatus.available,
        shape: TableShape.circle,
        positionX: 10,
        positionY: 60,
        width: 100,
        height: 100,
        section: 'Patio',
      ),
      const RestaurantTable(
        id: '7',
        name: 'Table 7',
        capacity: 6,
        status: TableStatus.occupied,
        shape: TableShape.rectangle,
        positionX: 30,
        positionY: 60,
        width: 150,
        height: 100,
        section: 'Patio',
        currentOrderId: 'order-456',
      ),

      // VIP Section
      const RestaurantTable(
        id: '8',
        name: 'VIP 1',
        capacity: 8,
        status: TableStatus.reserved,
        shape: TableShape.roundedRectangle,
        positionX: 70,
        positionY: 35,
        width: 180,
        height: 120,
        section: 'VIP',
        reservationName: 'Sarah Johnson',
      ),
      const RestaurantTable(
        id: '9',
        name: 'VIP 2',
        capacity: 6,
        status: TableStatus.available,
        shape: TableShape.roundedRectangle,
        positionX: 70,
        positionY: 60,
        width: 150,
        height: 100,
        section: 'VIP',
      ),

      // Bar Area
      const RestaurantTable(
        id: '10',
        name: 'Bar 1',
        capacity: 2,
        status: TableStatus.occupied,
        shape: TableShape.circle,
        positionX: 70,
        positionY: 10,
        width: 70,
        height: 70,
        section: 'Bar',
        currentOrderId: 'order-789',
      ),
      const RestaurantTable(
        id: '11',
        name: 'Bar 2',
        capacity: 2,
        status: TableStatus.available,
        shape: TableShape.circle,
        positionX: 82,
        positionY: 10,
        width: 70,
        height: 70,
        section: 'Bar',
      ),
    ];
  }

  void addTable(RestaurantTable table) {
    state = [...state, table];
  }

  void updateTable(String id, RestaurantTable updatedTable) {
    state = [
      for (final table in state)
        if (table.id == id) updatedTable else table,
    ];
  }

  void deleteTable(String id) {
    state = state.where((table) => table.id != id).toList();
  }

  void updateTablePosition(String id, double x, double y) {
    state = [
      for (final table in state)
        if (table.id == id)
          table.copyWith(positionX: x, positionY: y)
        else
          table,
    ];
  }

  void updateTableStatus(String id, TableStatus status) {
    state = [
      for (final table in state)
        if (table.id == id) table.copyWith(status: status) else table,
    ];
  }
}

/// Provider for kitchen stations
///
/// TODO: Replace with real API integration
/// GET /api/v1/kitchen-stations - List all stations
/// POST /api/v1/kitchen-stations - Create station
/// PATCH /api/v1/kitchen-stations/:id - Update station
/// DELETE /api/v1/kitchen-stations/:id - Delete station
final kitchenStationsProvider =
    StateNotifierProvider<KitchenStationsNotifier, List<KitchenStation>>((ref) {
  return KitchenStationsNotifier();
});

class KitchenStationsNotifier extends StateNotifier<List<KitchenStation>> {
  KitchenStationsNotifier() : super(_generateMockStations());

  static List<KitchenStation> _generateMockStations() {
    return [
      KitchenStation(
        id: '1',
        name: 'Grill Station',
        description: 'Handles all grilled items and meats',
        color: OdooColors.danger,
        categories: ['Steaks', 'Burgers', 'Grilled Chicken'],
        isActive: true,
        orderPosition: 0,
      ),
      KitchenStation(
        id: '2',
        name: 'Salad & Cold Station',
        description: 'Prepares salads, appetizers, and cold dishes',
        color: OdooColors.success,
        categories: ['Salads', 'Appetizers', 'Cold Sandwiches'],
        isActive: true,
        orderPosition: 1,
      ),
      KitchenStation(
        id: '3',
        name: 'Pasta & Hot Kitchen',
        description: 'Pasta, soups, and hot entrees',
        color: OdooColors.warning,
        categories: ['Pasta', 'Soups', 'Hot Entrees'],
        isActive: true,
        orderPosition: 2,
      ),
      KitchenStation(
        id: '4',
        name: 'Dessert Station',
        description: 'Desserts and sweet preparations',
        color: OdooColors.secondary,
        categories: ['Desserts', 'Pastries', 'Ice Cream'],
        isActive: true,
        orderPosition: 3,
      ),
      KitchenStation(
        id: '5',
        name: 'Beverage Station',
        description: 'Drinks, coffee, and cocktails',
        color: OdooColors.primary,
        categories: ['Beverages', 'Coffee', 'Cocktails'],
        isActive: true,
        orderPosition: 4,
      ),
    ];
  }

  void addStation(KitchenStation station) {
    state = [...state, station];
  }

  void updateStation(String id, KitchenStation updatedStation) {
    state = [
      for (final station in state)
        if (station.id == id) updatedStation else station,
    ];
  }

  void deleteStation(String id) {
    state = state.where((station) => station.id != id).toList();
  }

  void toggleStationActive(String id) {
    state = [
      for (final station in state)
        if (station.id == id)
          station.copyWith(isActive: !station.isActive)
        else
          station,
    ];
  }

  void reorderStations(int oldIndex, int newIndex) {
    final List<KitchenStation> newList = List.from(state);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final station = newList.removeAt(oldIndex);
    newList.insert(newIndex, station);

    // Update order positions
    state = List.generate(
      newList.length,
      (index) => newList[index].copyWith(orderPosition: index),
    );
  }
}
