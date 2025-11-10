import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Order Tracking Page - Order confirmation and tracking
///
/// Features:
/// - Large order number display
/// - Success animation
/// - Estimated wait time
/// - Instructions for pickup
/// - Auto-redirect to home after timeout
class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({
    required this.orderNumber,
    super.key,
  });

  final String orderNumber;

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _redirectTimer;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();

    // Success animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();

    // Auto-redirect timer
    _startRedirectTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _startRedirectTimer() {
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining <= 0) {
        timer.cancel();
        if (mounted) {
          context.go('/');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success checkmark animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Success message
              Text(
                'Order Placed Successfully!',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Order number
              Text(
                'Your Order Number',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: Text(
                  widget.orderNumber,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 72,
                    letterSpacing: 8,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Estimated wait time
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Estimated Wait Time',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '10-15 minutes',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Instructions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Please wait at the counter',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We\'ll call your order number when it\'s ready',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Print receipt
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Receipt printing...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.print, size: 28),
                      label: const Text('Print Receipt'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        textStyle: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        _redirectTimer?.cancel();
                        context.go('/');
                      },
                      icon: const Icon(Icons.home, size: 28),
                      label: const Text('New Order'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        textStyle: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Auto-redirect countdown
              Text(
                'Returning to home in $_secondsRemaining seconds...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
