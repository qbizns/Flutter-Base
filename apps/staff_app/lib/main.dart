import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/messages/presentation/pages/messages_page.dart';
import 'src/features/profile/presentation/pages/profile_page.dart';
import 'src/features/scheduling/presentation/pages/scheduling_page.dart';
import 'src/features/time_tracking/presentation/pages/time_tracking_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.dev,
    appBuilder: (config) => const ProviderScope(
      child: StaffApp(),
    ),
  );
}

/// Staff App
///
/// Employee management application for SmartPOS.
/// Features:
/// - Employee scheduling with calendar view
/// - Time tracking with clock in/out
/// - Staff messaging and announcements
/// - Employee profile and performance
class StaffApp extends StatelessWidget {
  const StaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Staff',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
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
    // Shell route with bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        return _StaffAppShell(child: child);
      },
      routes: [
        // Scheduling
        GoRoute(
          path: '/',
          builder: (context, state) => const SchedulingPage(),
        ),

        // Time Tracking
        GoRoute(
          path: '/time-tracking',
          builder: (context, state) => const TimeTrackingPage(),
        ),

        // Messages
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesPage(),
        ),

        // Profile
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);

/// Staff App Shell - Provides bottom navigation
class _StaffAppShell extends StatelessWidget {
  const _StaffAppShell({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavigation(),
    );
  }
}

/// Bottom Navigation Bar
class _BottomNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return NavigationBar(
      selectedIndex: _getSelectedIndex(location),
      onDestinationSelected: (index) {
        _navigateToIndex(context, index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: Icon(Icons.access_time_outlined),
          selectedIcon: Icon(Icons.access_time),
          label: 'Time Clock',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/time-tracking':
        return 1;
      case '/messages':
        return 2;
      case '/profile':
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
        context.go('/time-tracking');
        break;
      case 2:
        context.go('/messages');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
