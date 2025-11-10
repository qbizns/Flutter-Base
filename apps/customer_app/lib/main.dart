import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/account/presentation/pages/account_page.dart';
import 'src/features/cart/presentation/pages/cart_page.dart';
import 'src/features/cart/providers/cart_provider.dart';
import 'src/features/checkout/presentation/pages/checkout_page.dart';
import 'src/features/home/presentation/pages/home_page.dart';
import 'src/features/menu/presentation/pages/menu_page.dart';
import 'src/features/orders/presentation/pages/orders_page.dart';
import 'src/features/reservations/presentation/pages/reservations_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: CustomerApp(),
    ),
  );
}

/// Customer Mobile App
///
/// Complete customer-facing mobile application for ordering, tracking, and managing accounts.
/// Features:
/// - Browse menu and place orders
/// - Track order status in real-time
/// - Manage account and loyalty points
/// - Save addresses and payment methods
/// - Make table reservations
/// - View order history
/// - Earn and redeem loyalty rewards
class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Customer',
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
    );
  }
}

// Router configuration with bottom navigation
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Shell route with persistent bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        return _AppShell(child: child);
      },
      routes: [
        // Home
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),

        // Menu
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuPage(),
        ),

        // Orders
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersPage(),
        ),

        // Account
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountPage(),
        ),
      ],
    ),

    // Full-screen routes (no bottom nav)
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: '/reservations',
      builder: (context, state) => const ReservationsPage(),
    ),
  ],
);

/// App Shell - Provides bottom navigation structure
class _AppShell extends ConsumerWidget {
  const _AppShell({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(context),
        onDestinationSelected: (index) {
          _navigateToIndex(context, index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
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
      floatingActionButton: cart.itemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push('/cart');
              },
              icon: Badge(
                label: Text('${cart.itemCount}'),
                child: const Icon(Icons.shopping_cart),
              ),
              label: Text('\$${cart.total.toStringAsFixed(2)}'),
            )
          : null,
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/':
        return 0;
      case '/menu':
        return 1;
      case '/orders':
        return 2;
      case '/account':
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
        context.go('/menu');
        break;
      case 2:
        context.go('/orders');
        break;
      case 3:
        context.go('/account');
        break;
    }
  }
}
