# Offline Support Documentation

## Overview

The POS Register app includes comprehensive offline support, allowing the system to continue operating even when the internet connection is unavailable. Orders are saved locally and automatically synchronized with the backend when connectivity is restored.

## Architecture

### Components

1. **LocalDatabase** (`lib/src/data/database/local_database.dart`)
   - SQLite database using Drift ORM
   - Stores offline orders, order items, sync queue, and cart backups
   - Provides CRUD operations for all offline data

2. **SyncService** (`lib/src/data/services/sync_service.dart`)
   - Manages background synchronization
   - Monitors connectivity status
   - Handles sync queue processing
   - Implements retry logic with exponential backoff

3. **SyncStatusIndicator** (`lib/src/features/sync/presentation/widgets/sync_status_indicator.dart`)
   - UI widget showing online/offline status
   - Displays pending sync operations count
   - Allows manual sync trigger

## Database Schema

### OfflineOrders Table
Stores complete order information when offline:
- Order details (number, status, totals)
- Customer and table information
- Payment lines (JSON)
- Sync tracking (attempts, errors, timestamps)

### OfflineOrderItems Table
Stores individual order items:
- Product information
- Pricing and quantities
- Modifiers (JSON)
- Line-level notes

### SyncQueue Table
Tracks operations that need to be synchronized:
- Operation type (create_order, update_order, cash_movement)
- Entity information
- Payload (JSON)
- Status and retry tracking
- Priority levels (1=highest, 10=lowest)

### CartBackup Table
Crash recovery for in-progress carts:
- Cart items (JSON)
- Customer data
- Discount information
- Order notes

## Features

### Automatic Connectivity Detection
- Uses `connectivity_plus` to monitor network status
- Automatically switches between online/offline modes
- Updates UI indicators in real-time

### Background Sync
- Periodic sync every 30 seconds
- Automatic sync when connectivity is restored
- Manual sync trigger available
- Processes sync queue in priority order

### Retry Logic
- Automatic retry for failed operations
- Exponential backoff to prevent server overload
- Maximum 5 retry attempts per operation
- Failed operations marked after max attempts

### Sync Status Indicators
Three types of indicators:

1. **Inline Indicator** - Shows in app bar
   - Online/Offline status
   - Sync progress
   - Pending operations count

2. **Floating Button** - Shows when offline or pending sync
   - Prominent warning when offline
   - Shows pending operations count
   - Tap to view details

3. **Details Dialog** - Full sync information
   - Connection status
   - Last sync time
   - Pending operations
   - Error messages
   - Manual sync button

## Usage

### Setup

1. **Dependencies** (already added to `pubspec.yaml`):
```yaml
dependencies:
  drift: ^2.14.0
  drift_flutter: ^0.1.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  connectivity_plus: ^5.0.0

dev_dependencies:
  drift_dev: ^2.14.0
```

2. **Generate Drift Code**:
```bash
flutter pub get
flutter pub run build_runner build
```

### Saving Orders Offline

The payment page automatically saves orders offline when processing:

```dart
final syncService = ref.read(syncServiceProvider);

final orderId = await syncService.saveOrderOffline(
  orderNumber: 'ORD-123456',
  sessionId: 'session-id',
  cashierId: 'cashier-id',
  cashierName: 'John Doe',
  items: cartItems,
  paymentLines: paymentData,
  customerId: 'customer-id', // optional
  customerName: 'Jane Smith', // optional
  tableId: 'table-1', // optional
  tableName: 'Table 1', // optional
  notes: 'Special instructions', // optional
);
```

### Monitoring Sync Status

Watch sync state in widgets:

```dart
final syncStateAsync = ref.watch(syncStateProvider);

syncStateAsync.when(
  data: (syncState) {
    if (!syncState.isOnline) {
      // Handle offline mode
    }
    if (syncState.pendingOperations > 0) {
      // Show pending sync indicator
    }
  },
  loading: () => CircularProgressIndicator(),
  error: (_, __) => ErrorWidget(),
);
```

### Manual Sync Trigger

```dart
final syncService = ref.read(syncServiceProvider);
await syncService.forceSyncNow();
```

### Getting Pending Operations Count

```dart
final pendingCount = await ref.read(pendingOperationsCountProvider.future);
```

## Sync Flow

### Order Creation Flow

1. **User completes payment**
   - Payment page validates payment
   - Order data is prepared

2. **Save to local database**
   - Order saved to `OfflineOrders` table
   - Items saved to `OfflineOrderItems` table
   - Status set to `pending_sync`

3. **Queue for sync**
   - Operation added to `SyncQueue`
   - Priority set (1=high for orders)
   - Immediate sync triggered if online

4. **Background sync processes queue**
   - Connectivity checked
   - Operations processed by priority
   - API calls made to backend

5. **Success handling**
   - Order status updated to `synced`
   - Queue entry marked `completed`
   - Completed entries periodically cleaned up

6. **Failure handling**
   - Retry counter incremented
   - Error message stored
   - Operation retried on next sync cycle
   - After 5 failures, marked as `failed`

### Sync Queue Processing

The sync service processes operations in this order:

1. Check connectivity (skip if offline)
2. Get pending operations (ordered by priority)
3. For each operation:
   - Process based on operation type
   - Update status on success
   - Increment retry count on failure
   - Mark as failed after 5 attempts
4. Clean up completed operations
5. Update UI with results

## Sync Status States

| State | Description | Color | Icon |
|-------|-------------|-------|------|
| `idle` | Online, no pending sync | Gray | cloud_done |
| `syncing` | Sync in progress | Blue | cloud_sync |
| `success` | Last sync successful | Green | cloud_done |
| `error` | Sync errors occurred | Yellow | cloud_off |
| `offline` | No connectivity | Red | cloud_off |

## Maintenance

### Database Statistics

Get database stats:

```dart
final database = ref.read(localDatabaseProvider);
final stats = await database.getDatabaseStats();
// Returns: {
//   'orders': 10,
//   'items': 45,
//   'sync_queue': 3,
//   'cart_backups': 1,
// }
```

### Clean Up Old Failed Operations

Remove failed operations older than 7 days:

```dart
final syncService = ref.read(syncServiceProvider);
await syncService.clearOldFailedOperations(days: 7);
```

### Clear All Data (Testing/Debugging)

```dart
final database = ref.read(localDatabaseProvider);
await database.clearAllData();
```

## Testing Offline Mode

### Simulate Offline Mode

1. **Airplane Mode**: Enable airplane mode on device
2. **Network Throttling**: Use Chrome DevTools network throttling
3. **Backend Down**: Stop the backend server

### Test Scenarios

1. **Order While Offline**
   - Disable network
   - Create and complete an order
   - Verify order saved locally
   - Verify sync indicator shows offline
   - Re-enable network
   - Verify auto-sync occurs
   - Verify order appears in backend

2. **Sync Failure Recovery**
   - Create order while online
   - Stop backend server (simulate failure)
   - Wait for sync attempt
   - Verify retry logic
   - Restart backend
   - Verify successful sync

3. **Pending Operations Display**
   - Create multiple orders while offline
   - Verify pending count in indicator
   - Re-enable network
   - Watch pending count decrease as orders sync

## Best Practices

### 1. Always Check Sync State
```dart
final syncState = ref.watch(syncServiceProvider).currentState;
if (!syncState.isOnline) {
  // Show offline warning
}
```

### 2. Handle Offline Gracefully
```dart
try {
  await syncService.saveOrderOffline(...);
  // Show success with offline indicator
} catch (e) {
  // Show error, allow retry
}
```

### 3. Inform Users
- Show clear offline indicators
- Display pending sync count
- Allow manual sync trigger
- Show sync errors with details

### 4. Monitor Failed Operations
- Periodically check failed operations
- Investigate recurring failures
- Clean up old failed operations

## Limitations

1. **No Real-Time Updates**: Changes made on other devices won't sync to offline devices
2. **Conflict Resolution**: Simple last-write-wins strategy (can be enhanced)
3. **Storage Limits**: SQLite database size limited by device storage
4. **Sync Performance**: Large pending queues may take time to process

## Future Enhancements

1. **Smart Conflict Resolution**
   - Detect conflicts between local and server data
   - Merge strategies for different entity types
   - User-selectable conflict resolution

2. **Incremental Sync**
   - Only sync changed data
   - Reduce bandwidth usage
   - Faster sync times

3. **Priority Sync**
   - Critical operations synced first
   - Background operations queued lower
   - User-initiated operations prioritized

4. **Compression**
   - Compress large payloads
   - Reduce data transfer
   - Faster sync on slow connections

5. **Delta Sync**
   - Only send changes, not full records
   - Reduce payload size
   - Improve sync efficiency

## Troubleshooting

### Sync Not Working
1. Check connectivity indicator
2. Verify backend is running
3. Check for failed operations in sync queue
4. Review error messages in sync details dialog

### Orders Not Syncing
1. Check `OfflineOrders` table status
2. Verify order in sync queue
3. Check retry count and errors
4. Try manual sync

### Database Issues
1. Check database file exists
2. Verify schema version
3. Try clearing cache
4. Rebuild database if corrupted

## Support

For issues or questions:
1. Check error logs in sync details dialog
2. Review database statistics
3. Check failed operations
4. Review backend API logs
5. Contact development team with details

## Conclusion

The offline support system provides a robust foundation for the POS Register app to operate seamlessly regardless of network conditions. Orders are never lost, and the system automatically recovers when connectivity is restored.
