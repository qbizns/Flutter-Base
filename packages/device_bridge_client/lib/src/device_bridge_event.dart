import 'device_types.dart';

/// Event from the device bridge.
class DeviceBridgeEvent {
  const DeviceBridgeEvent({
    required this.deviceType,
    required this.eventType,
    this.deviceId,
    this.data,
  });

  final DeviceType deviceType;
  final String eventType;
  final String? deviceId;
  final Map<String, dynamic>? data;

  factory DeviceBridgeEvent.fromJson(Map<String, dynamic> json) {
    return DeviceBridgeEvent(
      deviceType: DeviceType.values.byName(json['deviceType'] as String),
      eventType: json['eventType'] as String,
      deviceId: json['deviceId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceType': deviceType.name,
      'eventType': eventType,
      if (deviceId != null) 'deviceId': deviceId,
      if (data != null) 'data': data,
    };
  }
}

// Common event types

/// Scanner scanned a barcode.
class BarcodeScannedEvent extends DeviceBridgeEvent {
  BarcodeScannedEvent({
    required String scannerId,
    required String barcode,
  }) : super(
          deviceType: DeviceType.scanner,
          eventType: 'barcode_scanned',
          deviceId: scannerId,
          data: {'barcode': barcode},
        );

  String get barcode => data!['barcode'] as String;
}

/// Printer status changed.
class PrinterStatusEvent extends DeviceBridgeEvent {
  PrinterStatusEvent({
    required String printerId,
    required String status,
  }) : super(
          deviceType: DeviceType.printer,
          eventType: 'status_changed',
          deviceId: printerId,
          data: {'status': status},
        );

  String get status => data!['status'] as String;
}

/// Scale weight changed.
class ScaleWeightEvent extends DeviceBridgeEvent {
  ScaleWeightEvent({
    required String scaleId,
    required double weight,
  }) : super(
          deviceType: DeviceType.scale,
          eventType: 'weight_changed',
          deviceId: scaleId,
          data: {'weight': weight},
        );

  double get weight => data!['weight'] as double;
}
