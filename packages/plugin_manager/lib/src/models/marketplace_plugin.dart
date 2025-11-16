import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_plugin.freezed.dart';
part 'marketplace_plugin.g.dart';

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
    String? iconUrl,
    String? bannerUrl,
    required String version,
    required String manifestUrl,
    @Default([]) List<String> requiredPermissions,
    @Default([]) List<String> optionalPermissions,
    @Default([]) List<String> webhookEvents,
    required String pricingModel,
    @Default(0.0) double basePrice,
    @Default('USD') String currency,
    @Default(0) int trialDays,
    required String status,
    @Default(false) bool isVerified,
    @Default(false) bool isFeatured,
    double? ratingAverage,
    @Default(0) int ratingCount,
    @Default(0) int installCount,
    @Default(0) int activeInstallCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? publishedAt,
  }) = _MarketplacePlugin;

  factory MarketplacePlugin.fromJson(Map<String, dynamic> json) =>
      _$MarketplacePluginFromJson(json);
}

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
    String? subscriptionPlan,
    DateTime? trialEndsAt,
    DateTime? subscriptionStartedAt,
    DateTime? lastSyncAt,
    String? syncFrequency,
    String? syncStatus,
    @Default('healthy') String healthStatus,
    DateTime? lastHealthCheckAt,
    required DateTime installedAt,
    String? installedBy,
  }) = _OrganizationPlugin;

  factory OrganizationPlugin.fromJson(Map<String, dynamic> json) =>
      _$OrganizationPluginFromJson(json);
}

@freezed
class PluginEvent with _$PluginEvent {
  const factory PluginEvent({
    required String id,
    required String organizationPluginId,
    required String organizationId,
    required String eventType,
    String? eventName,
    @Default({}) Map<String, dynamic> eventData,
    required String status,
    String? errorMessage,
    String? errorCode,
    int? durationMs,
    required DateTime createdAt,
  }) = _PluginEvent;

  factory PluginEvent.fromJson(Map<String, dynamic> json) =>
      _$PluginEventFromJson(json);
}
