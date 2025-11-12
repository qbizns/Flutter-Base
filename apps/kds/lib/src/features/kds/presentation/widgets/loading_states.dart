/// Loading State Widgets
/// Shimmer loading states and error displays following Odoo patterns
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

import 'order_animations.dart';

/// Order Card Skeleton
/// Loading placeholder for order cards
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Card(
        elevation: VodoDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: VodoDimensions.borderRadiusMd,
        ),
        child: Container(
          padding: VodoDimensions.paddingMd,
          constraints: const BoxConstraints(minHeight: 250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBox(width: 80, height: 20),
                  _buildBox(width: 60, height: 20),
                ],
              ),

              const SizedBox(height: VodoDimensions.spacingMd),

              // Items skeleton
              _buildBox(width: double.infinity, height: 40),
              const SizedBox(height: VodoDimensions.spacingSm),
              _buildBox(width: double.infinity, height: 40),
              const SizedBox(height: VodoDimensions.spacingSm),
              _buildBox(width: 200, height: 40),

              const Spacer(),

              // Footer skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBox(width: 100, height: 36),
                  _buildBox(width: 120, height: 36),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: VodoColors.backgroundSecondary,
        borderRadius: VodoDimensions.borderRadiusSm,
      ),
    );
  }
}

/// Loading Grid
/// Shows grid of skeleton cards
class LoadingGrid extends StatelessWidget {
  final int columns;
  final int rows;

  const LoadingGrid({
    super.key,
    this.columns = 3,
    this.rows = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: VodoDimensions.paddingMd,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 0.75,
        crossAxisSpacing: VodoDimensions.spacingMd,
        mainAxisSpacing: VodoDimensions.spacingMd,
      ),
      itemCount: columns * rows,
      itemBuilder: (context, index) => const OrderCardSkeleton(),
    );
  }
}

/// Empty State Widget
/// Shows when no orders are available
class EmptyOrdersState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRefresh;

  const EmptyOrdersState({
    super.key,
    this.title = 'No Orders',
    this.message = 'No orders to display at the moment',
    this.icon = Icons.restaurant_menu,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: VodoDimensions.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: VodoColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: VodoColors.primary,
              ),
            ),

            const SizedBox(height: VodoDimensions.spacingLg),

            // Title
            Text(
              title,
              style: VodoTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: VodoColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: VodoDimensions.spacingSm),

            // Message
            Text(
              message,
              style: VodoTextStyles.bodyMedium.copyWith(
                color: VodoColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            if (onRefresh != null) ...[
              const SizedBox(height: VodoDimensions.spacingLg),

              // Refresh button
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VodoColors.primary,
                  foregroundColor: VodoColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error State Widget
/// Shows when an error occurs with retry option
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? errorDetails;
  final VoidCallback? onRetry;
  final bool showDetails;

  const ErrorStateWidget({
    super.key,
    this.title = 'Something Went Wrong',
    this.message = 'An error occurred while loading orders',
    this.errorDetails,
    this.onRetry,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: VodoDimensions.paddingXl,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: VodoColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: VodoColors.danger,
              ),
            ),

            const SizedBox(height: VodoDimensions.spacingLg),

            // Title
            Text(
              title,
              style: VodoTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: VodoColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: VodoDimensions.spacingSm),

            // Message
            Text(
              message,
              style: VodoTextStyles.bodyMedium.copyWith(
                color: VodoColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            // Error details (expandable)
            if (showDetails && errorDetails != null) ...[
              const SizedBox(height: VodoDimensions.spacingMd),
              ExpansionTile(
                title: const Text(
                  'Error Details',
                  style: TextStyle(fontSize: 14),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: VodoDimensions.paddingSm,
                    decoration: BoxDecoration(
                      color: VodoColors.backgroundSecondary,
                      borderRadius: VodoDimensions.borderRadiusSm,
                    ),
                    child: Text(
                      errorDetails!,
                      style: VodoTextStyles.caption.copyWith(
                        fontFamily: 'monospace',
                        color: VodoColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (onRetry != null) ...[
              const SizedBox(height: VodoDimensions.spacingLg),

              // Retry button
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VodoColors.primary,
                  foregroundColor: VodoColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Connection Error Widget
/// Specific error for connection issues
class ConnectionErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const ConnectionErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Connection Lost',
      message: customMessage ??
          'Unable to connect to the server. Please check your internet connection and try again.',
      onRetry: onRetry,
    );
  }
}

/// Loading Overlay
/// Shows loading indicator over content
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                elevation: VodoDimensions.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: VodoDimensions.borderRadiusMd,
                ),
                child: Container(
                  padding: VodoDimensions.paddingLg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          VodoColors.primary,
                        ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: VodoDimensions.spacingMd),
                        Text(
                          message!,
                          style: VodoTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Status Message Banner
/// Shows status messages at top of screen
class StatusMessageBanner extends StatelessWidget {
  final String message;
  final StatusType type;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const StatusMessageBanner({
    super.key,
    required this.message,
    this.type = StatusType.info,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: _getBackgroundColor(),
      child: Container(
        padding: VodoDimensions.paddingMd,
        child: Row(
          children: [
            Icon(
              _getIcon(),
              color: VodoColors.textOnPrimary,
              size: 20,
            ),
            const SizedBox(width: VodoDimensions.spacingMd),
            Expanded(
              child: Text(
                message,
                style: VodoTextStyles.bodyMedium.copyWith(
                  color: VodoColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: VodoColors.textOnPrimary,
                ),
                child: Text(actionLabel!),
              ),
            ],
            if (onDismiss != null) ...[
              IconButton(
                icon: const Icon(Icons.close),
                color: VodoColors.textOnPrimary,
                onPressed: onDismiss,
                iconSize: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case StatusType.success:
        return VodoColors.success;
      case StatusType.warning:
        return VodoColors.warning;
      case StatusType.error:
        return VodoColors.danger;
      case StatusType.info:
        return VodoColors.info;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.warning:
        return Icons.warning;
      case StatusType.error:
        return Icons.error;
      case StatusType.info:
        return Icons.info;
    }
  }
}

enum StatusType {
  success,
  warning,
  error,
  info;
}

/// Retry Widget
/// Simple retry button component
class RetryButton extends StatelessWidget {
  final VoidCallback onRetry;
  final String label;
  final bool isLoading;

  const RetryButton({
    super.key,
    required this.onRetry,
    this.label = 'Retry',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onRetry,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.refresh),
      label: Text(isLoading ? 'Retrying...' : label),
      style: ElevatedButton.styleFrom(
        backgroundColor: VodoColors.primary,
        foregroundColor: VodoColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        disabledBackgroundColor: VodoColors.primary.withOpacity(0.6),
      ),
    );
  }
}
