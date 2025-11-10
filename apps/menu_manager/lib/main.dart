import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/availability/presentation/pages/availability_page.dart';
import 'src/features/bulk_operations/presentation/pages/bulk_operations_page.dart';
import 'src/features/categories/presentation/pages/categories_page.dart';
import 'src/features/menu_items/presentation/pages/menu_items_page.dart';
import 'src/features/modifiers/presentation/pages/modifiers_page.dart';
import 'src/features/pricing/presentation/pages/pricing_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: MenuManagerApp(),
    ),
  );
}

/// Menu Manager App
///
/// Complete menu management system for restaurant configuration.
/// Features:
/// - Menu items CRUD with grid/list views
/// - Category management with reordering
/// - Modifiers/add-ons system
/// - Pricing rules (happy hour, time-based discounts)
/// - Availability scheduling
/// - Bulk operations (import/export, bulk updates)
class MenuManagerApp extends StatelessWidget {
  const MenuManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Menu Manager',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
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
        return _MenuManagerShell(child: child);
      },
      routes: [
        // Menu Items
        GoRoute(
          path: '/',
          builder: (context, state) => const MenuItemsPage(),
        ),

        // Categories
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoriesPage(),
        ),

        // Modifiers
        GoRoute(
          path: '/modifiers',
          builder: (context, state) => const ModifiersPage(),
        ),

        // Pricing
        GoRoute(
          path: '/pricing',
          builder: (context, state) => const PricingPage(),
        ),

        // Availability
        GoRoute(
          path: '/availability',
          builder: (context, state) => const AvailabilityPage(),
        ),

        // Bulk Operations
        GoRoute(
          path: '/bulk-operations',
          builder: (context, state) => const BulkOperationsPage(),
        ),
      ],
    ),
  ],
);

/// Menu Manager Shell - Provides consistent navigation structure
class _MenuManagerShell extends StatelessWidget {
  const _MenuManagerShell({
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
                    Icons.restaurant_menu,
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
                'Menu Manager',
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
          icon: Icon(Icons.fastfood_outlined),
          selectedIcon: Icon(Icons.fastfood),
          label: Text('Menu Items'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.category_outlined),
          selectedIcon: Icon(Icons.category),
          label: Text('Categories'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: Text('Modifiers'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.local_offer_outlined),
          selectedIcon: Icon(Icons.local_offer),
          label: Text('Pricing Rules'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.schedule_outlined),
          selectedIcon: Icon(Icons.schedule),
          label: Text('Availability'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Bulk Operations'),
        ),
      ],
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/categories':
        return 1;
      case '/modifiers':
        return 2;
      case '/pricing':
        return 3;
      case '/availability':
        return 4;
      case '/bulk-operations':
        return 5;
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
        context.go('/categories');
        break;
      case 2:
        context.go('/modifiers');
        break;
      case 3:
        context.go('/pricing');
        break;
      case 4:
        context.go('/availability');
        break;
      case 5:
        context.go('/bulk-operations');
        break;
    }
  }
}
