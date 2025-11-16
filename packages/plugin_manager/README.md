# Plugin Manager

A comprehensive plugin marketplace and management system for Flutter-Base POS applications.

## Features

- **Marketplace Integration**: Browse and discover plugins
- **Plugin Installation**: Install plugins with configuration
- **Plugin Management**: Enable/disable, configure, and uninstall plugins
- **Plugin Execution**: Execute plugin actions from your app
- **State Management**: Built-in Riverpod providers for seamless state management
- **UI Components**: Ready-to-use widgets for marketplace and plugin management

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  plugin_manager:
    path: ../../packages/plugin_manager
```

## Quick Start

### 1. Setup Providers

Wrap your app with `ProviderScope` and override required providers:

```dart
import 'package:plugin_manager/plugin_manager.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        // API base URL
        apiBaseUrlProvider.overrideWith(
          (ref) => 'https://api.yourpos.com/api/v1',
        ),

        // Current organization ID (from auth)
        currentOrganizationIdProvider.overrideWith(
          (ref) => ref.watch(authProvider).organizationId,
        ),

        // Optional: Override Dio for auth interceptors
        dioProvider.overrideWith((ref) {
          final dio = Dio();
          dio.interceptors.add(YourAuthInterceptor());
          return dio;
        }),
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. Display Marketplace

```dart
import 'package:plugin_manager/plugin_manager.dart';

class MarketplacePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Plugin Marketplace')),
      body: PluginMarketplaceGrid(
        onPluginTap: (plugin) {
          // Navigate to plugin details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PluginDetailsPage(plugin: plugin),
            ),
          );
        },
        onPluginInstall: (plugin) async {
          // Install plugin
          final service = ref.read(pluginServiceProvider);
          final orgId = ref.read(currentOrganizationIdProvider);

          await service.installPlugin(orgId, plugin.pluginKey);

          // Refresh installed plugins
          ref.invalidate(installedPluginsProvider);
        },
      ),
    );
  }
}
```

### 3. Show Installed Plugins

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

          return PluginListTile(
            plugin: plugin,
            onToggle: (enabled) async {
              final service = ref.read(pluginServiceProvider);
              final orgId = ref.read(currentOrganizationIdProvider);

              await service.updatePluginConfig(
                orgId,
                plugin.id,
                plugin.config,
                isEnabled: enabled,
              );

              ref.invalidate(installedPluginsProvider);
            },
            onUninstall: () async {
              final service = ref.read(pluginServiceProvider);
              final orgId = ref.read(currentOrganizationIdProvider);

              await service.uninstallPlugin(orgId, plugin.id);
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

### 4. Execute Plugin Actions

```dart
class CheckoutPage extends ConsumerWidget {
  Future<void> processStripePayment(WidgetRef ref, double amount) async {
    final executor = ref.read(pluginExecutorProvider.notifier);

    final result = await executor.execute(
      pluginKey: 'payment_stripe',
      action: 'create_payment_intent',
      data: {
        'amount': (amount * 100).round(), // Convert to cents
        'currency': 'usd',
      },
    );

    if (result != null && result.success) {
      // Payment intent created
      final paymentIntentId = result.data?['payment_intent_id'];
      final clientSecret = result.data?['client_secret'];

      // Present payment sheet...
    } else {
      // Handle error
      print('Error: ${result?.error}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => processStripePayment(ref, 100.00),
          child: Text('Pay \$100.00'),
        ),
      ),
    );
  }
}
```

### 5. Check if Plugin is Active

```dart
class PaymentMethodSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStripeActive = ref.watch(
      isPluginActiveProvider('payment_stripe'),
    );

    return isStripeActive.when(
      data: (active) => active
          ? PaymentButton(
              icon: Icons.credit_card,
              label: 'Credit Card (Stripe)',
              onTap: () => processStripePayment(ref),
            )
          : UpgradePrompt(
              message: 'Install Stripe to accept credit cards',
              onInstall: () => navigateToMarketplace(context),
            ),
      loading: () => CircularProgressIndicator(),
      error: (_, __) => SizedBox.shrink(),
    );
  }
}
```

## Advanced Usage

### Filtering Marketplace Plugins

```dart
final filters = MarketplaceFilters(
  category: 'payment',
  search: 'stripe',
  minRating: 4.0,
  isFeatured: true,
  limit: 20,
);

final plugins = ref.watch(marketplacePluginsProvider(filters));
```

### Typed Plugin Execution

```dart
class PaymentResult {
  final String paymentIntentId;
  final String clientSecret;

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      paymentIntentId: json['payment_intent_id'],
      clientSecret: json['client_secret'],
    );
  }
}

// Execute with type parsing
final result = await executor.executeTyped<PaymentResult>(
  pluginKey: 'payment_stripe',
  action: 'create_payment_intent',
  data: {'amount': 1000},
  parser: PaymentResult.fromJson,
);

if (result != null) {
  print('Payment Intent: ${result.paymentIntentId}');
}
```

## API Reference

### Models

- `MarketplacePlugin`: Represents a plugin in the marketplace
- `OrganizationPlugin`: Represents an installed plugin
- `ExecutePluginResponse`: Response from plugin execution

### Services

- `PluginService`: Main service for plugin operations
  - `getMarketplacePlugins()`: Fetch marketplace plugins
  - `getInstalledPlugins()`: Get installed plugins
  - `installPlugin()`: Install a plugin
  - `uninstallPlugin()`: Uninstall a plugin
  - `executePlugin()`: Execute plugin action
  - `isPluginActive()`: Check if plugin is active

### Providers

- `marketplacePluginsProvider`: Fetches marketplace plugins
- `installedPluginsProvider`: Fetches installed plugins
- `isPluginActiveProvider`: Checks if plugin is active
- `pluginExecutorProvider`: Plugin execution state

### Widgets

- `PluginMarketplaceGrid`: Grid view of marketplace plugins
- `PluginCard`: Card displaying plugin information
- `PluginListTile`: List tile for installed plugins

## License

Proprietary - Flutter-Base POS
