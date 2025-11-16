# Plugin Manager

A comprehensive plugin marketplace and management system for Flutter-Base POS, enabling seamless integration with third-party services like payment gateways, accounting software, e-commerce platforms, and more.

## Features

- 🏪 **Marketplace Browser** - Discover and browse available plugins
- 📦 **Plugin Management** - Install, configure, and uninstall plugins
- ⚡ **Plugin Execution** - Execute plugin actions with type-safe APIs
- 🔒 **Multi-tenant Isolation** - Organization-scoped plugin installations
- 📊 **Health Monitoring** - Track plugin status and health
- 🔐 **OAuth2 Support** - Secure third-party authentication
- 📝 **Event Logging** - Comprehensive audit trail for all plugin operations

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  plugin_manager:
    path: ../packages/plugin_manager
```

## Usage

### 1. Setup Providers

Wire up the plugin system with your app's providers:

```dart
import 'package:plugin_manager/plugin_manager.dart';

// In your provider setup
final pluginServiceProvider = Provider<PluginService>((ref) {
  final dio = ref.watch(dioProvider);
  final logger = Logger();
  final baseUrl = ref.watch(apiBaseUrlProvider);

  return PluginService(
    dio: dio,
    logger: logger,
    baseUrl: baseUrl,
  );
});
```

### 2. Browse Marketplace Plugins

```dart
class MarketplacePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pluginsAsync = ref.watch(marketplacePluginsProvider(null));

    return pluginsAsync.when(
      data: (plugins) => ListView.builder(
        itemCount: plugins.length,
        itemBuilder: (context, index) {
          final plugin = plugins[index];
          return ListTile(
            title: Text(plugin.pluginName),
            subtitle: Text(plugin.shortDescription),
            trailing: Text('\$${plugin.basePrice}'),
          );
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }
}
```

### 3. Install a Plugin

```dart
class PluginInstallButton extends ConsumerWidget {
  final String pluginKey;

  const PluginInstallButton({required this.pluginKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installController = ref.watch(installPluginProvider.notifier);

    return ElevatedButton(
      onPressed: () async {
        await installController.install(
          pluginKey,
          config: {
            'api_key': 'your_api_key_here',
          },
        );

        // Refresh installed plugins list
        ref.invalidate(installedPluginsProvider);
      },
      child: Text('Install'),
    );
  }
}
```

### 4. Execute Plugin Actions

```dart
class CheckoutController extends StateNotifier<CheckoutState> {
  final PluginExecutor _pluginExecutor;

  Future<void> processStripePayment(double amount) async {
    // Check if Stripe is active
    final isActive = await ref.read(
      isPluginActiveProvider('payment_stripe').future,
    );

    if (!isActive) {
      throw Exception('Stripe plugin not installed');
    }

    // Execute payment
    final result = await _pluginExecutor.execute<PaymentResult>(
      pluginKey: 'payment_stripe',
      action: 'create_payment_intent',
      data: {
        'amount': (amount * 100).round(), // Convert to cents
        'currency': 'usd',
      },
      parser: (json) => PaymentResult.fromJson(json),
    );

    if (result != null && result.success) {
      // Payment succeeded
      print('Payment ID: ${result.paymentId}');
    }
  }
}
```

### 5. Manage Installed Plugins

```dart
class InstalledPluginsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pluginsAsync = ref.watch(installedPluginsProvider);

    return pluginsAsync.when(
      data: (plugins) => ListView.builder(
        itemCount: plugins.length,
        itemBuilder: (context, index) {
          final plugin = plugins[index];
          return SwitchListTile(
            title: Text(plugin.plugin.pluginName),
            subtitle: Text('Status: ${plugin.status}'),
            value: plugin.isEnabled,
            onChanged: (enabled) async {
              final service = ref.read(pluginServiceProvider);
              final orgId = ref.read(currentOrganizationIdProvider);

              await service.updatePluginConfig(
                orgId,
                plugin.id,
                isEnabled: enabled,
              );

              ref.invalidate(installedPluginsProvider);
            },
          );
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }
}
```

## Available Plugins

The system comes pre-seeded with example plugins:

### Payment Gateways
- **Stripe** - Accept credit cards and digital wallets
- **Square** - Process payments with Square

### Accounting
- **QuickBooks Online** - Sync sales and expenses
- **Xero** - Connect to Xero accounting

### E-commerce
- **Shopify** - Sync products and orders

### Marketing
- **Mailchimp** - Email marketing and customer receipts

## Plugin Development

To create your own plugin, you need:

1. **Plugin Manifest** - JSON file describing your plugin
2. **API Endpoints** - HTTP endpoints for plugin actions
3. **Webhook Handler** - Receive events from the POS system

See `/docs/QUICK_START_PLUGIN_GUIDE.md` for a complete tutorial.

## Architecture

```
plugin_manager/
├── lib/
│   ├── src/
│   │   ├── models/              # Data models
│   │   │   └── marketplace_plugin.dart
│   │   ├── services/            # Business logic
│   │   │   └── plugin_service.dart
│   │   └── providers/           # Riverpod providers
│   │       └── plugin_providers.dart
│   └── plugin_manager.dart      # Public exports
├── pubspec.yaml
└── README.md
```

## API Reference

### Models

- **MarketplacePlugin** - Represents a plugin in the marketplace
- **OrganizationPlugin** - Represents an installed plugin
- **PluginEvent** - Represents a plugin execution event

### Services

- **PluginService** - Core service for all plugin operations

### Providers

- **marketplacePluginsProvider** - Browse marketplace plugins
- **installedPluginsProvider** - Get installed plugins
- **isPluginActiveProvider** - Check if plugin is active
- **installPluginProvider** - Install plugin controller
- **uninstallPluginProvider** - Uninstall plugin controller
- **pluginExecutorProvider** - Execute plugin actions

## Testing

```dart
void main() {
  test('Install plugin successfully', () async {
    final service = PluginService(
      dio: MockDio(),
      logger: Logger(),
      baseUrl: 'https://api.test.com',
    );

    final result = await service.installPlugin(
      'org-id',
      'payment_stripe',
      config: {'api_key': 'sk_test_123'},
    );

    expect(result.plugin.pluginKey, 'payment_stripe');
    expect(result.status, 'active');
  });
}
```

## License

This package is part of the Flutter-Base POS system.
