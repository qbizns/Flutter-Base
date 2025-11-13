import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/dashboard/presentation/pages/dashboard_home_page.dart';
import 'src/features/devices/presentation/pages/devices_page.dart';
import 'src/features/monitoring/presentation/pages/monitoring_page.dart';
import 'src/features/products/presentation/pages/products_page.dart';
import 'src/features/products/presentation/pages/product_details_page.dart';
import 'src/features/restaurant/presentation/pages/restaurant_page.dart';
import 'src/features/sales/presentation/pages/sales_page.dart';
import 'src/features/settings/presentation/pages/settings_page.dart';
import 'src/features/staff/presentation/pages/staff_page.dart';
import 'src/ui/theme/odoo_theme.dart';
import 'src/ui/widgets/odoo_layout.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.dev,
    appBuilder: (config) => const ProviderScope(
      child: ManagerDashboardApp(),
    ),
  );
}

/// Manager Dashboard App
///
/// Comprehensive business intelligence and management application following
/// Odoo 17 design guidelines.
///
/// Features:
/// - Real-time operations monitoring
/// - Sales analytics and reports
/// - Product performance tracking
/// - Restaurant management (floor plans, tables, reservations)
/// - Staff management and scheduling
/// - Device monitoring and configuration
/// - System settings and configuration
class ManagerDashboardApp extends StatelessWidget {
  const ManagerDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Manager',
      theme: OdooTheme.light(),
      darkTheme: OdooTheme.dark(),
      themeMode: ThemeMode.light, // Default to light mode for Odoo consistency
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Router configuration with Odoo layout shell
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Shell route with Odoo layout
    ShellRoute(
      builder: (context, state, child) {
        return OdooLayout(child: child);
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

        // Product management
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsPage(),
        ),

        // Product details
        GoRoute(
          path: '/products/:id',
          builder: (context, state) {
            final productId = state.pathParameters['id']!;
            return ProductDetailsPage(productId: productId);
          },
        ),

        // Restaurant management
        GoRoute(
          path: '/restaurant',
          builder: (context, state) => const RestaurantPage(),
        ),

        // Staff management
        GoRoute(
          path: '/staff',
          builder: (context, state) => const StaffPage(),
        ),

        // Settings
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),

        // Devices monitoring
        GoRoute(
          path: '/devices',
          builder: (context, state) => const DevicesPage(),
        ),

        // Live monitoring
        GoRoute(
          path: '/monitoring',
          builder: (context, state) => const MonitoringPage(),
        ),
      ],
    ),
  ],
);

/// Placeholder page for features not yet implemented
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: const Color(0xFFF9F9F9), // Odoo background
      child: Center(
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
              subtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is coming soon',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
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
