import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/device_models.dart';
import '../../providers/devices_providers.dart';
import '../widgets/device_card.dart';
import '../widgets/device_form_dialog.dart';
import '../widgets/device_details_dialog.dart';

/// Devices Management Page - Hardware device management
///
/// Features:
/// - Device inventory and status monitoring
/// - Add/Edit/Delete devices
/// - Test device connections
/// - Filter by type and status
/// - Grid/List view toggle
/// - Search functionality
class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  bool _isGridView = true;
  DeviceType? _selectedType;
  DeviceStatus? _selectedStatus;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(deviceStatsProvider);

    return Container(
      color: OdooColors.backgroundLight,
      child: Column(
        children: [
          // Toolbar
          _buildToolbar(stats),

          // Filters and Search Bar
          _buildFiltersAndSearch(),

          // Device Grid/List
          Expanded(
            child: _buildDeviceView(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(DeviceStats stats) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.xl,
        vertical: OdooSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.devices,
            size: OdooIconSizes.xl,
            color: OdooColors.primary,
          ),
          const SizedBox(width: OdooSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Devices Management',
                style: OdooTypography.pageTitle.copyWith(
                  color: OdooColors.textPrimary,
                ),
              ),
              Text(
                'Manage hardware devices and connections',
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Quick Stats
          _buildQuickStat(
            icon: Icons.devices,
            label: 'Total',
            value: '${stats.total}',
            color: OdooColors.primary,
          ),
          const SizedBox(width: OdooSpacing.lg),
          _buildQuickStat(
            icon: Icons.check_circle,
            label: 'Online',
            value: '${stats.online}',
            color: OdooColors.success,
          ),
          const SizedBox(width: OdooSpacing.lg),
          _buildQuickStat(
            icon: Icons.error,
            label: 'Issues',
            value: '${stats.error + stats.offline}',
            color: stats.error + stats.offline > 0
                ? OdooColors.danger
                : OdooColors.textSecondary,
          ),
          const SizedBox(width: OdooSpacing.lg),
          _buildQuickStat(
            icon: Icons.build,
            label: 'Maintenance',
            value: '${stats.maintenance}',
            color: OdooColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.lg,
        vertical: OdooSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: OdooIconSizes.md,
            color: color,
          ),
          const SizedBox(width: OdooSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: OdooTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Search Bar
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search devices...',
                    hintStyle: OdooTypography.bodyMedium.copyWith(
                      color: OdooColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: OdooColors.textSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
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
                    filled: true,
                    fillColor: OdooColors.backgroundLight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: OdooSpacing.md,
                      vertical: OdooSpacing.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: OdooSpacing.md),

              // View Toggle
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: OdooColors.border),
                  borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view,
                        color: _isGridView ? OdooColors.primary : OdooColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isGridView = true;
                        });
                      },
                      tooltip: 'Grid View',
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: OdooColors.border,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.list,
                        color: !_isGridView ? OdooColors.primary : OdooColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isGridView = false;
                        });
                      },
                      tooltip: 'List View',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: OdooSpacing.md),

              // Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshDevices,
                tooltip: 'Refresh',
                color: OdooColors.primary,
              ),
              const SizedBox(width: OdooSpacing.md),

              // Add Device Button
              ElevatedButton.icon(
                onPressed: _showAddDeviceDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OdooColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: OdooSpacing.lg,
                    vertical: OdooSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: OdooSpacing.md),

          // Filter Chips
          Wrap(
            spacing: OdooSpacing.sm,
            runSpacing: OdooSpacing.sm,
            children: [
              // Type Filters
              _buildFilterChip(
                label: 'All Types',
                selected: _selectedType == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = null;
                  });
                },
              ),
              ...DeviceType.values.map((type) {
                return _buildFilterChip(
                  label: _getDeviceTypeName(type),
                  icon: _getDeviceTypeIcon(type),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? type : null;
                    });
                  },
                );
              }).toList(),

              const SizedBox(width: OdooSpacing.md),
              Container(
                width: 1,
                height: 32,
                color: OdooColors.border,
              ),
              const SizedBox(width: OdooSpacing.md),

              // Status Filters
              _buildFilterChip(
                label: 'All Status',
                selected: _selectedStatus == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = null;
                  });
                },
              ),
              ...DeviceStatus.values.map((status) {
                return _buildFilterChip(
                  label: _getDeviceStatusName(status),
                  color: _getDeviceStatusColor(status),
                  selected: _selectedStatus == status,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    Color? color,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: OdooIconSizes.sm,
              color: selected ? Colors.white : OdooColors.textSecondary,
            ),
            const SizedBox(width: OdooSpacing.xs),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: color?.withOpacity(0.1) ?? OdooColors.gray100,
      selectedColor: color ?? OdooColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: OdooTypography.bodySmall.copyWith(
        color: selected ? Colors.white : OdooColors.textPrimary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        side: BorderSide(
          color: selected ? (color ?? OdooColors.primary) : OdooColors.border,
        ),
      ),
    );
  }

  Widget _buildDeviceView() {
    final allDevices = ref.watch(devicesProvider);

    // Apply filters
    var filteredDevices = allDevices.where((device) {
      if (_selectedType != null && device.type != _selectedType) {
        return false;
      }
      if (_selectedStatus != null && device.status != _selectedStatus) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return device.name.toLowerCase().contains(query) ||
            device.typeDisplayName.toLowerCase().contains(query) ||
            device.location?.toLowerCase().contains(query) == true;
      }
      return true;
    }).toList();

    if (filteredDevices.isEmpty) {
      return _buildEmptyState();
    }

    return _isGridView
        ? _buildGridView(filteredDevices)
        : _buildListView(filteredDevices);
  }

  Widget _buildGridView(List<Device> devices) {
    return GridView.builder(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.5,
        crossAxisSpacing: OdooSpacing.lg,
        mainAxisSpacing: OdooSpacing.lg,
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return DeviceCard(
          device: devices[index],
          onEdit: () => _showEditDeviceDialog(devices[index]),
          onDelete: () => _deleteDevice(devices[index]),
          onTest: () => _testConnection(devices[index]),
          onTap: () => _showDeviceDetails(devices[index]),
        );
      },
    );
  }

  Widget _buildListView(List<Device> devices) {
    return ListView.separated(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      itemCount: devices.length,
      separatorBuilder: (context, index) => const SizedBox(height: OdooSpacing.md),
      itemBuilder: (context, index) {
        return DeviceCard(
          device: devices[index],
          isCompact: true,
          onEdit: () => _showEditDeviceDialog(devices[index]),
          onDelete: () => _deleteDevice(devices[index]),
          onTest: () => _testConnection(devices[index]),
          onTap: () => _showDeviceDetails(devices[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: OdooIconSizes.xxl * 2,
            color: OdooColors.textDisabled,
          ),
          const SizedBox(height: OdooSpacing.lg),
          Text(
            'No devices found',
            style: OdooTypography.titleLarge.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.sm),
          Text(
            _searchQuery.isNotEmpty || _selectedType != null || _selectedStatus != null
                ? 'Try adjusting your filters'
                : 'Add your first device to get started',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          if (_searchQuery.isEmpty && _selectedType == null && _selectedStatus == null) ...[
            const SizedBox(height: OdooSpacing.xl),
            ElevatedButton.icon(
              onPressed: _showAddDeviceDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Device'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OdooColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: OdooSpacing.xl,
                  vertical: OdooSpacing.md,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods for device type and status
  String _getDeviceTypeName(DeviceType type) {
    switch (type) {
      case DeviceType.printer:
        return 'Printers';
      case DeviceType.scanner:
        return 'Scanners';
      case DeviceType.paymentTerminal:
        return 'Terminals';
      case DeviceType.display:
        return 'Displays';
      case DeviceType.cashDrawer:
        return 'Cash Drawers';
      case DeviceType.scale:
        return 'Scales';
      case DeviceType.kds:
        return 'KDS';
      case DeviceType.tablet:
        return 'Tablets';
    }
  }

  IconData _getDeviceTypeIcon(DeviceType type) {
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

  Color _getDeviceStatusColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return OdooColors.success;
      case DeviceStatus.offline:
        return OdooColors.gray500;
      case DeviceStatus.error:
        return OdooColors.danger;
      case DeviceStatus.maintenance:
        return OdooColors.warning;
    }
  }

  // Action methods
  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) => const DeviceFormDialog(),
    );
  }

  void _showEditDeviceDialog(Device device) {
    showDialog(
      context: context,
      builder: (context) => DeviceFormDialog(device: device),
    );
  }

  void _deleteDevice(Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text('Are you sure you want to delete "${device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(devicesProvider.notifier).deleteDevice(device.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Device "${device.name}" deleted'),
                  backgroundColor: OdooColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: OdooColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection(Device device) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Testing connection to ${device.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );

    final success = await ref.read(devicesProvider.notifier).testConnection(device.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Connection to ${device.name} successful'
              : 'Failed to connect to ${device.name}',
        ),
        backgroundColor: success ? OdooColors.success : OdooColors.danger,
      ),
    );
  }

  void _showDeviceDetails(Device device) {
    showDialog(
      context: context,
      builder: (context) => DeviceDetailsDialog(device: device),
    );
  }

  Future<void> _refreshDevices() async {
    await ref.read(devicesProvider.notifier).refreshDevices();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Devices refreshed'),
        backgroundColor: OdooColors.success,
        duration: Duration(seconds: 1),
      ),
    );
  }
}
