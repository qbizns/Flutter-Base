# Plugin Module

This module implements the marketplace/plugin system for the POS platform, enabling third-party integrations like payment gateways, accounting software, e-commerce platforms, etc.

## Architecture

### Components

1. **dto.go** - Data Transfer Objects for API requests/responses
2. **service.go** - Business logic for plugin operations
3. **repository.go** - Database interface (implementation in repository_impl.go)
4. **handler.go** - HTTP handlers for REST API endpoints

### Key Features

- Browse marketplace plugins
- Install/uninstall plugins per organization
- Configure plugin settings
- Execute plugin actions (API calls to third-party services)
- Track plugin events and health status
- Support for OAuth2 authentication
- Multi-tenant isolation via RLS

## API Endpoints

### Marketplace Endpoints (Public)

```
GET /api/v1/marketplace/plugins
GET /api/v1/marketplace/plugins/{plugin_id}
```

### Organization Plugin Endpoints (Authenticated)

```
GET    /api/v1/organizations/{org_id}/plugins
GET    /api/v1/organizations/{org_id}/plugins/{plugin_id}
POST   /api/v1/organizations/{org_id}/plugins
PATCH  /api/v1/organizations/{org_id}/plugins/{plugin_id}
DELETE /api/v1/organizations/{org_id}/plugins/{plugin_id}
POST   /api/v1/organizations/{org_id}/plugins/{plugin_key}/execute
```

## Usage Example

### Install a Plugin

```bash
curl -X POST \
  http://localhost:8080/api/v1/organizations/{org_id}/plugins \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "plugin_key": "payment_stripe",
    "config": {
      "api_key": "sk_test_...",
      "webhook_secret": "whsec_..."
    }
  }'
```

### Execute Plugin Action

```bash
curl -X POST \
  http://localhost:8080/api/v1/organizations/{org_id}/plugins/payment_stripe/execute \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "create_payment_intent",
    "data": {
      "amount": 1000,
      "currency": "usd"
    }
  }'
```

## Plugin Manifest Format

Each plugin must provide a manifest JSON file:

```json
{
  "plugin_key": "payment_stripe",
  "version": "1.0.0",
  "api_version": "v1",
  "actions": {
    "create_payment_intent": "https://your-plugin.com/stripe/payment-intent",
    "refund_payment": "https://your-plugin.com/stripe/refund"
  },
  "webhooks": {
    "payment_succeeded": "https://your-plugin.com/stripe/webhook"
  },
  "permissions": ["payments:read", "payments:write"],
  "config_schema": {
    "type": "object",
    "properties": {
      "api_key": {"type": "string"},
      "webhook_secret": {"type": "string"}
    },
    "required": ["api_key"]
  }
}
```

## Security

- Multi-tenant isolation enforced via PostgreSQL RLS
- Plugin permissions validated before execution
- OAuth2 support for secure third-party authentication
- API keys encrypted at rest
- Plugin health monitoring and automatic disablement on errors

## Database Tables

- `marketplace_plugins` - Available plugins catalog
- `organization_plugins` - Installed plugins per org
- `plugin_events` - Execution logs and audit trail
- `plugin_reviews` - User ratings and reviews
- `oauth_providers` - OAuth2 provider configurations
- `oauth_tokens` - Encrypted OAuth tokens

## TODO

- [ ] Implement repository_impl.go with PostgreSQL queries
- [ ] Add JSON schema validation for plugin configs
- [ ] Implement OAuth2 flow handlers
- [ ] Add rate limiting per plugin
- [ ] Add plugin webhook receivers
- [ ] Add unit tests
- [ ] Add integration tests
- [ ] Add Swagger/OpenAPI documentation

## Integration Guide

See `/docs/QUICK_START_PLUGIN_GUIDE.md` for step-by-step guide on building your first plugin.
