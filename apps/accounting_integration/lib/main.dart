import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'src/features/dashboard/presentation/pages/accounting_dashboard_page.dart';
import 'src/features/transactions/presentation/pages/transaction_sync_page.dart';
import 'src/features/accounts/presentation/pages/chart_of_accounts_page.dart';
import 'src/features/reconciliation/presentation/pages/reconciliation_page.dart';
import 'src/features/reports/presentation/pages/financial_reports_page.dart';

void main() {
  runApp(const ProviderScope(child: AccountingIntegrationApp()));
}

class AccountingIntegrationApp extends StatelessWidget {
  const AccountingIntegrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Accounting Integration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return _MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const AccountingDashboardPage(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionSyncPage(),
        ),
        GoRoute(
          path: '/accounts',
          builder: (context, state) => const ChartOfAccountsPage(),
        ),
        GoRoute(
          path: '/reconciliation',
          builder: (context, state) => const ReconciliationPage(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const FinancialReportsPage(),
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
                  context.go('/dashboard');
                  break;
                case 1:
                  context.go('/transactions');
                  break;
                case 2:
                  context.go('/accounts');
                  break;
                case 3:
                  context.go('/reconciliation');
                  break;
                case 4:
                  context.go('/reports');
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
                            Icons.account_balance,
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
                                'Accounting',
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
                  'OVERVIEW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              const Divider(indent: 20, endIndent: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'SYNC & DATA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.sync_outlined),
                selectedIcon: Icon(Icons.sync),
                label: Text('Transaction Sync'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.account_tree_outlined),
                selectedIcon: Icon(Icons.account_tree),
                label: Text('Chart of Accounts'),
              ),
              const Divider(indent: 20, endIndent: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'ANALYSIS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.compare_outlined),
                selectedIcon: Icon(Icons.compare),
                label: Text('Reconciliation'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.assessment_outlined),
                selectedIcon: Icon(Icons.assessment),
                label: Text('Financial Reports'),
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
      case '/dashboard':
        return 0;
      case '/transactions':
        return 1;
      case '/accounts':
        return 2;
      case '/reconciliation':
        return 3;
      case '/reports':
        return 4;
      default:
        return 0;
    }
  }
}
