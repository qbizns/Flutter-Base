import 'package:equatable/equatable.dart';

/// Represents the current application context.
/// Contains information about the tenant, branch, device, and station.
/// This is crucial for multi-tenant POS systems where the same app
/// can be used across different organizations, locations, and devices.
class AppContext extends Equatable {
  const AppContext({
    this.tenantId,
    this.tenantName,
    this.branchId,
    this.branchName,
    this.deviceId,
    this.deviceName,
    this.deviceType,
    this.stationId,
    this.stationName,
    this.stationType,
  });

  /// Unique identifier for the tenant/organization
  final String? tenantId;

  /// Display name of the tenant
  final String? tenantName;

  /// Unique identifier for the branch/location
  final String? branchId;

  /// Display name of the branch
  final String? branchName;

  /// Unique identifier for the device
  final String? deviceId;

  /// Display name of the device
  final String? deviceName;

  /// Type of device (e.g., 'register', 'kds', 'kiosk', 'mobile')
  final String? deviceType;

  /// Unique identifier for the station within a branch
  final String? stationId;

  /// Display name of the station (e.g., 'Station 1', 'Drive-Thru')
  final String? stationName;

  /// Type of station (e.g., 'cashier', 'kitchen', 'prep')
  final String? stationType;

  /// Create an empty context (for apps that don't need multi-tenancy).
  factory AppContext.empty() => const AppContext();

  /// Create a context from JSON (for persistence/API responses).
  factory AppContext.fromJson(Map<String, dynamic> json) {
    return AppContext(
      tenantId: json['tenantId'] as String?,
      tenantName: json['tenantName'] as String?,
      branchId: json['branchId'] as String?,
      branchName: json['branchName'] as String?,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      deviceType: json['deviceType'] as String?,
      stationId: json['stationId'] as String?,
      stationName: json['stationName'] as String?,
      stationType: json['stationType'] as String?,
    );
  }

  /// Convert to JSON for persistence/API requests.
  Map<String, dynamic> toJson() {
    return {
      if (tenantId != null) 'tenantId': tenantId,
      if (tenantName != null) 'tenantName': tenantName,
      if (branchId != null) 'branchId': branchId,
      if (branchName != null) 'branchName': branchName,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
      if (deviceType != null) 'deviceType': deviceType,
      if (stationId != null) 'stationId': stationId,
      if (stationName != null) 'stationName': stationName,
      if (stationType != null) 'stationType': stationType,
    };
  }

  /// Check if the context has tenant information.
  bool get hasTenant => tenantId != null;

  /// Check if the context has branch information.
  bool get hasBranch => branchId != null;

  /// Check if the context has device information.
  bool get hasDevice => deviceId != null;

  /// Check if the context has station information.
  bool get hasStation => stationId != null;

  /// Copy with modified fields.
  AppContext copyWith({
    String? tenantId,
    String? tenantName,
    String? branchId,
    String? branchName,
    String? deviceId,
    String? deviceName,
    String? deviceType,
    String? stationId,
    String? stationName,
    String? stationType,
  }) {
    return AppContext(
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      stationType: stationType ?? this.stationType,
    );
  }

  @override
  List<Object?> get props => [
        tenantId,
        tenantName,
        branchId,
        branchName,
        deviceId,
        deviceName,
        deviceType,
        stationId,
        stationName,
        stationType,
      ];
}
