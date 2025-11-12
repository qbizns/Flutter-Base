import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/ui/pages/active_orders_page.dart';
import 'src/ui/pages/floor_plan_page.dart';
import 'src/ui/pages/order_taking_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: WaiterApp(),
    ),
  );
}

/// Waiter/Server App
///
/// Mobile-first application for restaurant servers to:
/// - Select and manage tables
/// - Take orders at tableside
/// - Track order status
/// - Process payments
/// - Transfer tables
class WaiterApp extends StatelessWidget {
  const WaiterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Waiter',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  /// Light theme optimized for mobile
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      // Mobile-optimized text sizes
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      // Mobile-friendly touch targets
      visualDensity: VisualDensity.comfortable,
    );
  }

  /// Dark theme for low-light environments
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      visualDensity: VisualDensity.comfortable,
    );
  }
}

// Router configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Floor Plan (Home)
    GoRoute(
      path: '/',
      builder: (context, state) => const FloorPlanPage(),
    ),

    // Order Taking for a specific table
    GoRoute(
      path: '/table/:tableId/order',
      builder: (context, state) {
        final tableId = state.pathParameters['tableId']!;
        return OrderTakingPage(tableId: tableId);
      },
    ),

    // Active Orders List
    GoRoute(
      path: '/orders',
      builder: (context, state) => const ActiveOrdersPage(),
    ),

    // Current Order for a table
    GoRoute(
      path: '/table/:tableId/current-order',
      builder: (context, state) {
        // TODO: Implement current order view
        final tableId = state.pathParameters['tableId']!;
        return Scaffold(
          appBar: AppBar(title: Text('Table $tableId - Current Order')),
          body: const Center(
            child: Text('Current order view coming soon'),
          ),
        );
      },
    ),

    // Checkout/Payment for a table
    GoRoute(
      path: '/table/:tableId/checkout',
      builder: (context, state) {
        // TODO: Implement checkout flow
        final tableId = state.pathParameters['tableId']!;
        return Scaffold(
          appBar: AppBar(title: Text('Table $tableId - Checkout')),
          body: const Center(
            child: Text('Checkout flow coming soon'),
          ),
        );
      },
    ),
  ],
);
