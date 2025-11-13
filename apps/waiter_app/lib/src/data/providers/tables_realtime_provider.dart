/// Tables Real-Time Provider
/// Manages table state with real-time multi-device synchronization
library;

import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../services/waiter_realtime_service.dart';

/// Table with real-time status
class TableWithStatus {
  final RestaurantTable table;
  final String status; // available, occupied, reserved
  final Order? currentOrder;
  final DateTime? lastUpdate;
  final int? guestCount;
  final Duration? occupiedDuration;

  const TableWithStatus({
    required this.table,
    required this.status,
    this.currentOrder,
    this.lastUpdate,
    this.guestCount,
    this.occupiedDuration,
  });

  TableWithStatus copyWith({
    RestaurantTable? table,
    String? status,
    Order? currentOrder,
    bool clearOrder = false,
    DateTime? lastUpdate,
    int? guestCount,
    Duration? occupiedDuration,
  }) {
    return TableWithStatus(
      table: table ?? this.table,
      status: status ?? this.status,
      currentOrder: clearOrder ? null : (currentOrder ?? this.currentOrder),
      lastUpdate: lastUpdate ?? this.lastUpdate,
      guestCount: guestCount ?? this.guestCount,
      occupiedDuration: occupiedDuration ?? this.occupiedDuration,
    );
  }

  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';
  bool get isReserved => status == 'reserved';
  bool get hasActiveOrder => currentOrder != null;
}

/// Tables state
class TablesRealtimeState {
  final Map<String, TableWithStatus> tables;
  final WaiterConnectionStatus connectionStatus;
  final DateTime? lastSync;
  final String? error;

  TablesRealtimeState({
    Map<String, TableWithStatus>? tables,
    this.connectionStatus = WaiterConnectionStatus.disconnected,
    this.lastSync,
    this.error,
  }) : tables = tables ?? {};

  /// Get tables as list, sorted by table number
  List<TableWithStatus> get tablesList {
    final list = tables.values.toList();
    list.sort((a, b) => a.table.name.compareTo(b.table.name));
    return list;
  }

  /// Get available tables
  List<TableWithStatus> get availableTables {
    return tablesList.where((t) => t.isAvailable).toList();
  }

  /// Get occupied tables
  List<TableWithStatus> get occupiedTables {
    return tablesList.where((t) => t.isOccupied).toList();
  }

  /// Get reserved tables
  List<TableWithStatus> get reservedTables {
    return tablesList.where((t) => t.isReserved).toList();
  }

  /// Get tables by zone
  List<TableWithStatus> getTablesByZone(String zoneId) {
    return tablesList
        .where((t) => t.table.zoneId == zoneId)
        .toList();
  }

  /// Get table counts by status
  Map<String, int> get tableCountsByStatus {
    final counts = <String, int>{
      'available': 0,
      'occupied': 0,
      'reserved': 0,
    };

    for (final table in tablesList) {
      counts[table.status] = (counts[table.status] ?? 0) + 1;
    }

    return counts;
  }

  bool get isConnected => connectionStatus == WaiterConnectionStatus.connected;
  bool get isConnecting => connectionStatus == WaiterConnectionStatus.connecting ||
      connectionStatus == WaiterConnectionStatus.reconnecting;

  TablesRealtimeState copyWith({
    Map<String, TableWithStatus>? tables,
    WaiterConnectionStatus? connectionStatus,
    DateTime? lastSync,
    String? error,
    bool clearError = false,
  }) {
    return TablesRealtimeState(
      tables: tables ?? this.tables,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      lastSync: lastSync ?? this.lastSync,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Tables Real-Time Notifier
/// Manages tables state with real-time updates from WebSocket
class TablesRealtimeNotifier extends StateNotifier<TablesRealtimeState> {
  final WaiterRealtimeService _realtimeService;
  final Ref _ref;
  StreamSubscription<WaiterConnectionStatus>? _statusSubscription;
  StreamSubscription<Map<String, dynamic>>? _tableStatusSubscription;
  StreamSubscription<Order>? _orderUpdateSubscription;

  TablesRealtimeNotifier({
    required WaiterRealtimeService realtimeService,
    required Ref ref,
  })  : _realtimeService = realtimeService,
        _ref = ref,
        super(TablesRealtimeState()) {
    _initialize();
  }

  /// Initialize WebSocket connection and listeners
  void _initialize() {
    // Connect to WebSocket
    _realtimeService.connect();

    // Listen to connection status
    _statusSubscription = _realtimeService.statusStream.listen((status) {
      state = state.copyWith(connectionStatus: status);
    });

    // Listen to table status updates
    _tableStatusSubscription = _realtimeService.tableStatusStream.listen(
      _handleTableStatusUpdate,
      onError: (error) {
        state = state.copyWith(error: error.toString());
      },
    );

    // Listen to order updates
    _orderUpdateSubscription = _realtimeService.orderUpdateStream.listen(
      _handleOrderUpdate,
      onError: (error) {
        state = state.copyWith(error: error.toString());
      },
    );

    // Load initial table data
    _loadInitialTables();
  }

  /// Load initial table data
  Future<void> _loadInitialTables() async {
    try {
      // In production, fetch from backend via tables repository
      // For now, create mock tables
      final mockTables = _createMockTables();

      final tablesMap = <String, TableWithStatus>{};
      for (final table in mockTables) {
        tablesMap[table.table.id] = table;
      }

      state = state.copyWith(
        tables: tablesMap,
        lastSync: DateTime.now(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to load tables: $e');
    }
  }

  /// Handle table status update from WebSocket
  void _handleTableStatusUpdate(Map<String, dynamic> data) {
    final tableId = data['table_id'] as String?;
    if (tableId == null) return;

    final newStatus = data['status'] as String?;
    final orderId = data['order_id'] as String?;
    final guestCount = data['guest_count'] as int?;

    final tables = Map<String, TableWithStatus>.from(state.tables);
    final existingTable = tables[tableId];

    if (existingTable != null) {
      tables[tableId] = existingTable.copyWith(
        status: newStatus ?? existingTable.status,
        lastUpdate: DateTime.now(),
        guestCount: guestCount,
        clearOrder: orderId == null && newStatus == 'available',
      );

      state = state.copyWith(
        tables: tables,
        lastSync: DateTime.now(),
        clearError: true,
      );
    }
  }

  /// Handle order update from WebSocket
  void _handleOrderUpdate(Order order) {
    if (order.tableId == null) return;

    final tables = Map<String, TableWithStatus>.from(state.tables);
    final existingTable = tables[order.tableId];

    if (existingTable != null) {
      // Update table with current order
      tables[order.tableId!] = existingTable.copyWith(
        currentOrder: order,
        status: order.status == OrderStatus.completed ||
                order.status == OrderStatus.cancelled
            ? 'available'
            : 'occupied',
        lastUpdate: DateTime.now(),
      );

      state = state.copyWith(
        tables: tables,
        lastSync: DateTime.now(),
        clearError: true,
      );
    }
  }

  /// Update table status locally and broadcast
  Future<void> updateTableStatus({
    required String tableId,
    required String status,
    int? guestCount,
  }) async {
    try {
      // Update locally first (optimistic update)
      final tables = Map<String, TableWithStatus>.from(state.tables);
      final existingTable = tables[tableId];

      if (existingTable != null) {
        tables[tableId] = existingTable.copyWith(
          status: status,
          lastUpdate: DateTime.now(),
          guestCount: guestCount,
          clearOrder: status == 'available',
        );

        state = state.copyWith(
          tables: tables,
          lastSync: DateTime.now(),
          clearError: true,
        );
      }

      // Broadcast to other devices via WebSocket
      _realtimeService.updateTableStatus(tableId, status);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update table status: $e');
    }
  }

  /// Assign order to table
  Future<void> assignOrderToTable({
    required String tableId,
    required Order order,
  }) async {
    try {
      final tables = Map<String, TableWithStatus>.from(state.tables);
      final existingTable = tables[tableId];

      if (existingTable != null) {
        tables[tableId] = existingTable.copyWith(
          currentOrder: order,
          status: 'occupied',
          lastUpdate: DateTime.now(),
        );

        state = state.copyWith(
          tables: tables,
          lastSync: DateTime.now(),
          clearError: true,
        );
      }

      // Notify other devices
      _realtimeService.notifyOrderCreated(order);
    } catch (e) {
      state = state.copyWith(error: 'Failed to assign order: $e');
    }
  }

  /// Refresh tables data
  Future<void> refresh() async {
    await _loadInitialTables();
  }

  /// Reconnect to WebSocket
  Future<void> reconnect() async {
    await _realtimeService.disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await _realtimeService.connect();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Create mock tables for development
  List<TableWithStatus> _createMockTables() {
    final now = DateTime.now();
    final tables = <TableWithStatus>[];

    // Zone 1: Main Dining Room
    for (int i = 1; i <= 10; i++) {
      tables.add(TableWithStatus(
        table: RestaurantTable(
          id: 'table-$i',
          name: 'T$i',
          capacity: (i % 3) + 2, // 2-4 capacity
          zoneId: 'zone-main',
          zoneName: 'Main Dining',
          x: 0,
          y: 0,
          width: 80,
          height: 80,
          shape: TableShape.square,
          status: TableStatus.available,
        ),
        status: i <= 3 ? 'occupied' : 'available',
        lastUpdate: now,
        guestCount: i <= 3 ? ((i % 3) + 2) : null,
      ));
    }

    // Zone 2: Patio
    for (int i = 11; i <= 15; i++) {
      tables.add(TableWithStatus(
        table: RestaurantTable(
          id: 'table-$i',
          name: 'P${i - 10}',
          capacity: 4,
          zoneId: 'zone-patio',
          zoneName: 'Patio',
          x: 0,
          y: 0,
          width: 80,
          height: 80,
          shape: TableShape.round,
          status: TableStatus.available,
        ),
        status: 'available',
        lastUpdate: now,
      ));
    }

    // Zone 3: Bar
    for (int i = 16; i <= 20; i++) {
      tables.add(TableWithStatus(
        table: RestaurantTable(
          id: 'table-$i',
          name: 'B${i - 15}',
          capacity: 2,
          zoneId: 'zone-bar',
          zoneName: 'Bar',
          x: 0,
          y: 0,
          width: 60,
          height: 60,
          shape: TableShape.square,
          status: TableStatus.available,
        ),
        status: i == 16 ? 'reserved' : 'available',
        lastUpdate: now,
      ));
    }

    return tables;
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _tableStatusSubscription?.cancel();
    _orderUpdateSubscription?.cancel();
    super.dispose();
  }
}

/// Real-time tables provider
final tablesRealtimeProvider =
    StateNotifierProvider<TablesRealtimeNotifier, TablesRealtimeState>((ref) {
  final realtimeService = ref.watch(waiterRealtimeServiceProvider);

  return TablesRealtimeNotifier(
    realtimeService: realtimeService,
    ref: ref,
  );
});

/// Convenience providers

/// All tables
final allTablesProvider = Provider<List<TableWithStatus>>((ref) {
  final state = ref.watch(tablesRealtimeProvider);
  return state.tablesList;
});

/// Available tables only
final availableTablesProvider = Provider<List<TableWithStatus>>((ref) {
  final state = ref.watch(tablesRealtimeProvider);
  return state.availableTables;
});

/// Occupied tables only
final occupiedTablesProvider = Provider<List<TableWithStatus>>((ref) {
  final state = ref.watch(tablesRealtimeProvider);
  return state.occupiedTables;
});

/// Tables by zone
final tablesByZoneProvider =
    Provider.family<List<TableWithStatus>, String>((ref, zoneId) {
  final state = ref.watch(tablesRealtimeProvider);
  return state.getTablesByZone(zoneId);
});

/// Table counts by status
final tableCountsProvider = Provider<Map<String, int>>((ref) {
  final state = ref.watch(tablesRealtimeProvider);
  return state.tableCountsByStatus;
});

/// Connection status
final waiterTableConnectionStatusProvider = Provider<WaiterConnectionStatus>((ref) {
  final state = ref.watch(tablesRealtimeProvider);
  return state.connectionStatus;
});
