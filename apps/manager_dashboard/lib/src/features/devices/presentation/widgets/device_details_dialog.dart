import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/device_models.dart';
import '../../providers/devices_providers.dart';

/// Device Details Dialog
///
/// Shows comprehensive device information including:
/// - Device details and status
/// - Connection information
/// - Device capabilities
/// - Configuration settings
/// - Connection logs
/// - Quick actions (Test, Edit)
class DeviceDetailsDialog extends ConsumerStatefulWidget {
  final Device device;

  const DeviceDetailsDialog({
    super.key,
    required this.device,
  });

  @override
  ConsumerState<DeviceDetailsDialog> createState() => _DeviceDetailsDialogState();
}

class _DeviceDetailsDialogState extends ConsumerState<DeviceDetailsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
      ),
      child: Container(
        width: 700,
        height: 600,
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: OdooColors.border),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: OdooColors.primary,
                unselectedLabelColor: OdooColors.textSecondary,
                indicatorColor: OdooColors.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.info),
                    text: 'Details',
                  ),
                  Tab(
                    icon: Icon(Icons.settings),
                    text: 'Configuration',
                  ),
                  Tab(
                    icon: Icon(Icons.history),
                    text: 'Logs',
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(),
                  _buildConfigurationTab(),
                  _buildLogsTab(),
                ],
              ),
            ),

            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      decoration: BoxDecoration(
        color: widget.device.statusColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(OdooSpacing.radiusStandard),
          topRight: Radius.circular(OdooSpacing.radiusStandard),
        ),
      ),
      child: Row(
        children: [
          // Device Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: widget.device.statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
            child: Icon(
              widget.device.typeIcon,
              size: OdooIconSizes.xl,
              color: widget.device.statusColor,
            ),
          ),
          const SizedBox(width: OdooSpacing.lg),

          // Device Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.device.name,
                        style: OdooTypography.titleLarge.copyWith(
                          color: OdooColors.textPrimary,
                        ),
                      ),
                    ),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: OdooSpacing.xs),
                Text(
                  widget.device.typeDisplayName,
                  style: OdooTypography.bodyMedium.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
                const SizedBox(height: OdooSpacing.xs),
                Row(
                  children: [
                    Icon(
                      widget.device.connectionIcon,
                      size: OdooIconSizes.sm,
                      color: OdooColors.textSecondary,
                    ),
                    const SizedBox(width: OdooSpacing.xs),
                    Text(
                      widget.device.connectionAddress,
                      style: OdooTypography.bodySmall.copyWith(
                        color: OdooColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Close Button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            color: OdooColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.md,
        vertical: OdooSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: widget.device.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        border: Border.all(
          color: widget.device.statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.device.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: OdooSpacing.sm),
          Text(
            widget.device.statusDisplayName,
            style: OdooTypography.labelMedium.copyWith(
              color: widget.device.statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OdooSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Basic Information'),
          const SizedBox(height: OdooSpacing.md),
          _buildInfoCard([
            _buildInfoRow('Device Name', widget.device.name),
            _buildInfoRow('Type', widget.device.typeDisplayName),
            _buildInfoRow('Status', widget.device.statusDisplayName),
            _buildInfoRow('Connection', widget.device.connectionDisplayName),
            if (widget.device.location != null)
              _buildInfoRow('Location', widget.device.location!),
          ]),
          const SizedBox(height: OdooSpacing.xl),

          _buildSectionTitle('Connection Details'),
          const SizedBox(height: OdooSpacing.md),
          _buildInfoCard([
            if (widget.device.ipAddress != null)
              _buildInfoRow('IP Address', widget.device.ipAddress!),
            if (widget.device.port != null)
              _buildInfoRow('Port', widget.device.port.toString()),
            _buildInfoRow('Auto-Connect', widget.device.autoConnect ? 'Yes' : 'No'),
            _buildInfoRow('Last Seen', _formatDateTime(widget.device.lastSeen)),
          ]),
          const SizedBox(height: OdooSpacing.xl),

          _buildSectionTitle('Device Information'),
          const SizedBox(height: OdooSpacing.md),
          _buildInfoCard([
            if (widget.device.serialNumber != null)
              _buildInfoRow('Serial Number', widget.device.serialNumber!),
            if (widget.device.firmwareVersion != null)
              _buildInfoRow('Firmware Version', widget.device.firmwareVersion!),
          ]),

          if (widget.device.capabilities != null && widget.device.capabilities!.isNotEmpty) ...[
            const SizedBox(height: OdooSpacing.xl),
            _buildSectionTitle('Capabilities'),
            const SizedBox(height: OdooSpacing.md),
            _buildInfoCard([
              for (final entry in widget.device.capabilities!.entries)
                _buildInfoRow(
                  _formatKey(entry.key),
                  entry.value.toString(),
                ),
            ]),
          ],

          if (widget.device.notes != null && widget.device.notes!.isNotEmpty) ...[
            const SizedBox(height: OdooSpacing.xl),
            _buildSectionTitle('Notes'),
            const SizedBox(height: OdooSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(OdooSpacing.md),
              decoration: BoxDecoration(
                color: OdooColors.warningLight,
                borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                border: Border.all(color: OdooColors.warning),
              ),
              child: Text(
                widget.device.notes!,
                style: OdooTypography.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfigurationTab() {
    final settings = widget.device.settings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OdooSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (settings != null && settings.isNotEmpty) ...[
            _buildSectionTitle('Device Settings'),
            const SizedBox(height: OdooSpacing.md),
            _buildInfoCard([
              for (final entry in settings.entries)
                _buildInfoRow(
                  _formatKey(entry.key),
                  entry.value.toString(),
                ),
            ]),
            const SizedBox(height: OdooSpacing.xl),
          ],

          _buildSectionTitle('Connection Settings'),
          const SizedBox(height: OdooSpacing.md),
          _buildInfoCard([
            _buildSettingRow(
              'Auto-Connect',
              'Automatically connect to this device on startup',
              widget.device.autoConnect,
            ),
          ]),

          const SizedBox(height: OdooSpacing.xl),
          Text(
            'To modify device settings, use the Edit button.',
            style: OdooTypography.bodySmall.copyWith(
              color: OdooColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    final logs = ref.watch(deviceConnectionLogsProvider);
    final deviceLogs = logs.where((log) => log.deviceId == widget.device.id).toList();

    return Column(
      children: [
        if (deviceLogs.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: OdooIconSizes.xxl,
                    color: OdooColors.textDisabled,
                  ),
                  const SizedBox(height: OdooSpacing.md),
                  Text(
                    'No connection logs yet',
                    style: OdooTypography.bodyMedium.copyWith(
                      color: OdooColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(OdooSpacing.lg),
              itemCount: deviceLogs.length,
              separatorBuilder: (context, index) => Divider(
                color: OdooColors.border,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final log = deviceLogs[index];
                return _buildLogItem(log);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLogItem(DeviceConnectionLog log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OdooSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: log.success
                  ? OdooColors.success.withOpacity(0.1)
                  : OdooColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
            child: Icon(
              log.success ? Icons.check_circle : Icons.error,
              size: OdooIconSizes.md,
              color: log.success ? OdooColors.success : OdooColors.danger,
            ),
          ),
          const SizedBox(width: OdooSpacing.md),

          // Log Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.event,
                  style: OdooTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: OdooColors.textPrimary,
                  ),
                ),
                if (log.details != null) ...[
                  const SizedBox(height: OdooSpacing.xs),
                  Text(
                    log.details!,
                    style: OdooTypography.bodySmall.copyWith(
                      color: OdooColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: OdooSpacing.xs),
                Text(
                  _formatDateTime(log.timestamp),
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
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
          if (widget.device.connectionType == DeviceConnectionType.network)
            ElevatedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? SizedBox(
                      width: OdooIconSizes.sm,
                      height: OdooIconSizes.sm,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OdooColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: OdooSpacing.lg,
                  vertical: OdooSpacing.md,
                ),
              ),
            ),

          const Spacer(),

          // Close Button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
            style: TextButton.styleFrom(
              foregroundColor: OdooColors.textSecondary,
              padding: const EdgeInsets.symmetric(
                horizontal: OdooSpacing.xl,
                vertical: OdooSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: OdooTypography.titleMedium.copyWith(
        fontWeight: FontWeight.w700,
        color: OdooColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        border: Border.all(color: OdooColors.border),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: OdooColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: OdooTypography.bodyMedium.copyWith(
                color: OdooColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: OdooTypography.bodyMedium.copyWith(
                color: OdooColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, String description, bool value) {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: OdooColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: OdooTypography.bodyMedium.copyWith(
                    color: OdooColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: OdooSpacing.xs),
                Text(
                  description,
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: OdooSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: OdooSpacing.md,
              vertical: OdooSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: value
                  ? OdooColors.success.withOpacity(0.1)
                  : OdooColors.gray300,
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
            child: Text(
              value ? 'Enabled' : 'Disabled',
              style: OdooTypography.labelSmall.copyWith(
                color: value ? OdooColors.success : OdooColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    // Convert snake_case to Title Case
    return key
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
    });

    final success = await ref.read(devicesProvider.notifier).testConnection(widget.device.id);

    if (!mounted) return;

    setState(() {
      _isTesting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Connection successful'
              : 'Connection failed',
        ),
        backgroundColor: success ? OdooColors.success : OdooColors.danger,
      ),
    );

    // Add log entry
    final log = DeviceConnectionLog(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      deviceId: widget.device.id,
      deviceName: widget.device.name,
      timestamp: DateTime.now(),
      event: 'Manual Connection Test',
      details: success ? 'Connection successful' : 'Connection failed',
      success: success,
    );
    ref.read(deviceConnectionLogsProvider.notifier).addLog(log);

    // Switch to logs tab to show the new entry
    if (success || !success) {
      _tabController.animateTo(2);
    }
  }
}
