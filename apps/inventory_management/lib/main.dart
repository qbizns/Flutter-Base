import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/purchase_orders/presentation/pages/purchase_orders_page.dart';
import 'src/features/reports/presentation/pages/inventory_reports_page.dart';
import 'src/features/stock/presentation/pages/stock_adjustment_page.dart';
import 'src/features/stock/presentation/pages/stock_levels_page.dart';
import 'src/features/suppliers/presentation/pages/suppliers_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.dev,
    appBuilder: (config) => const ProviderScope(
      child: InventoryManagementApp(),
    ),
  );
}

/// Inventory Management App
///
/// Comprehensive inventory control system for restaurants.
/// Features:
/// - Stock level monitoring with alerts
/// - Purchase order management
/// - Supplier relationship management
/// - Stock adjustments and corrections
/// - Inventory reports and analytics
/// - Low stock and overstock alerts
/// - Waste and shrinkage tracking
class InventoryManagementApp extends StatelessWidget {
  const InventoryManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Inventory',
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

// Router configuration with shell navigation
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Shell route with persistent navigation
    ShellRoute(
      builder: (context, state, child) {
        return _InventoryShell(child: child);
      },
      routes: [
        // Stock levels dashboard
        GoRoute(
          path: '/',
          builder: (context, state) => const StockLevelsPage(),
        ),

        // Stock adjustment
        GoRoute(
          path: '/stock-adjustment',
          builder: (context, state) {
            final productId = state.uri.queryParameters['productId'];
            return StockAdjustmentPage(productId: productId);
          },
        ),

        // Purchase orders
        GoRoute(
          path: '/purchase-orders',
          builder: (context, state) => const PurchaseOrdersPage(),
        ),
        GoRoute(
          path: '/purchase-orders/new',
          builder: (context, state) {
            final productId = state.uri.queryParameters['productId'];
            return const PurchaseOrdersPage(); // Would show create dialog
          },
        ),

        // Suppliers
        GoRoute(
          path: '/suppliers',
          builder: (context, state) => const SuppliersPage(),
        ),

        // Reports
        GoRoute(
          path: '/reports',
          builder: (context, state) => const InventoryReportsPage(),
        ),
      ],
    ),
  ],
);

/// Inventory Shell - Provides consistent navigation structure
class _InventoryShell extends StatelessWidget {
  const _InventoryShell({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation rail
          _NavigationRail(),

          // Main content
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Navigation Rail - Sidebar navigation
class _NavigationRail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.path;

    return NavigationDrawer(
      selectedIndex: _getSelectedIndex(location),
      onDestinationSelected: (index) {
        _navigateToIndex(context, index);
      },
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'SmartPOS',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Inventory Management',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // Navigation items
        const NavigationDrawerDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Stock Levels'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart),
          label: Text('Purchase Orders'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.business_outlined),
          selectedIcon: Icon(Icons.business),
          label: Text('Suppliers'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.assessment_outlined),
          selectedIcon: Icon(Icons.assessment),
          label: Text('Reports'),
        ),

        const Divider(),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),

        // Quick actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Adjust Stock'),
                onTap: () {
                  context.go('/stock-adjustment');
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: const Text('New Purchase Order'),
                onTap: () {
                  context.go('/purchase-orders');
                },
              ),
            ],
          ),
        ),

        const Spacer(),

        const Divider(),

        // User section
        Padding(
          padding: const EdgeInsets.all(16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: const Text('Inventory Manager'),
            subtitle: const Text('inventory@smartpos.com'),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'settings':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon')),
                    );
                    break;
                  case 'logout':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout feature coming soon')),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/stock-adjustment')) return 0;
    if (location.startsWith('/purchase-orders')) return 1;
    if (location.startsWith('/suppliers')) return 2;
    if (location.startsWith('/reports')) return 3;
    return 0; // Default to stock levels
  }

  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/purchase-orders');
        break;
      case 2:
        context.go('/suppliers');
        break;
      case 3:
        context.go('/reports');
        break;
    }
  }
}
