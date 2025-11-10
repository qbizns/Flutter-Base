import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/deliveries/presentation/pages/deliveries_dashboard_page.dart';
import 'src/features/drivers/presentation/pages/drivers_page.dart';
import 'src/features/zones/presentation/pages/delivery_zones_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: DeliveryManagementApp(),
    ),
  );
}

/// Delivery Management App
///
/// Complete delivery operations management system.
/// Features:
/// - Real-time delivery tracking
/// - Driver management and assignment
/// - Route optimization
/// - Delivery zones and fees
/// - Performance metrics
/// - Customer notifications
/// - Proof of delivery
class DeliveryManagementApp extends StatelessWidget {
  const DeliveryManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Delivery',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
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
        return _DeliveryShell(child: child);
      },
      routes: [
        // Deliveries dashboard
        GoRoute(
          path: '/',
          builder: (context, state) => const DeliveriesDashboardPage(),
        ),

        // Drivers
        GoRoute(
          path: '/drivers',
          builder: (context, state) => const DriversPage(),
        ),

        // Delivery zones
        GoRoute(
          path: '/zones',
          builder: (context, state) => const DeliveryZonesPage(),
        ),

        // Map view (placeholder)
        GoRoute(
          path: '/delivery-map',
          builder: (context, state) => const _PlaceholderPage(
            title: 'Delivery Map',
            icon: Icons.map,
          ),
        ),
      ],
    ),
  ],
);

/// Delivery Shell - Provides consistent navigation structure
class _DeliveryShell extends StatelessWidget {
  const _DeliveryShell({
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
                    Icons.delivery_dining,
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
                'Delivery Management',
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
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Drivers'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.place_outlined),
          selectedIcon: Icon(Icons.place),
          label: Text('Delivery Zones'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: Text('Map View'),
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
            title: const Text('Delivery Manager'),
            subtitle: const Text('delivery@smartpos.com'),
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
      case '/drivers':
        return 1;
      case '/zones':
        return 2;
      case '/delivery-map':
        return 3;
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
        context.go('/drivers');
        break;
      case 2:
        context.go('/zones');
        break;
      case 3:
        context.go('/delivery-map');
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
