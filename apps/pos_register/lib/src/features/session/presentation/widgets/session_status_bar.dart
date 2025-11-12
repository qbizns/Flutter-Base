/// Session Status Bar Widget
/// Odoo-style session status display at top of POS screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../../application/session_providers.dart';
import '../../domain/models/pos_session.dart';
import '../pages/session_open_page.dart';
import '../pages/session_close_page.dart';

/// Session status bar widget (Odoo-style)
/// Shows at top of POS screen with session info and quick actions
class SessionStatusBar extends ConsumerWidget {
  const SessionStatusBar({super.key});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  void _navigateToOpenSession(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SessionOpenPage(),
      ),
    );
  }

  void _navigateToCloseSession(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SessionClosePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(currentSessionProvider);
    final stats = ref.watch(sessionStatisticsProvider);

    return sessionState.when(
      data: (session) {
        if (session == null) {
          // No active session - show open session button
          return Container(
            padding: VodoDimensions.paddingMd,
            decoration: BoxDecoration(
              color: VodoColors.warning.withOpacity(0.1),
              border: const Border(
                bottom: BorderSide(
                  color: VodoColors.warning,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: VodoColors.warning,
                ),
                const SizedBox(width: VodoDimensions.spacingMd),
                Expanded(
                  child: Text(
                    'No active session - Please open a session to start',
                    style: VodoTextStyles.bodyMedium.copyWith(
                      color: VodoColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _navigateToOpenSession(context),
                  icon: const Icon(Icons.lock_open, size: 18),
                  label: const Text('Open Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VodoColors.success,
                    foregroundColor: VodoColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          );
        }

        // Active session - show session info bar (Odoo-style)
        return Container(
          padding: VodoDimensions.paddingMd,
          decoration: const BoxDecoration(
            color: VodoColors.primary,
            border: Border(
              bottom: BorderSide(
                color: VodoColors.primaryDark,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              // Session icon
              Container(
                padding: VodoDimensions.paddingSm,
                decoration: BoxDecoration(
                  color: VodoColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: VodoDimensions.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.point_of_sale,
                  color: VodoColors.textOnPrimary,
                  size: 20,
                ),
              ),

              const SizedBox(width: VodoDimensions.spacingMd),

              // Session info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          session.number,
                          style: VodoTextStyles.titleSmall.copyWith(
                            color: VodoColors.textOnPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: VodoDimensions.spacingSm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: VodoColors.success,
                            borderRadius: VodoDimensions.borderRadiusSm,
                          ),
                          child: Text(
                            'OPEN',
                            style: VodoTextStyles.badge.copyWith(
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${session.userName} • ${_formatDuration(DateTime.now().difference(session.startedAt))}',
                      style: VodoTextStyles.bodySmall.copyWith(
                        color: VodoColors.textOnPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick stats (Odoo-style smart buttons)
              if (stats != null) ...[
                _buildStatButton(
                  context,
                  icon: Icons.attach_money,
                  label: 'Sales',
                  value: '\$${stats.totalSales.toStringAsFixed(0)}',
                  color: VodoColors.success,
                ),
                const SizedBox(width: VodoDimensions.spacingSm),
                _buildStatButton(
                  context,
                  icon: Icons.receipt,
                  label: 'Orders',
                  value: stats.totalOrders.toString(),
                  color: VodoColors.info,
                ),
                const SizedBox(width: VodoDimensions.spacingSm),
                _buildStatButton(
                  context,
                  icon: Icons.account_balance_wallet,
                  label: 'Cash',
                  value: '\$${stats.currentCash.toStringAsFixed(0)}',
                  color: VodoColors.warning,
                ),
              ],

              const SizedBox(width: VodoDimensions.spacingMd),

              // Close session button
              TextButton.icon(
                onPressed: () => _navigateToCloseSession(context),
                icon: const Icon(
                  Icons.lock,
                  size: 18,
                  color: VodoColors.textOnPrimary,
                ),
                label: Text(
                  'Close',
                  style: VodoTextStyles.button.copyWith(
                    color: VodoColors.textOnPrimary,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: VodoColors.danger,
                  shape: RoundedRectangleBorder(
                    borderRadius: VodoDimensions.borderRadiusSm,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: VodoDimensions.paddingMd,
        decoration: const BoxDecoration(
          color: VodoColors.backgroundSecondary,
        ),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stack) => Container(
        padding: VodoDimensions.paddingMd,
        decoration: BoxDecoration(
          color: VodoColors.danger.withOpacity(0.1),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: VodoColors.danger),
            const SizedBox(width: VodoDimensions.spacingMd),
            Expanded(
              child: Text(
                'Error loading session: $error',
                style: VodoTextStyles.bodySmall.copyWith(
                  color: VodoColors.danger,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(currentSessionProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: VodoColors.textOnPrimary.withOpacity(0.15),
        borderRadius: VodoDimensions.borderRadiusSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: VodoTextStyles.titleSmall.copyWith(
                  color: VodoColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: VodoTextStyles.caption.copyWith(
              color: VodoColors.textOnPrimary.withOpacity(0.8),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal session status bar for compact views
class SessionStatusBarCompact extends ConsumerWidget {
  const SessionStatusBarCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(currentSessionProvider);

    return sessionState.when(
      data: (session) {
        if (session == null) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: VodoDimensions.spacingMd,
              vertical: VodoDimensions.spacingSm,
            ),
            color: VodoColors.warning.withOpacity(0.1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: VodoColors.warning,
                  size: 16,
                ),
                const SizedBox(width: VodoDimensions.spacingSm),
                Text(
                  'No Session',
                  style: VodoTextStyles.labelSmall.copyWith(
                    color: VodoColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: VodoDimensions.spacingMd,
            vertical: VodoDimensions.spacingSm,
          ),
          color: VodoColors.primary,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: VodoColors.textOnPrimary,
                size: 16,
              ),
              const SizedBox(width: VodoDimensions.spacingSm),
              Text(
                session.number,
                style: VodoTextStyles.labelSmall.copyWith(
                  color: VodoColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(VodoDimensions.spacingSm),
        child: const SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: VodoDimensions.spacingMd,
          vertical: VodoDimensions.spacingSm,
        ),
        color: VodoColors.danger.withOpacity(0.1),
        child: const Icon(
          Icons.error_outline,
          color: VodoColors.danger,
          size: 16,
        ),
      ),
    );
  }
}
