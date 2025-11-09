import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Grid widget for selecting payment method.
class PaymentMethodGrid extends StatelessWidget {
  const PaymentMethodGrid({
    required this.onMethodSelected,
    this.selectedMethod,
    this.enabledMethods,
    super.key,
  });

  final void Function(PaymentMethod) onMethodSelected;
  final PaymentMethod? selectedMethod;
  final List<PaymentMethod>? enabledMethods;

  @override
  Widget build(BuildContext context) {
    final methods = enabledMethods ?? PaymentMethod.values;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      padding: const EdgeInsets.all(16),
      children: methods.map((method) {
        return PaymentMethodCard(
          method: method,
          selected: method == selectedMethod,
          onTap: () => onMethodSelected(method),
        );
      }).toList(),
    );
  }
}

/// Card widget for a single payment method.
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    required this.method,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final PaymentMethod method;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: selected ? 4 : 1,
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIcon(),
                size: 40,
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                method.displayName,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? theme.colorScheme.onPrimaryContainer : null,
                  fontWeight: selected ? FontWeight.bold : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (method) {
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
}
