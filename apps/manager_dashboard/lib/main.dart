import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/dashboard/presentation/pages/dashboard_home_page.dart';
import 'src/features/monitoring/presentation/pages/monitoring_page.dart';
import 'src/features/products/presentation/pages/products_page.dart';
import 'src/features/sales/presentation/pages/sales_page.dart';
import 'src/features/staff/presentation/pages/staff_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: ManagerDashboardApp(),
    ),
  );
}

/// Manager Dashboard App
///
/// Comprehensive business intelligence and management application.
/// Features:
/// - Real-time operations monitoring
/// - Sales analytics and reports
/// - Product performance tracking
/// - Staff management
/// - Inventory oversight
/// - Multi-location support (future)
class ManagerDashboardApp extends StatelessWidget {
  const ManagerDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Manager',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
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
        return _DashboardShell(child: child);
      },
      routes: [
        // Dashboard home
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardHomePage(),
        ),

        // Sales analytics
        GoRoute(
          path: '/sales',
          builder: (context, state) => const SalesPage(),
        ),

        // Product performance
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsPage(),
        ),

        // Staff management
        GoRoute(
          path: '/staff',
          builder: (context, state) => const StaffPage(),
        ),

        // Live monitoring
        GoRoute(
          path: '/monitoring',
          builder: (context, state) => const MonitoringPage(),
        ),

        // Inventory (placeholder)
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const _PlaceholderPage(
            title: 'Inventory Management',
            icon: Icons.inventory_2_outlined,
          ),
        ),

        // Orders (placeholder)
        GoRoute(
          path: '/orders',
          builder: (context, state) => const _PlaceholderPage(
            title: 'Orders',
            icon: Icons.receipt_long,
          ),
        ),
      ],
    ),
  ],
);

/// Dashboard Shell - Provides consistent navigation structure
class _DashboardShell extends StatelessWidget {
  const _DashboardShell({
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
                    Icons.business,
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
                'Manager Dashboard',
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
          label: Text('Dashboard'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.monitor_outlined),
          selectedIcon: Icon(Icons.monitor),
          label: Text('Live Monitor'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.assessment_outlined),
          selectedIcon: Icon(Icons.assessment),
          label: Text('Sales Analytics'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: Text('Products'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Staff'),
        ),

        const Divider(),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Text(
            'OPERATIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),

        const NavigationDrawerDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: Text('Orders'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.inventory_outlined),
          selectedIcon: Icon(Icons.inventory),
          label: Text('Inventory'),
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
            title: const Text('Manager'),
            subtitle: const Text('manager@smartpos.com'),
            trailing: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout feature coming soon')),
                );
              },
              tooltip: 'Logout',
            ),
          ),
        ),
      ],
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/monitoring':
        return 1;
      case '/sales':
        return 2;
      case '/products':
        return 3;
      case '/staff':
        return 4;
      case '/orders':
        return 5;
      case '/inventory':
        return 6;
      default:
        return 0;
    }
  }

  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/monitoring');
        break;
      case 2:
        context.go('/sales');
        break;
      case 3:
        context.go('/products');
        break;
      case 4:
        context.go('/staff');
        break;
      case 5:
        context.go('/orders');
        break;
      case 6:
        context.go('/inventory');
        break;
    }
  }
}

/// Placeholder page for features not yet implemented
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

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
              icon,
              size: 120,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This feature is coming soon',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
