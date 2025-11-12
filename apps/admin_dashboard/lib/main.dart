import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/ui/theme/odoo_theme.dart';
import 'src/ui/widgets/odoo_layout.dart';
import 'src/features/dashboard/presentation/pages/dashboard_home_page.dart';
import 'src/features/sales/presentation/pages/sales_page.dart';
import 'src/features/products/presentation/pages/products_page.dart';
import 'src/features/restaurant/presentation/pages/restaurant_page.dart';
import 'src/features/staff/presentation/pages/staff_page.dart';
import 'src/features/settings/presentation/pages/settings_page.dart';
import 'src/features/devices/presentation/pages/devices_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: AdminDashboardApp(),
    ),
  );
}

/// Admin Dashboard App
/// Back office management for SmartPOS system
/// Following Odoo design guidelines 100%
class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Admin',
      theme: OdooTheme.lightTheme,
      darkTheme: OdooTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Router configuration with Odoo layout
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return OdooLayout(child: child);
      },
      routes: [
        // Dashboard (Home)
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardHomePage(),
        ),

        // Sales
        GoRoute(
          path: '/sales',
          name: 'sales',
          builder: (context, state) => const SalesPage(),
        ),

        // Products
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) => const ProductsPage(),
        ),

        // Restaurant
        GoRoute(
          path: '/restaurant',
          name: 'restaurant',
          builder: (context, state) => const RestaurantPage(),
        ),

        // Staff
        GoRoute(
          path: '/staff',
          name: 'staff',
          builder: (context, state) => const StaffPage(),
        ),

        // Settings
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),

        // Devices
        GoRoute(
          path: '/devices',
          name: 'devices',
          builder: (context, state) => const DevicesPage(),
        ),
      ],
    ),
  ],
);
