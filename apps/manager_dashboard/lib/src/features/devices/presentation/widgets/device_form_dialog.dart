import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/device_models.dart';
import '../../providers/devices_providers.dart';

/// Device Form Dialog
///
/// Add or edit device dialog with:
/// - Device name, type, connection type
/// - IP address and port (for network devices)
/// - Location, serial number, firmware version
/// - Auto-connect setting
/// - Notes
/// - Form validation
/// - Test connection button
class DeviceFormDialog extends ConsumerStatefulWidget {
  final Device? device;

  const DeviceFormDialog({super.key, this.device});

  @override
  ConsumerState<DeviceFormDialog> createState() => _DeviceFormDialogState();
}

class _DeviceFormDialogState extends ConsumerState<DeviceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ipAddressController;
  late final TextEditingController _portController;
  late final TextEditingController _locationController;
  late final TextEditingController _serialNumberController;
  late final TextEditingController _firmwareVersionController;
  late final TextEditingController _notesController;

  late DeviceType _selectedType;
  late DeviceConnectionType _selectedConnectionType;
  late DeviceStatus _selectedStatus;
  late bool _autoConnect;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    final device = widget.device;

    _nameController = TextEditingController(text: device?.name ?? '');
    _ipAddressController = TextEditingController(text: device?.ipAddress ?? '');
    _portController = TextEditingController(text: device?.port?.toString() ?? '');
    _locationController = TextEditingController(text: device?.location ?? '');
    _serialNumberController = TextEditingController(text: device?.serialNumber ?? '');
    _firmwareVersionController = TextEditingController(text: device?.firmwareVersion ?? '');
    _notesController = TextEditingController(text: device?.notes ?? '');

    _selectedType = device?.type ?? DeviceType.printer;
    _selectedConnectionType = device?.connectionType ?? DeviceConnectionType.network;
    _selectedStatus = device?.status ?? DeviceStatus.offline;
    _autoConnect = device?.autoConnect ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipAddressController.dispose();
    _portController.dispose();
    _locationController.dispose();
    _serialNumberController.dispose();
    _firmwareVersionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.device != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(OdooSpacing.lg),
              decoration: BoxDecoration(
                color: OdooColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(OdooSpacing.radiusStandard),
                  topRight: Radius.circular(OdooSpacing.radiusStandard),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.devices,
                    color: OdooColors.primary,
                    size: OdooIconSizes.lg,
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  Text(
                    isEditing ? 'Edit Device' : 'Add New Device',
                    style: OdooTypography.titleLarge.copyWith(
                      color: OdooColors.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: OdooColors.textSecondary,
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(OdooSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Device Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Device Name',
                        hint: 'e.g., Front Counter Printer',
                        icon: Icons.label,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a device name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      // Device Type and Status
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField<DeviceType>(
                              value: _selectedType,
                              label: 'Device Type',
                              icon: Icons.category,
                              items: DeviceType.values,
                              itemBuilder: (type) => _getDeviceTypeName(type),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: OdooSpacing.md),
                          Expanded(
                            child: _buildDropdownField<DeviceStatus>(
                              value: _selectedStatus,
                              label: 'Status',
                              icon: Icons.signal_cellular_alt,
                              items: DeviceStatus.values,
                              itemBuilder: (status) => _getDeviceStatusName(status),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      // Connection Type
                      _buildDropdownField<DeviceConnectionType>(
                        value: _selectedConnectionType,
                        label: 'Connection Type',
                        icon: Icons.cable,
                        items: DeviceConnectionType.values,
                        itemBuilder: (type) => _getConnectionTypeName(type),
                        onChanged: (value) {
                          setState(() {
                            _selectedConnectionType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      // Network Settings (only for network connection)
                      if (_selectedConnectionType == DeviceConnectionType.network) ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                controller: _ipAddressController,
                                label: 'IP Address',
                                hint: '192.168.1.100',
                                icon: Icons.computer,
                                validator: (value) {
                                  if (_selectedConnectionType == DeviceConnectionType.network) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required for network devices';
                                    }
                                    // Basic IP validation
                                    final ipRegex = RegExp(
                                      r'^(\d{1,3}\.){3}\d{1,3}$',
                                    );
                                    if (!ipRegex.hasMatch(value)) {
                                      return 'Invalid IP address';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: OdooSpacing.md),
                            Expanded(
                              child: _buildTextField(
                                controller: _portController,
                                label: 'Port',
                                hint: '9100',
                                icon: Icons.numbers,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final port = int.tryParse(value);
                                    if (port == null || port < 1 || port > 65535) {
                                      return 'Invalid port';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: OdooSpacing.lg),
                      ],

                      // Location
                      _buildTextField(
                        controller: _locationController,
                        label: 'Location',
                        hint: 'e.g., Front Counter, Kitchen, Bar',
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      // Serial Number and Firmware Version
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _serialNumberController,
                              label: 'Serial Number',
                              hint: 'Optional',
                              icon: Icons.tag,
                            ),
                          ),
                          const SizedBox(width: OdooSpacing.md),
                          Expanded(
                            child: _buildTextField(
                              controller: _firmwareVersionController,
                              label: 'Firmware Version',
                              hint: 'Optional',
                              icon: Icons.system_update,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      // Auto-connect Checkbox
                      CheckboxListTile(
                        value: _autoConnect,
                        onChanged: (value) {
                          setState(() {
                            _autoConnect = value ?? true;
                          });
                        },
                        title: Text(
                          'Auto-connect on startup',
                          style: OdooTypography.bodyMedium,
                        ),
                        subtitle: Text(
                          'Automatically connect to this device when the app starts',
                          style: OdooTypography.bodySmall.copyWith(
                            color: OdooColors.textSecondary,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: OdooColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      // Notes
                      _buildTextField(
                        controller: _notesController,
                        label: 'Notes',
                        hint: 'Additional information...',
                        icon: Icons.note,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(OdooSpacing.lg),
              decoration: BoxDecoration(
                color: OdooColors.backgroundLight,
                border: Border(
                  top: BorderSide(color: OdooColors.border),
                ),
              ),
              child: Row(
                children: [
                  // Test Connection Button
                  if (_selectedConnectionType == DeviceConnectionType.network)
                    OutlinedButton.icon(
                      onPressed: _isTesting ? null : _testConnection,
                      icon: _isTesting
                          ? SizedBox(
                              width: OdooIconSizes.sm,
                              height: OdooIconSizes.sm,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  OdooColors.info,
                                ),
                              ),
                            )
                          : const Icon(Icons.wifi_tethering),
                      label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: OdooColors.info,
                        side: BorderSide(color: OdooColors.info),
                        padding: const EdgeInsets.symmetric(
                          horizontal: OdooSpacing.lg,
                          vertical: OdooSpacing.md,
                        ),
                      ),
                    ),
                  const Spacer(),

                  // Cancel Button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: OdooColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: OdooSpacing.xl,
                        vertical: OdooSpacing.md,
                      ),
                    ),
                  ),
                  const SizedBox(width: OdooSpacing.md),

                  // Save Button
                  ElevatedButton.icon(
                    onPressed: _saveDevice,
                    icon: const Icon(Icons.save),
                    label: Text(isEditing ? 'Update' : 'Add Device'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OdooColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: OdooSpacing.xl,
                        vertical: OdooSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: OdooTypography.labelLarge.copyWith(
            color: OdooColors.textPrimary,
          ),
        ),
        const SizedBox(height: OdooSpacing.sm),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: OdooIconSizes.md),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              borderSide: BorderSide(color: OdooColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              borderSide: BorderSide(color: OdooColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              borderSide: BorderSide(color: OdooColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              borderSide: BorderSide(color: OdooColors.danger),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: OdooSpacing.md,
              vertical: OdooSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: OdooTypography.labelLarge.copyWith(
            color: OdooColors.textPrimary,
          ),
        ),
        const SizedBox(height: OdooSpacing.sm),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemBuilder(item)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: OdooIconSizes.md),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              borderSide: BorderSide(color: OdooColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              borderSide: BorderSide(color: OdooColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              borderSide: BorderSide(color: OdooColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: OdooSpacing.md,
              vertical: OdooSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  String _getDeviceTypeName(DeviceType type) {
    switch (type) {
      case DeviceType.printer:
        return 'Printer';
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

  String _getDeviceStatusName(DeviceStatus status) {
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

  String _getConnectionTypeName(DeviceConnectionType type) {
    switch (type) {
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

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isTesting = true;
    });

    // Simulate network test
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final success = DateTime.now().second % 3 != 0; // Mock: ~66% success rate

    setState(() {
      _isTesting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Connection successful to ${_ipAddressController.text}'
              : 'Failed to connect to ${_ipAddressController.text}',
        ),
        backgroundColor: success ? OdooColors.success : OdooColors.danger,
      ),
    );
  }

  void _saveDevice() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final device = Device(
      id: widget.device?.id ?? 'dev-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      type: _selectedType,
      status: _selectedStatus,
      ipAddress: _ipAddressController.text.isNotEmpty
          ? _ipAddressController.text
          : null,
      port: _portController.text.isNotEmpty
          ? int.tryParse(_portController.text)
          : null,
      connectionType: _selectedConnectionType,
      lastSeen: DateTime.now(),
      location: _locationController.text.isNotEmpty
          ? _locationController.text
          : null,
      serialNumber: _serialNumberController.text.isNotEmpty
          ? _serialNumberController.text
          : null,
      firmwareVersion: _firmwareVersionController.text.isNotEmpty
          ? _firmwareVersionController.text
          : null,
      autoConnect: _autoConnect,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (widget.device != null) {
      // Update existing device
      ref.read(devicesProvider.notifier).updateDevice(widget.device!.id, device);
    } else {
      // Add new device
      ref.read(devicesProvider.notifier).addDevice(device);
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.device != null
              ? 'Device "${device.name}" updated successfully'
              : 'Device "${device.name}" added successfully',
        ),
        backgroundColor: OdooColors.success,
      ),
    );
  }
}
