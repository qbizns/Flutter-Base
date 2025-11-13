import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_models.dart';

/// Provider for devices
///
/// TODO: Replace with real API integration
/// GET /api/v1/devices - List all devices
/// POST /api/v1/devices - Add new device
/// PATCH /api/v1/devices/:id - Update device
/// DELETE /api/v1/devices/:id - Delete device
/// POST /api/v1/devices/:id/test - Test device connection
final devicesProvider =
    StateNotifierProvider<DevicesNotifier, List<Device>>((ref) {
  return DevicesNotifier();
});

class DevicesNotifier extends StateNotifier<List<Device>> {
  DevicesNotifier() : super(_generateMockDevices());

  static List<Device> _generateMockDevices() {
    final now = DateTime.now();
    return [
      // Receipt Printers
      Device(
        id: 'dev-001',
        name: 'Front Counter Printer',
        type: DeviceType.printer,
        status: DeviceStatus.online,
        ipAddress: '192.168.1.100',
        port: 9100,
        connectionType: DeviceConnectionType.network,
        lastSeen: now.subtract(const Duration(minutes: 2)),
        location: 'Front Counter',
        serialNumber: 'TM-T88VI-001',
        firmwareVersion: '1.2.3',
        capabilities: {
          'model': 'Epson TM-T88VI',
          'protocol': 'ESC/POS',
          'paper_width': '80mm',
          'auto_cutter': true,
          'supports_graphics': true,
        },
        settings: {
          'print_density': 'medium',
          'auto_cut': true,
          'buzzer': false,
        },
        autoConnect: true,
      ),
      Device(
        id: 'dev-002',
        name: 'Kitchen Printer',
        type: DeviceType.printer,
        status: DeviceStatus.online,
        ipAddress: '192.168.1.101',
        port: 9100,
        connectionType: DeviceConnectionType.network,
        lastSeen: now.subtract(const Duration(minutes: 1)),
        location: 'Kitchen',
        serialNumber: 'TM-T88VI-002',
        firmwareVersion: '1.2.3',
        capabilities: {
          'model': 'Epson TM-T88VI',
          'protocol': 'ESC/POS',
          'paper_width': '80mm',
          'auto_cutter': true,
        },
        settings: {
          'print_density': 'high',
          'auto_cut': true,
          'buzzer': true,
        },
        autoConnect: true,
      ),
      Device(
        id: 'dev-003',
        name: 'Bar Label Printer',
        type: DeviceType.printer,
        status: DeviceStatus.offline,
        ipAddress: '192.168.1.102',
        port: 9100,
        connectionType: DeviceConnectionType.network,
        lastSeen: now.subtract(const Duration(hours: 2)),
        location: 'Bar',
        serialNumber: 'ZD420-001',
        firmwareVersion: '2.1.0',
        capabilities: {
          'model': 'Zebra ZD420',
          'protocol': 'ZPL',
          'label_width': '4 inch',
          'resolution': '203 dpi',
        },
        settings: {
          'darkness': 15,
          'print_speed': 4,
        },
        autoConnect: false,
        notes: 'Paper jam - needs service',
      ),

      // Barcode Scanners
      Device(
        id: 'dev-004',
        name: 'Counter Scanner 1',
        type: DeviceType.scanner,
        status: DeviceStatus.online,
        connectionType: DeviceConnectionType.usb,
        lastSeen: now.subtract(const Duration(seconds: 30)),
        location: 'Front Counter',
        serialNumber: 'DS2278-001',
        firmwareVersion: '1.0.5',
        capabilities: {
          'model': 'Zebra DS2278',
          'type': '2D Imager',
          'wireless': false,
        },
        autoConnect: true,
      ),
      Device(
        id: 'dev-005',
        name: 'Wireless Scanner',
        type: DeviceType.scanner,
        status: DeviceStatus.online,
        connectionType: DeviceConnectionType.bluetooth,
        lastSeen: now.subtract(const Duration(minutes: 5)),
        location: 'Warehouse',
        serialNumber: 'LI4278-001',
        firmwareVersion: '2.3.1',
        capabilities: {
          'model': 'Zebra LI4278',
          'type': '1D Linear',
          'wireless': true,
          'battery_level': 85,
        },
        autoConnect: true,
      ),

      // Payment Terminals
      Device(
        id: 'dev-006',
        name: 'Counter Terminal 1',
        type: DeviceType.paymentTerminal,
        status: DeviceStatus.online,
        ipAddress: '192.168.1.110',
        port: 443,
        connectionType: DeviceConnectionType.network,
        lastSeen: now.subtract(const Duration(minutes: 1)),
        location: 'Front Counter',
        serialNumber: 'PAX-A920-001',
        firmwareVersion: '3.1.2',
        capabilities: {
          'model': 'PAX A920',
          'supports_nfc': true,
          'supports_chip': true,
          'supports_swipe': true,
          'supports_contactless': true,
        },
        settings: {
          'timeout': 60,
          'receipts': 'electronic',
        },
        autoConnect: true,
      ),
      Device(
        id: 'dev-007',
        name: 'Mobile Terminal',
        type: DeviceType.paymentTerminal,
        status: DeviceStatus.error,
        ipAddress: '192.168.1.111',
        port: 443,
        connectionType: DeviceConnectionType.network,
        lastSeen: now.subtract(const Duration(minutes: 30)),
        location: 'Mobile',
        serialNumber: 'PAX-A920-002',
        firmwareVersion: '3.1.2',
        capabilities: {
          'model': 'PAX A920',
          'supports_nfc': true,
          'supports_chip': true,
        },
        notes: 'Connection timeout - check network',
      ),

      // Customer Display
      Device(
        id: 'dev-008',
        name: 'Front Counter Display',
        type: DeviceType.display,
        status: DeviceStatus.online,
        connectionType: DeviceConnectionType.usb,
        lastSeen: now.subtract(const Duration(minutes: 1)),
        location: 'Front Counter',
        serialNumber: 'LCD-2X20-001',
        firmwareVersion: '1.0.0',
        capabilities: {
          'model': 'Generic LCD 2x20',
          'lines': 2,
          'chars_per_line': 20,
        },
        autoConnect: true,
      ),

      // Cash Drawer
      Device(
        id: 'dev-009',
        name: 'Main Cash Drawer',
        type: DeviceType.cashDrawer,
        status: DeviceStatus.online,
        connectionType: DeviceConnectionType.serial,
        lastSeen: now.subtract(const Duration(minutes: 10)),
        location: 'Front Counter',
        serialNumber: 'CD-4141-001',
        firmwareVersion: '1.0.0',
        capabilities: {
          'model': 'APG Vasario 1416',
          'slots': 5,
          'lock': true,
        },
        autoConnect: true,
      ),

      // Kitchen Display System
      Device(
        id: 'dev-010',
        name: 'Kitchen Display 1',
        type: DeviceType.kds,
        status: DeviceStatus.maintenance,
        ipAddress: '192.168.1.120',
        connectionType: DeviceConnectionType.network,
        lastSeen: now.subtract(const Duration(hours: 1)),
        location: 'Kitchen',
        serialNumber: 'KDS-TAB-001',
        firmwareVersion: '2.0.1',
        capabilities: {
          'model': 'Samsung Galaxy Tab A8',
          'screen_size': '10.5 inch',
          'os': 'Android 12',
        },
        notes: 'Software update scheduled for tonight',
        autoConnect: false,
      ),
    ];
  }

  /// Add a new device
  void addDevice(Device device) {
    state = [...state, device];
  }

  /// Update an existing device
  void updateDevice(String id, Device updatedDevice) {
    state = [
      for (final device in state)
        if (device.id == id) updatedDevice else device,
    ];
  }

  /// Delete a device
  void deleteDevice(String id) {
    state = state.where((device) => device.id != id).toList();
  }

  /// Update device status
  void updateDeviceStatus(String id, DeviceStatus status) {
    state = [
      for (final device in state)
        if (device.id == id)
          device.copyWith(
            status: status,
            lastSeen: DateTime.now(),
          )
        else
          device,
    ];
  }

  /// Test device connection (mock implementation)
  Future<bool> testConnection(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock: 80% success rate
    final success = DateTime.now().second % 5 != 0;

    if (success) {
      updateDeviceStatus(id, DeviceStatus.online);
    } else {
      updateDeviceStatus(id, DeviceStatus.error);
    }

    return success;
  }

  /// Refresh device status (mock implementation)
  Future<void> refreshDevices() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock: Update last seen for online devices
    state = [
      for (final device in state)
        if (device.status == DeviceStatus.online)
          device.copyWith(lastSeen: DateTime.now())
        else
          device,
    ];
  }
}

/// Provider for filtered devices by type
final devicesByTypeProvider = Provider.family<List<Device>, DeviceType?>((ref, type) {
  final devices = ref.watch(devicesProvider);
  if (type == null) return devices;
  return devices.where((d) => d.type == type).toList();
});

/// Provider for filtered devices by status
final devicesByStatusProvider = Provider.family<List<Device>, DeviceStatus?>((ref, status) {
  final devices = ref.watch(devicesProvider);
  if (status == null) return devices;
  return devices.where((d) => d.status == status).toList();
});

/// Provider for device statistics
final deviceStatsProvider = Provider<DeviceStats>((ref) {
  final devices = ref.watch(devicesProvider);

  return DeviceStats(
    total: devices.length,
    online: devices.where((d) => d.status == DeviceStatus.online).length,
    offline: devices.where((d) => d.status == DeviceStatus.offline).length,
    error: devices.where((d) => d.status == DeviceStatus.error).length,
    maintenance: devices.where((d) => d.status == DeviceStatus.maintenance).length,
  );
});

/// Device statistics model
class DeviceStats {
  final int total;
  final int online;
  final int offline;
  final int error;
  final int maintenance;

  const DeviceStats({
    required this.total,
    required this.online,
    required this.offline,
    required this.error,
    required this.maintenance,
  });

  int get healthy => online + maintenance;
  double get healthPercentage => total > 0 ? (healthy / total) * 100 : 0;
}

/// Provider for device connection logs (mock)
final deviceConnectionLogsProvider =
    StateNotifierProvider<DeviceConnectionLogsNotifier, List<DeviceConnectionLog>>((ref) {
  return DeviceConnectionLogsNotifier();
});

class DeviceConnectionLogsNotifier extends StateNotifier<List<DeviceConnectionLog>> {
  DeviceConnectionLogsNotifier() : super(_generateMockLogs());

  static List<DeviceConnectionLog> _generateMockLogs() {
    final now = DateTime.now();
    return [
      DeviceConnectionLog(
        id: 'log-001',
        deviceId: 'dev-001',
        deviceName: 'Front Counter Printer',
        timestamp: now.subtract(const Duration(minutes: 2)),
        event: 'Connection Test',
        details: 'Connection successful - 15ms',
        success: true,
      ),
      DeviceConnectionLog(
        id: 'log-002',
        deviceId: 'dev-006',
        deviceName: 'Counter Terminal 1',
        timestamp: now.subtract(const Duration(minutes: 5)),
        event: 'Payment Processed',
        details: 'Transaction #12345 - \$45.00',
        success: true,
      ),
      DeviceConnectionLog(
        id: 'log-003',
        deviceId: 'dev-007',
        deviceName: 'Mobile Terminal',
        timestamp: now.subtract(const Duration(minutes: 30)),
        event: 'Connection Failed',
        details: 'Timeout after 30 seconds',
        success: false,
      ),
      DeviceConnectionLog(
        id: 'log-004',
        deviceId: 'dev-002',
        deviceName: 'Kitchen Printer',
        timestamp: now.subtract(const Duration(hours: 1)),
        event: 'Print Job',
        details: 'Order #1234 printed',
        success: true,
      ),
      DeviceConnectionLog(
        id: 'log-005',
        deviceId: 'dev-003',
        deviceName: 'Bar Label Printer',
        timestamp: now.subtract(const Duration(hours: 2)),
        event: 'Connection Lost',
        details: 'Device went offline',
        success: false,
      ),
    ];
  }

  void addLog(DeviceConnectionLog log) {
    state = [log, ...state];
  }
}
