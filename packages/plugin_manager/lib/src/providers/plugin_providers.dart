import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../models/marketplace_plugin.dart';
import '../services/plugin_service.dart';

// =============================================================================
// Configuration Providers
// =============================================================================

/// Provider for base API URL
/// Override this in your app:
/// ```dart
/// ProviderScope(
///   overrides: [
///     apiBaseUrlProvider.overrideWith((ref) => 'https://api.yourpos.com/api/v1'),
///   ],
/// )
/// ```
final apiBaseUrlProvider = Provider<String>((ref) {
  throw UnimplementedError('apiBaseUrlProvider must be overridden');
});

/// Provider for current organization ID
/// Override this in your app with the authenticated user's org
final currentOrganizationIdProvider = Provider<String>((ref) {
  throw UnimplementedError('currentOrganizationIdProvider must be overridden');
});

/// Provider for Dio HTTP client
/// Can be overridden to add auth interceptors
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors for logging, auth, etc.
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
});

/// Provider for Logger
final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );
});

// =============================================================================
// Service Providers
// =============================================================================

/// Plugin service provider
final pluginServiceProvider = Provider<PluginService>((ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  final baseUrl = ref.watch(apiBaseUrlProvider);

  return PluginService(
    dio: dio,
    logger: logger,
    baseUrl: baseUrl,
  );
});

// =============================================================================
// Data Providers
// =============================================================================

/// Marketplace plugins provider
/// Fetches all available plugins in the marketplace
///
/// Optional filters can be applied via [MarketplaceFilters]
final marketplacePluginsProvider = FutureProvider.autoDispose
    .family<List<MarketplacePlugin>, MarketplaceFilters?>((ref, filters) async {
  final service = ref.watch(pluginServiceProvider);

  return service.getMarketplacePlugins(
    category: filters?.category,
    search: filters?.search,
    minRating: filters?.minRating,
    isFeatured: filters?.isFeatured,
    isVerified: filters?.isVerified,
    limit: filters?.limit,
    offset: filters?.offset,
  );
});

/// Installed plugins provider
/// Fetches all plugins installed by the current organization
final installedPluginsProvider =
    FutureProvider.autoDispose<List<OrganizationPlugin>>((ref) async {
  final service = ref.watch(pluginServiceProvider);
  final orgId = ref.watch(currentOrganizationIdProvider);

  return service.getInstalledPlugins(orgId);
});

/// Plugin active check provider
/// Checks if a specific plugin is installed and active
final isPluginActiveProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, pluginKey) async {
  final service = ref.watch(pluginServiceProvider);
  final orgId = ref.watch(currentOrganizationIdProvider);

  return service.isPluginActive(orgId, pluginKey);
});

/// Get specific installed plugin provider
final installedPluginProvider = FutureProvider.autoDispose
    .family<OrganizationPlugin?, String>((ref, pluginKey) async {
  final service = ref.watch(pluginServiceProvider);
  final orgId = ref.watch(currentOrganizationIdProvider);

  return service.getInstalledPlugin(orgId, pluginKey);
});

// =============================================================================
// State Notifier Providers
// =============================================================================

/// Plugin executor state notifier
/// Manages plugin action execution
class PluginExecutor extends StateNotifier<AsyncValue<ExecutePluginResponse?>> {
  final PluginService _service;
  final String _organizationId;

  PluginExecutor(this._service, this._organizationId)
      : super(const AsyncValue.data(null));

  /// Execute a plugin action
  Future<ExecutePluginResponse?> execute({
    required String pluginKey,
    required String action,
    required Map<String, dynamic> data,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await _service.executePlugin(
        _organizationId,
        pluginKey,
        action,
        data,
      );

      state = AsyncValue.data(result);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Execute with type parsing
  Future<T?> executeTyped<T>({
    required String pluginKey,
    required String action,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    final result = await execute(
      pluginKey: pluginKey,
      action: action,
      data: data,
    );

    if (result != null && result.success && result.data != null) {
      return parser(result.data!);
    }

    return null;
  }

  /// Clear the current execution state
  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// Plugin executor provider
final pluginExecutorProvider =
    StateNotifierProvider<PluginExecutor, AsyncValue<ExecutePluginResponse?>>(
        (ref) {
  final service = ref.watch(pluginServiceProvider);
  final orgId = ref.watch(currentOrganizationIdProvider);

  return PluginExecutor(service, orgId);
});

// =============================================================================
// Helper Classes
// =============================================================================

/// Marketplace filters
class MarketplaceFilters {
  final String? category;
  final String? search;
  final double? minRating;
  final bool? isFeatured;
  final bool? isVerified;
  final int? limit;
  final int? offset;

  const MarketplaceFilters({
    this.category,
    this.search,
    this.minRating,
    this.isFeatured,
    this.isVerified,
    this.limit,
    this.offset,
  });

  MarketplaceFilters copyWith({
    String? category,
    String? search,
    double? minRating,
    bool? isFeatured,
    bool? isVerified,
    int? limit,
    int? offset,
  }) {
    return MarketplaceFilters(
      category: category ?? this.category,
      search: search ?? this.search,
      minRating: minRating ?? this.minRating,
      isFeatured: isFeatured ?? this.isFeatured,
      isVerified: isVerified ?? this.isVerified,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

/// Provider for marketplace filters (stateful)
final marketplaceFiltersProvider =
    StateProvider<MarketplaceFilters>((ref) => const MarketplaceFilters());
