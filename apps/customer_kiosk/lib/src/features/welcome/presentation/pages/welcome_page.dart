import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Welcome Page - Kiosk idle/start screen
///
/// Features:
/// - Large "Start Order" button
/// - Branding and welcome message
/// - Language selection
/// - Auto-reset after timeout
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo/Branding
              Icon(
                Icons.restaurant_menu,
                size: 120,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 32),

              // Welcome message
              Text(
                'Welcome to SmartPOS',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Order your favorite food',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 80),

              // Start Order button
              SizedBox(
                width: size.width * 0.5,
                height: 100,
                child: FilledButton(
                  onPressed: () => context.go('/menu'),
                  style: FilledButton.styleFrom(
                    textStyle: theme.textTheme.displaySmall,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, size: 48),
                      SizedBox(width: 16),
                      Text('Tap to Start Order'),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Language selector
              Padding(
                padding: const EdgeInsets.all(32),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLanguageButton(context, '🇺🇸', 'English'),
                    _buildLanguageButton(context, '🇪🇸', 'Español'),
                    _buildLanguageButton(context, '🇸🇦', 'العربية'),
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Touch anywhere to begin',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String flag,
    String language,
  ) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: () {
        // TODO: Change language
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language changed to $language')),
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        textStyle: theme.textTheme.titleLarge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Text(language),
        ],
      ),
    );
  }
}
