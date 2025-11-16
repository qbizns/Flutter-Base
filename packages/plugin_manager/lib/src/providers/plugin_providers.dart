import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/marketplace_plugin.dart';
import '../services/plugin_service.dart';

// =============================================================================
// Dependencies (these would come from your main app)
// =============================================================================

// Note: In your actual app, you should provide these from your main app configuration
// For example:
// final dioProvider = Provider<Dio>((ref) => ref.watch(networkModuleProvider).dio);
// final apiBaseUrlProvider = Provider<String>((ref) => ref.watch(configProvider).apiBaseUrl);
// final currentOrganizationIdProvider = Provider<String>((ref) => ref.watch(authProvider).organizationId);

// =============================================================================
// Plugin Service Provider
// =============================================================================

final pluginServiceProvider = Provider<PluginService>((ref) {
  // TODO: Wire up with your actual app providers
  final dio = Dio(); // ref.watch(dioProvider);
  final logger = Logger();
  final baseUrl = ''; // ref.watch(apiBaseUrlProvider);

  return PluginService(
    dio: dio,
    logger: logger,
    baseUrl: baseUrl,
  );
});

// =============================================================================
// Marketplace Plugins Providers
// =============================================================================

/// Get all marketplace plugins (optionally filtered by category)
final marketplacePluginsProvider = FutureProvider.autoDispose
    .family<List<MarketplacePlugin>, String?>((ref, category) async {
  final service = ref.watch(pluginServiceProvider);
  return service.getMarketplacePlugins(category: category);
});

/// Get a specific marketplace plugin by ID
final marketplacePluginProvider = FutureProvider.autoDispose
    .family<MarketplacePlugin, String>((ref, pluginId) async {
  final service = ref.watch(pluginServiceProvider);
  return service.getMarketplacePlugin(pluginId);
});

// =============================================================================
// Installed Plugins Providers
// =============================================================================

/// Get all installed plugins for current organization
final installedPluginsProvider =
    FutureProvider.autoDispose<List<OrganizationPlugin>>((ref) async {
  final service = ref.watch(pluginServiceProvider);
  // TODO: Get orgId from your auth provider
  final orgId = ''; // ref.watch(currentOrganizationIdProvider);
  return service.getInstalledPlugins(orgId);
});

/// Get a specific installed plugin
final installedPluginProvider = FutureProvider.autoDispose
    .family<OrganizationPlugin, String>((ref, pluginId) async {
  final service = ref.watch(pluginServiceProvider);
  // TODO: Get orgId from your auth provider
  final orgId = ''; // ref.watch(currentOrganizationIdProvider);
  return service.getInstalledPlugin(orgId, pluginId);
});

/// Check if a specific plugin is active
final isPluginActiveProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, pluginKey) async {
  final service = ref.watch(pluginServiceProvider);
  // TODO: Get orgId from your auth provider
  final orgId = ''; // ref.watch(currentOrganizationIdProvider);
  return service.isPluginActive(orgId, pluginKey);
});

// =============================================================================
// Plugin Actions (State Notifiers)
// =============================================================================

/// Controller for installing plugins
final installPluginProvider =
    StateNotifierProvider<InstallPluginController, AsyncValue<OrganizationPlugin?>>((ref) {
  final service = ref.watch(pluginServiceProvider);
  // TODO: Get orgId from your auth provider
  final orgId = ''; // ref.watch(currentOrganizationIdProvider);
  return InstallPluginController(service, orgId);
});

class InstallPluginController extends StateNotifier<AsyncValue<OrganizationPlugin?>> {
  final PluginService _service;
  final String _organizationId;

  InstallPluginController(this._service, this._organizationId)
      : super(const AsyncValue.data(null));

  Future<void> install(
    String pluginKey, {
    Map<String, dynamic>? config,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _service.installPlugin(
        _organizationId,
        pluginKey,
        config: config,
      );
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Controller for uninstalling plugins
final uninstallPluginProvider =
    StateNotifierProvider<UninstallPluginController, AsyncValue<bool>>((ref) {
  final service = ref.watch(pluginServiceProvider);
  // TODO: Get orgId from your auth provider
  final orgId = ''; // ref.watch(currentOrganizationIdProvider);
  return UninstallPluginController(service, orgId);
});

class UninstallPluginController extends StateNotifier<AsyncValue<bool>> {
  final PluginService _service;
  final String _organizationId;

  UninstallPluginController(this._service, this._organizationId)
      : super(const AsyncValue.data(false));

  Future<void> uninstall(String pluginId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.uninstallPlugin(_organizationId, pluginId);
      return true;
    });
  }

  void reset() {
    state = const AsyncValue.data(false);
  }
}

// =============================================================================
// Plugin Executor
// =============================================================================

/// Executor for running plugin actions
final pluginExecutorProvider = Provider<PluginExecutor>((ref) {
  final service = ref.watch(pluginServiceProvider);
  // TODO: Get orgId from your auth provider
  final orgId = ''; // ref.watch(currentOrganizationIdProvider);
  return PluginExecutor(service, orgId);
});

class PluginExecutor {
  final PluginService _service;
  final String _organizationId;

  PluginExecutor(this._service, this._organizationId);

  /// Execute a plugin action with typed result
  Future<T?> execute<T>({
    required String pluginKey,
    required String action,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    final result = await _service.executePlugin(
      _organizationId,
      pluginKey,
      action,
      data,
    );

    if (result['success'] == true && result['data'] != null) {
      return parser(result['data'] as Map<String, dynamic>);
    }

    return null;
  }

  /// Execute a plugin action with raw result
  Future<Map<String, dynamic>> executeRaw({
    required String pluginKey,
    required String action,
    required Map<String, dynamic> data,
  }) async {
    return await _service.executePlugin(
      _organizationId,
      pluginKey,
      action,
      data,
    );
  }
}
