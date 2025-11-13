/// Cash Movements Page
/// Track cash in/out movements during session (Odoo pattern)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../../application/session_providers.dart';
import '../../domain/models/cash_movement.dart';
import '../widgets/cash_movement_dialog.dart';

/// Page to view and manage cash movements for current session
class CashMovementsPage extends ConsumerStatefulWidget {
  const CashMovementsPage({super.key});

  @override
  ConsumerState<CashMovementsPage> createState() => _CashMovementsPageState();
}

class _CashMovementsPageState extends ConsumerState<CashMovementsPage> {
  bool _isLoading = false;
  List<CashMovement> _movements = [];

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  Future<void> _loadMovements() async {
    final sessionAsync = ref.read(currentSessionProvider);

    sessionAsync.whenData((session) async {
      if (session != null) {
        setState(() => _isLoading = true);

        // TODO: Load movements from repository
        // For now, show empty list

        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _showAddCashMovementDialog(CashMovementType type) async {
    final sessionAsync = ref.read(currentSessionProvider);

    final session = sessionAsync.valueOrNull;
    if (session == null) {
      _showError('No active session');
      return;
    }

    final currentBalance = session.openingCash +
        session.totalCashPayments +
        session.totalCashIn -
        session.totalCashOut;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CashMovementDialog(
        initialType: type,
        currentBalance: currentBalance,
      ),
    );

    if (result != null && mounted) {
      await _addCashMovement(result);
    }
  }

  Future<void> _addCashMovement(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);

    try {
      final controller = ref.read(currentSessionProvider.notifier);

      final success = await controller.addCashMovement(
        type: data['type'] as CashMovementType,
        amount: data['amount'] as double,
        reason: data['reason'] as CashMovementReason,
        customReason: data['custom_reason'] as String?,
        notes: data['notes'] as String?,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['type'] == CashMovementType.cashIn
                  ? 'Cash added to register successfully'
                  : 'Cash removed from register successfully',
            ),
            backgroundColor: VodoColors.success,
          ),
        );

        // Reload movements
        await _loadMovements();
      } else {
        _showError('Failed to record cash movement');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: VodoColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(currentSessionProvider);

    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: VodoColors.primary,
        foregroundColor: VodoColors.textOnPrimary,
        title: const Text(
          'Cash Movements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session == null) {
            return _buildNoSessionView();
          }

          return Column(
            children: [
              // Session summary card
              _buildSessionSummary(session),

              // Quick action buttons
              _buildQuickActions(),

              // Movements list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _movements.isEmpty
                        ? _buildEmptyView()
                        : _buildMovementsList(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildSessionSummary(dynamic session) {
    final currentBalance = session.openingCash +
        session.totalCashPayments +
        session.totalCashIn -
        session.totalCashOut;

    return Card(
      margin: VodoDimensions.paddingMd,
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Padding(
        padding: VodoDimensions.cardPadding,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Balance',
                  style: VodoTextStyles.titleMedium,
                ),
                Text(
                  '\$${currentBalance.toStringAsFixed(2)}',
                  style: VodoTextStyles.price.copyWith(
                    color: VodoColors.success,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: VodoDimensions.spacingMd),
            Divider(color: VodoColors.textTertiary.withOpacity(0.2)),
            const SizedBox(height: VodoDimensions.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceItem(
                    label: 'Opening',
                    amount: session.openingCash,
                    icon: Icons.login,
                    color: VodoColors.info,
                  ),
                ),
                Expanded(
                  child: _buildBalanceItem(
                    label: 'Cash In',
                    amount: session.totalCashIn,
                    icon: Icons.add_circle,
                    color: VodoColors.success,
                  ),
                ),
                Expanded(
                  child: _buildBalanceItem(
                    label: 'Cash Out',
                    amount: session.totalCashOut,
                    icon: Icons.remove_circle,
                    color: VodoColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: VodoDimensions.iconSizeMd),
        const SizedBox(height: VodoDimensions.spacingXs),
        Text(
          label,
          style: VodoTextStyles.labelSmall.copyWith(
            color: VodoColors.textSecondary,
          ),
        ),
        const SizedBox(height: VodoDimensions.spacingXs),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: VodoTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: VodoDimensions.paddingMd,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showAddCashMovementDialog(
                CashMovementType.cashIn,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: VodoColors.success,
                minimumSize: const Size(0, VodoDimensions.buttonHeightLg),
              ),
              icon: const Icon(Icons.add_circle),
              label: const Text('Add Cash'),
            ),
          ),
          const SizedBox(width: VodoDimensions.spacingMd),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showAddCashMovementDialog(
                CashMovementType.cashOut,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: VodoColors.warning,
                minimumSize: const Size(0, VodoDimensions.buttonHeightLg),
              ),
              icon: const Icon(Icons.remove_circle),
              label: const Text('Remove Cash'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsList() {
    return ListView.builder(
      padding: VodoDimensions.paddingMd,
      itemCount: _movements.length,
      itemBuilder: (context, index) {
        final movement = _movements[index];
        return _buildMovementCard(movement);
      },
    );
  }

  Widget _buildMovementCard(CashMovement movement) {
    final isCashIn = movement.type == CashMovementType.cashIn;

    return Card(
      margin: const EdgeInsets.only(bottom: VodoDimensions.spacingMd),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isCashIn ? VodoColors.success : VodoColors.warning)
              .withOpacity(0.2),
          child: Icon(
            isCashIn ? Icons.add_circle : Icons.remove_circle,
            color: isCashIn ? VodoColors.success : VodoColors.warning,
          ),
        ),
        title: Text(
          movement.reason.displayName,
          style: VodoTextStyles.titleSmall,
        ),
        subtitle: Text(
          movement.notes ?? 'No notes',
          style: VodoTextStyles.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCashIn ? '+' : '-'}\$${movement.amount.toStringAsFixed(2)}',
              style: VodoTextStyles.titleMedium.copyWith(
                color: isCashIn ? VodoColors.success : VodoColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
            // TODO: Add timestamp when model is updated
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: VodoColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: VodoDimensions.spacingLg),
          Text(
            'No Cash Movements Yet',
            style: VodoTextStyles.titleMedium.copyWith(
              color: VodoColors.textSecondary,
            ),
          ),
          const SizedBox(height: VodoDimensions.spacingSm),
          Text(
            'Use the buttons above to add or remove cash',
            style: VodoTextStyles.bodyMedium.copyWith(
              color: VodoColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoSessionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: VodoColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: VodoDimensions.spacingLg),
          Text(
            'No Active Session',
            style: VodoTextStyles.titleMedium.copyWith(
              color: VodoColors.textSecondary,
            ),
          ),
          const SizedBox(height: VodoDimensions.spacingSm),
          Text(
            'Please open a session first',
            style: VodoTextStyles.bodyMedium.copyWith(
              color: VodoColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
