import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/cash_drawer/presentation/pages/cash_drawer_page.dart';
import 'src/features/payment/presentation/pages/payment_page.dart';
import 'src/features/pos/presentation/pages/pos_terminal_page.dart';
import 'src/features/transactions/presentation/pages/transactions_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: CashierApp(),
    ),
  );
}

/// Cashier App
///
/// Complete POS terminal application for payment processing and cash management.
/// Features:
/// - Order selection and processing
/// - Multiple payment methods (cash, card, digital wallet, gift card)
/// - Tip calculation (percentage or custom)
/// - Cash handling with change calculation
/// - Split bill functionality
/// - Transaction history with search and filters
/// - Cash drawer management
/// - End of shift reconciliation
/// - Receipt printing
/// - Refund/void capabilities
class CashierApp extends StatelessWidget {
  const CashierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Cashier',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      visualDensity: VisualDensity.standard,
    );
  }
}

// Router configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // POS Terminal (Main screen)
    GoRoute(
      path: '/',
      builder: (context, state) => const PosTerminalPage(),
    ),

    // Payment processing
    GoRoute(
      path: '/payment',
      builder: (context, state) {
        final order = state.extra as Order;
        return PaymentPage(order: order);
      },
    ),

    // Transaction history
    GoRoute(
      path: '/transactions',
      builder: (context, state) => const TransactionsPage(),
    ),

    // Cash drawer management
    GoRoute(
      path: '/cash-drawer',
      builder: (context, state) => const CashDrawerPage(),
    ),

    // Split bill (future implementation)
    GoRoute(
      path: '/split-bill',
      builder: (context, state) => const _ComingSoonPage(
        title: 'Split Bill',
        description: 'Split bill functionality coming soon',
      ),
    ),
  ],
);

/// Coming Soon Page - Placeholder for future features
class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              description,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
