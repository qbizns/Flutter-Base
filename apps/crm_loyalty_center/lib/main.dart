import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/campaigns/presentation/pages/campaigns_page.dart';
import 'src/features/customers/presentation/pages/customers_page.dart';
import 'src/features/feedback/presentation/pages/feedback_page.dart';
import 'src/features/loyalty/presentation/pages/loyalty_rules_page.dart';
import 'src/features/vouchers/presentation/pages/vouchers_page.dart';

void main() {
  AppBootstrap.run(
    environment: Environment.dev,
    appBuilder: (config) => const ProviderScope(
      child: CRMLoyaltyCenterApp(),
    ),
  );
}

/// CRM & Loyalty Center App
///
/// Customer relationship management and loyalty program backoffice.
/// Features:
/// - Customer profiles and segmentation
/// - Loyalty program rules and tiers
/// - Marketing campaigns (push, email, SMS)
/// - Vouchers and coupons
/// - Customer feedback and NPS tracking
class CRMLoyaltyCenterApp extends StatelessWidget {
  const CRMLoyaltyCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS CRM & Loyalty',
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

// Router configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return _CRMShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const CustomersPage(),
        ),
        GoRoute(
          path: '/loyalty',
          builder: (context, state) => const LoyaltyRulesPage(),
        ),
        GoRoute(
          path: '/campaigns',
          builder: (context, state) => const CampaignsPage(),
        ),
        GoRoute(
          path: '/vouchers',
          builder: (context, state) => const VouchersPage(),
        ),
        GoRoute(
          path: '/feedback',
          builder: (context, state) => const FeedbackPage(),
        ),
      ],
    ),
  ],
);

/// CRM Shell - Navigation drawer
class _CRMShell extends StatelessWidget {
  const _CRMShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: _getSelectedIndex(GoRouterState.of(context).uri.path),
            onDestinationSelected: (index) => _navigateToIndex(context, index),
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, size: 32, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'SmartPOS',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CRM & Loyalty',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const NavigationDrawerDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Customers'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.stars_outlined),
                selectedIcon: Icon(Icons.stars),
                label: Text('Loyalty Program'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.campaign_outlined),
                selectedIcon: Icon(Icons.campaign),
                label: Text('Campaigns'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.card_giftcard_outlined),
                selectedIcon: Icon(Icons.card_giftcard),
                label: Text('Vouchers'),
              ),
              const NavigationDrawerDestination(
                icon: Icon(Icons.feedback_outlined),
                selectedIcon: Icon(Icons.feedback),
                label: Text('Feedback'),
              ),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/': return 0;
      case '/loyalty': return 1;
      case '/campaigns': return 2;
      case '/vouchers': return 3;
      case '/feedback': return 4;
      default: return 0;
    }
  }

  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/loyalty'); break;
      case 2: context.go('/campaigns'); break;
      case 3: context.go('/vouchers'); break;
      case 4: context.go('/feedback'); break;
    }
  }
}
