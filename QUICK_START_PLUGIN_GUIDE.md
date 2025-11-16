# Quick Start: Building Your First Plugin
## Stripe Payment Integration Example

This guide walks you through building your first plugin for the Flutter-Base POS marketplace using Stripe as an example.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Step 1: Database Setup](#step-1-database-setup)
4. [Step 2: Register Plugin in Marketplace](#step-2-register-plugin-in-marketplace)
5. [Step 3: Create Plugin Backend](#step-3-create-plugin-backend)
6. [Step 4: Integrate in Flutter App](#step-4-integrate-in-flutter-app)
7. [Step 5: Testing](#step-5-testing)
8. [Next Steps](#next-steps)

---

## Overview

**Goal:** Build a Stripe payment plugin that:
- Processes credit card payments
- Creates payment intents
- Handles webhooks from Stripe
- Shows up in the POS marketplace

**Time:** 2-3 hours

**Skills needed:**
- Basic Go (for backend)
- Basic Dart/Flutter
- Stripe API knowledge

---

## Prerequisites

### 1. Stripe Account
```bash
# Sign up at https://stripe.com
# Get your API keys from Dashboard → Developers → API keys
```

### 2. Database Migrations Applied
```bash
cd Flutter-Database
# Apply the plugin marketplace migration
psql -U postgres -d pos_db -f postgres/migrations/V025_20251116_create_plugin_marketplace.sql
```

### 3. Dependencies Installed
```bash
# Go Stripe SDK
cd Flutter-Database/backend
go get github.com/stripe/stripe-go/v76

# Flutter (in your app)
cd apps/pos_register
flutter pub add flutter_stripe
```

---

## Step 1: Database Setup

### Apply Plugin Tables Migration

The migration from the implementation plan creates these key tables:
- `marketplace_plugins` - Plugin catalog
- `organization_plugins` - Installed plugins
- `plugin_events` - Execution logs
- `oauth_tokens` - Credentials storage

**Verify tables exist:**
```sql
SELECT table_name FROM information_schema.tables
WHERE table_name IN (
  'marketplace_plugins',
  'organization_plugins',
  'plugin_events'
);
```

---

## Step 2: Register Plugin in Marketplace

### Insert Stripe Plugin into Database

```sql
INSERT INTO marketplace_plugins (
    plugin_key,
    plugin_name,
    plugin_slug,
    category,
    subcategory,
    short_description,
    long_description,
    version,
    manifest_url,
    icon_url,
    required_permissions,
    webhook_url,
    webhook_events,
    config_schema,
    pricing_model,
    base_price,
    status,
    is_verified,
    is_featured
) VALUES (
    'payment_stripe',
    'Stripe Payment Gateway',
    'stripe',
    'payment',
    'payment_gateway',
    'Accept credit cards, debit cards, and digital wallets',
    'Stripe is the best software platform for running an internet business. We handle billions of dollars every year for forward-thinking businesses around the world.',
    '1.0.0',
    'https://plugins.yourpos.com/stripe/manifest.json',
    'https://plugins.yourpos.com/stripe/icon.png',
    ARRAY['payments:read', 'payments:write', 'sales:read'],
    'https://plugins.yourpos.com/stripe/webhook',
    ARRAY['sale.completed', 'payment.completed'],
    '{
        "type": "object",
        "properties": {
            "api_key": {
                "type": "string",
                "title": "Stripe Secret Key",
                "description": "Your Stripe secret key (sk_...)"
            },
            "webhook_secret": {
                "type": "string",
                "title": "Webhook Secret",
                "description": "Your Stripe webhook signing secret"
            },
            "capture_method": {
                "type": "string",
                "enum": ["automatic", "manual"],
                "default": "automatic"
            }
        },
        "required": ["api_key"]
    }',
    'per_transaction',
    2.90,  -- 2.9% + $0.30 per transaction
    'approved',
    true,
    true
) RETURNING id;
```

**Verify plugin is in marketplace:**
```sql
SELECT plugin_key, plugin_name, status
FROM marketplace_plugins
WHERE plugin_key = 'payment_stripe';
```

---

## Step 3: Create Plugin Backend

### 3.1: Create Stripe Integration Module

Create directory: `Flutter-Database/backend/internal/integrations/stripe/`

**File: `stripe_client.go`**
```go
package stripe

import (
    "github.com/stripe/stripe-go/v76"
    "github.com/stripe/stripe-go/v76/paymentintent"
)

type Client struct {
    apiKey string
}

func NewClient(apiKey string) *Client {
    stripe.Key = apiKey
    return &Client{apiKey: apiKey}
}

// CreatePaymentIntent creates a new payment intent
func (c *Client) CreatePaymentIntent(amount int64, currency string, metadata map[string]string) (*stripe.PaymentIntent, error) {
    params := &stripe.PaymentIntentParams{
        Amount:   stripe.Int64(amount),
        Currency: stripe.String(currency),
        Metadata: metadata,
    }

    pi, err := paymentintent.New(params)
    if err != nil {
        return nil, err
    }

    return pi, nil
}

// ConfirmPaymentIntent confirms a payment intent
func (c *Client) ConfirmPaymentIntent(paymentIntentID string) (*stripe.PaymentIntent, error) {
    params := &stripe.PaymentIntentConfirmParams{}

    pi, err := paymentintent.Confirm(paymentIntentID, params)
    if err != nil {
        return nil, err
    }

    return pi, nil
}

// CancelPaymentIntent cancels a payment intent
func (c *Client) CancelPaymentIntent(paymentIntentID string) (*stripe.PaymentIntent, error) {
    pi, err := paymentintent.Cancel(paymentIntentID, nil)
    if err != nil {
        return nil, err
    }

    return pi, nil
}
```

### 3.2: Create Stripe Plugin Handler

**File: `stripe_handler.go`**
```go
package stripe

import (
    "encoding/json"
    "net/http"
    "github.com/go-chi/chi/v5"
)

type Handler struct {
    pluginService *plugin.Service  // From plugin module
    logger        Logger
}

func NewHandler(pluginService *plugin.Service, logger Logger) *Handler {
    return &Handler{
        pluginService: pluginService,
        logger:        logger,
    }
}

// POST /plugins/stripe/payment-intent
func (h *Handler) CreatePaymentIntent(w http.ResponseWriter, r *http.Request) {
    var req struct {
        Amount       int64             `json:"amount"`        // in cents
        Currency     string            `json:"currency"`
        SaleID       string            `json:"sale_id"`
        CustomerID   string            `json:"customer_id"`
    }

    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    // Get organization ID from context (set by auth middleware)
    orgID := getOrgIDFromContext(r.Context())

    // Get Stripe plugin installation
    orgPlugin, err := h.pluginService.GetOrganizationPluginByKey(
        r.Context(),
        orgID,
        "payment_stripe",
    )
    if err != nil {
        http.Error(w, "Stripe plugin not installed", http.StatusNotFound)
        return
    }

    // Get API key from config
    apiKey, ok := orgPlugin.Config["api_key"].(string)
    if !ok {
        http.Error(w, "Stripe API key not configured", http.StatusBadRequest)
        return
    }

    // Create Stripe client
    stripeClient := NewClient(apiKey)

    // Create payment intent
    pi, err := stripeClient.CreatePaymentIntent(
        req.Amount,
        req.Currency,
        map[string]string{
            "sale_id":     req.SaleID,
            "customer_id": req.CustomerID,
            "org_id":      orgID.String(),
        },
    )
    if err != nil {
        h.logger.Error("Failed to create payment intent", "error", err)
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    // Log event
    h.pluginService.LogPluginEvent(r.Context(), orgPlugin.ID, "payment_intent_created", map[string]interface{}{
        "payment_intent_id": pi.ID,
        "amount":            req.Amount,
        "currency":          req.Currency,
    })

    // Return payment intent
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]interface{}{
        "success":            true,
        "payment_intent_id":  pi.ID,
        "client_secret":      pi.ClientSecret,
        "status":             pi.Status,
    })
}

// POST /plugins/stripe/webhook
func (h *Handler) HandleWebhook(w http.ResponseWriter, r *http.Request) {
    // Verify Stripe signature
    // Handle events: payment_intent.succeeded, payment_intent.payment_failed
    // Update payment status in database
    // ... implementation
}
```

### 3.3: Register Routes

**File: `cmd/api/main.go`** (add to existing routes)
```go
// Stripe plugin routes
stripeHandler := stripe.NewHandler(pluginService, logger)

r.Route("/plugins/stripe", func(r chi.Router) {
    r.Use(authMiddleware, orgContextMiddleware)
    r.Post("/payment-intent", stripeHandler.CreatePaymentIntent)
    r.Post("/webhook", stripeHandler.HandleWebhook)
})
```

---

## Step 4: Integrate in Flutter App

### 4.1: Add Stripe to Checkout Flow

**File: `apps/pos_register/lib/src/features/checkout/application/checkout_controller.dart`**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_manager/plugin_manager.dart';

class CheckoutController extends StateNotifier<CheckoutState> {
  final PluginExecutor _pluginExecutor;
  final CheckoutRepository _repository;

  CheckoutController(this._pluginExecutor, this._repository)
      : super(const CheckoutState());

  Future<void> processStripePayment(double amount) async {
    state = state.copyWith(isProcessing: true);

    try {
      // 1. Create payment intent via plugin
      final result = await _pluginExecutor.execute<StripePaymentIntent>(
        pluginKey: 'payment_stripe',
        action: 'create_payment_intent',
        data: {
          'amount': (amount * 100).round(),  // Convert to cents
          'currency': 'usd',
          'sale_id': state.saleId,
          'customer_id': state.customerId,
        },
        parser: (json) => StripePaymentIntent.fromJson(json),
      );

      if (result == null) {
        throw Exception('Failed to create payment intent');
      }

      // 2. Present payment sheet to customer
      // (using flutter_stripe package)
      final confirmed = await _presentPaymentSheet(result.clientSecret);

      if (confirmed) {
        // 3. Complete sale
        await _repository.completeSale(
          saleId: state.saleId,
          paymentMethod: 'stripe',
          paymentIntentId: result.paymentIntentId,
        );

        state = state.copyWith(
          isProcessing: false,
          paymentStatus: PaymentStatus.completed,
        );
      } else {
        state = state.copyWith(
          isProcessing: false,
          error: 'Payment canceled',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> _presentPaymentSheet(String clientSecret) async {
    // Implementation using flutter_stripe
    // ... details
    return true;
  }
}

// Models
class StripePaymentIntent {
  final String paymentIntentId;
  final String clientSecret;
  final String status;

  StripePaymentIntent({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.status,
  });

  factory StripePaymentIntent.fromJson(Map<String, dynamic> json) {
    return StripePaymentIntent(
      paymentIntentId: json['payment_intent_id'],
      clientSecret: json['client_secret'],
      status: json['status'],
    );
  }
}
```

### 4.2: Add Payment Method Selection

**File: `apps/pos_register/lib/src/features/checkout/presentation/widgets/payment_method_selector.dart`**
```dart
class PaymentMethodSelector extends ConsumerWidget {
  final void Function(String method) onMethodSelected;

  const PaymentMethodSelector({
    Key? key,
    required this.onMethodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installedPlugins = ref.watch(installedPluginsProvider);

    return installedPlugins.when(
      data: (plugins) {
        final paymentPlugins = plugins
            .where((p) => p.plugin.category == 'payment' && p.isEnabled)
            .toList();

        return Column(
          children: [
            // Cash option (always available)
            PaymentMethodTile(
              icon: Icons.money,
              title: 'Cash',
              onTap: () => onMethodSelected('cash'),
            ),

            // Installed payment plugins
            ...paymentPlugins.map((plugin) {
              if (plugin.plugin.pluginKey == 'payment_stripe') {
                return PaymentMethodTile(
                  icon: Icons.credit_card,
                  title: 'Credit Card (Stripe)',
                  onTap: () => onMethodSelected('stripe'),
                );
              } else if (plugin.plugin.pluginKey == 'payment_square') {
                return PaymentMethodTile(
                  icon: Icons.credit_card,
                  title: 'Credit Card (Square)',
                  onTap: () => onMethodSelected('square'),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading payment methods'),
    );
  }
}
```

### 4.3: Add Plugin Installation UI

**File: `apps/manager_dashboard/lib/src/features/settings/presentation/pages/plugins_settings_page.dart`**
```dart
class PluginsSettingsPage extends ConsumerWidget {
  const PluginsSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installedPlugins = ref.watch(installedPluginsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Installed Plugins'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/marketplace');
            },
          ),
        ],
      ),
      body: installedPlugins.when(
        data: (plugins) => ListView.builder(
          itemCount: plugins.length,
          itemBuilder: (context, index) {
            final plugin = plugins[index];
            return PluginTile(
              plugin: plugin,
              onConfigure: () => _showConfigDialog(context, ref, plugin),
              onToggle: (enabled) => _togglePlugin(ref, plugin, enabled),
              onUninstall: () => _uninstallPlugin(ref, plugin),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showConfigDialog(
    BuildContext context,
    WidgetRef ref,
    OrganizationPlugin plugin,
  ) {
    showDialog(
      context: context,
      builder: (context) => PluginConfigDialog(plugin: plugin),
    );
  }

  Future<void> _togglePlugin(
    WidgetRef ref,
    OrganizationPlugin plugin,
    bool enabled,
  ) async {
    final service = ref.read(pluginServiceProvider);
    final orgId = ref.read(currentOrganizationIdProvider);

    await service.updatePluginConfig(
      orgId,
      plugin.id,
      {...plugin.config, 'is_enabled': enabled},
    );

    // Refresh plugins list
    ref.invalidate(installedPluginsProvider);
  }

  Future<void> _uninstallPlugin(
    WidgetRef ref,
    OrganizationPlugin plugin,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Uninstall ${plugin.plugin.pluginName}?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Uninstall'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = ref.read(pluginServiceProvider);
      final orgId = ref.read(currentOrganizationIdProvider);

      await service.uninstallPlugin(orgId, plugin.id);
      ref.invalidate(installedPluginsProvider);
    }
  }
}
```

---

## Step 5: Testing

### 5.1: Manual Testing

**Test Plugin Installation:**
```dart
void main() async {
  final pluginService = PluginService(
    dio: Dio(),
    logger: Logger(),
    baseUrl: 'http://localhost:8080/api/v1',
  );

  // Install Stripe
  final installed = await pluginService.installPlugin(
    'org-id-here',
    'payment_stripe',
    config: {
      'api_key': 'sk_test_your_key_here',
    },
  );

  print('Installed: ${installed.id}');
}
```

**Test Payment:**
```bash
# Using curl
curl -X POST http://localhost:8080/plugins/stripe/payment-intent \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 1000,
    "currency": "usd",
    "sale_id": "sale-123",
    "customer_id": "customer-456"
  }'
```

### 5.2: Unit Tests

**File: `test/plugin_service_test.dart`**
```dart
void main() {
  group('Stripe Plugin', () {
    late PluginService service;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      service = PluginService(
        dio: mockDio,
        logger: Logger(),
        baseUrl: 'https://api.test.com',
      );
    });

    test('creates payment intent successfully', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'payment_intent_id': 'pi_123',
                  'client_secret': 'pi_123_secret',
                  'status': 'requires_payment_method',
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await service.executePlugin(
        'org-id',
        'payment_stripe',
        'create_payment_intent',
        {'amount': 1000, 'currency': 'usd'},
      );

      expect(result['success'], true);
      expect(result['payment_intent_id'], 'pi_123');
    });
  });
}
```

### 5.3: Integration Test

**File: `integration_test/stripe_plugin_test.dart`**
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete payment flow with Stripe', (tester) async {
    // 1. Launch app
    await tester.pumpWidget(MyApp());

    // 2. Add item to cart
    await tester.tap(find.text('Coffee'));
    await tester.pumpAndSettle();

    // 3. Go to checkout
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    // 4. Select Stripe payment
    await tester.tap(find.text('Credit Card (Stripe)'));
    await tester.pumpAndSettle();

    // 5. Enter test card details
    await tester.enterText(
      find.byKey(Key('card_number')),
      '4242424242424242',
    );

    // 6. Complete payment
    await tester.tap(find.text('Pay'));
    await tester.pumpAndSettle();

    // 7. Verify success
    expect(find.text('Payment Successful'), findsOneWidget);
  });
}
```

---

## Next Steps

### 1. Add More Payment Plugins
- Square
- PayPal
- Authorize.net

### 2. Add Webhook Handling
```go
func (h *Handler) HandleStripeWebhook(w http.ResponseWriter, r *http.Request) {
    // Verify signature
    // Handle events:
    // - payment_intent.succeeded
    // - payment_intent.payment_failed
    // - charge.refunded
}
```

### 3. Add Error Handling
```dart
try {
  await processStripePayment(amount);
} on StripeException catch (e) {
  if (e.error.code == 'card_declined') {
    showError('Card declined');
  } else if (e.error.code == 'insufficient_funds') {
    showError('Insufficient funds');
  }
}
```

### 4. Add Analytics
```dart
// Track plugin usage
await analytics.logEvent(
  name: 'plugin_executed',
  parameters: {
    'plugin_key': 'payment_stripe',
    'action': 'create_payment_intent',
    'success': true,
  },
);
```

### 5. Create More Plugins

Use this same pattern for:
- **QuickBooks** (accounting)
- **Shopify** (e-commerce)
- **Mailchimp** (marketing)
- **FedEx** (shipping)

---

## Summary

You now have:
✅ Stripe plugin registered in marketplace
✅ Backend API for creating payment intents
✅ Flutter integration in checkout flow
✅ Installation and configuration UI
✅ Testing framework

**Time to build your next plugin!**

For more examples, see:
- `/docs/plugin-examples/quickbooks.md`
- `/docs/plugin-examples/shopify.md`
- `/docs/plugin-examples/mailchimp.md`
