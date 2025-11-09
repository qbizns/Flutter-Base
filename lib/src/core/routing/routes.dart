/// Route path constants for the application.
/// Centralized location for all route paths.
class Routes {
  const Routes._();

  // Auth routes
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String verification = '/verification';

  // Main app routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';

  // Legacy (to be removed after migration)
  static const String welcome = '/welcome';
}

/// Route names for navigation.
class RouteNames {
  const RouteNames._();

  // Auth routes
  static const String splash = 'splash';
  static const String signIn = 'signIn';
  static const String signUp = 'signUp';
  static const String forgotPassword = 'forgotPassword';
  static const String verification = 'verification';

  // Main app routes
  static const String home = 'home';
  static const String profile = 'profile';
  static const String onboarding = 'onboarding';

  // Legacy
  static const String welcome = 'welcome';
}
