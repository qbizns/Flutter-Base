import 'package:flutter/material.dart';

/// Device type enum
enum DeviceType {
  printer,
  scanner,
  paymentTerminal,
  display,
  cashDrawer,
  scale,
  kds,
  tablet,
}

/// Device status enum
enum DeviceStatus {
  online,
  offline,
  error,
  maintenance,
}

/// Device connection type enum
enum DeviceConnectionType {
  usb,
  network,
  bluetooth,
  serial,
}

/// Device Model
class Device {
  final String id;
  final String name;
  final DeviceType type;
  final DeviceStatus status;
  final String? ipAddress;
  final int? port;
  final DeviceConnectionType connectionType;
  final DateTime lastSeen;
  final String? location;
  final String? serialNumber;
  final String? firmwareVersion;
  final Map<String, dynamic>? capabilities;
  final Map<String, dynamic>? settings;
  final bool autoConnect;
  final String? notes;

  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.ipAddress,
    this.port,
    required this.connectionType,
    required this.lastSeen,
    this.location,
    this.serialNumber,
    this.firmwareVersion,
    this.capabilities,
    this.settings,
    this.autoConnect = true,
    this.notes,
  });

  /// Get device type display name
  String get typeDisplayName {
    switch (type) {
      case DeviceType.printer:
        return 'Receipt Printer';
      case DeviceType.scanner:
        return 'Barcode Scanner';
      case DeviceType.paymentTerminal:
        return 'Payment Terminal';
      case DeviceType.display:
        return 'Customer Display';
      case DeviceType.cashDrawer:
        return 'Cash Drawer';
      case DeviceType.scale:
        return 'Scale';
      case DeviceType.kds:
        return 'Kitchen Display';
      case DeviceType.tablet:
        return 'Tablet/Device';
    }
  }

  /// Get device type icon
  IconData get typeIcon {
    switch (type) {
      case DeviceType.printer:
        return Icons.print;
      case DeviceType.scanner:
        return Icons.qr_code_scanner;
      case DeviceType.paymentTerminal:
        return Icons.credit_card;
      case DeviceType.display:
        return Icons.monitor;
      case DeviceType.cashDrawer:
        return Icons.inventory_2;
      case DeviceType.scale:
        return Icons.scale;
      case DeviceType.kds:
        return Icons.restaurant;
      case DeviceType.tablet:
        return Icons.tablet_android;
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case DeviceStatus.online:
        return 'Online';
      case DeviceStatus.offline:
        return 'Offline';
      case DeviceStatus.error:
        return 'Error';
      case DeviceStatus.maintenance:
        return 'Maintenance';
    }
  }

  /// Get status color
  Color get statusColor {
    switch (status) {
      case DeviceStatus.online:
        return const Color(0xFF28A745); // Success green
      case DeviceStatus.offline:
        return const Color(0xFF6C757D); // Gray
      case DeviceStatus.error:
        return const Color(0xFFDC3545); // Danger red
      case DeviceStatus.maintenance:
        return const Color(0xFFF0AD4E); // Warning orange
    }
  }

  /// Get connection type display name
  String get connectionDisplayName {
    switch (connectionType) {
      case DeviceConnectionType.usb:
        return 'USB';
      case DeviceConnectionType.network:
        return 'Network';
      case DeviceConnectionType.bluetooth:
        return 'Bluetooth';
      case DeviceConnectionType.serial:
        return 'Serial';
    }
  }

  /// Get connection icon
  IconData get connectionIcon {
    switch (connectionType) {
      case DeviceConnectionType.usb:
        return Icons.usb;
      case DeviceConnectionType.network:
        return Icons.lan;
      case DeviceConnectionType.bluetooth:
        return Icons.bluetooth;
      case DeviceConnectionType.serial:
        return Icons.cable;
    }
  }

  /// Get connection address
  String get connectionAddress {
    if (connectionType == DeviceConnectionType.network && ipAddress != null) {
      return port != null ? '$ipAddress:$port' : ipAddress!;
    }
    return connectionDisplayName;
  }

  /// Check if device is healthy (online or maintenance)
  bool get isHealthy => status == DeviceStatus.online || status == DeviceStatus.maintenance;

  /// Get time since last seen
  String get timeSinceLastSeen {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Device copyWith({
    String? id,
    String? name,
    DeviceType? type,
    DeviceStatus? status,
    String? ipAddress,
    int? port,
    DeviceConnectionType? connectionType,
    DateTime? lastSeen,
    String? location,
    String? serialNumber,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    bool? autoConnect,
    String? notes,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      connectionType: connectionType ?? this.connectionType,
      lastSeen: lastSeen ?? this.lastSeen,
      location: location ?? this.location,
      serialNumber: serialNumber ?? this.serialNumber,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      capabilities: capabilities ?? this.capabilities,
      settings: settings ?? this.settings,
      autoConnect: autoConnect ?? this.autoConnect,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'status': status.name,
      'ip_address': ipAddress,
      'port': port,
      'connection_type': connectionType.name,
      'last_seen': lastSeen.toIso8601String(),
      'location': location,
      'serial_number': serialNumber,
      'firmware_version': firmwareVersion,
      'capabilities': capabilities,
      'settings': settings,
      'auto_connect': autoConnect,
      'notes': notes,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      name: json['name'] as String,
      type: DeviceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DeviceType.printer,
      ),
      status: DeviceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DeviceStatus.offline,
      ),
      ipAddress: json['ip_address'] as String?,
      port: json['port'] as int?,
      connectionType: DeviceConnectionType.values.firstWhere(
        (e) => e.name == json['connection_type'],
        orElse: () => DeviceConnectionType.network,
      ),
      lastSeen: DateTime.parse(json['last_seen'] as String),
      location: json['location'] as String?,
      serialNumber: json['serial_number'] as String?,
      firmwareVersion: json['firmware_version'] as String?,
      capabilities: json['capabilities'] as Map<String, dynamic>?,
      settings: json['settings'] as Map<String, dynamic>?,
      autoConnect: json['auto_connect'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }
}

/// Device connection log entry
class DeviceConnectionLog {
  final String id;
  final String deviceId;
  final String deviceName;
  final DateTime timestamp;
  final String event;
  final String? details;
  final bool success;

  const DeviceConnectionLog({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.timestamp,
    required this.event,
    this.details,
    required this.success,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'device_name': deviceName,
      'timestamp': timestamp.toIso8601String(),
      'event': event,
      'details': details,
      'success': success,
    };
  }

  factory DeviceConnectionLog.fromJson(Map<String, dynamic> json) {
    return DeviceConnectionLog(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      event: json['event'] as String,
      details: json['details'] as String?,
      success: json['success'] as bool,
    );
  }
}
