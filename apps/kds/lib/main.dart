import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/kds/presentation/pages/kds_display_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: KdsApp(),
    ),
  );
}

/// Kitchen Display System App
///
/// Real-time kitchen display for restaurant operations.
/// Follows Odoo KDS patterns 100%:
/// - Multiple station support (Grill, Fryer, Cold Prep, etc.)
/// - Status-based workflow (New → Preparing → Ready → Done)
/// - Color-coded order cards with timers
/// - Real-time updates and alerts
class KdsApp extends StatelessWidget {
  const KdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kitchen Display System',
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
    GoRoute(
      path: '/',
      builder: (context, state) => const KdsDisplayPage(),
    ),
  ],
);
