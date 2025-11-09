import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/checkout/presentation/pages/checkout_page.dart';
import 'src/features/more/presentation/pages/more_page.dart';
import 'src/features/orders/presentation/pages/orders_page.dart';
import 'src/features/pos/presentation/pages/main_pos_page.dart';
import 'src/features/shell/presentation/pages/app_shell.dart';
import 'src/features/tables/presentation/pages/tables_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: PosRegisterApp(),
    ),
  );
}

/// POS Register App
///
/// Main POS terminal application for restaurants and retail.
/// This is a thin wrapper around pos_core that provides:
/// - App-specific configuration
/// - Custom app identity (name, icons, theme overrides)
/// - Feature selection (which features are enabled for this app)
class PosRegisterApp extends StatelessWidget {
  const PosRegisterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Register',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Router configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // POS Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const MainPosPage(),
            ),
          ],
        ),
        // Tables Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tables',
              builder: (context, state) => const TablesPage(),
            ),
          ],
        ),
        // Orders Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersPage(),
            ),
          ],
        ),
        // More Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const MorePage(),
            ),
          ],
        ),
      ],
    ),
    // Checkout Route (outside of shell)
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
  ],
);
