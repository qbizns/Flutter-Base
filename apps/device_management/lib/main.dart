import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'src/features/devices/presentation/pages/devices_dashboard_page.dart';
import 'src/features/provisioning/presentation/pages/device_provisioning_page.dart';
import 'src/features/firmware/presentation/pages/firmware_updates_page.dart';
import 'src/features/diagnostics/presentation/pages/device_diagnostics_page.dart';

void main() {
  runApp(const ProviderScope(child: DeviceManagementApp()));
}

class DeviceManagementApp extends StatelessWidget {
  const DeviceManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Device Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/devices',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return _MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/devices',
          builder: (context, state) => const DevicesDashboardPage(),
        ),
        GoRoute(
          path: '/provisioning',
          builder: (context, state) => const DeviceProvisioningPage(),
        ),
        GoRoute(
          path: '/firmware',
          builder: (context, state) => const FirmwareUpdatesPage(),
        ),
        GoRoute(
          path: '/diagnostics',
          builder: (context, state) => const DeviceDiagnosticsPage(),
        ),
      ],
    ),
  ],
);

class _MainScaffold extends StatelessWidget {
  final Widget child;

  const _MainScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: _getSelectedIndex(location),
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/devices');
                  break;
                case 1:
                  context.go('/provisioning');
                  break;
                case 2:
                  context.go('/firmware');
                  break;
                case 3:
                  context.go('/diagnostics');
                  break;
              }
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.devices,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Device Mgmt',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'SmartPOS',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'OPERATIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.devices_outlined),
                selectedIcon: Icon(Icons.devices),
                label: Text('Devices'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.add_box_outlined),
                selectedIcon: Icon(Icons.add_box),
                label: Text('Provisioning'),
              ),
              const Divider(indent: 20, endIndent: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'MAINTENANCE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.system_update_outlined),
                selectedIcon: Icon(Icons.system_update),
                label: Text('Firmware Updates'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.monitor_heart_outlined),
                selectedIcon: Icon(Icons.monitor_heart),
                label: Text('Diagnostics'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/devices':
        return 0;
      case '/provisioning':
        return 1;
      case '/firmware':
        return 2;
      case '/diagnostics':
        return 3;
      default:
        return 0;
    }
  }
}
