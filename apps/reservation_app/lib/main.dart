import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/floor/presentation/pages/floor_layout_page.dart';
import 'src/features/reservations/presentation/pages/reservations_page.dart';
import 'src/features/waitlist/presentation/pages/waitlist_page.dart';

void main() {
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: ReservationApp(),
    ),
  );
}

/// Reservation App
///
/// Table reservation and waitlist management for restaurants.
/// Features:
/// - Reservation booking with calendar
/// - Waitlist management
/// - Floor layout and table assignment
/// - Guest check-in
/// - No-show tracking
class ReservationApp extends StatelessWidget {
  const ReservationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Reservations',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.pink,
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

// Router configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return _ReservationShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ReservationsPage(),
        ),
        GoRoute(
          path: '/waitlist',
          builder: (context, state) => const WaitlistPage(),
        ),
        GoRoute(
          path: '/floor',
          builder: (context, state) => const FloorLayoutPage(),
        ),
      ],
    ),
  ],
);

/// Reservation Shell - Bottom navigation
class _ReservationShell extends StatelessWidget {
  const _ReservationShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(GoRouterState.of(context).uri.path),
        onDestinationSelected: (index) => _navigateToIndex(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Reservations',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Waitlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_restaurant_outlined),
            selectedIcon: Icon(Icons.table_restaurant),
            label: 'Floor Plan',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/waitlist':
        return 1;
      case '/floor':
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
        context.go('/waitlist');
        break;
      case 2:
        context.go('/floor');
        break;
    }
  }
}
