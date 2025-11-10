import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/audit/presentation/pages/audit_logs_page.dart';
import 'src/features/dashboard/presentation/pages/dashboard_page.dart';
import 'src/features/roles/presentation/pages/roles_page.dart';
import 'src/features/settings/presentation/pages/settings_page.dart';
import 'src/features/users/presentation/pages/users_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: AdminPortalApp(),
    ),
  );
}

/// Admin Portal App
///
/// Complete administrative portal for system configuration and management.
/// Features:
/// - User management with CRUD operations
/// - Role and permissions management
/// - System settings configuration
/// - Audit logs viewer
/// - System health dashboard
/// - Real-time monitoring
/// - Database backup and restore
class AdminPortalApp extends StatelessWidget {
  const AdminPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Admin',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
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
        return _AdminShell(child: child);
      },
      routes: [
        // Dashboard
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardPage(),
        ),

        // Users
        GoRoute(
          path: '/users',
          builder: (context, state) => const UsersPage(),
        ),

        // Roles
        GoRoute(
          path: '/roles',
          builder: (context, state) => const RolesPage(),
        ),

        // Settings
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),

        // Audit Logs
        GoRoute(
          path: '/audit-logs',
          builder: (context, state) => const AuditLogsPage(),
        ),
      ],
    ),
  ],
);

/// Admin Shell - Provides consistent navigation structure
class _AdminShell extends StatelessWidget {
  const _AdminShell({
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
                    Icons.admin_panel_settings,
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
                'Admin Portal',
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
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Users'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.shield_outlined),
          selectedIcon: Icon(Icons.shield),
          label: Text('Roles & Permissions'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('System Settings'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.article_outlined),
          selectedIcon: Icon(Icons.article),
          label: Text('Audit Logs'),
        ),

        const Spacer(),

        const Divider(),

        // User section
        Padding(
          padding: const EdgeInsets.all(16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: const Text('System Admin'),
            subtitle: const Text('admin@smartpos.com'),
            trailing: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout feature coming soon')),
                );
              },
              tooltip: 'Logout',
            ),
          ),
        ),
      ],
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/users':
        return 1;
      case '/roles':
        return 2;
      case '/settings':
        return 3;
      case '/audit-logs':
        return 4;
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
        context.go('/users');
        break;
      case 2:
        context.go('/roles');
        break;
      case 3:
        context.go('/settings');
        break;
      case 4:
        context.go('/audit-logs');
        break;
    }
  }
}
