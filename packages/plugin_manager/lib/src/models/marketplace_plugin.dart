import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_plugin.freezed.dart';
part 'marketplace_plugin.g.dart';

/// Represents a plugin available in the marketplace
@freezed
class MarketplacePlugin with _$MarketplacePlugin {
  const factory MarketplacePlugin({
    required String id,
    required String pluginKey,
    required String pluginName,
    required String pluginSlug,
    required String category,
    String? subcategory,
    required String shortDescription,
    String? longDescription,
    @Default([]) List<String> features,
    String? iconUrl,
    String? bannerUrl,
    required String version,
    required String pricingModel,
    @Default(0.0) double basePrice,
    @Default('USD') String currency,
    @Default(0) int trialDays,
    @Default(0.0) double ratingAverage,
    @Default(0) int ratingCount,
    @Default(0) int installCount,
    @Default(0) int activeInstallCount,
    @Default(false) bool isVerified,
    @Default(false) bool isFeatured,
    @Default([]) List<String> requiredPermissions,
    @Default([]) List<String> optionalPermissions,
    Map<String, dynamic>? configSchema,
    String? developerName,
    String? supportEmail,
    String? documentationUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MarketplacePlugin;

  factory MarketplacePlugin.fromJson(Map<String, dynamic> json) =>
      _$MarketplacePluginFromJson(json);
}

/// Represents an installed plugin instance
@freezed
class OrganizationPlugin with _$OrganizationPlugin {
  const factory OrganizationPlugin({
    required String id,
    required String organizationId,
    required MarketplacePlugin plugin,
    required String status,
    @Default(true) bool isEnabled,
    @Default({}) Map<String, dynamic> config,
    @Default([]) List<String> grantedPermissions,
    String? subscriptionStatus,
    DateTime? trialEndsAt,
    DateTime? subscriptionEndsAt,
    DateTime? nextBillingDate,
    DateTime? lastSyncAt,
    String? syncStatus,
    @Default('healthy') String healthStatus,
    String? healthMessage,
    required DateTime installedAt,
    String? installedBy,
  }) = _OrganizationPlugin;

  factory OrganizationPlugin.fromJson(Map<String, dynamic> json) =>
      _$OrganizationPluginFromJson(json);
}

/// Request to install a plugin
@freezed
class InstallPluginRequest with _$InstallPluginRequest {
  const factory InstallPluginRequest({
    required String pluginKey,
    @Default({}) Map<String, dynamic> config,
  }) = _InstallPluginRequest;

  factory InstallPluginRequest.fromJson(Map<String, dynamic> json) =>
      _$InstallPluginRequestFromJson(json);
}

/// Request to update plugin configuration
@freezed
class UpdatePluginConfigRequest with _$UpdatePluginConfigRequest {
  const factory UpdatePluginConfigRequest({
    required Map<String, dynamic> config,
    bool? isEnabled,
  }) = _UpdatePluginConfigRequest;

  factory UpdatePluginConfigRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePluginConfigRequestFromJson(json);
}

/// Request to execute a plugin action
@freezed
class ExecutePluginRequest with _$ExecutePluginRequest {
  const factory ExecutePluginRequest({
    required String action,
    @Default({}) Map<String, dynamic> data,
  }) = _ExecutePluginRequest;

  factory ExecutePluginRequest.fromJson(Map<String, dynamic> json) =>
      _$ExecutePluginRequestFromJson(json);
}

/// Response from plugin execution
@freezed
class ExecutePluginResponse with _$ExecutePluginResponse {
  const factory ExecutePluginResponse({
    required bool success,
    Map<String, dynamic>? data,
    String? error,
  }) = _ExecutePluginResponse;

  factory ExecutePluginResponse.fromJson(Map<String, dynamic> json) =>
      _$ExecutePluginResponseFromJson(json);
}

/// Plugin category enum
enum PluginCategory {
  @JsonValue('payment')
  payment,
  @JsonValue('accounting')
  accounting,
  @JsonValue('ecommerce')
  ecommerce,
  @JsonValue('marketing')
  marketing,
  @JsonValue('shipping')
  shipping,
  @JsonValue('analytics')
  analytics,
  @JsonValue('loyalty')
  loyalty,
  @JsonValue('other')
  other,
}

extension PluginCategoryExtension on PluginCategory {
  String get displayName {
    switch (this) {
      case PluginCategory.payment:
        return 'Payment Gateways';
      case PluginCategory.accounting:
        return 'Accounting';
      case PluginCategory.ecommerce:
        return 'E-commerce';
      case PluginCategory.marketing:
        return 'Marketing';
      case PluginCategory.shipping:
        return 'Shipping & Delivery';
      case PluginCategory.analytics:
        return 'Analytics';
      case PluginCategory.loyalty:
        return 'Loyalty Programs';
      case PluginCategory.other:
        return 'Other';
    }
  }

  String get iconName {
    switch (this) {
      case PluginCategory.payment:
        return 'credit_card';
      case PluginCategory.accounting:
        return 'account_balance';
      case PluginCategory.ecommerce:
        return 'shopping_cart';
      case PluginCategory.marketing:
        return 'campaign';
      case PluginCategory.shipping:
        return 'local_shipping';
      case PluginCategory.analytics:
        return 'analytics';
      case PluginCategory.loyalty:
        return 'loyalty';
      case PluginCategory.other:
        return 'extension';
    }
  }
}
