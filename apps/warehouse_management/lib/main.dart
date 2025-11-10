import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'src/features/inventory/presentation/pages/inventory_dashboard_page.dart';
import 'src/features/transfers/presentation/pages/stock_transfers_page.dart';
import 'src/features/receiving/presentation/pages/receiving_page.dart';
import 'src/features/distribution/presentation/pages/distribution_page.dart';

void main() {
  runApp(const ProviderScope(child: WarehouseManagementApp()));
}

class WarehouseManagementApp extends StatelessWidget {
  const WarehouseManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Warehouse Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/inventory',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryDashboardPage(),
        ),
        GoRoute(
          path: '/transfers',
          builder: (context, state) => const StockTransfersPage(),
        ),
        GoRoute(
          path: '/receiving',
          builder: (context, state) => const ReceivingPage(),
        ),
        GoRoute(
          path: '/distribution',
          builder: (context, state) => const DistributionPage(),
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavigation extends StatelessWidget {
  const ScaffoldWithNavigation({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onDestinationSelected(index, context),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warehouse, size: 32, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Warehouse Management',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Central Inventory & Distribution',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 8, 28, 8),
                child: Text('INVENTORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Inventory'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.compare_arrows_outlined),
                selectedIcon: Icon(Icons.compare_arrows),
                label: Text('Stock Transfers'),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 8, 28, 8),
                child: Text('OPERATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping),
                label: Text('Receiving'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: Text('Distribution'),
              ),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/inventory')) return 0;
    if (location.startsWith('/transfers')) return 1;
    if (location.startsWith('/receiving')) return 2;
    if (location.startsWith('/distribution')) return 3;
    return 0;
  }

  void _onDestinationSelected(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/inventory');
        break;
      case 1:
        context.go('/transfers');
        break;
      case 2:
        context.go('/receiving');
        break;
      case 3:
        context.go('/distribution');
        break;
    }
  }
}
