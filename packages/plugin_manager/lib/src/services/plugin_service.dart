import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/marketplace_plugin.dart';

/// Service for managing plugins via API
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

  /// Get all marketplace plugins
  ///
  /// [category] - Filter by category (optional)
  /// [search] - Search query (optional)
  /// [minRating] - Minimum rating filter (optional)
  /// [isFeatured] - Filter featured plugins (optional)
  Future<List<MarketplacePlugin>> getMarketplacePlugins({
    String? category,
    String? search,
    double? minRating,
    bool? isFeatured,
    bool? isVerified,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (category != null) queryParams['category'] = category;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (minRating != null) queryParams['min_rating'] = minRating;
      if (isFeatured != null) queryParams['is_featured'] = isFeatured;
      if (isVerified != null) queryParams['is_verified'] = isVerified;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _dio.get(
        '$_baseUrl/marketplace/plugins',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => MarketplacePlugin.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch marketplace plugins: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Failed to fetch marketplace plugins', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error fetching marketplace plugins', error: e);
      rethrow;
    }
  }

  /// Get installed plugins for an organization
  ///
  /// [organizationId] - The organization ID
  Future<List<OrganizationPlugin>> getInstalledPlugins(
    String organizationId,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/organizations/$organizationId/plugins',
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => OrganizationPlugin.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch installed plugins: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Failed to fetch installed plugins', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error fetching installed plugins', error: e);
      rethrow;
    }
  }

  /// Install a plugin
  ///
  /// [organizationId] - The organization ID
  /// [pluginKey] - The plugin key to install
  /// [config] - Plugin configuration (optional)
  Future<OrganizationPlugin> installPlugin(
    String organizationId,
    String pluginKey, {
    Map<String, dynamic>? config,
  }) async {
    try {
      final request = InstallPluginRequest(
        pluginKey: pluginKey,
        config: config ?? {},
      );

      final response = await _dio.post(
        '$_baseUrl/organizations/$organizationId/plugins',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return OrganizationPlugin.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to install plugin: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Failed to install plugin', error: e);
      if (e.response?.data != null && e.response!.data is Map) {
        throw Exception(e.response!.data['error'] ?? 'Failed to install plugin');
      }
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error installing plugin', error: e);
      rethrow;
    }
  }

  /// Uninstall a plugin
  ///
  /// [organizationId] - The organization ID
  /// [pluginId] - The plugin installation ID
  Future<void> uninstallPlugin(
    String organizationId,
    String pluginId,
  ) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/organizations/$organizationId/plugins/$pluginId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to uninstall plugin: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Failed to uninstall plugin', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error uninstalling plugin', error: e);
      rethrow;
    }
  }

  /// Update plugin configuration
  ///
  /// [organizationId] - The organization ID
  /// [pluginId] - The plugin installation ID
  /// [config] - Updated configuration
  /// [isEnabled] - Enable/disable the plugin (optional)
  Future<void> updatePluginConfig(
    String organizationId,
    String pluginId,
    Map<String, dynamic> config, {
    bool? isEnabled,
  }) async {
    try {
      final request = UpdatePluginConfigRequest(
        config: config,
        isEnabled: isEnabled,
      );

      final response = await _dio.patch(
        '$_baseUrl/organizations/$organizationId/plugins/$pluginId',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update plugin config: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Failed to update plugin config', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error updating plugin config', error: e);
      rethrow;
    }
  }

  /// Execute a plugin action
  ///
  /// [organizationId] - The organization ID
  /// [pluginKey] - The plugin key
  /// [action] - The action to execute
  /// [data] - Action data
  Future<ExecutePluginResponse> executePlugin(
    String organizationId,
    String pluginKey,
    String action,
    Map<String, dynamic> data,
  ) async {
    try {
      final request = ExecutePluginRequest(
        action: action,
        data: data,
      );

      final response = await _dio.post(
        '$_baseUrl/organizations/$organizationId/plugins/$pluginKey/execute',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ExecutePluginResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to execute plugin: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Failed to execute plugin', error: e);
      if (e.response?.data != null && e.response!.data is Map) {
        return ExecutePluginResponse(
          success: false,
          error: e.response!.data['error']?.toString() ?? 'Failed to execute plugin',
        );
      }
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error executing plugin', error: e);
      return ExecutePluginResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Check if a plugin is installed and active
  ///
  /// [organizationId] - The organization ID
  /// [pluginKey] - The plugin key to check
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

  /// Get a specific installed plugin
  ///
  /// [organizationId] - The organization ID
  /// [pluginKey] - The plugin key
  Future<OrganizationPlugin?> getInstalledPlugin(
    String organizationId,
    String pluginKey,
  ) async {
    try {
      final plugins = await getInstalledPlugins(organizationId);
      return plugins.firstWhere(
        (p) => p.plugin.pluginKey == pluginKey,
        orElse: () => throw Exception('Plugin not found'),
      );
    } catch (e) {
      _logger.e('Failed to get installed plugin', error: e);
      return null;
    }
  }
}
