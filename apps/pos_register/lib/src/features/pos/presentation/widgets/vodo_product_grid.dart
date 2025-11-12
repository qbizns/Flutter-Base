/// Vodo Product Grid Widget
/// Odoo-style product grid for POS with enhanced interactions
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Enhanced product grid following Odoo POS patterns
class VodoProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final bool showStock;
  final int crossAxisCount;

  const VodoProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.showStock = true,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: VodoDimensions.paddingMd,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: VodoDimensions.spacingMd,
        mainAxisSpacing: VodoDimensions.spacingMd,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return VodoProductCard(
          product: products[index],
          onTap: () => onProductTap(products[index]),
          showStock: showStock,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: VodoColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: VodoDimensions.spacingMd),
          Text(
            'No products found',
            style: VodoTextStyles.bodyLarge.copyWith(
              color: VodoColors.textSecondary,
            ),
          ),
          const SizedBox(height: VodoDimensions.spacingSm),
          Text(
            'Try selecting a different category or clearing filters',
            style: VodoTextStyles.bodySmall.copyWith(
              color: VodoColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Odoo-style product card
class VodoProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final bool showStock;

  const VodoProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showStock = true,
  });

  @override
  State<VodoProductCard> createState() => _VodoProductCardState();
}

class _VodoProductCardState extends State<VodoProductCard>
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
    setState(() => _isPressed = true);
    _controller.forward();
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
    final isLowStock = widget.product.stock != null && widget.product.stock! < 10;
    final isOutOfStock = widget.product.stock != null && widget.product.stock! <= 0;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: isOutOfStock ? null : widget.onTap,
        child: Card(
          elevation: _isPressed ? 8 : VodoDimensions.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: VodoDimensions.borderRadiusMd,
            side: _isPressed
                ? BorderSide(color: VodoColors.primary, width: 2)
                : BorderSide.none,
          ),
          child: Stack(
            children: [
              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product image
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: VodoColors.backgroundSecondary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(VodoDimensions.radiusMd),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (widget.product.imageUrl != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(VodoDimensions.radiusMd),
                              ),
                              child: Image.network(
                                widget.product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildImagePlaceholder();
                                },
                              ),
                            )
                          else
                            _buildImagePlaceholder(),

                          // Out of stock overlay
                          if (isOutOfStock)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(VodoDimensions.radiusMd),
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  padding: VodoDimensions.paddingSm,
                                  decoration: BoxDecoration(
                                    color: VodoColors.danger,
                                    borderRadius: VodoDimensions.borderRadiusSm,
                                  ),
                                  child: Text(
                                    'OUT OF STOCK',
                                    style: VodoTextStyles.badge.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Product info
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: VodoDimensions.paddingSm,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Product name
                          Text(
                            widget.product.name,
                            style: VodoTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Price and stock info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Price
                              Text(
                                '\$${widget.product.price.toStringAsFixed(2)}',
                                style: VodoTextStyles.priceMedium.copyWith(
                                  color: isOutOfStock
                                      ? VodoColors.textTertiary
                                      : VodoColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              // Stock indicator
                              if (widget.showStock && widget.product.stock != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      isLowStock
                                          ? Icons.warning_amber
                                          : Icons.check_circle,
                                      size: 12,
                                      color: isOutOfStock
                                          ? VodoColors.danger
                                          : (isLowStock
                                              ? VodoColors.warning
                                              : VodoColors.success),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        isOutOfStock
                                            ? 'Out of stock'
                                            : '${widget.product.stock} in stock',
                                        style: VodoTextStyles.caption.copyWith(
                                          color: isOutOfStock
                                              ? VodoColors.danger
                                              : (isLowStock
                                                  ? VodoColors.warning
                                                  : VodoColors.textSecondary),
                                          fontWeight: isLowStock || isOutOfStock
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Quick add button (Odoo-style)
              if (!isOutOfStock)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: VodoColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: VodoColors.success.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: VodoColors.textOnPrimary,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      onPressed: widget.onTap,
                      tooltip: 'Add to cart',
                    ),
                  ),
                ),

              // Product badge (if on sale, featured, etc.)
              if (widget.product.isOnSale)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: VodoColors.danger,
                      borderRadius: VodoDimensions.borderRadiusSm,
                    ),
                    child: Text(
                      'SALE',
                      style: VodoTextStyles.badge.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: VodoColors.backgroundSecondary,
      child: Icon(
        Icons.fastfood,
        size: 48,
        color: VodoColors.textTertiary.withOpacity(0.3),
      ),
    );
  }
}

/// Responsive product grid that adjusts columns based on screen size
class ResponsiveVodoProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final bool showStock;

  const ResponsiveVodoProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.showStock = true,
  });

  int _getCrossAxisCount(double width) {
    if (width > 1400) return 6;
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return VodoProductGrid(
          products: products,
          onProductTap: onProductTap,
          showStock: showStock,
          crossAxisCount: _getCrossAxisCount(constraints.maxWidth),
        );
      },
    );
  }
}
