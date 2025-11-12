/// Cart Display Widget
/// Shows current cart items with running total
/// Following Odoo POS customer display patterns
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/customer_display_models.dart';

/// Cart Display
/// Main view showing current cart as items are scanned
class CartDisplay extends StatelessWidget {
  final CustomerCart? cart;

  const CartDisplay({
    super.key,
    this.cart,
  });

  @override
  Widget build(BuildContext context) {
    if (cart == null || cart!.isEmpty) {
      return _buildEmptyCart(context);
    }

    return Row(
      children: [
        // Left side - Item list (70% width)
        Expanded(
          flex: 7,
          child: _buildItemsList(context, cart!),
        ),

        // Divider
        Container(
          width: 2,
          color: VodoColors.border,
        ),

        // Right side - Totals (30% width)
        Expanded(
          flex: 3,
          child: _buildTotals(context, cart!),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: VodoColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Cart is Empty',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: VodoColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Items will appear here as they are scanned',
            style: TextStyle(
              fontSize: 24,
              color: VodoColors.textSecondary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, CustomerCart cart) {
    return Container(
      color: VodoColors.backgroundPrimary,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: VodoColors.backgroundSecondary,
              border: Border(
                bottom: BorderSide(
                  color: VodoColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'ITEM',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: VodoColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'QTY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: VodoColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'PRICE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: VodoColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                final isLast = item.isLastScanned ?? false;

                return _buildCartItem(context, item, isLast);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, CustomerCartItem item, bool isLastScanned) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLastScanned
            ? VodoColors.primary.withOpacity(0.1)
            : VodoColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLastScanned ? VodoColors.primary : VodoColors.border,
          width: isLastScanned ? 3 : 1,
        ),
        boxShadow: isLastScanned
            ? [
                BoxShadow(
                  color: VodoColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Item info (left side)
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: isLastScanned ? 32 : 28,
                    fontWeight: isLastScanned ? FontWeight.w700 : FontWeight.w600,
                    color: VodoColors.textPrimary,
                    height: 1.2,
                  ),
                ),

                // Category and modifiers
                if (item.categoryName != null ||
                    item.modifiers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (item.categoryName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: VodoColors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.categoryName!,
                            style: TextStyle(
                              fontSize: 16,
                              color: VodoColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (item.modifiers.isNotEmpty)
                        Flexible(
                          child: Text(
                            item.modifiers.join(', '),
                            style: TextStyle(
                              fontSize: 16,
                              color: VodoColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],

                // Discount indicator
                if (item.hasDiscount) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: 18,
                        color: VodoColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${NumberFormat.currency(symbol: '\$').format(item.discount)} discount',
                        style: TextStyle(
                          fontSize: 18,
                          color: VodoColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Quantity (center)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isLastScanned
                    ? VodoColors.primary.withOpacity(0.15)
                    : VodoColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'x${item.quantity}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLastScanned ? 32 : 28,
                  fontWeight: FontWeight.w700,
                  color: isLastScanned
                      ? VodoColors.primary
                      : VodoColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Price (right side)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Line total
                Text(
                  NumberFormat.currency(symbol: '\$')
                      .format(item.totalAfterDiscount),
                  style: TextStyle(
                    fontSize: isLastScanned ? 36 : 32,
                    fontWeight: FontWeight.w700,
                    color: VodoColors.textPrimary,
                    height: 1.0,
                  ),
                ),

                // Unit price
                if (item.quantity > 1) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormat.currency(symbol: '\$').format(item.displayPrice)} each',
                    style: TextStyle(
                      fontSize: 16,
                      color: VodoColors.textSecondary,
                    ),
                  ),
                ],

                // Original price if discounted
                if (item.hasDiscount) ...[
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(symbol: '\$')
                        .format(item.lineTotal),
                    style: TextStyle(
                      fontSize: 16,
                      color: VodoColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals(BuildContext context, CustomerCart cart) {
    return Container(
      color: VodoColors.backgroundSecondary,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'ORDER TOTAL',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: VodoColors.textSecondary,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 32),

          // Item count
          _buildTotalRow(
            'Items:',
            '${cart.totalItems}',
            isLarge: false,
          ),

          const Divider(height: 32, thickness: 1),

          // Subtotal
          _buildTotalRow(
            'Subtotal:',
            NumberFormat.currency(symbol: '\$').format(cart.subtotal),
            isLarge: false,
          ),

          const SizedBox(height: 16),

          // Tax
          _buildTotalRow(
            'Tax:',
            NumberFormat.currency(symbol: '\$').format(cart.tax),
            isLarge: false,
          ),

          // Discount (if any)
          if (cart.discount > 0) ...[
            const SizedBox(height: 16),
            _buildTotalRow(
              'Discount:',
              '-${NumberFormat.currency(symbol: '\$').format(cart.discount)}',
              isLarge: false,
              color: VodoColors.success,
            ),
          ],

          const Spacer(),

          // Total (prominent)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: VodoColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: VodoColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: VodoColors.textOnPrimary.withOpacity(0.9),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  NumberFormat.currency(symbol: '\$').format(cart.total),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: VodoColors.textOnPrimary,
                    height: 1.0,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Payment pending indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VodoColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: VodoColors.info.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 24,
                  color: VodoColors.info,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ready for Payment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: VodoColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    String value, {
    bool isLarge = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 28 : 22,
            fontWeight: isLarge ? FontWeight.w700 : FontWeight.w600,
            color: color ?? VodoColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 32 : 24,
            fontWeight: FontWeight.w700,
            color: color ?? VodoColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
