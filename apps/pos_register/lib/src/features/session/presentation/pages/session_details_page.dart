/// Session Details Page
/// Vodo-style detailed view of a single POS session
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../../application/session_providers.dart';
import '../../domain/models/pos_session.dart';

/// Session details page showing full session information
class SessionDetailsPage extends ConsumerWidget {
  final String sessionId;

  const SessionDetailsPage({
    super.key,
    required this.sessionId,
  });

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.draft:
        return VodoColors.textSecondary;
      case SessionStatus.open:
        return VodoColors.success;
      case SessionStatus.closing:
        return VodoColors.warning;
      case SessionStatus.closed:
        return VodoColors.info;
      case SessionStatus.cancelled:
        return VodoColors.danger;
    }
  }

  String _getStatusLabel(SessionStatus status) {
    switch (status) {
      case SessionStatus.draft:
        return 'DRAFT';
      case SessionStatus.open:
        return 'OPEN';
      case SessionStatus.closing:
        return 'CLOSING';
      case SessionStatus.closed:
        return 'CLOSED';
      case SessionStatus.cancelled:
        return 'CANCELLED';
    }
  }

  IconData _getStatusIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.draft:
        return Icons.edit_note;
      case SessionStatus.open:
        return Icons.lock_open;
      case SessionStatus.closing:
        return Icons.pending;
      case SessionStatus.closed:
        return Icons.lock;
      case SessionStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(DateTime start, DateTime? end) {
    final duration = (end ?? DateTime.now()).difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, we'd fetch the specific session by ID
    // For now, we'll get it from history
    final historyState = ref.watch(sessionHistoryProvider);

    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: VodoColors.primary,
        foregroundColor: VodoColors.textOnPrimary,
        title: const Text(
          'Session Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          // Print report button
          IconButton(
            onPressed: () {
              // TODO: Implement print report
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Print report feature coming soon'),
                ),
              );
            },
            icon: const Icon(Icons.print),
            tooltip: 'Print Report',
          ),
          // More actions menu
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implement actions
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value coming soon')),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email, size: 20),
                    SizedBox(width: 8),
                    Text('Email Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: historyState.when(
        data: (sessions) {
          final session = sessions.firstWhere(
            (s) => s.id == sessionId,
            orElse: () => throw Exception('Session not found'),
          );

          final difference =
              session.actualClosingCash - session.expectedClosingCash;
          final hasDifference = difference.abs() > 0.01;

          return SingleChildScrollView(
            padding: VodoDimensions.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Session header card
                Card(
                  elevation: VodoDimensions.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: VodoDimensions.borderRadiusMd,
                  ),
                  child: Padding(
                    padding: VodoDimensions.cardPaddingLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: VodoDimensions.paddingMd,
                              decoration: BoxDecoration(
                                color:
                                    _getStatusColor(session.status).withOpacity(0.1),
                                borderRadius: VodoDimensions.borderRadiusMd,
                              ),
                              child: Icon(
                                _getStatusIcon(session.status),
                                color: _getStatusColor(session.status),
                                size: VodoDimensions.iconSizeLg,
                              ),
                            ),
                            const SizedBox(width: VodoDimensions.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.number,
                                    style: VodoTextStyles.headlineSmall,
                                  ),
                                  const SizedBox(height: VodoDimensions.spacingXs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(session.status),
                                      borderRadius: VodoDimensions.borderRadiusSm,
                                    ),
                                    child: Text(
                                      _getStatusLabel(session.status),
                                      style: VodoTextStyles.badge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: VodoDimensions.spacingLg),
                        const Divider(),
                        const SizedBox(height: VodoDimensions.spacingMd),

                        // Session info grid
                        _buildInfoRow(
                          Icons.person,
                          'Cashier',
                          session.userName,
                        ),
                        const SizedBox(height: VodoDimensions.spacingSm),
                        _buildInfoRow(
                          Icons.desktop_windows,
                          'Register',
                          session.registerId,
                        ),
                        const SizedBox(height: VodoDimensions.spacingSm),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Started',
                          _formatDateTime(session.startedAt),
                        ),
                        if (session.closedAt != null) ...[
                          const SizedBox(height: VodoDimensions.spacingSm),
                          _buildInfoRow(
                            Icons.event_available,
                            'Closed',
                            _formatDateTime(session.closedAt!),
                          ),
                        ],
                        const SizedBox(height: VodoDimensions.spacingSm),
                        _buildInfoRow(
                          Icons.access_time,
                          'Duration',
                          _formatDuration(session.startedAt, session.closedAt),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: VodoDimensions.spacingLg),

                // Sales summary card (Odoo-style smart buttons)
                Card(
                  elevation: VodoDimensions.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: VodoDimensions.borderRadiusMd,
                  ),
                  child: Padding(
                    padding: VodoDimensions.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Summary',
                          style: VodoTextStyles.titleMedium,
                        ),
                        const SizedBox(height: VodoDimensions.spacingMd),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                'Total Sales',
                                '\$${session.totalSales.toStringAsFixed(2)}',
                                Icons.attach_money,
                                VodoColors.success,
                              ),
                            ),
                            const SizedBox(width: VodoDimensions.spacingMd),
                            Expanded(
                              child: _buildStatBox(
                                'Orders',
                                session.totalOrders.toString(),
                                Icons.receipt,
                                VodoColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: VodoDimensions.spacingMd),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                'Returns',
                                session.totalReturns.toString(),
                                Icons.assignment_return,
                                VodoColors.warning,
                              ),
                            ),
                            const SizedBox(width: VodoDimensions.spacingMd),
                            Expanded(
                              child: _buildStatBox(
                                'Discounts',
                                '\$${session.totalDiscounts.toStringAsFixed(2)}',
                                Icons.local_offer,
                                VodoColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: VodoDimensions.spacingLg),

                // Payment methods breakdown
                Card(
                  elevation: VodoDimensions.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: VodoDimensions.borderRadiusMd,
                  ),
                  child: Padding(
                    padding: VodoDimensions.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Methods',
                          style: VodoTextStyles.titleMedium,
                        ),
                        const SizedBox(height: VodoDimensions.spacingMd),
                        _buildPaymentMethodRow(
                          Icons.attach_money,
                          'Cash',
                          session.totalCashPayments,
                          VodoColors.success,
                        ),
                        const Divider(),
                        _buildPaymentMethodRow(
                          Icons.credit_card,
                          'Card',
                          session.totalCardPayments,
                          VodoColors.info,
                        ),
                        const Divider(),
                        _buildPaymentMethodRow(
                          Icons.account_balance_wallet,
                          'Digital Wallet',
                          session.totalDigitalWalletPayments,
                          VodoColors.accent,
                        ),
                        const Divider(),
                        _buildPaymentMethodRow(
                          Icons.smartphone,
                          'Other',
                          session.totalOtherPayments,
                          VodoColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: VodoDimensions.spacingLg),

                // Cash reconciliation (if closed)
                if (session.status == SessionStatus.closed)
                  Card(
                    elevation: VodoDimensions.cardElevation,
                    shape: RoundedRectangleBorder(
                      borderRadius: VodoDimensions.borderRadiusMd,
                      side: hasDifference
                          ? BorderSide(
                              color: difference > 0
                                  ? VodoColors.success
                                  : VodoColors.danger,
                              width: 2,
                            )
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: VodoDimensions.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                hasDifference
                                    ? (difference > 0
                                        ? Icons.trending_up
                                        : Icons.trending_down)
                                    : Icons.check_circle,
                                color: hasDifference
                                    ? (difference > 0
                                        ? VodoColors.success
                                        : VodoColors.danger)
                                    : VodoColors.success,
                              ),
                              const SizedBox(width: VodoDimensions.spacingSm),
                              Text(
                                'Cash Reconciliation',
                                style: VodoTextStyles.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: VodoDimensions.spacingMd),
                          Container(
                            padding: VodoDimensions.paddingMd,
                            decoration: BoxDecoration(
                              color: VodoColors.backgroundSecondary,
                              borderRadius: VodoDimensions.borderRadiusMd,
                            ),
                            child: Column(
                              children: [
                                _buildCashRow(
                                  'Opening Cash',
                                  session.openingCash,
                                  VodoColors.textSecondary,
                                ),
                                const SizedBox(height: VodoDimensions.spacingSm),
                                _buildCashRow(
                                  'Cash Sales',
                                  session.totalCashPayments,
                                  VodoColors.success,
                                ),
                                const SizedBox(height: VodoDimensions.spacingSm),
                                _buildCashRow(
                                  'Cash In/Out',
                                  session.totalCashMovements,
                                  session.totalCashMovements >= 0
                                      ? VodoColors.success
                                      : VodoColors.danger,
                                ),
                                const Divider(),
                                _buildCashRow(
                                  'Expected Closing',
                                  session.expectedClosingCash,
                                  VodoColors.info,
                                  bold: true,
                                ),
                                const SizedBox(height: VodoDimensions.spacingMd),
                                _buildCashRow(
                                  'Actual Closing',
                                  session.actualClosingCash,
                                  VodoColors.textPrimary,
                                  bold: true,
                                ),
                                const Divider(),
                                _buildCashRow(
                                  'Difference',
                                  difference,
                                  hasDifference
                                      ? (difference > 0
                                          ? VodoColors.success
                                          : VodoColors.danger)
                                      : VodoColors.textSecondary,
                                  bold: true,
                                  large: true,
                                ),
                              ],
                            ),
                          ),
                          if (hasDifference) ...[
                            const SizedBox(height: VodoDimensions.spacingMd),
                            Container(
                              padding: VodoDimensions.paddingSm,
                              decoration: BoxDecoration(
                                color: (difference > 0
                                        ? VodoColors.success
                                        : VodoColors.danger)
                                    .withOpacity(0.1),
                                borderRadius: VodoDimensions.borderRadiusSm,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: difference > 0
                                        ? VodoColors.success
                                        : VodoColors.danger,
                                  ),
                                  const SizedBox(width: VodoDimensions.spacingSm),
                                  Expanded(
                                    child: Text(
                                      difference > 0
                                          ? 'Cash over by \$${difference.toStringAsFixed(2)}'
                                          : 'Cash short by \$${difference.abs().toStringAsFixed(2)}',
                                      style: VodoTextStyles.bodySmall.copyWith(
                                        color: difference > 0
                                            ? VodoColors.success
                                            : VodoColors.danger,
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
                  ),

                const SizedBox(height: VodoDimensions.spacingLg),

                // Session notes (if any)
                if (session.notes != null && session.notes!.isNotEmpty)
                  Card(
                    elevation: VodoDimensions.cardElevation,
                    shape: RoundedRectangleBorder(
                      borderRadius: VodoDimensions.borderRadiusMd,
                    ),
                    child: Padding(
                      padding: VodoDimensions.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.note,
                                size: VodoDimensions.iconSizeMd,
                              ),
                              const SizedBox(width: VodoDimensions.spacingSm),
                              Text(
                                'Notes',
                                style: VodoTextStyles.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: VodoDimensions.spacingMd),
                          Container(
                            width: double.infinity,
                            padding: VodoDimensions.paddingMd,
                            decoration: BoxDecoration(
                              color: VodoColors.backgroundSecondary,
                              borderRadius: VodoDimensions.borderRadiusMd,
                            ),
                            child: Text(
                              session.notes!,
                              style: VodoTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: VodoDimensions.spacingXl),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: VodoColors.danger,
              ),
              const SizedBox(height: VodoDimensions.spacingMd),
              Text(
                'Error loading session',
                style: VodoTextStyles.bodyLarge.copyWith(
                  color: VodoColors.danger,
                ),
              ),
              const SizedBox(height: VodoDimensions.spacingMd),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: VodoColors.textSecondary,
        ),
        const SizedBox(width: VodoDimensions.spacingSm),
        Text(
          '$label: ',
          style: VodoTextStyles.bodyMedium.copyWith(
            color: VodoColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: VodoTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: VodoDimensions.paddingMd,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: VodoDimensions.iconSizeLg),
          const SizedBox(height: VodoDimensions.spacingSm),
          Text(
            value,
            style: VodoTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: VodoTextStyles.labelSmall.copyWith(
              color: VodoColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodRow(
      IconData icon, String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VodoDimensions.spacingSm),
      child: Row(
        children: [
          Icon(icon, color: color, size: VodoDimensions.iconSizeMd),
          const SizedBox(width: VodoDimensions.spacingMd),
          Expanded(
            child: Text(
              label,
              style: VodoTextStyles.bodyMedium,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: VodoTextStyles.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashRow(String label, double amount, Color color,
      {bool bold = false, bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (large ? VodoTextStyles.titleMedium : VodoTextStyles.bodyMedium)
              .copyWith(
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: (large ? VodoTextStyles.titleMedium : VodoTextStyles.bodyMedium)
              .copyWith(
            color: color,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
