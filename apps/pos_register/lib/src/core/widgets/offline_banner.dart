/// Offline Banner Widget
/// Shows connectivity status banner (Odoo pattern)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../services/connectivity_service.dart';

/// Offline mode banner that appears at the top of the screen
/// Following Odoo POS pattern: clear visual indicator of offline mode
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityStatusProvider);

    return connectivityStatus.when(
      data: (status) {
        if (status == ConnectivityStatus.online) {
          return const SizedBox.shrink();
        }

        // Show offline banner
        return _OfflineBannerContent(
          status: status,
          onRetry: () {
            ref.read(connectivityServiceProvider).checkConnectivity();
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Offline banner content widget
class _OfflineBannerContent extends ConsumerWidget {
  final ConnectivityStatus status;
  final VoidCallback onRetry;

  const _OfflineBannerContent({
    required this.status,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(connectivityServiceProvider);
    final offlineDuration = service.offlineDuration;

    return Material(
      color: VodoColors.warning,
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: VodoDimensions.paddingMd,
            vertical: VodoDimensions.paddingSm,
          ),
          child: Row(
            children: [
              // Offline icon
              const Icon(
                Icons.cloud_off,
                color: VodoColors.textOnWarning,
                size: 20,
              ),

              const SizedBox(width: VodoDimensions.spacingSm),

              // Status text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Working Offline',
                      style: VodoTextStyles.bodyMedium.copyWith(
                        color: VodoColors.textOnWarning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (offlineDuration != null)
                      Text(
                        _formatOfflineDuration(offlineDuration),
                        style: VodoTextStyles.bodySmall.copyWith(
                          color: VodoColors.textOnWarning.withOpacity(0.9),
                        ),
                      ),
                  ],
                ),
              ),

              // Retry button
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh,
                  size: 16,
                  color: VodoColors.textOnWarning,
                ),
                label: Text(
                  'Retry',
                  style: VodoTextStyles.bodySmall.copyWith(
                    color: VodoColors.textOnWarning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VodoDimensions.paddingSm,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),

              // Info button
              IconButton(
                onPressed: () => _showOfflineInfo(context, offlineDuration),
                icon: const Icon(
                  Icons.info_outline,
                  color: VodoColors.textOnWarning,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Offline mode info',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatOfflineDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return 'Offline for ${duration.inMinutes}m';
    } else if (duration.inHours < 24) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return 'Offline for ${hours}h ${minutes}m';
    } else {
      return 'Offline for ${duration.inDays}d';
    }
  }

  void _showOfflineInfo(BuildContext context, Duration? offlineDuration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cloud_off, color: VodoColors.warning),
            const SizedBox(width: VodoDimensions.spacingSm),
            const Text('Offline Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are currently working offline.',
              style: VodoTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: VodoDimensions.spacingMd),
            _buildInfoRow(
              icon: Icons.check_circle,
              text: 'You can continue taking orders',
              color: VodoColors.success,
            ),
            const SizedBox(height: VodoDimensions.spacingSm),
            _buildInfoRow(
              icon: Icons.check_circle,
              text: 'All data is saved locally',
              color: VodoColors.success,
            ),
            const SizedBox(height: VodoDimensions.spacingSm),
            _buildInfoRow(
              icon: Icons.sync,
              text: 'Orders will sync when connection returns',
              color: VodoColors.info,
            ),
            const SizedBox(height: VodoDimensions.spacingSm),
            _buildInfoRow(
              icon: Icons.warning_amber,
              text: 'Some features may be limited',
              color: VodoColors.warning,
            ),
            if (offlineDuration != null) ...[
              const SizedBox(height: VodoDimensions.spacingMd),
              Container(
                padding: VodoDimensions.paddingSm,
                decoration: BoxDecoration(
                  color: VodoColors.backgroundSecondary,
                  borderRadius: VodoDimensions.borderRadiusSm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: VodoColors.textSecondary,
                    ),
                    const SizedBox(width: VodoDimensions.spacingSm),
                    Text(
                      'Offline: ${_formatOfflineDuration(offlineDuration)}',
                      style: VodoTextStyles.bodySmall.copyWith(
                        color: VodoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Check Connection'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: VodoDimensions.spacingSm),
        Expanded(
          child: Text(
            text,
            style: VodoTextStyles.bodySmall.copyWith(
              color: VodoColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Sync queue indicator showing pending operations
class SyncQueueIndicator extends ConsumerWidget {
  const SyncQueueIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);

    // TODO: Watch sync queue count from database
    final pendingCount = 0; // Placeholder

    if (!isOffline || pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VodoDimensions.paddingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: VodoColors.info,
        borderRadius: VodoDimensions.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sync,
            color: VodoColors.textOnPrimary,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$pendingCount pending',
            style: VodoTextStyles.caption.copyWith(
              color: VodoColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
