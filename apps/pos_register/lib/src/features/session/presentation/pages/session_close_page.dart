/// Session Close Page
/// Vodo-style page for closing POS session with cash reconciliation
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../../application/session_providers.dart';
import '../../domain/models/cash_count.dart';
import '../../domain/models/pos_session.dart';
import '../widgets/cash_count_widget.dart';

/// Session close page
class SessionClosePage extends ConsumerStatefulWidget {
  const SessionClosePage({super.key});

  @override
  ConsumerState<SessionClosePage> createState() => _SessionClosePageState();
}

class _SessionClosePageState extends ConsumerState<SessionClosePage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  double _actualClosingCash = 0.0;

  // Cash count state
  CashCount _cashCount = CashCount(
    type: CashCountType.closing,
    denominations: USDenominations.all,
  );

  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleCloseSession(PosSession session) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Session?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to close this session?'),
            const SizedBox(height: VodoDimensions.spacingMd),
            _buildReconciliationSummary(session),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: VodoColors.danger,
            ),
            child: const Text('Close Session'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(currentSessionProvider.notifier);

      final success = await controller.closeSession(
        actualClosingCash: _actualClosingCash,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session closed successfully'),
            backgroundColor: VodoColors.success,
          ),
        );

        // Navigate back to main screen
        Navigator.of(context).pop();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to close session'),
            backgroundColor: VodoColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleCashCountChanged(CashCount cashCount) {
    setState(() {
      _cashCount = cashCount;
      _actualClosingCash = cashCount.totalAmount;
    });
  }

  Widget _buildReconciliationSummary(PosSession session) {
    final difference = _actualClosingCash - session.expectedClosingCash;
    final isDifferent = difference.abs() > 0.01;

    return Container(
      padding: VodoDimensions.paddingMd,
      decoration: BoxDecoration(
        color: VodoColors.backgroundSecondary,
        borderRadius: VodoDimensions.borderRadiusMd,
        border: Border.all(
          color: isDifferent ? VodoColors.warning : VodoColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Expected Cash',
            '\$${session.expectedClosingCash.toStringAsFixed(2)}',
            VodoColors.textSecondary,
          ),
          const Divider(),
          _buildSummaryRow(
            'Actual Cash',
            '\$${_actualClosingCash.toStringAsFixed(2)}',
            VodoColors.textPrimary,
          ),
          const Divider(),
          _buildSummaryRow(
            'Difference',
            '\$${difference.toStringAsFixed(2)}',
            isDifferent
                ? (difference > 0 ? VodoColors.success : VodoColors.danger)
                : VodoColors.textSecondary,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VodoDimensions.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: VodoTextStyles.bodyMedium.copyWith(
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: VodoTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(currentSessionProvider);

    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: VodoColors.primary,
        foregroundColor: VodoColors.textOnPrimary,
        title: const Text(
          'Close POS Session',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: sessionState.when(
        data: (session) {
          if (session == null) {
            return const Center(
              child: Text('No active session to close'),
            );
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: VodoDimensions.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Session info card
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
                                  color: VodoColors.danger.withOpacity(0.1),
                                  borderRadius: VodoDimensions.borderRadiusMd,
                                ),
                                child: const Icon(
                                  Icons.lock,
                                  color: VodoColors.danger,
                                  size: VodoDimensions.iconSizeLg,
                                ),
                              ),
                              const SizedBox(width: VodoDimensions.spacingMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Session ${session.number}',
                                      style: VodoTextStyles.headlineSmall,
                                    ),
                                    const SizedBox(height: VodoDimensions.spacingXs),
                                    Text(
                                      'Started at ${session.startedAt.toString().substring(11, 16)}',
                                      style: VodoTextStyles.bodyMedium.copyWith(
                                        color: VodoColors.textSecondary,
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
                          // Session statistics
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
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: VodoDimensions.spacingLg),

                  // Expected cash card
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
                            'Expected Cash in Register',
                            style: VodoTextStyles.titleMedium,
                          ),
                          const SizedBox(height: VodoDimensions.spacingMd),
                          Container(
                            padding: VodoDimensions.paddingLg,
                            decoration: BoxDecoration(
                              color: VodoColors.backgroundSecondary,
                              borderRadius: VodoDimensions.borderRadiusMd,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Opening',
                                      style: VodoTextStyles.labelMedium.copyWith(
                                        color: VodoColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '\$${session.openingCash.toStringAsFixed(2)}',
                                      style: VodoTextStyles.priceMedium,
                                    ),
                                  ],
                                ),
                                const Icon(Icons.add, color: VodoColors.textSecondary),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cash Sales',
                                      style: VodoTextStyles.labelMedium.copyWith(
                                        color: VodoColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '\$${session.totalCashPayments.toStringAsFixed(2)}',
                                      style: VodoTextStyles.priceMedium,
                                    ),
                                  ],
                                ),
                                const Icon(Icons.drag_handle,
                                    color: VodoColors.textSecondary),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expected',
                                      style: VodoTextStyles.labelMedium.copyWith(
                                        color: VodoColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '\$${session.expectedClosingCash.toStringAsFixed(2)}',
                                      style: VodoTextStyles.price.copyWith(
                                        color: VodoColors.info,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: VodoDimensions.spacingLg),

                  // Cash count widget
                  CashCountWidget(
                    cashCount: _cashCount,
                    onChanged: _handleCashCountChanged,
                  ),

                  const SizedBox(height: VodoDimensions.spacingLg),

                  // Reconciliation summary
                  _buildReconciliationSummary(session),

                  const SizedBox(height: VodoDimensions.spacingLg),

                  // Notes card
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
                            'Closing Notes (Optional)',
                            style: VodoTextStyles.titleMedium,
                          ),
                          const SizedBox(height: VodoDimensions.spacingMd),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Add any notes about discrepancies or issues...',
                              prefixIcon: Icon(Icons.note),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: VodoDimensions.spacingXl),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _isSubmitting ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, VodoDimensions.buttonHeightLg),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: VodoDimensions.spacingMd),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _handleCloseSession(session),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, VodoDimensions.buttonHeightLg),
                            backgroundColor: VodoColors.danger,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      VodoColors.textOnPrimary,
                                    ),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock),
                                    SizedBox(width: VodoDimensions.spacingSm),
                                    Text('Close Session'),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: VodoDimensions.spacingXl),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
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
}
