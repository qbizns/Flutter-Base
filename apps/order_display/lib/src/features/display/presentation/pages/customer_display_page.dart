/// Customer Display Page
/// Odoo-style POS customer-facing display
/// Shows current cart as items are scanned at the register
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/customer_display_models.dart';
import '../../../../data/services/customer_display_service.dart';
import '../widgets/idle_screen.dart';
import '../widgets/cart_display.dart';
import '../widgets/payment_screen.dart';
import '../widgets/thank_you_screen.dart';

/// Customer Display Page
/// Main page for Odoo-style customer-facing POS display
class CustomerDisplayPage extends ConsumerStatefulWidget {
  const CustomerDisplayPage({super.key});

  @override
  ConsumerState<CustomerDisplayPage> createState() =>
      _CustomerDisplayPageState();
}

class _CustomerDisplayPageState extends ConsumerState<CustomerDisplayPage>
    with TickerProviderStateMixin {
  late AnimationController _modeTransitionController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Mode transition animation
    _modeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _modeTransitionController,
      curve: Curves.easeInOut,
    );

    _modeTransitionController.forward();

    // Load mock demo after delay (for testing)
    Future.delayed(const Duration(seconds: 2), () {
      // Uncomment to test with mock data:
      // ref.read(customerDisplayStateProvider.notifier).loadMockDemo();
    });
  }

  @override
  void dispose() {
    _modeTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayState = ref.watch(customerDisplayStateProvider);

    // Trigger animation on mode change
    ref.listen<CustomerDisplayState>(customerDisplayStateProvider,
        (previous, next) {
      if (previous?.mode != next.mode) {
        _modeTransitionController.forward(from: 0);
      }
    });

    return Scaffold(
      backgroundColor: VodoColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header with branding and time
            _buildHeader(context),

            // Main display area (changes based on mode)
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildDisplayContent(context, displayState),
              ),
            ),

            // Footer with tagline
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: VodoColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo and store name
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: VodoColors.textOnPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 48,
              color: VodoColors.textOnPrimary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vodo Restaurant',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: VodoColors.textOnPrimary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer Display',
                  style: TextStyle(
                    fontSize: 18,
                    color: VodoColors.textOnPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('h:mm a').format(now),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: VodoColors.textOnPrimary,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d, yyyy').format(now),
                style: TextStyle(
                  fontSize: 16,
                  color: VodoColors.textOnPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayContent(
      BuildContext context, CustomerDisplayState state) {
    switch (state.mode) {
      case DisplayMode.idle:
        return IdleScreen(content: state.marketingContent);

      case DisplayMode.cart:
        return CartDisplay(cart: state.currentCart);

      case DisplayMode.payment:
        return PaymentScreen(payment: state.paymentProgress);

      case DisplayMode.thankYou:
        return ThankYouScreen(order: state.completedOrder);
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: VodoColors.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            size: 20,
            color: VodoColors.danger,
          ),
          const SizedBox(width: 12),
          Text(
            'Thank you for choosing Vodo Restaurant',
            style: TextStyle(
              fontSize: 18,
              color: VodoColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
