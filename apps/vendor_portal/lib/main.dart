import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'src/features/vendors/presentation/pages/vendors_dashboard_page.dart';
import 'src/features/orders/presentation/pages/purchase_orders_page.dart';
import 'src/features/invoices/presentation/pages/invoices_page.dart';
import 'src/features/products/presentation/pages/products_catalog_page.dart';

void main() {
  runApp(const ProviderScope(child: VendorPortalApp()));
}

class VendorPortalApp extends StatelessWidget {
  const VendorPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Vendor Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/vendors',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return _MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/vendors',
          builder: (context, state) => const VendorsDashboardPage(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const PurchaseOrdersPage(),
        ),
        GoRoute(
          path: '/invoices',
          builder: (context, state) => const InvoicesPage(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsCatalogPage(),
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
                  context.go('/vendors');
                  break;
                case 1:
                  context.go('/orders');
                  break;
                case 2:
                  context.go('/invoices');
                  break;
                case 3:
                  context.go('/products');
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
                            Icons.handshake,
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
                                'Vendor Portal',
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
                  'PROCUREMENT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.business_outlined),
                selectedIcon: Icon(Icons.business),
                label: Text('Vendors'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: Text('Purchase Orders'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Invoices'),
              ),
              const Divider(indent: 20, endIndent: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'CATALOG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Products'),
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
      case '/vendors':
        return 0;
      case '/orders':
        return 1;
      case '/invoices':
        return 2;
      case '/products':
        return 3;
      default:
        return 0;
    }
  }
}
