/// Cache Strategy Service
/// Implements smart cache refresh strategy with age-based logic (Odoo pattern)
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/local_database.dart';
import 'connectivity_service.dart';

/// Cache refresh strategy
enum CacheRefreshStrategy {
  /// Immediate refresh (ignore cache)
  immediate,

  /// Refresh if stale (default: 24h)
  ifStale,

  /// Refresh if expired (default: 7 days)
  ifExpired,

  /// Never refresh (use cache only)
  never,
}

/// Cache status
enum CacheStatus {
  /// Cache is fresh and valid
  fresh,

  /// Cache is stale (past soft limit, should refresh)
  stale,

  /// Cache is expired (past hard limit, must refresh)
  expired,

  /// No cache exists
  missing,
}

/// Smart cache strategy service (Odoo pattern)
/// Manages cache lifecycle with age-based refresh logic
class CacheStrategyService {
  final LocalDatabase _database;
  final ConnectivityService _connectivity;

  // Cache age thresholds
  final Duration staleDuration;
  final Duration expiredDuration;

  // Background refresh timer
  Timer? _refreshTimer;

  CacheStrategyService({
    required LocalDatabase database,
    required ConnectivityService connectivity,
    this.staleDuration = const Duration(hours: 24),
    this.expiredDuration = const Duration(days: 7),
  })  : _database = database,
        _connectivity = connectivity {
    _startBackgroundRefresh();
  }

  /// Get cache status for a specific cache key
  Future<CacheStatus> getCacheStatus(String cacheKey) async {
    final metadata = await _database.getCacheMetadata(cacheKey);

    if (metadata == null) {
      return CacheStatus.missing;
    }

    final age = DateTime.now().difference(metadata.lastRefresh);

    if (age > expiredDuration) {
      return CacheStatus.expired;
    } else if (age > staleDuration) {
      return CacheStatus.stale;
    } else {
      return CacheStatus.fresh;
    }
  }

  /// Check if cache should be refreshed based on strategy
  Future<bool> shouldRefresh(
    String cacheKey,
    CacheRefreshStrategy strategy,
  ) async {
    switch (strategy) {
      case CacheRefreshStrategy.immediate:
        return true;

      case CacheRefreshStrategy.ifStale:
        final status = await getCacheStatus(cacheKey);
        return status == CacheStatus.stale ||
            status == CacheStatus.expired ||
            status == CacheStatus.missing;

      case CacheRefreshStrategy.ifExpired:
        final status = await getCacheStatus(cacheKey);
        return status == CacheStatus.expired ||
            status == CacheStatus.missing;

      case CacheRefreshStrategy.never:
        return false;
    }
  }

  /// Get all cache statuses
  Future<Map<String, CacheStatus>> getAllCacheStatuses() async {
    final cacheKeys = [
      'products',
      'categories',
      'customers',
      'payment_methods',
      'tax_rates',
    ];

    final statuses = <String, CacheStatus>{};

    for (final key in cacheKeys) {
      statuses[key] = await getCacheStatus(key);
    }

    return statuses;
  }

  /// Start background refresh for stale caches (when online)
  void _startBackgroundRefresh() {
    // Check every 5 minutes
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performBackgroundRefresh(),
    );
  }

  /// Perform background refresh for stale caches
  Future<void> _performBackgroundRefresh() async {
    // Only refresh when online
    if (!_connectivity.isOnline) {
      return;
    }

    final statuses = await getAllCacheStatuses();

    // Find stale caches
    final staleCaches = statuses.entries
        .where((entry) =>
            entry.value == CacheStatus.stale ||
            entry.value == CacheStatus.expired)
        .map((entry) => entry.key)
        .toList();

    if (staleCaches.isEmpty) {
      return;
    }

    // Mark as stale in database (triggers refresh on next access)
    for (final cacheKey in staleCaches) {
      await _database.markCacheStale(cacheKey);
    }

    print('Background refresh: marked ${staleCaches.length} caches as stale');
  }

  /// Force refresh all caches
  Future<void> forceRefreshAll() async {
    final cacheKeys = [
      'products',
      'categories',
      'customers',
      'payment_methods',
      'tax_rates',
    ];

    for (final key in cacheKeys) {
      await _database.markCacheStale(key);
    }
  }

  /// Get cache statistics
  Future<CacheStatistics> getCacheStatistics() async {
    final statuses = await getAllCacheStatuses();

    int freshCount = 0;
    int staleCount = 0;
    int expiredCount = 0;
    int missingCount = 0;

    for (final status in statuses.values) {
      switch (status) {
        case CacheStatus.fresh:
          freshCount++;
          break;
        case CacheStatus.stale:
          staleCount++;
          break;
        case CacheStatus.expired:
          expiredCount++;
          break;
        case CacheStatus.missing:
          missingCount++;
          break;
      }
    }

    return CacheStatistics(
      totalCaches: statuses.length,
      freshCount: freshCount,
      staleCount: staleCount,
      expiredCount: expiredCount,
      missingCount: missingCount,
    );
  }

  /// Get cache age for a specific cache key
  Future<Duration?> getCacheAge(String cacheKey) async {
    final metadata = await _database.getCacheMetadata(cacheKey);
    if (metadata == null) return null;

    return DateTime.now().difference(metadata.lastRefresh);
  }

  /// Get cache item count for a specific cache key
  Future<int?> getCacheItemCount(String cacheKey) async {
    final metadata = await _database.getCacheMetadata(cacheKey);
    return metadata?.itemCount;
  }

  /// Dispose resources
  void dispose() {
    _refreshTimer?.cancel();
  }
}

/// Cache statistics
class CacheStatistics {
  final int totalCaches;
  final int freshCount;
  final int staleCount;
  final int expiredCount;
  final int missingCount;

  CacheStatistics({
    required this.totalCaches,
    required this.freshCount,
    required this.staleCount,
    required this.expiredCount,
    required this.missingCount,
  });

  int get healthyCaches => freshCount;
  int get needsRefresh => staleCount + expiredCount + missingCount;

  double get healthPercentage =>
      totalCaches > 0 ? (healthyCaches / totalCaches) * 100 : 0;

  String get summary =>
      '$healthyCaches/$totalCaches caches fresh (${healthPercentage.toStringAsFixed(0)}%)';
}

/// Provider for cache strategy service
final cacheStrategyServiceProvider = Provider<CacheStrategyService>((ref) {
  final database = ref.watch(localDatabaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);

  final service = CacheStrategyService(
    database: database,
    connectivity: connectivity,
    staleDuration: const Duration(hours: 24),
    expiredDuration: const Duration(days: 7),
  );

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for local database instance
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  final database = LocalDatabase();

  ref.onDispose(() {
    database.close();
  });

  return database;
});

/// Provider for cache statistics
final cacheStatisticsProvider = FutureProvider<CacheStatistics>((ref) async {
  final service = ref.watch(cacheStrategyServiceProvider);
  return service.getCacheStatistics();
});

/// Provider for all cache statuses
final allCacheStatusesProvider =
    FutureProvider<Map<String, CacheStatus>>((ref) async {
  final service = ref.watch(cacheStrategyServiceProvider);
  return service.getAllCacheStatuses();
});

/// Provider to check if a specific cache should be refreshed
final shouldRefreshCacheProvider =
    FutureProvider.family<bool, (String, CacheRefreshStrategy)>((
  ref,
  params,
) async {
  final service = ref.watch(cacheStrategyServiceProvider);
  final (cacheKey, strategy) = params;
  return service.shouldRefresh(cacheKey, strategy);
});
