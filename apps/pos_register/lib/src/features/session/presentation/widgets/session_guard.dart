/// Session Guard Widget
/// Vodo-style guard that ensures POS session is open before allowing transactions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import '../../application/session_providers.dart';
import '../pages/session_open_page.dart';

/// Session guard widget that ensures active session before allowing POS operations
///
/// Following Odoo POS pattern:
/// - Blocks POS operations when no session is open
/// - Shows session open prompt
/// - Allows transactions only when session is active
class SessionGuard extends ConsumerWidget {
  final Widget child;
  final bool requireOpenSession;

  const SessionGuard({
    super.key,
    required this.child,
    this.requireOpenSession = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!requireOpenSession) {
      return child;
    }

    final sessionState = ref.watch(currentSessionProvider);

    return sessionState.when(
      data: (session) {
        if (session == null) {
          // No active session - show session required screen
          return _SessionRequiredScreen(
            onOpenSession: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SessionOpenPage(),
                ),
              );
            },
          );
        }

        // Session exists - allow access
        return child;
      },
      loading: () => _SessionLoadingScreen(),
      error: (error, stack) => _SessionErrorScreen(
        error: error,
        onRetry: () {
          ref.read(currentSessionProvider.notifier).refresh();
        },
      ),
    );
  }
}

/// Session required screen (Odoo-style)
class _SessionRequiredScreen extends StatelessWidget {
  final VoidCallback onOpenSession;

  const _SessionRequiredScreen({
    required this.onOpenSession,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: VodoDimensions.paddingXl,
          child: Card(
            elevation: VodoDimensions.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: VodoDimensions.borderRadiusMd,
            ),
            child: Padding(
              padding: VodoDimensions.cardPaddingXl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Odoo-style icon
                  Container(
                    padding: VodoDimensions.paddingXl,
                    decoration: BoxDecoration(
                      color: VodoColors.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_open,
                      size: 80,
                      color: VodoColors.warning,
                    ),
                  ),

                  const SizedBox(height: VodoDimensions.spacingXl),

                  // Title
                  Text(
                    'Session Required',
                    style: VodoTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: VodoDimensions.spacingMd),

                  // Description
                  Text(
                    'You need to open a POS session before you can start processing orders. '
                    'Please count your opening cash and start a new session.',
                    style: VodoTextStyles.bodyLarge.copyWith(
                      color: VodoColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: VodoDimensions.spacingXl),

                  // Odoo-style information box
                  Container(
                    padding: VodoDimensions.paddingMd,
                    decoration: BoxDecoration(
                      color: VodoColors.info.withOpacity(0.1),
                      borderRadius: VodoDimensions.borderRadiusMd,
                      border: Border.all(
                        color: VodoColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: VodoColors.info,
                          size: VodoDimensions.iconSizeMd,
                        ),
                        const SizedBox(width: VodoDimensions.spacingMd),
                        Expanded(
                          child: Text(
                            'Sessions help track your sales and cash throughout your shift',
                            style: VodoTextStyles.bodySmall.copyWith(
                              color: VodoColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: VodoDimensions.spacingXl),

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onOpenSession,
                      icon: const Icon(Icons.lock_open),
                      label: const Text('Open Session'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, VodoDimensions.buttonHeightLg),
                        backgroundColor: VodoColors.success,
                      ),
                    ),
                  ),

                  const SizedBox(height: VodoDimensions.spacingMd),

                  // Secondary action (view history)
                  TextButton.icon(
                    onPressed: () {
                      context.push('/session/history');
                    },
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('View Session History'),
                    style: TextButton.styleFrom(
                      foregroundColor: VodoColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Session loading screen
class _SessionLoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: VodoDimensions.spacingLg),
            Text(
              'Checking session status...',
              style: VodoTextStyles.bodyLarge.copyWith(
                color: VodoColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Session error screen
class _SessionErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _SessionErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: VodoDimensions.paddingXl,
          child: Card(
            elevation: VodoDimensions.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: VodoDimensions.borderRadiusMd,
            ),
            child: Padding(
              padding: VodoDimensions.cardPaddingXl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error icon
                  Container(
                    padding: VodoDimensions.paddingXl,
                    decoration: BoxDecoration(
                      color: VodoColors.danger.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 64,
                      color: VodoColors.danger,
                    ),
                  ),

                  const SizedBox(height: VodoDimensions.spacingXl),

                  // Title
                  Text(
                    'Session Check Failed',
                    style: VodoTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: VodoColors.danger,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: VodoDimensions.spacingMd),

                  // Error message
                  Text(
                    'Unable to verify your session status. Please check your connection and try again.',
                    style: VodoTextStyles.bodyMedium.copyWith(
                      color: VodoColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: VodoDimensions.spacingSm),

                  // Technical details
                  Container(
                    padding: VodoDimensions.paddingSm,
                    decoration: BoxDecoration(
                      color: VodoColors.backgroundSecondary,
                      borderRadius: VodoDimensions.borderRadiusSm,
                    ),
                    child: Text(
                      error.toString(),
                      style: VodoTextStyles.bodySmall.copyWith(
                        color: VodoColors.textTertiary,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: VodoDimensions.spacingXl),

                  // Retry button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, VodoDimensions.buttonHeightLg),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
