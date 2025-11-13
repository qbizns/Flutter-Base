import 'package:flutter/material.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/device_models.dart';

/// Device Card Widget
///
/// Displays device information in a card format with:
/// - Device icon and status indicator
/// - Device name, type, and connection info
/// - Last seen timestamp
/// - Quick action buttons (Edit, Test, Delete)
/// - Hover effects
class DeviceCard extends StatefulWidget {
  final Device device;
  final bool isCompact;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTest;

  const DeviceCard({
    super.key,
    required this.device,
    this.isCompact = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onTest,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          border: Border.all(
            color: _isHovered ? OdooColors.primary : OdooColors.border,
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: OdooColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          child: widget.isCompact ? _buildCompactLayout() : _buildGridLayout(),
        ),
      ),
    );
  }

  Widget _buildGridLayout() {
    return Padding(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and status
          Row(
            children: [
              // Device Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.device.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                ),
                child: Icon(
                  widget.device.typeIcon,
                  size: OdooIconSizes.lg,
                  color: widget.device.statusColor,
                ),
              ),
              const SizedBox(width: OdooSpacing.md),

              // Status Indicator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.device.name,
                      style: OdooTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: OdooColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: OdooSpacing.xs),
                    _buildStatusBadge(),
                  ],
                ),
              ),

              // Action Buttons
              if (_isHovered) _buildActionButtons(),
            ],
          ),

          const Spacer(),

          // Device Type
          Row(
            children: [
              Icon(
                widget.device.typeIcon,
                size: OdooIconSizes.sm,
                color: OdooColors.textSecondary,
              ),
              const SizedBox(width: OdooSpacing.xs),
              Text(
                widget.device.typeDisplayName,
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: OdooSpacing.sm),

          // Connection Info
          Row(
            children: [
              Icon(
                widget.device.connectionIcon,
                size: OdooIconSizes.sm,
                color: OdooColors.textSecondary,
              ),
              const SizedBox(width: OdooSpacing.xs),
              Expanded(
                child: Text(
                  widget.device.connectionAddress,
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Location (if available)
          if (widget.device.location != null) ...[
            const SizedBox(height: OdooSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: OdooIconSizes.sm,
                  color: OdooColors.textSecondary,
                ),
                const SizedBox(width: OdooSpacing.xs),
                Expanded(
                  child: Text(
                    widget.device.location!,
                    style: OdooTypography.bodySmall.copyWith(
                      color: OdooColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: OdooSpacing.md),

          // Last Seen
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: OdooIconSizes.sm,
                color: OdooColors.textSecondary,
              ),
              const SizedBox(width: OdooSpacing.xs),
              Text(
                'Last seen: ${widget.device.timeSinceLastSeen}',
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Padding(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Row(
        children: [
          // Device Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.device.statusColor.withOpacity(0.1),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.device.name,
                        style: OdooTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: OdooSpacing.md),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: OdooSpacing.sm),
                Row(
                  children: [
                    Icon(
                      widget.device.typeIcon,
                      size: OdooIconSizes.sm,
                      color: OdooColors.textSecondary,
                    ),
                    const SizedBox(width: OdooSpacing.xs),
                    Text(
                      widget.device.typeDisplayName,
                      style: OdooTypography.bodySmall.copyWith(
                        color: OdooColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: OdooSpacing.lg),
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
                    if (widget.device.location != null) ...[
                      const SizedBox(width: OdooSpacing.lg),
                      Icon(
                        Icons.location_on,
                        size: OdooIconSizes.sm,
                        color: OdooColors.textSecondary,
                      ),
                      const SizedBox(width: OdooSpacing.xs),
                      Text(
                        widget.device.location!,
                        style: OdooTypography.bodySmall.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      widget.device.timeSinceLastSeen,
                      style: OdooTypography.bodySmall.copyWith(
                        color: OdooColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          if (_isHovered) ...[
            const SizedBox(width: OdooSpacing.lg),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.sm,
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
          const SizedBox(width: OdooSpacing.xs),
          Text(
            widget.device.statusDisplayName,
            style: OdooTypography.labelSmall.copyWith(
              color: widget.device.statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Test Connection Button
        if (widget.onTest != null)
          IconButton(
            icon: const Icon(Icons.wifi_tethering),
            tooltip: 'Test Connection',
            onPressed: widget.onTest,
            color: OdooColors.info,
            iconSize: OdooIconSizes.md,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),

        // Edit Button
        if (widget.onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Device',
            onPressed: widget.onEdit,
            color: OdooColors.primary,
            iconSize: OdooIconSizes.md,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),

        // Delete Button
        if (widget.onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Device',
            onPressed: widget.onDelete,
            color: OdooColors.danger,
            iconSize: OdooIconSizes.md,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }
}
