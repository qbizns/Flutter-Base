import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import 'src/features/kds/presentation/pages/kds_main_page.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const ProviderScope(
      child: KitchenDisplayApp(),
    ),
  );
}

/// Kitchen Display System App
///
/// Real-time kitchen order display for restaurant kitchens.
/// Features:
/// - Real-time order queue display
/// - Station-based filtering
/// - Order preparation tracking
/// - Bump orders to completion
/// - Timer tracking with visual alerts
/// - Priority ordering
class KitchenDisplayApp extends StatelessWidget {
  const KitchenDisplayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPOS Kitchen Display',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const KdsMainPage(),
      debugShowCheckedModeBanner: false,
    );
  }

  /// Custom light theme optimized for kitchen displays
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.light,
      ),
      // Large text for kitchen visibility
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 18),
        bodyMedium: TextStyle(fontSize: 16),
        bodySmall: TextStyle(fontSize: 14),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
      ),
    );
  }

  /// Custom dark theme optimized for low-light kitchen environments
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.dark,
      ),
      // Large text for kitchen visibility
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 18),
        bodyMedium: TextStyle(fontSize: 16),
        bodySmall: TextStyle(fontSize: 14),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
      ),
    );
  }
}
