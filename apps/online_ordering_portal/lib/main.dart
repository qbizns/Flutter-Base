import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/account/presentation/pages/account_page.dart';
import 'src/features/cart/presentation/pages/cart_page.dart';
import 'src/features/checkout/presentation/pages/checkout_page.dart';
import 'src/features/menu/presentation/pages/menu_page.dart';
import 'src/features/orders/presentation/pages/order_tracking_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.dev,
    appBuilder: (config) => const ProviderScope(
      child: OnlineOrderingPortalApp(),
    ),
  );
}

/// Online Ordering Portal App
///
/// Web/PWA customer ordering platform for SmartPOS.
/// Features:
/// - Menu browsing with search and filters
/// - Shopping cart with order customization
/// - Checkout with multiple payment methods
/// - Real-time order tracking
/// - User accounts with order history
/// - Loyalty rewards program
class OnlineOrderingPortalApp extends StatelessWidget {
  const OnlineOrderingPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Online Ordering',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }
}

// Router configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Shell route with bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        return _OnlineOrderingShell(child: child);
      },
      routes: [
        // Menu (Home)
        GoRoute(
          path: '/',
          builder: (context, state) => const MenuPage(),
        ),

        // Orders
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrderTrackingPage(),
        ),

        // Account
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountPage(),
        ),
      ],
    ),

    // Cart (full screen)
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),

    // Checkout (full screen)
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
  ],
);

/// Online Ordering Shell - Provides consistent navigation
class _OnlineOrderingShell extends StatelessWidget {
  const _OnlineOrderingShell({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(location),
        onDestinationSelected: (index) {
          _navigateToIndex(context, index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/cart'),
        icon: badges.Badge(
          badgeContent: const Text(
            '3',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: theme.colorScheme.error,
          ),
          child: const Icon(Icons.shopping_cart),
        ),
        label: const Text('Cart'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/orders':
        return 1;
      case '/account':
        return 2;
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
        context.go('/orders');
        break;
      case 2:
        context.go('/account');
        break;
    }
  }
}
