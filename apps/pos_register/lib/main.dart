import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/checkout/presentation/pages/checkout_page.dart';
import 'src/features/more/presentation/pages/more_page.dart';
import 'src/features/orders/presentation/pages/orders_page.dart';
import 'src/features/orders/presentation/pages/vodo_orders_page.dart';
import 'src/features/payment/presentation/pages/payment_page.dart';
import 'src/features/pos/presentation/pages/main_pos_page.dart';
import 'src/features/session/presentation/pages/session_open_page.dart';
import 'src/features/session/presentation/pages/session_close_page.dart';
import 'src/features/session/presentation/pages/session_history_page.dart';
import 'src/features/session/presentation/pages/session_details_page.dart';
import 'src/features/session/presentation/widgets/session_guard.dart';
import 'src/features/shell/presentation/pages/app_shell.dart';
import 'src/features/tables/presentation/pages/tables_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.dev,
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
      theme: VodoTheme.lightTheme,
      darkTheme: VodoTheme.darkTheme,
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
        // POS Tab (requires active session)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const SessionGuard(
                child: MainPosPage(),
              ),
            ),
          ],
        ),
        // Tables Tab (requires active session)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tables',
              builder: (context, state) => const SessionGuard(
                child: TablesPage(),
              ),
            ),
          ],
        ),
        // Orders Tab (requires active session)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const SessionGuard(
                child: VodoOrdersPage(),
              ),
            ),
          ],
        ),
        // More Tab (no session required - settings/info)
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
    // Checkout Route (requires active session)
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const SessionGuard(
        child: CheckoutPage(),
      ),
    ),
    // Payment Route (requires active session)
    GoRoute(
      path: '/payment',
      builder: (context, state) => const SessionGuard(
        child: PaymentPage(),
      ),
    ),
    // Session Open Route (no session required - this is where you open it)
    GoRoute(
      path: '/session/open',
      builder: (context, state) => const SessionOpenPage(),
    ),
    // Session Close Route (requires active session)
    GoRoute(
      path: '/session/close',
      builder: (context, state) => const SessionGuard(
        child: SessionClosePage(),
      ),
    ),
    // Session History Route (no session required - view past sessions)
    GoRoute(
      path: '/session/history',
      builder: (context, state) => const SessionHistoryPage(),
    ),
    // Session Details Route (no session required - view past session details)
    GoRoute(
      path: '/session/details/:id',
      builder: (context, state) {
        final sessionId = state.pathParameters['id']!;
        return SessionDetailsPage(sessionId: sessionId);
      },
    ),
  ],
);
