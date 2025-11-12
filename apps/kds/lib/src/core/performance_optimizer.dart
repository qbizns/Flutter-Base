/// Performance Optimizer
/// Utilities for optimizing real-time updates and rendering
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Debouncer
/// Delays execution until no more calls are made within the duration
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({required this.duration});

  /// Run action after debounce period
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler
/// Limits execution to once per duration
class Throttler {
  final Duration duration;
  Timer? _timer;
  bool _isThrottled = false;

  Throttler({required this.duration});

  /// Run action if not throttled
  void run(VoidCallback action) {
    if (!_isThrottled) {
      action();
      _isThrottled = true;
      _timer = Timer(duration, () {
        _isThrottled = false;
      });
    }
  }

  /// Check if currently throttled
  bool get isThrottled => _isThrottled;

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
  }
}

/// Batch Processor
/// Batches multiple operations into a single execution
class BatchProcessor<T> {
  final Duration batchWindow;
  final Future<void> Function(List<T> items) processor;

  final List<T> _pendingItems = [];
  Timer? _batchTimer;
  bool _isProcessing = false;

  BatchProcessor({
    required this.batchWindow,
    required this.processor,
  });

  /// Add item to batch
  void add(T item) {
    _pendingItems.add(item);

    // Start batch timer if not already running
    if (_batchTimer == null || !_batchTimer!.isActive) {
      _batchTimer = Timer(batchWindow, _processBatch);
    }
  }

  /// Process batch immediately
  Future<void> flush() async {
    _batchTimer?.cancel();
    await _processBatch();
  }

  Future<void> _processBatch() async {
    if (_isProcessing || _pendingItems.isEmpty) return;

    _isProcessing = true;
    final items = List<T>.from(_pendingItems);
    _pendingItems.clear();

    try {
      await processor(items);
    } catch (error) {
      debugPrint('Batch processing error: $error');
    } finally {
      _isProcessing = false;
    }
  }

  /// Get pending item count
  int get pendingCount => _pendingItems.length;

  /// Dispose resources
  void dispose() {
    _batchTimer?.cancel();
    _pendingItems.clear();
  }
}

/// Stream Optimizer
/// Optimizes stream subscriptions with throttling and debouncing
class StreamOptimizer<T> {
  final Stream<T> source;
  final Duration? throttleDuration;
  final Duration? debounceDuration;

  StreamOptimizer(
    this.source, {
    this.throttleDuration,
    this.debounceDuration,
  });

  /// Get optimized stream
  Stream<T> get stream {
    var result = source;

    if (throttleDuration != null) {
      result = _throttleStream(result, throttleDuration!);
    }

    if (debounceDuration != null) {
      result = _debounceStream(result, debounceDuration!);
    }

    return result;
  }

  Stream<T> _throttleStream(Stream<T> stream, Duration duration) {
    return stream.transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) {
          final throttler = Throttler(duration: duration);
          throttler.run(() => sink.add(data));
        },
      ),
    );
  }

  Stream<T> _debounceStream(Stream<T> stream, Duration duration) {
    return stream.transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) {
          final debouncer = Debouncer(duration: duration);
          debouncer.run(() => sink.add(data));
        },
      ),
    );
  }
}

/// Update Aggregator
/// Aggregates multiple updates into a single update
class UpdateAggregator<K, V> {
  final Duration aggregationWindow;
  final Future<void> Function(Map<K, V> updates) processor;

  final Map<K, V> _pendingUpdates = {};
  Timer? _timer;
  bool _isProcessing = false;

  UpdateAggregator({
    required this.aggregationWindow,
    required this.processor,
  });

  /// Add or update item
  void update(K key, V value) {
    _pendingUpdates[key] = value;

    // Start timer if not running
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer(aggregationWindow, _processUpdates);
    }
  }

  /// Process updates immediately
  Future<void> flush() async {
    _timer?.cancel();
    await _processUpdates();
  }

  Future<void> _processUpdates() async {
    if (_isProcessing || _pendingUpdates.isEmpty) return;

    _isProcessing = true;
    final updates = Map<K, V>.from(_pendingUpdates);
    _pendingUpdates.clear();

    try {
      await processor(updates);
    } catch (error) {
      debugPrint('Update processing error: $error');
    } finally {
      _isProcessing = false;
    }
  }

  /// Get pending update count
  int get pendingCount => _pendingUpdates.length;

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _pendingUpdates.clear();
  }
}

/// Frame Rate Limiter
/// Limits updates to target frame rate
class FrameRateLimiter {
  final int targetFps;
  DateTime? _lastFrame;

  FrameRateLimiter({this.targetFps = 60});

  /// Check if should render new frame
  bool shouldRender() {
    final now = DateTime.now();

    if (_lastFrame == null) {
      _lastFrame = now;
      return true;
    }

    final elapsed = now.difference(_lastFrame!);
    final targetDuration = Duration(milliseconds: 1000 ~/ targetFps);

    if (elapsed >= targetDuration) {
      _lastFrame = now;
      return true;
    }

    return false;
  }

  /// Reset limiter
  void reset() {
    _lastFrame = null;
  }
}

/// Memory Pool
/// Reuses objects to reduce allocations
class MemoryPool<T> {
  final T Function() creator;
  final void Function(T)? resetter;
  final int maxSize;

  final List<T> _available = [];
  final Set<T> _inUse = {};

  MemoryPool({
    required this.creator,
    this.resetter,
    this.maxSize = 100,
  });

  /// Acquire object from pool
  T acquire() {
    T object;

    if (_available.isNotEmpty) {
      object = _available.removeLast();
    } else {
      object = creator();
    }

    _inUse.add(object);
    return object;
  }

  /// Release object back to pool
  void release(T object) {
    if (!_inUse.remove(object)) return;

    resetter?.call(object);

    if (_available.length < maxSize) {
      _available.add(object);
    }
  }

  /// Release all objects
  void releaseAll() {
    for (final object in _inUse.toList()) {
      release(object);
    }
  }

  /// Clear pool
  void clear() {
    _available.clear();
    _inUse.clear();
  }

  /// Get pool stats
  PoolStats get stats => PoolStats(
        available: _available.length,
        inUse: _inUse.length,
        total: _available.length + _inUse.length,
      );
}

/// Pool Statistics
class PoolStats {
  final int available;
  final int inUse;
  final int total;

  const PoolStats({
    required this.available,
    required this.inUse,
    required this.total,
  });

  double get utilizationPercent => total > 0 ? (inUse / total * 100) : 0;

  @override
  String toString() {
    return 'PoolStats(available: $available, inUse: $inUse, '
        'total: $total, utilization: ${utilizationPercent.toStringAsFixed(1)}%)';
  }
}

/// Performance Monitor
/// Monitors and logs performance metrics
class PerformanceMonitor {
  final String name;
  final Stopwatch _stopwatch = Stopwatch();
  final List<Duration> _measurements = [];

  PerformanceMonitor(this.name);

  /// Start measuring
  void start() {
    _stopwatch.reset();
    _stopwatch.start();
  }

  /// Stop measuring and record
  Duration stop() {
    _stopwatch.stop();
    final duration = _stopwatch.elapsed;
    _measurements.add(duration);
    return duration;
  }

  /// Get average duration
  Duration get averageDuration {
    if (_measurements.isEmpty) return Duration.zero;

    final total = _measurements.fold<int>(
      0,
      (sum, duration) => sum + duration.inMicroseconds,
    );

    return Duration(microseconds: total ~/ _measurements.length);
  }

  /// Get min/max durations
  Duration get minDuration => _measurements.isEmpty
      ? Duration.zero
      : _measurements.reduce((a, b) => a < b ? a : b);

  Duration get maxDuration => _measurements.isEmpty
      ? Duration.zero
      : _measurements.reduce((a, b) => a > b ? a : b);

  /// Get measurement count
  int get measurementCount => _measurements.length;

  /// Print stats
  void printStats() {
    debugPrint('=== Performance Stats: $name ===');
    debugPrint('Measurements: $measurementCount');
    debugPrint('Average: ${averageDuration.inMilliseconds}ms');
    debugPrint('Min: ${minDuration.inMilliseconds}ms');
    debugPrint('Max: ${maxDuration.inMilliseconds}ms');
  }

  /// Clear measurements
  void clear() {
    _measurements.clear();
  }
}

/// Caching Utility
/// Simple cache with expiration
class CacheManager<K, V> {
  final Duration defaultExpiration;
  final Map<K, _CacheEntry<V>> _cache = {};

  CacheManager({
    this.defaultExpiration = const Duration(minutes: 5),
  });

  /// Get value from cache
  V? get(K key) {
    final entry = _cache[key];

    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  /// Put value in cache
  void put(K key, V value, {Duration? expiration}) {
    _cache[key] = _CacheEntry(
      value: value,
      expiration: expiration ?? defaultExpiration,
    );
  }

  /// Check if key exists and is valid
  bool contains(K key) {
    return get(key) != null;
  }

  /// Remove key from cache
  void remove(K key) {
    _cache.remove(key);
  }

  /// Clear entire cache
  void clear() {
    _cache.clear();
  }

  /// Get cache size
  int get size => _cache.length;

  /// Clean expired entries
  void cleanExpired() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }
}

class _CacheEntry<V> {
  final V value;
  final DateTime expiresAt;

  _CacheEntry({
    required this.value,
    required Duration expiration,
  }) : expiresAt = DateTime.now().add(expiration);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
