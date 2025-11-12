/// Thank You Screen Widget
/// Shows after order completion
/// Following Odoo POS customer display patterns
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/customer_display_models.dart';

/// Thank You Screen
/// Displays after order is completed
class ThankYouScreen extends StatefulWidget {
  final CompletedOrder? order;

  const ThankYouScreen({
    super.key,
    this.order,
  });

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _heartBeatController;
  late Animation<double> _heartBeatAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    // Heart beat animation
    _heartBeatController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _heartBeatAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _heartBeatController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _heartBeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order == null) {
      return Center(
        child: Text(
          'No completed order',
          style: TextStyle(
            fontSize: 32,
            color: VodoColors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      color: VodoColors.backgroundPrimary,
      child: Stack(
        children: [
          // Confetti background effect
          _buildConfettiEffect(),

          // Main content
          Center(
            child: _buildThankYouContent(context, widget.order!),
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiEffect() {
    return Positioned.fill(
      child: FadeTransition(
        opacity: _confettiController,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                VodoColors.primary.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThankYouContent(BuildContext context, CompletedOrder order) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated heart icon
        ScaleTransition(
          scale: _heartBeatAnimation,
          child: Container(
            padding: const EdgeInsets.all(56),
            decoration: BoxDecoration(
              color: VodoColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: VodoColors.success.withOpacity(0.2),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.favorite,
              size: 140,
              color: VodoColors.success,
            ),
          ),
        ),

        const SizedBox(height: 64),

        // Thank you message
        ScaleTransition(
          scale: _confettiController,
          child: Text(
            'Thank You!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w900,
              color: VodoColors.primary,
              letterSpacing: 4,
              height: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Customer name (if available)
        if (order.customerName != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              color: VodoColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              order.customerName!,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w600,
                color: VodoColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Order summary card
        FadeTransition(
          opacity: _confettiController,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: VodoColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: VodoColors.border,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                // Order number
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 32,
                      color: VodoColors.primary,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Order: ${order.orderNumber}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: VodoColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Divider
                Container(
                  width: 200,
                  height: 2,
                  color: VodoColors.border,
                ),

                const SizedBox(height: 24),

                // Items count
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      size: 28,
                      color: VodoColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${order.totalItems} items',
                      style: TextStyle(
                        fontSize: 28,
                        color: VodoColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Total amount
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: VodoColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total: ',
                        style: TextStyle(
                          fontSize: 32,
                          color: VodoColors.textSecondary,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(order.total),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: VodoColors.primary,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 64),

        // Appreciation message
        Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: VodoColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: VodoColors.success.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Your order has been completed successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: VodoColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We hope you enjoy your meal!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: VodoColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Footer badges
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBadge(
              icon: Icons.star,
              label: 'Quality',
              color: VodoColors.warning,
            ),
            const SizedBox(width: 24),
            _buildBadge(
              icon: Icons.speed,
              label: 'Fast',
              color: VodoColors.info,
            ),
            const SizedBox(width: 24),
            _buildBadge(
              icon: Icons.favorite,
              label: 'Care',
              color: VodoColors.danger,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
