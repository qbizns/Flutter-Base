/// Sync Status Indicator Widget
/// Shows online/offline status and sync progress
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../../../../data/services/sync_service.dart';

/// Sync status indicator widget
class SyncStatusIndicator extends ConsumerWidget {
  final bool showLabel;
  final bool compact;

  const SyncStatusIndicator({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStateAsync = ref.watch(syncStateProvider);

    return syncStateAsync.when(
      data: (syncState) => _buildStatusIndicator(context, syncState),
      loading: () => _buildLoadingIndicator(),
      error: (_, __) => _buildErrorIndicator(),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, SyncState syncState) {
    final color = _getStatusColor(syncState);
    final icon = _getStatusIcon(syncState);
    final label = _getStatusLabel(syncState);

    if (compact) {
      return _buildCompactIndicator(color, icon);
    }

    return InkWell(
      onTap: () => _showSyncDetails(context, syncState),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: VodoDimensions.spacingSm,
          vertical: VodoDimensions.spacingXs,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: VodoDimensions.borderRadiusSm,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            if (showLabel) ...[
              const SizedBox(width: VodoDimensions.spacingXs),
              Text(
                label,
                style: VodoTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (syncState.pendingOperations > 0) ...[
              const SizedBox(width: VodoDimensions.spacingXs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${syncState.pendingOperations}',
                  style: VodoTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactIndicator(Color color, IconData icon) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(VodoDimensions.spacingXs),
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VodoDimensions.spacingSm,
        vertical: VodoDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: VodoColors.danger.withOpacity(0.1),
        borderRadius: VodoDimensions.borderRadiusSm,
      ),
      child: const Icon(
        Icons.error_outline,
        size: 16,
        color: VodoColors.danger,
      ),
    );
  }

  Color _getStatusColor(SyncState syncState) {
    if (!syncState.isOnline) return VodoColors.danger;

    switch (syncState.status) {
      case SyncStatus.idle:
        return VodoColors.textSecondary;
      case SyncStatus.syncing:
        return VodoColors.info;
      case SyncStatus.success:
        return VodoColors.success;
      case SyncStatus.error:
        return VodoColors.warning;
      case SyncStatus.offline:
        return VodoColors.danger;
    }
  }

  IconData _getStatusIcon(SyncState syncState) {
    if (!syncState.isOnline) return Icons.cloud_off;

    switch (syncState.status) {
      case SyncStatus.idle:
        return Icons.cloud_done;
      case SyncStatus.syncing:
        return Icons.cloud_sync;
      case SyncStatus.success:
        return Icons.cloud_done;
      case SyncStatus.error:
        return Icons.cloud_off;
      case SyncStatus.offline:
        return Icons.cloud_off;
    }
  }

  String _getStatusLabel(SyncState syncState) {
    if (!syncState.isOnline) return 'Offline';

    switch (syncState.status) {
      case SyncStatus.idle:
        return 'Synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.success:
        return 'Synced';
      case SyncStatus.error:
        return 'Sync Error';
      case SyncStatus.offline:
        return 'Offline';
    }
  }

  void _showSyncDetails(BuildContext context, SyncState syncState) {
    showDialog(
      context: context,
      builder: (context) => _SyncDetailsDialog(syncState: syncState),
    );
  }
}

/// Sync details dialog
class _SyncDetailsDialog extends ConsumerWidget {
  final SyncState syncState;

  const _SyncDetailsDialog({required this.syncState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastSyncText = syncState.lastSyncTime != null
        ? _formatLastSync(syncState.lastSyncTime!)
        : 'Never';

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            syncState.isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: syncState.isOnline ? VodoColors.success : VodoColors.danger,
          ),
          const SizedBox(width: VodoDimensions.spacingSm),
          const Text('Sync Status'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            'Connection',
            syncState.isOnline ? 'Online' : 'Offline',
            syncState.isOnline ? VodoColors.success : VodoColors.danger,
          ),
          const SizedBox(height: VodoDimensions.spacingSm),
          _buildDetailRow(
            'Status',
            _getStatusText(syncState.status),
            _getStatusColor(syncState),
          ),
          const SizedBox(height: VodoDimensions.spacingSm),
          _buildDetailRow(
            'Last Sync',
            lastSyncText,
            VodoColors.textSecondary,
          ),
          if (syncState.pendingOperations > 0) ...[
            const SizedBox(height: VodoDimensions.spacingSm),
            _buildDetailRow(
              'Pending',
              '${syncState.pendingOperations} operations',
              VodoColors.warning,
            ),
          ],
          if (syncState.errorMessage != null) ...[
            const SizedBox(height: VodoDimensions.spacingSm),
            Container(
              padding: VodoDimensions.paddingSm,
              decoration: BoxDecoration(
                color: VodoColors.danger.withOpacity(0.1),
                borderRadius: VodoDimensions.borderRadiusSm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: VodoColors.danger,
                  ),
                  const SizedBox(width: VodoDimensions.spacingXs),
                  Expanded(
                    child: Text(
                      syncState.errorMessage!,
                      style: VodoTextStyles.caption.copyWith(
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
      actions: [
        if (syncState.isOnline && syncState.status != SyncStatus.syncing)
          TextButton.icon(
            onPressed: () {
              ref.read(syncServiceProvider).forceSyncNow();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.sync),
            label: const Text('Sync Now'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: VodoTextStyles.bodyMedium.copyWith(
            color: VodoColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: VodoTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(SyncState syncState) {
    if (!syncState.isOnline) return VodoColors.danger;

    switch (syncState.status) {
      case SyncStatus.idle:
        return VodoColors.textSecondary;
      case SyncStatus.syncing:
        return VodoColors.info;
      case SyncStatus.success:
        return VodoColors.success;
      case SyncStatus.error:
        return VodoColors.warning;
      case SyncStatus.offline:
        return VodoColors.danger;
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Idle';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.success:
        return 'Success';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.offline:
        return 'Offline';
    }
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Floating sync status button
class FloatingSyncStatusButton extends ConsumerWidget {
  const FloatingSyncStatusButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStateAsync = ref.watch(syncStateProvider);

    return syncStateAsync.when(
      data: (syncState) {
        // Only show if there are pending operations or offline
        if (syncState.pendingOperations == 0 && syncState.isOnline) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: 16,
          right: 16,
          child: Material(
            elevation: 4,
            borderRadius: VodoDimensions.borderRadiusMd,
            child: InkWell(
              onTap: () => _showSyncDialog(context, syncState, ref),
              borderRadius: VodoDimensions.borderRadiusMd,
              child: Container(
                padding: VodoDimensions.paddingMd,
                decoration: BoxDecoration(
                  color: syncState.isOnline
                      ? VodoColors.warning.withOpacity(0.1)
                      : VodoColors.danger.withOpacity(0.1),
                  borderRadius: VodoDimensions.borderRadiusMd,
                  border: Border.all(
                    color: syncState.isOnline
                        ? VodoColors.warning
                        : VodoColors.danger,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      syncState.isOnline ? Icons.cloud_sync : Icons.cloud_off,
                      size: 20,
                      color: syncState.isOnline
                          ? VodoColors.warning
                          : VodoColors.danger,
                    ),
                    const SizedBox(width: VodoDimensions.spacingSm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          syncState.isOnline ? 'Pending Sync' : 'Offline Mode',
                          style: VodoTextStyles.labelSmall.copyWith(
                            color: syncState.isOnline
                                ? VodoColors.warning
                                : VodoColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (syncState.pendingOperations > 0)
                          Text(
                            '${syncState.pendingOperations} operations',
                            style: VodoTextStyles.caption.copyWith(
                              color: VodoColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showSyncDialog(BuildContext context, SyncState syncState, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _SyncDetailsDialog(syncState: syncState),
    );
  }
}
