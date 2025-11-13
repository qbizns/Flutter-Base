import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../models/restaurant_table.dart';
import '../data/sources/restaurant_remote_source.dart';

/// Provider for restaurant remote data source.
///
/// Switches between HTTP and Mock implementation based on configuration.
final restaurantRemoteSourceProvider = Provider<RestaurantRemoteSource>((ref) {
  final config = ref.watch(appConfigProvider);
  final context = ref.watch(appContextProvider);

  // Use HTTP implementation if API URL is configured and we have tenant ID
  if (config.apiBaseUrl.isNotEmpty && context.tenantId != null) {
    final apiClient = ref.watch(apiClientProvider);
    return RestaurantRemoteSourceHttp(
      apiClient: apiClient,
      organizationId: context.tenantId!,
    );
  }

  // Fall back to mock for development/testing
  return RestaurantRemoteSourceMock();
});

/// Provider for restaurant tables
final tablesProvider = StateNotifierProvider<TablesNotifier, List<RestaurantTable>>((ref) {
  final remoteSource = ref.watch(restaurantRemoteSourceProvider);
  return TablesNotifier(remoteSource);
});

class TablesNotifier extends StateNotifier<List<RestaurantTable>> {
  TablesNotifier(this._remoteSource) : super([]) {
    _loadTables();
  }

  final RestaurantRemoteSource _remoteSource;

  Future<void> _loadTables() async {
    try {
      final tables = await _remoteSource.getTables();
      state = tables;
    } catch (e) {
      // Handle error - in production, you might want to show a snackbar or error state
      print('Error loading tables: $e');
    }
  }

  Future<void> addTable(RestaurantTable table) async {
    try {
      final newTable = await _remoteSource.createTable(table);
      state = [...state, newTable];
    } catch (e) {
      print('Error adding table: $e');
      rethrow;
    }
  }

  Future<void> updateTable(String id, RestaurantTable updatedTable) async {
    try {
      final updated = await _remoteSource.updateTable(id, updatedTable);
      state = [
        for (final table in state)
          if (table.id == id) updated else table,
      ];
    } catch (e) {
      print('Error updating table: $e');
      rethrow;
    }
  }

  Future<void> deleteTable(String id) async {
    try {
      await _remoteSource.deleteTable(id);
      state = state.where((table) => table.id != id).toList();
    } catch (e) {
      print('Error deleting table: $e');
      rethrow;
    }
  }

  void updateTablePosition(String id, double x, double y) {
    // Update position locally first for smooth UX
    state = [
      for (final table in state)
        if (table.id == id)
          table.copyWith(positionX: x, positionY: y)
        else
          table,
    ];

    // Then sync with backend
    final table = state.firstWhere((t) => t.id == id);
    updateTable(id, table).catchError((e) {
      print('Error syncing table position: $e');
    });
  }

  void updateTableStatus(String id, TableStatus status) {
    // Update status locally first for smooth UX
    state = [
      for (final table in state)
        if (table.id == id) table.copyWith(status: status) else table,
    ];

    // Then sync with backend
    final table = state.firstWhere((t) => t.id == id);
    updateTable(id, table).catchError((e) {
      print('Error syncing table status: $e');
    });
  }

  Future<void> refresh() async {
    await _loadTables();
  }
}

/// Provider for kitchen stations
final kitchenStationsProvider =
    StateNotifierProvider<KitchenStationsNotifier, List<KitchenStation>>((ref) {
  final remoteSource = ref.watch(restaurantRemoteSourceProvider);
  return KitchenStationsNotifier(remoteSource);
});

class KitchenStationsNotifier extends StateNotifier<List<KitchenStation>> {
  KitchenStationsNotifier(this._remoteSource) : super([]) {
    _loadStations();
  }

  final RestaurantRemoteSource _remoteSource;

  Future<void> _loadStations() async {
    try {
      final stations = await _remoteSource.getKitchenStations();
      state = stations;
    } catch (e) {
      // Handle error - in production, you might want to show a snackbar or error state
      print('Error loading kitchen stations: $e');
    }
  }

  Future<void> addStation(KitchenStation station) async {
    try {
      final newStation = await _remoteSource.createKitchenStation(station);
      state = [...state, newStation];
    } catch (e) {
      print('Error adding kitchen station: $e');
      rethrow;
    }
  }

  Future<void> updateStation(String id, KitchenStation updatedStation) async {
    try {
      final updated = await _remoteSource.updateKitchenStation(id, updatedStation);
      state = [
        for (final station in state)
          if (station.id == id) updated else station,
      ];
    } catch (e) {
      print('Error updating kitchen station: $e');
      rethrow;
    }
  }

  Future<void> deleteStation(String id) async {
    try {
      await _remoteSource.deleteKitchenStation(id);
      state = state.where((station) => station.id != id).toList();
    } catch (e) {
      print('Error deleting kitchen station: $e');
      rethrow;
    }
  }

  void toggleStationActive(String id) {
    // Toggle locally first for smooth UX
    state = [
      for (final station in state)
        if (station.id == id)
          station.copyWith(isActive: !station.isActive)
        else
          station,
    ];

    // Then sync with backend
    final station = state.firstWhere((s) => s.id == id);
    updateStation(id, station).catchError((e) {
      print('Error syncing station active state: $e');
    });
  }

  void reorderStations(int oldIndex, int newIndex) {
    final List<KitchenStation> newList = List.from(state);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final station = newList.removeAt(oldIndex);
    newList.insert(newIndex, station);

    // Update order positions locally
    state = List.generate(
      newList.length,
      (index) => newList[index].copyWith(orderPosition: index),
    );

    // Sync all updated positions with backend
    for (var i = 0; i < state.length; i++) {
      updateStation(state[i].id, state[i]).catchError((e) {
        print('Error syncing station order: $e');
      });
    }
  }

  Future<void> refresh() async {
    await _loadStations();
  }
}
