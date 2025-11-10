import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Vouchers Page - Coupon and voucher management
class VouchersPage extends ConsumerWidget {
  const VouchersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final vouchers = [
      Voucher('SAVE10', VoucherType.percentage, 10, 350, 500, DateTime.now().add(const Duration(days: 30)), true),
      Voucher('FREESHIP', VoucherType.freeDelivery, 0, 125, 200, DateTime.now().add(const Duration(days: 15)), true),
      Voucher('WELCOME20', VoucherType.fixed, 20, 45, 1000, DateTime.now().add(const Duration(days: 60)), true),
      Voucher('EXPIRED10', VoucherType.percentage, 10, 100, 100, DateTime.now().subtract(const Duration(days: 5)), false),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Vouchers & Coupons')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          final voucher = vouchers[index];
          final isExpired = voucher.expiryDate.isBefore(DateTime.now());

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExpired ? Colors.grey.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getVoucherIcon(voucher.type),
                  color: isExpired ? Colors.grey : Colors.green,
                ),
              ),
              title: Text(
                voucher.code,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: isExpired ? Colors.grey : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getVoucherDescription(voucher)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text('${voucher.usedCount}/${voucher.maxUses} used'),
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text(isExpired ? 'Expired' : 'Expires ${DateFormat('MMM dd').format(voucher.expiryDate)}'),
                    ],
                  ),
                ],
              ),
              trailing: Switch(
                value: voucher.isActive && !isExpired,
                onChanged: isExpired ? null : (value) {},
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Create Voucher'),
      ),
    );
  }

  IconData _getVoucherIcon(VoucherType type) {
    switch (type) {
      case VoucherType.percentage: return Icons.percent;
      case VoucherType.fixed: return Icons.attach_money;
      case VoucherType.freeDelivery: return Icons.local_shipping;
    }
  }

  String _getVoucherDescription(Voucher voucher) {
    switch (voucher.type) {
      case VoucherType.percentage:
        return '${voucher.value}% OFF';
      case VoucherType.fixed:
        return '\$${voucher.value.toStringAsFixed(2)} OFF';
      case VoucherType.freeDelivery:
        return 'Free Delivery';
    }
  }
}

class Voucher {
  final String code;
  final VoucherType type;
  final double value;
  final int usedCount;
  final int maxUses;
  final DateTime expiryDate;
  final bool isActive;
  Voucher(this.code, this.type, this.value, this.usedCount, this.maxUses, this.expiryDate, this.isActive);
}

enum VoucherType { percentage, fixed, freeDelivery }
