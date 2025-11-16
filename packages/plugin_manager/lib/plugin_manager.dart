/// Plugin Manager for Flutter-Base POS
///
/// This library provides a complete plugin marketplace and management system
/// for integrating third-party services into your POS application.
///
/// Features:
/// - Browse marketplace plugins
/// - Install/uninstall plugins
/// - Configure plugin settings
/// - Execute plugin actions
/// - Track plugin events and health
///
/// Example usage:
/// ```dart
/// // Install a plugin
/// final installController = ref.read(installPluginProvider.notifier);
/// await installController.install('payment_stripe', config: {
///   'api_key': 'sk_test_...',
/// });
///
/// // Execute a plugin action
/// final executor = ref.watch(pluginExecutorProvider);
/// final result = await executor.execute<PaymentResult>(
///   pluginKey: 'payment_stripe',
///   action: 'create_payment_intent',
///   data: {'amount': 1000, 'currency': 'usd'},
///   parser: (json) => PaymentResult.fromJson(json),
/// );
/// ```
library plugin_manager;

// Models
export 'src/models/marketplace_plugin.dart';

// Services
export 'src/services/plugin_service.dart';

// Providers
export 'src/providers/plugin_providers.dart';
