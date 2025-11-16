# Marketplace & Plugin System - Production Implementation Guide

## Overview

This guide documents the complete implementation of the Odoo-style marketplace and plugin system for Flutter-Base POS. The implementation is **production-ready** and includes:

✅ Database schema with multi-tenant security (RLS)
✅ Complete Go backend API module
✅ Flutter plugin_manager package
✅ Marketplace UI in manager_dashboard
✅ Example plugin integrations
✅ Developer documentation

---

## Architecture Summary

```
┌─────────────────────────────────────────────┐
│         Flutter Apps (26 apps)              │
│  ┌──────────────────────────────────────┐  │
│  │    plugin_manager package            │  │
│  │  - Models (Freezed)                   │  │
│  │  - Services (Dio HTTP)                │  │
│  │  - Providers (Riverpod)               │  │
│  │  - Widgets (Reusable UI)              │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
                    ↕ REST API
┌─────────────────────────────────────────────┐
│          Backend API (Go)                   │
│  ┌──────────────────────────────────────┐  │
│  │    backend_modules/plugin/           │  │
│  │  - dto.go (Data Transfer Objects)    │  │
│  │  - service.go (Business Logic)       │  │
│  │  - repository.go (Database Layer)    │  │
│  │  - handler.go (HTTP Handlers)        │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
                    ↕ SQL
┌─────────────────────────────────────────────┐
│         PostgreSQL Database                 │
│  - marketplace_plugins                      │
│  - organization_plugins                     │
│  - plugin_events                            │
│  - oauth_providers & oauth_tokens           │
│  - plugin_reviews                           │
└─────────────────────────────────────────────┘
```

---

## Phase 1: Database Deployment

### 1.1 Apply Migrations

**Location:** `database_migrations/`

Files to deploy to Flutter-Database repository:
- `V025_20251116_create_plugin_marketplace.sql`
- `V026_20251116_add_plugin_support_to_existing_tables.sql`

**Deployment Steps:**

```bash
# 1. Copy migrations to Flutter-Database
cp database_migrations/*.sql ../Flutter-Database/postgres/migrations/

# 2. Apply migrations
cd ../Flutter-Database
psql -U postgres -d pos_db -f postgres/migrations/V025_20251116_create_plugin_marketplace.sql
psql -U postgres -d pos_db -f postgres/migrations/V026_20251116_add_plugin_support_to_existing_tables.sql

# 3. Verify tables created
psql -U postgres -d pos_db -c "\dt marketplace_plugins"
psql -U postgres -d pos_db -c "\dt organization_plugins"
```

### 1.2 Verify Database Structure

```sql
-- Check marketplace plugins
SELECT COUNT(*) FROM marketplace_plugins;
-- Should show 6 seed plugins (Stripe, Square, QuickBooks, Xero, Shopify, Mailchimp)

-- Test helper functions
SELECT is_plugin_active(
  'your-org-id'::UUID,
  'payment_stripe'
);
```

---

## Phase 2: Backend Deployment

### 2.1 Copy Backend Module

**Location:** `backend_modules/plugin/`

Files to deploy to Flutter-Database:
- `dto.go`
- `service.go`
- `repository.go`
- `handler.go`
- `routes_example.go`

**Deployment Steps:**

```bash
# 1. Copy plugin module
cp -r backend_modules/plugin ../Flutter-Database/backend/internal/

# 2. Add dependencies
cd ../Flutter-Database/backend
go get github.com/google/uuid
go get github.com/lib/pq
go get github.com/go-chi/chi/v5

# 3. Update main.go (see routes_example.go for reference)
```

### 2.2 Update main.go

Add to `Flutter-Database/backend/cmd/api/main.go`:

```go
import (
    "your-project/internal/plugin"
)

func main() {
    // ... existing setup ...

    // Initialize plugin system
    pluginRepo := plugin.NewRepository(db)
    pluginService := plugin.NewService(pluginRepo, logger)
    pluginHandler := plugin.NewHandler(pluginService, logger)

    // Register routes
    r.Route("/api/v1/marketplace", func(r chi.Router) {
        r.Get("/plugins", pluginHandler.ListMarketplacePlugins)
    })

    r.Route("/api/v1/organizations/{org_id}/plugins", func(r chi.Router) {
        r.Use(authMiddleware, orgContextMiddleware)
        r.Get("/", pluginHandler.GetInstalledPlugins)
        r.Post("/", pluginHandler.InstallPlugin)
        r.Patch("/{plugin_id}", pluginHandler.UpdatePluginConfig)
        r.Delete("/{plugin_id}", pluginHandler.UninstallPlugin)
        r.Post("/{plugin_key}/execute", pluginHandler.ExecutePlugin)
    })

    // ... rest of main ...
}
```

### 2.3 Test Backend API

```bash
# Start backend
cd ../Flutter-Database/backend
go run cmd/api/main.go

# Test marketplace endpoint
curl http://localhost:8080/api/v1/marketplace/plugins

# Expected: List of 6 plugins
```

---

## Phase 3: Flutter Package Deployment

### 3.1 Plugin Manager Package

**Location:** `packages/plugin_manager/`

The package is already created in the Flutter-Base repository at the correct location.

### 3.2 Add to Apps

Update `pubspec.yaml` in each app that needs plugin support:

```yaml
dependencies:
  plugin_manager:
    path: ../../packages/plugin_manager
```

### 3.3 Generate Freezed Models

```bash
cd packages/plugin_manager
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Phase 4: Marketplace UI Deployment

### 4.1 Files Created

**Location:** `apps/manager_dashboard/lib/src/features/marketplace/`

Structure:
```
marketplace/
├── presentation/
│   ├── pages/
│   │   ├── marketplace_page.dart
│   │   ├── plugin_details_page.dart
│   │   └── installed_plugins_page.dart
│   └── widgets/
│       ├── category_sidebar.dart
│       └── marketplace_search_bar.dart
```

### 4.2 Add Routes

Update `apps/manager_dashboard/lib/main.dart`:

```dart
import 'src/features/marketplace/presentation/pages/marketplace_page.dart';
import 'src/features/marketplace/presentation/pages/installed_plugins_page.dart';

// In routes
routes: {
  '/marketplace': (context) => const MarketplacePage(),
  '/marketplace/installed': (context) => const InstalledPluginsPage(),
}
```

### 4.3 Setup Providers

Wrap app with ProviderScope:

```dart
void main() {
  runApp(
    ProviderScope(
      overrides: [
        apiBaseUrlProvider.overrideWith(
          (ref) => 'https://api.yourpos.com/api/v1',
        ),
        currentOrganizationIdProvider.overrideWith(
          (ref) => ref.watch(authProvider).organizationId,
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## Phase 5: Example Plugin Integration

### 5.1 Stripe Payment Plugin

**Usage in Checkout Flow:**

```dart
import 'package:plugin_manager/plugin_manager.dart';

class CheckoutController extends StateNotifier<CheckoutState> {
  Future<void> processStripePayment(double amount) async {
    // 1. Check if Stripe is active
    final isActive = await ref.read(
      isPluginActiveProvider('payment_stripe').future,
    );

    if (!isActive) {
      throw Exception('Stripe plugin not installed');
    }

    // 2. Execute payment
    final executor = ref.read(pluginExecutorProvider.notifier);

    final result = await executor.execute(
      pluginKey: 'payment_stripe',
      action: 'create_payment_intent',
      data: {
        'amount': (amount * 100).round(),
        'currency': 'usd',
        'sale_id': state.saleId,
      },
    );

    if (result != null && result.success) {
      // 3. Process payment intent
      final paymentIntentId = result.data?['payment_intent_id'];
      // ... present payment sheet
    }
  }
}
```

---

## Testing

### Unit Tests

```bash
# Test plugin_manager package
cd packages/plugin_manager
flutter test
```

### Integration Tests

```bash
# Test backend API
cd ../Flutter-Database/backend
go test ./internal/plugin/...

# Test Flutter integration
cd ../../Flutter-Base/apps/manager_dashboard
flutter test integration_test/marketplace_test.dart
```

### Manual Testing Checklist

- [ ] Browse marketplace plugins
- [ ] Filter by category
- [ ] Search for plugins
- [ ] View plugin details
- [ ] Install a plugin
- [ ] Configure plugin settings
- [ ] Enable/disable plugin
- [ ] Uninstall plugin
- [ ] Execute plugin action (e.g., Stripe payment)

---

## Production Deployment Checklist

### Database

- [ ] Migrations applied to production database
- [ ] RLS policies active and tested
- [ ] Seed plugins inserted
- [ ] Helper functions created
- [ ] Indexes created for performance

### Backend

- [ ] Plugin module compiled and deployed
- [ ] API routes registered
- [ ] Authentication middleware configured
- [ ] Organization context middleware configured
- [ ] Logging enabled
- [ ] Error handling tested

### Frontend

- [ ] plugin_manager package published or linked
- [ ] All apps updated with package dependency
- [ ] Freezed models generated
- [ ] Provider overrides configured with production API URL
- [ ] Marketplace UI routes added
- [ ] Build successful for all platforms

### Security

- [ ] API endpoints protected with auth
- [ ] RLS policies enforced
- [ ] Plugin permissions validated
- [ ] OAuth tokens encrypted
- [ ] Rate limiting configured
- [ ] Input validation in place

### Performance

- [ ] Database indexes optimized
- [ ] API response caching enabled
- [ ] Plugin manifest caching implemented
- [ ] Lazy loading for plugin grid
- [ ] Image loading optimized

---

## Monitoring & Maintenance

### Metrics to Track

1. **Plugin Usage**
   - Most installed plugins
   - Most active plugins
   - Plugin execution success/failure rates

2. **Performance**
   - API response times
   - Plugin execution duration
   - Database query performance

3. **Health**
   - Plugin health status
   - Failed plugin executions
   - OAuth token expiration

### Logs to Monitor

```sql
-- Plugin execution failures
SELECT * FROM plugin_events
WHERE status = 'error'
ORDER BY created_at DESC
LIMIT 100;

-- Plugin health issues
SELECT * FROM organization_plugins
WHERE health_status != 'healthy';

-- Most used plugins
SELECT mp.plugin_name, COUNT(*) as execution_count
FROM plugin_events pe
JOIN organization_plugins op ON pe.organization_plugin_id = op.id
JOIN marketplace_plugins mp ON op.plugin_id = mp.id
WHERE pe.created_at > NOW() - INTERVAL '30 days'
GROUP BY mp.plugin_name
ORDER BY execution_count DESC;
```

---

## Next Steps

### Additional Plugins to Implement

1. **QuickBooks Integration** - Accounting sync
2. **Shopify Integration** - E-commerce product sync
3. **Square Payments** - Alternative payment gateway
4. **Mailchimp** - Email marketing
5. **FedEx/UPS** - Shipping label generation

### Feature Enhancements

1. **Plugin Reviews** - Allow users to rate and review plugins
2. **Plugin Analytics** - Dashboard showing plugin usage stats
3. **Auto-Updates** - Automatic plugin updates
4. **Webhooks** - Two-way sync with external services
5. **Sandbox Mode** - Test plugins before production use

---

## Support & Documentation

### Developer Resources

- `/docs/PLUGIN_DEVELOPMENT_GUIDE.md` - How to build plugins
- `/docs/API_REFERENCE.md` - API endpoints documentation
- `QUICK_START_PLUGIN_GUIDE.md` - Stripe tutorial
- `PLUGIN_VS_FEATURE_FLAGS_GUIDE.md` - Decision framework

### Getting Help

- GitHub Issues: Report bugs and request features
- Internal Wiki: Plugin system documentation
- Developer Slack: #plugin-marketplace channel

---

## Summary

You now have a **complete, production-ready** plugin marketplace system:

✅ **Database**: Multi-tenant with RLS, 6 seed plugins, helper functions
✅ **Backend**: RESTful API with CRUD operations, plugin execution
✅ **Frontend**: Reusable package, marketplace UI, plugin management
✅ **Security**: Permission system, OAuth support, data isolation
✅ **Documentation**: Comprehensive guides and examples

The system is designed to:
- Scale to thousands of plugins
- Support third-party developers
- Integrate seamlessly with existing POS features
- Provide excellent user experience

**Ready to deploy!** 🚀
