import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/display/presentation/pages/customer_display_page.dart';
import 'src/features/display/presentation/pages/order_status_display_page.dart';
import 'src/features/settings/presentation/pages/display_settings_page.dart';

void main() {
  // Set preferred orientations for display
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide system UI for kiosk mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.dev,
    appBuilder: (config) => const ProviderScope(
      child: OrderDisplayApp(),
    ),
  );
}

/// Customer Display App
///
/// Odoo-style POS customer-facing display that shows the current cart
/// as items are scanned at the register in real-time.
///
/// Features:
/// - Real-time cart display with item details
/// - Last scanned item highlighting
/// - Running total prominently displayed
/// - Payment status display
/// - Thank you screen after completion
/// - Idle screen with marketing content
/// - Smooth animations and transitions
/// - Following Odoo POS customer display patterns 100%
/// - Full-screen landscape display
class OrderDisplayApp extends StatelessWidget {
  const OrderDisplayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Order Display',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      visualDensity: VisualDensity.standard,

      // Large text for display
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}

// Router configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Main display - Odoo-style Customer Display
    GoRoute(
      path: '/',
      builder: (context, state) => const CustomerDisplayPage(),
    ),

    // Alternate display - Order Status Queue
    GoRoute(
      path: '/queue',
      builder: (context, state) => const OrderStatusDisplayPage(),
    ),

    // Settings (accessed via gesture or admin button)
    GoRoute(
      path: '/settings',
      builder: (context, state) => const DisplaySettingsPage(),
    ),
  ],
);

/// Wrapper to add settings access via gesture
class _DisplayWithSettings extends StatefulWidget {
  const _DisplayWithSettings({required this.child});

  final Widget child;

  @override
  State<_DisplayWithSettings> createState() => _DisplayWithSettingsState();
}

class _DisplayWithSettingsState extends State<_DisplayWithSettings> {
  int _tapCount = 0;
  DateTime? _lastTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Triple tap on top-right corner to access settings
      onTapUp: (details) {
        final size = MediaQuery.of(context).size;
        final tapPosition = details.globalPosition;

        // Check if tap is in top-right corner (100x100 area)
        if (tapPosition.dx > size.width - 100 && tapPosition.dy < 100) {
          final now = DateTime.now();

          if (_lastTap != null && now.difference(_lastTap!).inSeconds < 2) {
            _tapCount++;
            if (_tapCount >= 3) {
              _tapCount = 0;
              _lastTap = null;
              context.push('/settings');
              return;
            }
          } else {
            _tapCount = 1;
          }

          _lastTap = now;
        }
      },
      child: widget.child,
    );
  }
}
