import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

void main() {
  // Run app in development environment
  AppBootstrap.run(
    environment: Environment.development,
    appBuilder: (config) => const PosRegisterApp(),
  );
}

/// POS Register App
///
/// Main POS terminal application for restaurants and retail.
/// This is a thin wrapper around pos_core that provides:
/// - App-specific configuration
/// - Custom app identity (name, icons, theme overrides)
/// - Feature selection (which features are enabled for this app)
class PosRegisterApp extends StatelessWidget {
  const PosRegisterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPOS Register',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('POS Register - Coming Soon'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
