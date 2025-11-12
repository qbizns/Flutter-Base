/// Connection Settings Card
/// Configure customer display connection to POS register
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../../../../data/protocol/display_protocol.dart';
import '../../../../data/services/display_websocket_service.dart';

/// Connection Settings Card
/// Allows configuring connection to POS register
class ConnectionSettingsCard extends ConsumerStatefulWidget {
  const ConnectionSettingsCard({super.key});

  @override
  ConsumerState<ConnectionSettingsCard> createState() =>
      _ConnectionSettingsCardState();
}

class _ConnectionSettingsCardState
    extends ConsumerState<ConnectionSettingsCard> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _displayNameController;
  bool _autoReconnect = true;
  bool _enableIdleTimeout = true;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: 'localhost');
    _portController = TextEditingController(text: '8080');
    _displayNameController = TextEditingController(text: 'Customer Display');
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(displayConnectionStateProvider);
    final wsService = ref.read(displayWebSocketServiceProvider);

    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Padding(
        padding: VodoDimensions.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.link,
                  size: 28,
                  color: VodoColors.primary,
                ),
                const SizedBox(width: VodoDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POS Connection',
                        style: VodoTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connect to POS register for real-time updates',
                        style: VodoTextStyles.bodySmall.copyWith(
                          color: VodoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Connection status indicator
                _buildConnectionStatus(connectionState),
              ],
            ),

            const SizedBox(height: VodoDimensions.spacingLg),

            // Display Name
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                hintText: 'Enter display name',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: VodoDimensions.borderRadiusMd,
                ),
              ),
            ),

            const SizedBox(height: VodoDimensions.spacingMd),

            // Server Host
            TextField(
              controller: _hostController,
              decoration: InputDecoration(
                labelText: 'POS Server Host',
                hintText: 'Enter IP address or hostname',
                prefixIcon: const Icon(Icons.computer),
                border: OutlineInputBorder(
                  borderRadius: VodoDimensions.borderRadiusMd,
                ),
                helperText: 'Example: 192.168.1.100 or localhost',
              ),
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: VodoDimensions.spacingMd),

            // Server Port
            TextField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: 'Port',
                hintText: 'Enter port number',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: VodoDimensions.borderRadiusMd,
                ),
                helperText: 'Default: 8080',
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: VodoDimensions.spacingMd),

            // Auto Reconnect Switch
            SwitchListTile(
              title: const Text('Auto Reconnect'),
              subtitle: const Text('Automatically reconnect if connection lost'),
              value: _autoReconnect,
              onChanged: (value) {
                setState(() {
                  _autoReconnect = value;
                });
              },
              activeColor: VodoColors.primary,
            ),

            // Idle Timeout Switch
            SwitchListTile(
              title: const Text('Enable Idle Timeout'),
              subtitle: const Text('Return to idle screen after inactivity'),
              value: _enableIdleTimeout,
              onChanged: (value) {
                setState(() {
                  _enableIdleTimeout = value;
                });
              },
              activeColor: VodoColors.primary,
            ),

            const SizedBox(height: VodoDimensions.spacingLg),

            // Connection Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: connectionState.isConnected
                        ? () => _disconnect(wsService)
                        : connectionState.isConnecting
                            ? null
                            : () => _connect(wsService),
                    icon: Icon(
                      connectionState.isConnected
                          ? Icons.link_off
                          : Icons.link,
                    ),
                    label: Text(
                      connectionState.isConnected
                          ? 'Disconnect'
                          : connectionState.isConnecting
                              ? 'Connecting...'
                              : 'Connect',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: connectionState.isConnected
                          ? VodoColors.danger
                          : VodoColors.primary,
                      foregroundColor: VodoColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                if (connectionState.isConnected) ...[
                  const SizedBox(width: VodoDimensions.spacingMd),
                  IconButton(
                    onPressed: () => _testConnection(wsService),
                    icon: const Icon(Icons.play_arrow),
                    tooltip: 'Test Connection',
                    style: IconButton.styleFrom(
                      backgroundColor: VodoColors.info,
                      foregroundColor: VodoColors.textOnPrimary,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ],
            ),

            // Connection Info
            if (connectionState.isConnected) ...[
              const SizedBox(height: VodoDimensions.spacingMd),
              Container(
                padding: VodoDimensions.paddingMd,
                decoration: BoxDecoration(
                  color: VodoColors.success.withOpacity(0.1),
                  borderRadius: VodoDimensions.borderRadiusMd,
                  border: Border.all(
                    color: VodoColors.success.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: VodoColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: VodoDimensions.spacingSm),
                    Expanded(
                      child: Text(
                        'Connected to ${_hostController.text}:${_portController.text}',
                        style: VodoTextStyles.bodySmall.copyWith(
                          color: VodoColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Error Message
            if (connectionState == ConnectionState.error) ...[
              const SizedBox(height: VodoDimensions.spacingMd),
              Container(
                padding: VodoDimensions.paddingMd,
                decoration: BoxDecoration(
                  color: VodoColors.danger.withOpacity(0.1),
                  borderRadius: VodoDimensions.borderRadiusMd,
                  border: Border.all(
                    color: VodoColors.danger.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: VodoColors.danger,
                      size: 20,
                    ),
                    const SizedBox(width: VodoDimensions.spacingSm),
                    Expanded(
                      child: Text(
                        'Connection failed. Check server address and try again.',
                        style: VodoTextStyles.bodySmall.copyWith(
                          color: VodoColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(ConnectionState state) {
    Color color;
    IconData icon;

    switch (state) {
      case ConnectionState.connected:
        color = VodoColors.success;
        icon = Icons.check_circle;
        break;
      case ConnectionState.connecting:
      case ConnectionState.reconnecting:
        color = VodoColors.warning;
        icon = Icons.sync;
        break;
      case ConnectionState.error:
        color = VodoColors.danger;
        icon = Icons.error;
        break;
      case ConnectionState.disconnected:
        color = VodoColors.textSecondary;
        icon = Icons.radio_button_unchecked;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            state.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _connect(DisplayWebSocketService service) {
    final host = _hostController.text.trim();
    final portText = _portController.text.trim();
    final displayName = _displayNameController.text.trim();

    if (host.isEmpty || portText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter server host and port'),
          backgroundColor: VodoColors.danger,
        ),
      );
      return;
    }

    final port = int.tryParse(portText);
    if (port == null || port < 1 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid port number (1-65535)'),
          backgroundColor: VodoColors.danger,
        ),
      );
      return;
    }

    final config = DisplayConfiguration(
      displayId: 'display_${DateTime.now().millisecondsSinceEpoch}',
      displayName: displayName.isEmpty ? 'Customer Display' : displayName,
      serverHost: host,
      serverPort: port,
      autoReconnect: _autoReconnect,
      enableIdleTimeout: _enableIdleTimeout,
    );

    service.connect(config);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting to $host:$port...'),
        backgroundColor: VodoColors.info,
      ),
    );
  }

  void _disconnect(DisplayWebSocketService service) {
    service.disconnect();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disconnected from POS register'),
        backgroundColor: VodoColors.warning,
      ),
    );
  }

  void _testConnection(DisplayWebSocketService service) {
    // Start mock demo to test the connection
    final mockService = MockDisplayWebSocketService(service);
    mockService.startMockDemo();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Running test demo...'),
        backgroundColor: VodoColors.info,
      ),
    );
  }
}
