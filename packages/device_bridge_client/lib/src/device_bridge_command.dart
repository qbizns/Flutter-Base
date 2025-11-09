import 'device_types.dart';

/// Command to send to the device bridge.
class DeviceBridgeCommand {
  const DeviceBridgeCommand({
    required this.deviceType,
    required this.action,
    this.deviceId,
    this.parameters,
  });

  final DeviceType deviceType;
  final String action;
  final String? deviceId;
  final Map<String, dynamic>? parameters;

  Map<String, dynamic> toJson() {
    return {
      'deviceType': deviceType.name,
      'action': action,
      if (deviceId != null) 'deviceId': deviceId,
      if (parameters != null) 'parameters': parameters,
    };
  }

  factory DeviceBridgeCommand.fromJson(Map<String, dynamic> json) {
    return DeviceBridgeCommand(
      deviceType: DeviceType.values.byName(json['deviceType'] as String),
      action: json['action'] as String,
      deviceId: json['deviceId'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );
  }
}

// Command factories for common operations

/// Print a receipt.
class PrintReceiptCommand extends DeviceBridgeCommand {
  PrintReceiptCommand({
    required String printerId,
    required Map<String, dynamic> receiptData,
  }) : super(
          deviceType: DeviceType.printer,
          action: 'print_receipt',
          deviceId: printerId,
          parameters: receiptData,
        );
}

/// Open cash drawer.
class OpenCashDrawerCommand extends DeviceBridgeCommand {
  OpenCashDrawerCommand({
    String? drawerId,
  }) : super(
          deviceType: DeviceType.cashDrawer,
          action: 'open',
          deviceId: drawerId,
        );
}

/// Scan barcode.
class ScanBarcodeCommand extends DeviceBridgeCommand {
  ScanBarcodeCommand({
    String? scannerId,
  }) : super(
          deviceType: DeviceType.scanner,
          action: 'scan',
          deviceId: scannerId,
        );
}

/// Read scale weight.
class ReadScaleCommand extends DeviceBridgeCommand {
  ReadScaleCommand({
    String? scaleId,
  }) : super(
          deviceType: DeviceType.scale,
          action: 'read_weight',
          deviceId: scaleId,
        );
}
