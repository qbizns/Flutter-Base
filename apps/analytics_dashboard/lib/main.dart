import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/customers/presentation/pages/customer_insights_page.dart';
import 'src/features/dashboard/presentation/pages/dashboard_overview_page.dart';
import 'src/features/products/presentation/pages/product_analytics_page.dart';
import 'src/features/reports/presentation/pages/reports_page.dart';
import 'src/features/sales/presentation/pages/sales_analytics_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: AnalyticsDashboardApp(),
    ),
  );
}

/// Analytics Dashboard App
///
/// Advanced analytics and reporting dashboard for business insights.
/// Features:
/// - Dashboard overview with KPIs and trends
/// - Sales analytics with detailed charts
/// - Product performance analysis
/// - Customer insights and segmentation
/// - Reports generation and scheduling
class AnalyticsDashboardApp extends StatelessWidget {
  const AnalyticsDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Analytics Dashboard',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.cyan,
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
        return _AnalyticsDashboardShell(child: child);
      },
      routes: [
        // Dashboard Overview
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardOverviewPage(),
        ),

        // Sales Analytics
        GoRoute(
          path: '/sales',
          builder: (context, state) => const SalesAnalyticsPage(),
        ),

        // Product Analytics
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductAnalyticsPage(),
        ),

        // Customer Insights
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomerInsightsPage(),
        ),

        // Reports
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsPage(),
        ),
      ],
    ),
  ],
);

/// Analytics Dashboard Shell - Provides consistent navigation structure
class _AnalyticsDashboardShell extends StatelessWidget {
  const _AnalyticsDashboardShell({
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
                    Icons.analytics,
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
                'Analytics Dashboard',
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
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: Text('Sales Analytics'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: Text('Product Analytics'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Customer Insights'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: Text('Reports'),
        ),
      ],
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/sales':
        return 1;
      case '/products':
        return 2;
      case '/customers':
        return 3;
      case '/reports':
        return 4;
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
        context.go('/sales');
        break;
      case 2:
        context.go('/products');
        break;
      case 3:
        context.go('/customers');
        break;
      case 4:
        context.go('/reports');
        break;
    }
  }
}
