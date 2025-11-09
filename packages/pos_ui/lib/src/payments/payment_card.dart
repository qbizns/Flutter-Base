import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Card widget for displaying payment information.
class PaymentCard extends StatelessWidget {
  const PaymentCard({
    required this.payment,
    this.onTap,
    super.key,
  });

  final Payment payment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Payment Method
                  Row(
                    children: [
                      Icon(
                        _getMethodIcon(),
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        payment.method.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Status Badge
                  _buildStatusBadge(theme),
                ],
              ),

              const SizedBox(height: 12),

              // Amount
              Text(
                '\$${payment.totalAmount.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),

              if (payment.tipAmount > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Includes \$${payment.tipAmount.toStringAsFixed(2)} tip',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Card Details (if applicable)
              if (payment.cardLastFour != null) ...[
                Row(
                  children: [
                    Text(
                      'Card:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${payment.cardBrand ?? 'Card'} •••• ${payment.cardLastFour}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Transaction ID
              if (payment.transactionId != null) ...[
                Row(
                  children: [
                    Text(
                      'Transaction:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payment.transactionId!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Timestamp
              Text(
                _getTimestamp(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    final statusColor = _getStatusColor(theme);
    final statusText = _getStatusText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme) {
    switch (payment.status) {
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return theme.colorScheme.error;
      case PaymentStatus.refunded:
      case PaymentStatus.partiallyRefunded:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    switch (payment.status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _getMethodIcon() {
    switch (payment.method) {
      case PaymentMethod.cash:
        return Icons.attach_money;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.payment;
      case PaymentMethod.mobileWallet:
        return Icons.smartphone;
      case PaymentMethod.giftCard:
        return Icons.card_giftcard;
      case PaymentMethod.check:
        return Icons.receipt_long;
      case PaymentMethod.storeCredit:
        return Icons.account_balance_wallet;
      case PaymentMethod.online:
        return Icons.language;
      case PaymentMethod.other:
        return Icons.more_horiz;
    }
  }

  String _getTimestamp() {
    final processedAt = payment.processedAt ?? payment.createdAt;
    final now = DateTime.now();
    final diff = now.difference(processedAt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
