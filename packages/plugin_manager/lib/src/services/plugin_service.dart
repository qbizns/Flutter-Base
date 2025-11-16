import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/marketplace_plugin.dart';

class PluginService {
  final Dio _dio;
  final Logger _logger;
  final String _baseUrl;

  PluginService({
    required Dio dio,
    required Logger logger,
    required String baseUrl,
  })  : _dio = dio,
        _logger = logger,
        _baseUrl = baseUrl;

  // ==========================================================================
  // Marketplace Plugins
  // ==========================================================================

  /// Get all marketplace plugins
  Future<List<MarketplacePlugin>> getMarketplacePlugins({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/marketplace/plugins',
        queryParameters: {
          if (category != null) 'category': category,
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List;

      return items
          .map((json) => MarketplacePlugin.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Failed to fetch marketplace plugins', error: e);
      rethrow;
    }
  }

  /// Get a single marketplace plugin by ID
  Future<MarketplacePlugin> getMarketplacePlugin(String pluginId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/marketplace/plugins/$pluginId',
      );

      return MarketplacePlugin.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Failed to fetch marketplace plugin', error: e);
      rethrow;
    }
  }

  // ==========================================================================
  // Organization Plugins (Installed)
  // ==========================================================================

  /// Get all installed plugins for an organization
  Future<List<OrganizationPlugin>> getInstalledPlugins(
    String organizationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/organizations/$organizationId/plugins',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List;

      return items
          .map((json) => OrganizationPlugin.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Failed to fetch installed plugins', error: e);
      rethrow;
    }
  }

  /// Get a single installed plugin
  Future<OrganizationPlugin> getInstalledPlugin(
    String organizationId,
    String pluginId,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/organizations/$organizationId/plugins/$pluginId',
      );

      return OrganizationPlugin.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Failed to fetch installed plugin', error: e);
      rethrow;
    }
  }

  /// Install a plugin for an organization
  Future<OrganizationPlugin> installPlugin(
    String organizationId,
    String pluginKey, {
    Map<String, dynamic>? config,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/organizations/$organizationId/plugins',
        data: {
          'plugin_key': pluginKey,
          if (config != null) 'config': config,
        },
      );

      _logger.i('Plugin installed successfully: $pluginKey');

      return OrganizationPlugin.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Failed to install plugin', error: e);
      rethrow;
    }
  }

  /// Update plugin configuration
  Future<OrganizationPlugin> updatePluginConfig(
    String organizationId,
    String pluginId, {
    Map<String, dynamic>? config,
    bool? isEnabled,
  }) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/organizations/$organizationId/plugins/$pluginId',
        data: {
          if (config != null) 'config': config,
          if (isEnabled != null) 'is_enabled': isEnabled,
        },
      );

      _logger.i('Plugin config updated successfully');

      return OrganizationPlugin.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Failed to update plugin config', error: e);
      rethrow;
    }
  }

  /// Uninstall a plugin
  Future<void> uninstallPlugin(
    String organizationId,
    String pluginId,
  ) async {
    try {
      await _dio.delete(
        '$_baseUrl/organizations/$organizationId/plugins/$pluginId',
      );

      _logger.i('Plugin uninstalled successfully');
    } catch (e) {
      _logger.e('Failed to uninstall plugin', error: e);
      rethrow;
    }
  }

  // ==========================================================================
  // Plugin Execution
  // ==========================================================================

  /// Execute a plugin action
  Future<Map<String, dynamic>> executePlugin(
    String organizationId,
    String pluginKey,
    String action,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/organizations/$organizationId/plugins/$pluginKey/execute',
        data: {
          'action': action,
          'data': data,
        },
      );

      _logger.d('Plugin executed: $pluginKey.$action');

      return response.data as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Failed to execute plugin', error: e);
      rethrow;
    }
  }

  // ==========================================================================
  // Helper Methods
  // ==========================================================================

  /// Check if a plugin is installed and active
  Future<bool> isPluginActive(
    String organizationId,
    String pluginKey,
  ) async {
    try {
      final plugins = await getInstalledPlugins(organizationId);

      return plugins.any(
        (p) =>
            p.plugin.pluginKey == pluginKey &&
            p.isEnabled &&
            p.status == 'active',
      );
    } catch (e) {
      _logger.e('Failed to check plugin status', error: e);
      return false;
    }
  }

  /// Get plugin configuration
  Future<Map<String, dynamic>> getPluginConfig(
    String organizationId,
    String pluginKey,
  ) async {
    try {
      final plugins = await getInstalledPlugins(organizationId);

      final plugin = plugins.firstWhere(
        (p) => p.plugin.pluginKey == pluginKey,
        orElse: () => throw Exception('Plugin not installed'),
      );

      return plugin.config;
    } catch (e) {
      _logger.e('Failed to get plugin config', error: e);
      rethrow;
    }
  }
}
