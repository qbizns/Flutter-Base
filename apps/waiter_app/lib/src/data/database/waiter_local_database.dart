/// Waiter Local Database
/// Local storage for offline-first order management using Drift
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:pos_core/pos_core.dart';

part 'waiter_local_database.g.dart';

/// Local orders table
class LocalOrders extends Table {
  TextColumn get id => text()();
  TextColumn get tableId => text().nullable()();
  TextColumn get tableName => text().nullable()();
  TextColumn get serverId => text().nullable()();
  TextColumn get serverName => text().nullable()();
  TextColumn get status => text()();
  TextColumn get itemsJson => text()();
  RealColumn get subtotal => real()();
  RealColumn get tax => real()();
  RealColumn get total => real()();
  TextColumn get notes => text().nullable()();
  IntColumn get guestCount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get syncAttempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSyncAttempt => dateTime().nullable()();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sync queue table for order operations
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text()();
  TextColumn get operation => text()(); // create, update, status_change, cancel
  TextColumn get dataJson => text()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
  TextColumn get error => text().nullable()();
}

/// Order modifications table
class OrderModifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text()();
  TextColumn get itemId => text()();
  TextColumn get modificationType => text()(); // add, remove, update_quantity, update_modifiers
  TextColumn get dataJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

/// Waiter Local Database
@DriftDatabase(tables: [LocalOrders, SyncQueue, OrderModifications])
class WaiterLocalDatabase extends _$WaiterLocalDatabase {
  WaiterLocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ==================== Local Orders ====================

  /// Get all local orders
  Future<List<LocalOrder>> getAllOrders() => select(localOrders).get();

  /// Get orders by status
  Future<List<LocalOrder>> getOrdersByStatus(String status) {
    return (select(localOrders)..where((o) => o.status.equals(status))).get();
  }

  /// Get unsynced orders
  Future<List<LocalOrder>> getUnsyncedOrders() {
    return (select(localOrders)..where((o) => o.isSynced.equals(false))).get();
  }

  /// Get order by ID
  Future<LocalOrder?> getOrderById(String id) {
    return (select(localOrders)..where((o) => o.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get orders by table
  Future<List<LocalOrder>> getOrdersByTable(String tableId) {
    return (select(localOrders)..where((o) => o.tableId.equals(tableId))).get();
  }

  /// Insert or update order
  Future<void> insertOrder(Order order, {bool isSynced = false}) {
    return into(localOrders).insertOnConflictUpdate(
      LocalOrder(
        id: order.id,
        tableId: order.tableId,
        tableName: order.tableName,
        serverId: order.serverId,
        serverName: order.serverName,
        status: order.status.name,
        itemsJson: jsonEncode(order.items.map((i) => i.toJson()).toList()),
        subtotal: order.subtotal,
        tax: order.tax,
        total: order.total,
        notes: order.notes,
        guestCount: order.guestCount,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
        isSynced: isSynced,
        syncAttempts: 0,
        lastSyncAttempt: null,
        syncError: null,
      ),
    );
  }

  /// Update order sync status
  Future<void> markOrderAsSynced(String orderId) {
    return (update(localOrders)..where((o) => o.id.equals(orderId))).write(
      LocalOrdersCompanion(
        isSynced: const Value(true),
        syncAttempts: const Value(0),
        syncError: const Value(null),
      ),
    );
  }

  /// Update order sync attempt
  Future<void> recordSyncAttempt(String orderId, String? error) {
    return (update(localOrders)..where((o) => o.id.equals(orderId))).write(
      LocalOrdersCompanion(
        syncAttempts: Value(localOrders.syncAttempts + const Constant(1)),
        lastSyncAttempt: Value(DateTime.now()),
        syncError: Value(error),
      ),
    );
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) {
    return (update(localOrders)..where((o) => o.id.equals(orderId))).write(
      LocalOrdersCompanion(
        status: Value(status.name),
        updatedAt: Value(DateTime.now()),
        isSynced: const Value(false),
      ),
    );
  }

  /// Delete order
  Future<void> deleteOrder(String orderId) {
    return (delete(localOrders)..where((o) => o.id.equals(orderId))).go();
  }

  /// Delete synced orders older than specified duration
  Future<void> cleanupSyncedOrders(Duration olderThan) {
    final cutoffDate = DateTime.now().subtract(olderThan);
    return (delete(localOrders)
          ..where((o) =>
              o.isSynced.equals(true) & o.updatedAt.isSmallerThanValue(cutoffDate)))
        .go();
  }

  // ==================== Sync Queue ====================

  /// Get all pending sync operations
  Future<List<SyncQueueData>> getPendingSyncOperations() {
    return (select(syncQueue)..orderBy([(o) => OrderingTerm.desc(o.priority)]))
        .get();
  }

  /// Add sync operation
  Future<int> addSyncOperation({
    required String orderId,
    required String operation,
    required Map<String, dynamic> data,
    int priority = 0,
  }) {
    return into(syncQueue).insert(
      SyncQueueData(
        id: 0, // Auto-increment
        orderId: orderId,
        operation: operation,
        dataJson: jsonEncode(data),
        priority: priority,
        createdAt: DateTime.now(),
        attempts: 0,
        lastAttempt: null,
        error: null,
      ),
    );
  }

  /// Remove sync operation
  Future<void> removeSyncOperation(int id) {
    return (delete(syncQueue)..where((o) => o.id.equals(id))).go();
  }

  /// Update sync operation attempt
  Future<void> recordSyncOperationAttempt(int id, String? error) {
    return (update(syncQueue)..where((o) => o.id.equals(id))).write(
      SyncQueueCompanion(
        attempts: Value(syncQueue.attempts + const Constant(1)),
        lastAttempt: Value(DateTime.now()),
        error: Value(error),
      ),
    );
  }

  /// Clear sync queue for order
  Future<void> clearSyncQueueForOrder(String orderId) {
    return (delete(syncQueue)..where((o) => o.orderId.equals(orderId))).go();
  }

  // ==================== Order Modifications ====================

  /// Get modifications for order
  Future<List<OrderModification>> getModificationsForOrder(String orderId) {
    return (select(orderModifications)
          ..where((m) => m.orderId.equals(orderId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  /// Get unsynced modifications
  Future<List<OrderModification>> getUnsyncedModifications() {
    return (select(orderModifications)
          ..where((m) => m.isSynced.equals(false)))
        .get();
  }

  /// Add modification
  Future<int> addModification({
    required String orderId,
    required String itemId,
    required String modificationType,
    required Map<String, dynamic> data,
  }) {
    return into(orderModifications).insert(
      OrderModification(
        id: 0, // Auto-increment
        orderId: orderId,
        itemId: itemId,
        modificationType: modificationType,
        dataJson: jsonEncode(data),
        createdAt: DateTime.now(),
        isSynced: false,
      ),
    );
  }

  /// Mark modification as synced
  Future<void> markModificationAsSynced(int id) {
    return (update(orderModifications)..where((m) => m.id.equals(id))).write(
      const OrderModificationsCompanion(
        isSynced: Value(true),
      ),
    );
  }

  /// Delete synced modifications older than specified duration
  Future<void> cleanupSyncedModifications(Duration olderThan) {
    final cutoffDate = DateTime.now().subtract(olderThan);
    return (delete(orderModifications)
          ..where((m) =>
              m.isSynced.equals(true) &
              m.createdAt.isSmallerThanValue(cutoffDate)))
        .go();
  }

  // ==================== Helper Methods ====================

  /// Convert LocalOrder to Order
  Order localOrderToOrder(LocalOrder localOrder) {
    final items = (jsonDecode(localOrder.itemsJson) as List)
        .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
        .toList();

    return Order(
      id: localOrder.id,
      tableId: localOrder.tableId,
      tableName: localOrder.tableName,
      serverId: localOrder.serverId,
      serverName: localOrder.serverName,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == localOrder.status,
        orElse: () => OrderStatus.pending,
      ),
      items: items,
      subtotal: localOrder.subtotal,
      tax: localOrder.tax,
      total: localOrder.total,
      notes: localOrder.notes,
      guestCount: localOrder.guestCount,
      createdAt: localOrder.createdAt,
      updatedAt: localOrder.updatedAt,
    );
  }

  /// Get database statistics
  Future<Map<String, int>> getStats() async {
    final totalOrders = await select(localOrders).get();
    final unsyncedOrders = await getUnsyncedOrders();
    final pendingSync = await getPendingSyncOperations();
    final unsyncedMods = await getUnsyncedModifications();

    return {
      'total_orders': totalOrders.length,
      'unsynced_orders': unsyncedOrders.length,
      'pending_sync_operations': pendingSync.length,
      'unsynced_modifications': unsyncedMods.length,
    };
  }
}

/// Open database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'waiter_local.db'));
    return NativeDatabase(file);
  });
}
