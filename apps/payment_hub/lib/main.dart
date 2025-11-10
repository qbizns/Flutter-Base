import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'src/features/transactions/presentation/pages/transactions_page.dart';
import 'src/features/settlements/presentation/pages/settlements_page.dart';
import 'src/features/providers/presentation/pages/providers_page.dart';
import 'src/features/refunds/presentation/pages/refunds_page.dart';
import 'src/features/analytics/presentation/pages/analytics_page.dart';

void main() {
  runApp(const ProviderScope(child: PaymentHubApp()));
}

class PaymentHubApp extends StatelessWidget {
  const PaymentHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Payment Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/transactions',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return _MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionsPage(),
        ),
        GoRoute(
          path: '/settlements',
          builder: (context, state) => const SettlementsPage(),
        ),
        GoRoute(
          path: '/providers',
          builder: (context, state) => const ProvidersPage(),
        ),
        GoRoute(
          path: '/refunds',
          builder: (context, state) => const RefundsPage(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsPage(),
        ),
      ],
    ),
  ],
);

class _MainScaffold extends StatelessWidget {
  final Widget child;

  const _MainScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: _getSelectedIndex(location),
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/transactions');
                  break;
                case 1:
                  context.go('/settlements');
                  break;
                case 2:
                  context.go('/providers');
                  break;
                case 3:
                  context.go('/refunds');
                  break;
                case 4:
                  context.go('/analytics');
                  break;
              }
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Hub',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'SmartPOS',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'PAYMENT OPERATIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Transactions'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.account_balance_outlined),
                selectedIcon: Icon(Icons.account_balance),
                label: Text('Settlements'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.credit_card_outlined),
                selectedIcon: Icon(Icons.credit_card),
                label: Text('Providers'),
              ),
              const Divider(indent: 20, endIndent: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'DISPUTE MANAGEMENT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.keyboard_return_outlined),
                selectedIcon: Icon(Icons.keyboard_return),
                label: Text('Refunds & Chargebacks'),
              ),
              const Divider(indent: 20, endIndent: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'INSIGHTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/transactions':
        return 0;
      case '/settlements':
        return 1;
      case '/providers':
        return 2;
      case '/refunds':
        return 3;
      case '/analytics':
        return 4;
      default:
        return 0;
    }
  }
}
