/// Vodo Payment Grid Widget
/// Odoo-style payment method selection grid
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Payment method data model
class VodoPaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool requiresDevice;
  final bool enabled;

  const VodoPaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.requiresDevice = false,
    this.enabled = true,
  });

  static const cash = VodoPaymentMethod(
    id: 'cash',
    name: 'Cash',
    icon: Icons.attach_money,
    color: VodoColors.success,
  );

  static const card = VodoPaymentMethod(
    id: 'card',
    name: 'Card',
    icon: Icons.credit_card,
    color: VodoColors.info,
    requiresDevice: true,
  );

  static const digitalWallet = VodoPaymentMethod(
    id: 'digital_wallet',
    name: 'Digital Wallet',
    icon: Icons.account_balance_wallet,
    color: VodoColors.accent,
    requiresDevice: true,
  );

  static const bank = VodoPaymentMethod(
    id: 'bank',
    name: 'Bank Transfer',
    icon: Icons.account_balance,
    color: VodoColors.primary,
  );

  static const check = VodoPaymentMethod(
    id: 'check',
    name: 'Check',
    icon: Icons.receipt_long,
    color: VodoColors.warning,
  );

  static const voucher = VodoPaymentMethod(
    id: 'voucher',
    name: 'Voucher',
    icon: Icons.card_giftcard,
    color: VodoColors.accent,
  );

  static List<VodoPaymentMethod> get all => [
        cash,
        card,
        digitalWallet,
        bank,
        check,
        voucher,
      ];
}

/// Payment method grid following Odoo POS patterns
class VodoPaymentGrid extends StatelessWidget {
  final List<VodoPaymentMethod> methods;
  final ValueChanged<VodoPaymentMethod> onMethodSelected;
  final double totalAmount;
  final int crossAxisCount;

  const VodoPaymentGrid({
    super.key,
    required this.methods,
    required this.onMethodSelected,
    required this.totalAmount,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with amount
        Container(
          padding: VodoDimensions.paddingLg,
          decoration: BoxDecoration(
            color: VodoColors.primary.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(VodoDimensions.radiusMd),
            ),
          ),
          child: Column(
            children: [
              Text(
                'Select Payment Method',
                style: VodoTextStyles.titleMedium.copyWith(
                  color: VodoColors.textSecondary,
                ),
              ),
              const SizedBox(height: VodoDimensions.spacingSm),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: VodoTextStyles.display.copyWith(
                  color: VodoColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: VodoDimensions.spacingMd),

        // Payment method grid
        Padding(
          padding: VodoDimensions.paddingMd,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.2,
              crossAxisSpacing: VodoDimensions.spacingMd,
              mainAxisSpacing: VodoDimensions.spacingMd,
            ),
            itemCount: methods.length,
            itemBuilder: (context, index) {
              return _VodoPaymentMethodCard(
                method: methods[index],
                onTap: () => onMethodSelected(methods[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual payment method card (Odoo-style)
class _VodoPaymentMethodCard extends StatefulWidget {
  final VodoPaymentMethod method;
  final VoidCallback onTap;

  const _VodoPaymentMethodCard({
    required this.method,
    required this.onTap,
  });

  @override
  State<_VodoPaymentMethodCard> createState() => _VodoPaymentMethodCardState();
}

class _VodoPaymentMethodCardState extends State<_VodoPaymentMethodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.method.enabled) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.method.enabled ? widget.onTap : null,
        child: Card(
          elevation: _isPressed ? 8 : VodoDimensions.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: VodoDimensions.borderRadiusMd,
            side: _isPressed
                ? BorderSide(color: widget.method.color, width: 3)
                : BorderSide(
                    color: widget.method.enabled
                        ? widget.method.color.withOpacity(0.3)
                        : VodoColors.border,
                    width: 2,
                  ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: widget.method.enabled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.method.color.withOpacity(0.1),
                        widget.method.color.withOpacity(0.05),
                      ],
                    )
                  : null,
              borderRadius: VodoDimensions.borderRadiusMd,
            ),
            child: Stack(
              children: [
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        padding: VodoDimensions.paddingMd,
                        decoration: BoxDecoration(
                          color: widget.method.enabled
                              ? widget.method.color.withOpacity(0.2)
                              : VodoColors.backgroundSecondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.method.icon,
                          size: 32,
                          color: widget.method.enabled
                              ? widget.method.color
                              : VodoColors.textTertiary,
                        ),
                      ),

                      const SizedBox(height: VodoDimensions.spacingSm),

                      // Name
                      Text(
                        widget.method.name,
                        style: VodoTextStyles.titleSmall.copyWith(
                          color: widget.method.enabled
                              ? VodoColors.textPrimary
                              : VodoColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Device required badge
                      if (widget.method.requiresDevice) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.method.enabled
                                ? VodoColors.info.withOpacity(0.2)
                                : VodoColors.backgroundSecondary,
                            borderRadius: VodoDimensions.borderRadiusSm,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.devices,
                                size: 10,
                                color: widget.method.enabled
                                    ? VodoColors.info
                                    : VodoColors.textTertiary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Device',
                                style: VodoTextStyles.caption.copyWith(
                                  fontSize: 9,
                                  color: widget.method.enabled
                                      ? VodoColors.info
                                      : VodoColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Disabled overlay
                if (!widget.method.enabled)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: VodoDimensions.borderRadiusMd,
                      ),
                      child: Center(
                        child: Text(
                          'Coming Soon',
                          style: VodoTextStyles.labelSmall.copyWith(
                            color: VodoColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive payment grid
class ResponsiveVodoPaymentGrid extends StatelessWidget {
  final List<VodoPaymentMethod> methods;
  final ValueChanged<VodoPaymentMethod> onMethodSelected;
  final double totalAmount;

  const ResponsiveVodoPaymentGrid({
    super.key,
    required this.methods,
    required this.onMethodSelected,
    required this.totalAmount,
  });

  int _getCrossAxisCount(double width) {
    if (width > 900) return 3;
    if (width > 600) return 2;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return VodoPaymentGrid(
          methods: methods,
          onMethodSelected: onMethodSelected,
          totalAmount: totalAmount,
          crossAxisCount: _getCrossAxisCount(constraints.maxWidth),
        );
      },
    );
  }
}
