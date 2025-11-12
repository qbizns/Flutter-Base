/// Local Database for Offline Support
/// SQLite database using Drift ORM for offline order storage and sync queue
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

part 'local_database.g.dart';

/// Offline orders table
class OfflineOrders extends Table {
  TextColumn get id => text()();
  TextColumn get orderNumber => text()();
  TextColumn get status => text()(); // draft, pending_sync, synced, failed
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Order details
  RealColumn get subtotal => real()();
  RealColumn get tax => real()();
  RealColumn get total => real()();
  IntColumn get itemsCount => integer()();

  // Optional fields
  TextColumn get customerId => text().nullable()();
  TextColumn get customerName => text().nullable()();
  TextColumn get tableId => text().nullable()();
  TextColumn get tableName => text().nullable()();
  TextColumn get notes => text().nullable()();

  // Session info
  TextColumn get sessionId => text()();
  TextColumn get cashierId => text()();
  TextColumn get cashierName => text()();

  // Payment info (JSON)
  TextColumn get paymentLines => text()(); // JSON array of payment lines

  // Sync tracking
  DateTimeColumn get lastSyncAttempt => dateTime().nullable()();
  IntColumn get syncAttempts => integer().withDefault(const Constant(0))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Offline order items table
class OfflineOrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();

  // Product info
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get productSku => text()();
  TextColumn get productImageUrl => text().nullable()();
  TextColumn get categoryId => text().nullable()();

  // Pricing
  RealColumn get basePrice => real()();
  RealColumn get totalPrice => real()();
  IntColumn get quantity => integer()();
  RealColumn get taxPercent => real()();

  // Modifiers (JSON)
  TextColumn get modifiersJson => text().withDefault(const Constant('[]'))();

  // Notes
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sync queue for operations that need to be synced
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get operationType => text()(); // create_order, update_order, cash_movement
  TextColumn get entityType => text()(); // order, session, product
  TextColumn get entityId => text()();

  TextColumn get payloadJson => text()(); // JSON payload for the operation
  TextColumn get status => text()(); // pending, processing, completed, failed

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get error => text().nullable()();

  IntColumn get priority => integer().withDefault(const Constant(5))(); // 1=highest, 10=lowest
}

/// Cart backup for crash recovery
class CartBackup extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get itemsJson => text()(); // JSON array of cart items
  TextColumn get customerJson => text().nullable()(); // JSON customer object
  TextColumn get discountJson => text().nullable()(); // JSON discount object
  TextColumn get notesJson => text().nullable()(); // JSON notes

  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite database for offline support
@DriftDatabase(tables: [
  OfflineOrders,
  OfflineOrderItems,
  SyncQueue,
  CartBackup,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future schema upgrades here
      },
    );
  }

  // ============================================
  // Offline Orders Operations
  // ============================================

  /// Get all offline orders
  Future<List<OfflineOrder>> getAllOfflineOrders() async {
    return await select(offlineOrders).get();
  }

  /// Get orders by status
  Future<List<OfflineOrder>> getOrdersByStatus(String status) async {
    return await (select(offlineOrders)
          ..where((order) => order.status.equals(status)))
        .get();
  }

  /// Get pending orders (need to be synced)
  Future<List<OfflineOrder>> getPendingOrders() async {
    return await (select(offlineOrders)
          ..where((order) => order.status.equals('pending_sync')))
        .get();
  }

  /// Insert or update an offline order
  Future<int> upsertOfflineOrder(OfflineOrdersCompanion order) async {
    return await into(offlineOrders).insertOnConflictUpdate(order);
  }

  /// Delete an offline order
  Future<int> deleteOfflineOrder(String orderId) async {
    return await (delete(offlineOrders)
          ..where((order) => order.id.equals(orderId)))
        .go();
  }

  /// Update order sync status
  Future<int> updateOrderSyncStatus({
    required String orderId,
    required String status,
    String? error,
  }) async {
    return await (update(offlineOrders)
          ..where((order) => order.id.equals(orderId)))
        .write(
      OfflineOrdersCompanion(
        status: Value(status),
        lastSyncAttempt: Value(DateTime.now()),
        syncAttempts: Value.ofNullable(null), // Increment handled separately
        syncError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Increment sync attempts
  Future<void> incrementSyncAttempts(String orderId) async {
    final order = await (select(offlineOrders)
          ..where((o) => o.id.equals(orderId)))
        .getSingle();

    await (update(offlineOrders)..where((o) => o.id.equals(orderId))).write(
      OfflineOrdersCompanion(
        syncAttempts: Value(order.syncAttempts + 1),
        lastSyncAttempt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================
  // Offline Order Items Operations
  // ============================================

  /// Get items for an order
  Future<List<OfflineOrderItem>> getOrderItems(String orderId) async {
    return await (select(offlineOrderItems)
          ..where((item) => item.orderId.equals(orderId)))
        .get();
  }

  /// Insert order items
  Future<void> insertOrderItems(List<OfflineOrderItemsCompanion> items) async {
    await batch((batch) {
      batch.insertAll(offlineOrderItems, items);
    });
  }

  /// Delete items for an order
  Future<int> deleteOrderItems(String orderId) async {
    return await (delete(offlineOrderItems)
          ..where((item) => item.orderId.equals(orderId)))
        .go();
  }

  // ============================================
  // Sync Queue Operations
  // ============================================

  /// Get all pending sync operations
  Future<List<SyncQueueData>> getPendingSyncOperations() async {
    return await (select(syncQueue)
          ..where((op) => op.status.equals('pending'))
          ..orderBy([(op) => OrderingTerm(expression: op.priority)]))
        .get();
  }

  /// Add operation to sync queue
  Future<int> addToSyncQueue({
    required String operationType,
    required String entityType,
    required String entityId,
    required String payloadJson,
    int priority = 5,
  }) async {
    return await into(syncQueue).insert(
      SyncQueueCompanion.insert(
        operationType: operationType,
        entityType: entityType,
        entityId: entityId,
        payloadJson: payloadJson,
        status: 'pending',
        createdAt: DateTime.now(),
        priority: Value(priority),
      ),
    );
  }

  /// Update sync operation status
  Future<int> updateSyncOperationStatus({
    required int operationId,
    required String status,
    String? error,
  }) async {
    return await (update(syncQueue)
          ..where((op) => op.id.equals(operationId)))
        .write(
      SyncQueueCompanion(
        status: Value(status),
        lastAttempt: Value(DateTime.now()),
        error: Value(error),
      ),
    );
  }

  /// Increment sync operation attempts
  Future<void> incrementSyncOperationAttempts(int operationId) async {
    final operation = await (select(syncQueue)
          ..where((op) => op.id.equals(operationId)))
        .getSingle();

    await (update(syncQueue)..where((op) => op.id.equals(operationId))).write(
      SyncQueueCompanion(
        attempts: Value(operation.attempts + 1),
        lastAttempt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete completed sync operations
  Future<int> deleteCompletedSyncOperations() async {
    return await (delete(syncQueue)
          ..where((op) => op.status.equals('completed')))
        .go();
  }

  /// Clear failed sync operations older than specified days
  Future<int> clearOldFailedOperations({int days = 7}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return await (delete(syncQueue)
          ..where((op) =>
              op.status.equals('failed') &
              op.createdAt.isSmallerThanValue(cutoffDate)))
        .go();
  }

  // ============================================
  // Cart Backup Operations
  // ============================================

  /// Save cart backup
  Future<int> saveCartBackup({
    required String itemsJson,
    String? customerJson,
    String? discountJson,
    String? notesJson,
  }) async {
    // Delete old backups first (keep only latest)
    await delete(cartBackup).go();

    // Insert new backup
    return await into(cartBackup).insert(
      CartBackupCompanion.insert(
        itemsJson: itemsJson,
        customerJson: Value(customerJson),
        discountJson: Value(discountJson),
        notesJson: Value(notesJson),
        savedAt: DateTime.now(),
      ),
    );
  }

  /// Get latest cart backup
  Future<CartBackupData?> getLatestCartBackup() async {
    final results = await (select(cartBackup)
          ..orderBy([(backup) => OrderingTerm.desc(backup.savedAt)])
          ..limit(1))
        .get();

    return results.isEmpty ? null : results.first;
  }

  /// Clear cart backup
  Future<int> clearCartBackup() async {
    return await delete(cartBackup).go();
  }

  // ============================================
  // Database Maintenance
  // ============================================

  /// Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final ordersCount = await _getTableCount(offlineOrders);
    final itemsCount = await _getTableCount(offlineOrderItems);
    final syncQueueCount = await _getTableCount(syncQueue);
    final cartBackupCount = await _getTableCount(cartBackup);

    return {
      'orders': ordersCount,
      'items': itemsCount,
      'sync_queue': syncQueueCount,
      'cart_backups': cartBackupCount,
    };
  }

  Future<int> _getTableCount<T extends Table>(TableInfo<T, dynamic> table) async {
    final query = selectOnly(table)..addColumns([table.$columns.first.count()]);
    final result = await query.getSingle();
    return result.read(table.$columns.first.count()) ?? 0;
  }

  /// Clear all data (for testing/debugging)
  Future<void> clearAllData() async {
    await delete(offlineOrders).go();
    await delete(offlineOrderItems).go();
    await delete(syncQueue).go();
    await delete(cartBackup).go();
  }
}

/// Open database connection
QueryExecutor _openConnection() {
  return driftDatabase(name: 'pos_register_local');
}
