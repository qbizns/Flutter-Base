/// Hardware Providers
/// Riverpod providers for hardware device integration
library;

import 'package:device_bridge_client/device_bridge_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../services/hardware_service.dart';

// ========================================
// Device Bridge Client
// ========================================

/// Device Bridge Client Provider
/// Creates connection to Device Bridge backend
final deviceBridgeClientProvider = Provider<DeviceBridgeClient>((ref) {
  final config = ref.watch(configProvider);

  // Device Bridge runs on localhost:8080 by default
  // In production, this would be configured per station
  final deviceBridgeUrl = config.metadata['deviceBridgeUrl'] as String? ??
      'http://localhost:8080';

  return DeviceBridgeClient(
    baseUrl: deviceBridgeUrl,
    timeout: const Duration(seconds: 30),
    debug: config.environment == Environment.development,
  );
});

// ========================================
// Device IDs Configuration
// ========================================

/// Receipt Printer ID Provider
/// Device ID for receipt printer
final receiptPrinterIdProvider = Provider<String?>((ref) {
  final config = ref.watch(configProvider);
  return config.metadata['receiptPrinterId'] as String?;
});

/// Kitchen Printer ID Provider
/// Device ID for kitchen printer
final kitchenPrinterIdProvider = Provider<String?>((ref) {
  final config = ref.watch(configProvider);
  return config.metadata['kitchenPrinterId'] as String?;
});

/// Barcode Scanner ID Provider
/// Device ID for barcode scanner
final barcodeScannerIdProvider = Provider<String?>((ref) {
  final config = ref.watch(configProvider);
  return config.metadata['barcodeScan​nerId'] as String?;
});

/// Payment Terminal ID Provider
/// Device ID for payment terminal
final paymentTerminalIdProvider = Provider<String?>((ref) {
  final config = ref.watch(configProvider);
  return config.metadata['paymentTerminalId'] as String?;
});

// ========================================
// Hardware Service
// ========================================

/// Hardware Service Provider
/// Main service for all hardware operations
final hardwareServiceProvider = Provider<HardwareService>((ref) {
  final deviceBridge = ref.watch(deviceBridgeClientProvider);
  final receiptPrinterId = ref.watch(receiptPrinterIdProvider);
  final kitchenPrinterId = ref.watch(kitchenPrinterIdProvider);
  final barcodeScan​nerId = ref.watch(barcodeScannerIdProvider);
  final paymentTerminalId = ref.watch(paymentTerminalIdProvider);

  return HardwareService(
    deviceBridge: deviceBridge,
    receiptPrinterId: receiptPrinterId,
    kitchenPrinterId: kitchenPrinterId,
    barcodeScan​nerId: barcodeScan​nerId,
    paymentTerminalId: paymentTerminalId,
  );
});

// ========================================
// Device Status Providers
// ========================================

/// Receipt Printer Status Provider
/// Checks if receipt printer is ready
final receiptPrinterStatusProvider = FutureProvider<bool>((ref) async {
  final hardware = ref.watch(hardwareServiceProvider);
  final result = await hardware.checkReceiptPrinterStatus();
  return result.when(
    success: (isReady) => isReady,
    failure: (_) => false,
  );
});

/// Payment Terminal Status Provider
/// Checks if payment terminal is ready
final paymentTerminalStatusProvider = FutureProvider<bool>((ref) async {
  final hardware = ref.watch(hardwareServiceProvider);
  final result = await hardware.checkPaymentTerminalStatus();
  return result.when(
    success: (isReady) => isReady,
    failure: (_) => false,
  );
});

// ========================================
// Barcode Scanner Stream
// ========================================

/// Barcode Scanner Stream Provider
/// Stream of barcode scan events
final barcodeScannerStreamProvider = StreamProvider<String>((ref) {
  final hardware = ref.watch(hardwareServiceProvider);
  return hardware.barcodeStream;
});
