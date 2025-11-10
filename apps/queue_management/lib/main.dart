import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'src/features/queue/presentation/pages/queue_dashboard_page.dart';
import 'src/features/tickets/presentation/pages/tickets_page.dart';
import 'src/features/counters/presentation/pages/counters_page.dart';
import 'src/features/analytics/presentation/pages/analytics_page.dart';

void main() {
  runApp(const ProviderScope(child: QueueManagementApp()));
}

class QueueManagementApp extends StatelessWidget {
  const QueueManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Queue Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const QueueDashboardPage(),
        ),
        GoRoute(
          path: '/tickets',
          builder: (context, state) => const TicketsPage(),
        ),
        GoRoute(
          path: '/counters',
          builder: (context, state) => const CountersPage(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsPage(),
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavigation extends StatelessWidget {
  const ScaffoldWithNavigation({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onDestinationSelected(index, context),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.queue, size: 32, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Queue Management',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ticketing & Service System',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 8, 28, 8),
                child: Text('OPERATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.confirmation_number_outlined),
                selectedIcon: Icon(Icons.confirmation_number),
                label: Text('Tickets'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.countertops_outlined),
                selectedIcon: Icon(Icons.countertops),
                label: Text('Service Counters'),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 8, 28, 8),
                child: Text('INSIGHTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/tickets')) return 1;
    if (location.startsWith('/counters')) return 2;
    if (location.startsWith('/analytics')) return 3;
    return 0;
  }

  void _onDestinationSelected(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/tickets');
        break;
      case 2:
        context.go('/counters');
        break;
      case 3:
        context.go('/analytics');
        break;
    }
  }
}
