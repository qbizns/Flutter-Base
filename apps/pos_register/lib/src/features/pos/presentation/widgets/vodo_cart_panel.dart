/// Vodo Cart Panel Widget
/// Odoo-style enhanced cart panel with customer, notes, and discount features
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Enhanced cart panel following Odoo POS patterns
class VodoCartPanel extends StatelessWidget {
  final Cart cart;
  final Function(OrderItem, int) onItemQuantityChanged;
  final Function(OrderItem) onItemRemoved;
  final VoidCallback onCheckout;
  final VoidCallback onClear;
  final VoidCallback? onCustomerSelect;
  final VoidCallback? onNotesAdd;
  final VoidCallback? onDiscountApply;
  final String? customerName;
  final String? orderNotes;
  final double? discountAmount;

  const VodoCartPanel({
    super.key,
    required this.cart,
    required this.onItemQuantityChanged,
    required this.onItemRemoved,
    required this.onCheckout,
    required this.onClear,
    this.onCustomerSelect,
    this.onNotesAdd,
    this.onDiscountApply,
    this.customerName,
    this.orderNotes,
    this.discountAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: VodoColors.backgroundPrimary,
        border: Border(
          left: BorderSide(color: VodoColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Cart header
          _buildCartHeader(context),

          // Customer section (Odoo-style)
          if (onCustomerSelect != null) _buildCustomerSection(context),

          // Order notes section
          if (onNotesAdd != null) _buildNotesSection(context),

          // Cart items
          Expanded(
            child: cart.isEmpty
                ? _buildEmptyCart()
                : _buildCartItems(context),
          ),

          // Cart actions (discount, clear)
          if (cart.isNotEmpty) _buildCartActions(context),

          // Cart summary
          _buildCartSummary(context),

          // Checkout button
          _buildCheckoutButton(context),
        ],
      ),
    );
  }

  Widget _buildCartHeader(BuildContext context) {
    return Container(
      padding: VodoDimensions.paddingMd,
      decoration: const BoxDecoration(
        color: VodoColors.primary,
        border: Border(
          bottom: BorderSide(color: VodoColors.primaryDark, width: 2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_cart,
            color: VodoColors.textOnPrimary,
            size: 20,
          ),
          const SizedBox(width: VodoDimensions.spacingSm),
          Expanded(
            child: Text(
              'Current Order',
              style: VodoTextStyles.titleMedium.copyWith(
                color: VodoColors.textOnPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Item count badge
          if (cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: VodoColors.textOnPrimary,
                borderRadius: VodoDimensions.borderRadiusSm,
              ),
              child: Text(
                '${cart.itemsCount}',
                style: VodoTextStyles.labelSmall.copyWith(
                  color: VodoColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection(BuildContext context) {
    return InkWell(
      onTap: onCustomerSelect,
      child: Container(
        padding: VodoDimensions.paddingMd,
        decoration: const BoxDecoration(
          color: VodoColors.backgroundSecondary,
          border: Border(
            bottom: BorderSide(color: VodoColors.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              color: customerName != null
                  ? VodoColors.primary
                  : VodoColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: VodoDimensions.spacingSm),
            Expanded(
              child: Text(
                customerName ?? 'Select Customer',
                style: VodoTextStyles.bodyMedium.copyWith(
                  color: customerName != null
                      ? VodoColors.textPrimary
                      : VodoColors.textSecondary,
                  fontWeight: customerName != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: VodoColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return InkWell(
      onTap: onNotesAdd,
      child: Container(
        padding: VodoDimensions.paddingSm,
        decoration: const BoxDecoration(
          color: VodoColors.backgroundPrimary,
          border: Border(
            bottom: BorderSide(color: VodoColors.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              orderNotes != null ? Icons.note : Icons.note_add,
              color: orderNotes != null
                  ? VodoColors.accent
                  : VodoColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: VodoDimensions.spacingSm),
            Expanded(
              child: Text(
                orderNotes ?? 'Add order notes',
                style: VodoTextStyles.bodySmall.copyWith(
                  color: orderNotes != null
                      ? VodoColors.textPrimary
                      : VodoColors.textSecondary,
                  fontStyle:
                      orderNotes != null ? FontStyle.normal : FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: VodoColors.textTertiary.withOpacity(0.3),
          ),
          const SizedBox(height: VodoDimensions.spacingMd),
          Text(
            'Cart is empty',
            style: VodoTextStyles.bodyLarge.copyWith(
              color: VodoColors.textSecondary,
            ),
          ),
          const SizedBox(height: VodoDimensions.spacingSm),
          Text(
            'Add products to start an order',
            style: VodoTextStyles.bodySmall.copyWith(
              color: VodoColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context) {
    return ListView.separated(
      padding: VodoDimensions.paddingSm,
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return _VodoCartItem(
          item: item,
          onQuantityChanged: (quantity) {
            onItemQuantityChanged(item, quantity);
          },
          onRemove: () => onItemRemoved(item),
        );
      },
    );
  }

  Widget _buildCartActions(BuildContext context) {
    return Container(
      padding: VodoDimensions.paddingSm,
      decoration: const BoxDecoration(
        color: VodoColors.backgroundSecondary,
        border: Border(
          top: BorderSide(color: VodoColors.border, width: 1),
          bottom: BorderSide(color: VodoColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Discount button
          if (onDiscountApply != null)
            Expanded(
              child: TextButton.icon(
                onPressed: onDiscountApply,
                icon: Icon(
                  discountAmount != null && discountAmount! > 0
                      ? Icons.local_offer
                      : Icons.local_offer_outlined,
                  size: 18,
                ),
                label: Text(
                  discountAmount != null && discountAmount! > 0
                      ? '-\$${discountAmount!.toStringAsFixed(2)}'
                      : 'Discount',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: discountAmount != null && discountAmount! > 0
                      ? VodoColors.success
                      : VodoColors.textSecondary,
                ),
              ),
            ),

          const SizedBox(width: VodoDimensions.spacingSm),

          // Clear cart button
          Expanded(
            child: TextButton.icon(
              onPressed: () => _showClearCartDialog(context),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: VodoColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context) {
    return Container(
      padding: VodoDimensions.paddingMd,
      decoration: const BoxDecoration(
        color: VodoColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(color: VodoColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Subtotal
          _buildSummaryRow(
            'Subtotal',
            '\$${cart.subtotal.toStringAsFixed(2)}',
            VodoColors.textSecondary,
          ),
          const SizedBox(height: VodoDimensions.spacingXs),

          // Discount (if any)
          if (discountAmount != null && discountAmount! > 0) ...[
            _buildSummaryRow(
              'Discount',
              '-\$${discountAmount!.toStringAsFixed(2)}',
              VodoColors.success,
            ),
            const SizedBox(height: VodoDimensions.spacingXs),
          ],

          // Tax
          _buildSummaryRow(
            'Tax',
            '\$${cart.tax.toStringAsFixed(2)}',
            VodoColors.textSecondary,
          ),
          const SizedBox(height: VodoDimensions.spacingSm),
          const Divider(),
          const SizedBox(height: VodoDimensions.spacingSm),

          // Total
          _buildSummaryRow(
            'Total',
            '\$${cart.total.toStringAsFixed(2)}',
            VodoColors.primary,
            bold: true,
            large: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color color, {
    bool bold = false,
    bool large = false,
  }) {
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
          value,
          style: (large ? VodoTextStyles.price : VodoTextStyles.priceMedium)
              .copyWith(
            color: color,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return Container(
      padding: VodoDimensions.paddingMd,
      child: ElevatedButton(
        onPressed: cart.isEmpty ? null : onCheckout,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, VodoDimensions.buttonHeightLg),
          backgroundColor: VodoColors.success,
          disabledBackgroundColor: VodoColors.backgroundSecondary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 20),
            const SizedBox(width: VodoDimensions.spacingSm),
            Text(
              cart.isEmpty
                  ? 'Add Items to Checkout'
                  : 'Pay - \$${cart.total.toStringAsFixed(2)}',
              style: VodoTextStyles.button.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClearCartDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text(
          'Are you sure you want to clear all items from the cart? This action cannot be undone.',
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
            child: const Text('Clear Cart'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onClear();
    }
  }
}

/// Individual cart item widget (Odoo-style)
class _VodoCartItem extends StatelessWidget {
  final OrderItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _VodoCartItem({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: VodoDimensions.paddingSm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image (small)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: VodoColors.backgroundSecondary,
              borderRadius: VodoDimensions.borderRadiusSm,
            ),
            child: item.productImageUrl != null
                ? ClipRRect(
                    borderRadius: VodoDimensions.borderRadiusSm,
                    child: Image.network(
                      item.productImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.fastfood,
                          size: 24,
                          color: VodoColors.textTertiary,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.fastfood,
                    size: 24,
                    color: VodoColors.textTertiary,
                  ),
          ),

          const SizedBox(width: VodoDimensions.spacingSm),

          // Product info and controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  item.productName,
                  style: VodoTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Modifiers (if any)
                if (item.selectedModifiers.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  ...item.selectedModifiers.map((modifier) {
                    return Text(
                      '+ ${modifier.name}',
                      style: VodoTextStyles.caption.copyWith(
                        color: VodoColors.textSecondary,
                      ),
                    );
                  }),
                ],

                const SizedBox(height: VodoDimensions.spacingXs),

                // Quantity controls and price
                Row(
                  children: [
                    // Quantity controls
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: VodoColors.border),
                        borderRadius: VodoDimensions.borderRadiusSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Decrease button
                          InkWell(
                            onTap: item.quantity > 1
                                ? () => onQuantityChanged(item.quantity - 1)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: item.quantity > 1
                                    ? VodoColors.danger
                                    : VodoColors.textTertiary,
                              ),
                            ),
                          ),

                          // Quantity display
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: VodoTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // Increase button
                          InkWell(
                            onTap: () => onQuantityChanged(item.quantity + 1),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: VodoColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Item total
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: VodoTextStyles.priceMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: VodoColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: VodoDimensions.spacingSm),

          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
            color: VodoColors.textSecondary,
            tooltip: 'Remove item',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
