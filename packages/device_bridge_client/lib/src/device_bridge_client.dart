import 'package:pos_core/pos_core.dart';
import 'device_bridge_command.dart';
import 'device_bridge_event.dart';

/// Client for communicating with the device bridge service.
///
/// The device bridge is an external Go service that handles all hardware
/// interactions (printers, scanners, cash drawers, scales, etc.).
///
/// Flutter apps NEVER talk directly to hardware via platform channels.
/// Instead, they use this client to send commands to the device bridge.
abstract class DeviceBridgeClient {
  /// Send a command to the device bridge.
  Future<Result<DeviceBridgeResponse>> sendCommand(
    DeviceBridgeCommand command,
  );

  /// Subscribe to events from the device bridge.
  Stream<DeviceBridgeEvent> get events;

  /// Check if the device bridge is connected and available.
  Future<bool> isConnected();

  /// Connect to the device bridge service.
  Future<Result<void>> connect(String baseUrl);

  /// Disconnect from the device bridge service.
  Future<void> disconnect();
}

/// Response from a device bridge command.
class DeviceBridgeResponse {
  const DeviceBridgeResponse({
    required this.success,
    this.data,
    this.error,
  });

  final bool success;
  final Map<String, dynamic>? data;
  final String? error;

  factory DeviceBridgeResponse.fromJson(Map<String, dynamic> json) {
    return DeviceBridgeResponse(
      success: json['success'] as bool,
      data: json['data'] as Map<String, dynamic>?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data,
      if (error != null) 'error': error,
    };
  }
}

/// Default implementation of DeviceBridgeClient.
/// TODO: Implement actual HTTP/WebSocket communication with Go service.
class DeviceBridgeClientImpl implements DeviceBridgeClient {
  DeviceBridgeClientImpl();

  String? _baseUrl;
  bool _isConnected = false;

  @override
  Future<Result<DeviceBridgeResponse>> sendCommand(
    DeviceBridgeCommand command,
  ) async {
    if (!_isConnected) {
      return Result.failure(
        Failure(message: 'Device bridge not connected'),
      );
    }

    // TODO: Implement actual HTTP request to device bridge
    // Example: POST $_baseUrl/command
    //   body: command.toJson()

    // Placeholder response
    return Result.success(
      DeviceBridgeResponse(
        success: true,
        data: {'message': 'Command sent successfully'},
      ),
    );
  }

  @override
  Stream<DeviceBridgeEvent> get events {
    // TODO: Implement actual WebSocket connection for events
    // Example: WebSocket connection to $_baseUrl/events

    // Placeholder empty stream
    return const Stream.empty();
  }

  @override
  Future<bool> isConnected() async {
    return _isConnected;
  }

  @override
  Future<Result<void>> connect(String baseUrl) async {
    _baseUrl = baseUrl;

    // TODO: Implement actual connection logic
    // Example: Test HTTP connection to $baseUrl/health

    _isConnected = true;
    return const Result.success(null);
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _baseUrl = null;
  }
}
