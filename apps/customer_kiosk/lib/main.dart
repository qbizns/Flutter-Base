import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/cart/presentation/pages/cart_page.dart';
import 'src/features/checkout/presentation/pages/checkout_page.dart';
import 'src/features/menu/presentation/pages/menu_page.dart';
import 'src/features/order/presentation/pages/order_tracking_page.dart';
import 'src/features/welcome/presentation/pages/welcome_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.dev,
    appBuilder: (config) => const ProviderScope(
      child: CustomerKioskApp(),
    ),
  );
}

/// Customer Kiosk App
///
/// Self-service ordering system optimized for large touchscreens.
/// Features:
/// - Welcome screen with language selection
/// - Product browsing with large images
/// - Cart review and editing
/// - Self-checkout with payment terminal
/// - Order tracking and confirmation
/// - Auto-reset after timeout
class CustomerKioskApp extends StatelessWidget {
  const CustomerKioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartPOS Kiosk',
      theme: _buildKioskTheme(Brightness.light),
      darkTheme: _buildKioskTheme(Brightness.dark),
      themeMode: ThemeMode.light, // Kiosks typically use light mode
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  /// Kiosk-optimized theme with large text and touch targets
  ThemeData _buildKioskTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,

      // Extra large text for kiosk displays (10-15 inch screens)
      textTheme: TextTheme(
        // Display styles (used for hero text)
        displayLarge: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displayMedium: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displaySmall: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),

        // Headline styles (used for section headers)
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        headlineSmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),

        // Title styles (used for cards and list items)
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        titleSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),

        // Body styles (used for content)
        bodyLarge: TextStyle(
          fontSize: 18,
          color: colorScheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface,
        ),

        // Label styles (used for buttons)
        labelLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        labelSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),

      // Large cards for better touch
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Large app bar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 2,
        titleTextStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      ),

      // Large buttons for easy touching
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(120, 60),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(120, 60),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Large icon buttons
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(60, 60),
          padding: const EdgeInsets.all(16),
        ),
      ),

      // Comfortable spacing for kiosk
      visualDensity: VisualDensity.comfortable,
    );
  }
}

// Router configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Welcome screen (idle state)
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomePage(),
    ),

    // Menu browsing
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MenuPage(),
    ),

    // Cart review
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),

    // Checkout/Payment
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutPage(),
    ),

    // Order tracking
    GoRoute(
      path: '/order-tracking/:orderNumber',
      builder: (context, state) {
        final orderNumber = state.pathParameters['orderNumber']!;
        return OrderTrackingPage(orderNumber: orderNumber);
      },
    ),
  ],
);
