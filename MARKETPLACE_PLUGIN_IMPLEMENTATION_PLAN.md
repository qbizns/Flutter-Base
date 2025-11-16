# Marketplace & Plugin System Implementation Plan
## For Flutter-Base POS Ecosystem

**Version:** 1.0
**Date:** 2025-11-16
**Author:** Claude Code Analysis

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [System Architecture Overview](#system-architecture-overview)
3. [Plugin System vs Feature Flags](#plugin-system-vs-feature-flags)
4. [Implementation Approach](#implementation-approach)
5. [Phase 1: Database Infrastructure](#phase-1-database-infrastructure)
6. [Phase 2: Backend API Development](#phase-2-backend-api-development)
7. [Phase 3: Flutter Plugin SDK](#phase-3-flutter-plugin-sdk)
8. [Phase 4: Marketplace UI](#phase-4-marketplace-ui)
9. [Phase 5: Plugin Examples](#phase-5-plugin-examples)
10. [Security & Isolation](#security--isolation)
11. [Testing Strategy](#testing-strategy)
12. [Deployment & DevOps](#deployment--devops)
13. [Timeline & Resources](#timeline--resources)

---

## Executive Summary

### Current State Analysis

**Your POS ecosystem consists of:**
- ✅ **Flutter-Base**: 26 Flutter apps with shared packages (pos_core, pos_ui)
- ✅ **Flutter-Database**: Go backend with PostgreSQL (50+ tables, multi-tenant)
- ✅ **Flutter-Device**: Hardware abstraction layer (11+ device types)

**Strengths:**
- Clean Architecture with feature-first organization
- Multi-tenant with Row-Level Security (RLS)
- JSONB extensibility in all tables
- Webhook infrastructure ready
- API-first design with organization scoping

**Gaps:**
- No dynamic plugin loading/unloading
- No third-party developer SDK
- No marketplace UI
- No plugin versioning system

### Proposed Solution

Build an **Odoo-style marketplace** with two complementary approaches:

1. **Plugin System**: For third-party integrations (Stripe, QuickBooks, etc.)
2. **Feature Flags**: For first-party features (inventory, loyalty, delivery)

**Target Architecture:**
```
┌─────────────────────────────────────────────────────────┐
│                  Flutter POS Apps                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Register │  │ Manager  │  │   KDS    │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
                        ↕
┌─────────────────────────────────────────────────────────┐
│              Plugin Marketplace Layer                    │
│  ┌────────────────┐  ┌────────────────┐                │
│  │ Plugin Manager │  │ Feature Flags  │                │
│  └────────────────┘  └────────────────┘                │
└─────────────────────────────────────────────────────────┘
                        ↕
┌─────────────────────────────────────────────────────────┐
│                Core POS Backend API                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Products │  │  Sales   │  │ Payments │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
                        ↕
┌─────────────────────────────────────────────────────────┐
│              Third-Party Plugins                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │  Stripe  │  │QuickBooks│  │ Shopify  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
```

---

## System Architecture Overview

### Three-Layer Architecture

#### Layer 1: Core POS (Always Available)
```dart
Core Features (Free):
- User Authentication
- Basic Product Management
- Simple Sales Recording
- Cash Payments
- Basic Reporting
```

#### Layer 2: First-Party Features (Feature Flags)
```dart
Optional Features (Paid Tiers):
- Advanced Inventory Management
- Multi-location Support
- Loyalty Programs
- Delivery Management
- E-invoicing
- Kitchen Display System
```

#### Layer 3: Third-Party Plugins (Marketplace)
```dart
External Integrations:
- Payment Gateways (Stripe, PayPal, Square)
- Accounting (QuickBooks, Xero, Wave)
- E-commerce (Shopify, WooCommerce)
- Delivery (UberEats, DoorDash)
- Marketing (Mailchimp, SendGrid)
- Analytics (Google Analytics, Mixpanel)
```

### Data Flow Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Flutter App (pos_register)                              │
│                                                          │
│  1. User initiates action (e.g., complete sale)        │
│  2. Check feature flag: is_feature_enabled('loyalty')   │
│  3. Check installed plugins: get_active_plugins()       │
│  4. Execute core logic + plugin hooks                   │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │ Plugin Hook Points:                             │    │
│  │  - beforeSaleComplete()                         │    │
│  │  - afterSaleComplete()                          │    │
│  │  - onPaymentProcess()                           │    │
│  │  - onInventoryUpdate()                          │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ Backend API (Go)                                         │
│                                                          │
│  1. Receive sale completion request                     │
│  2. Load organization plugins from DB                   │
│  3. Execute plugin webhooks in sequence:                │
│                                                          │
│     Plugin 1 (Stripe): Process payment                  │
│     Plugin 2 (QuickBooks): Create invoice               │
│     Plugin 3 (Mailchimp): Send receipt email            │
│                                                          │
│  4. Update database with results                        │
│  5. Emit event to event bus                            │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ Plugin Endpoints (External)                             │
│                                                          │
│  Stripe:      POST /webhook → payment_intent.succeeded  │
│  QuickBooks:  POST /webhook → invoice.created           │
│  Mailchimp:   POST /webhook → email.sent                │
└─────────────────────────────────────────────────────────┘
```

---

## Plugin System vs Feature Flags

### When to Use Feature Flags

**Use Case:** First-party features you control

**Examples:**
- Advanced inventory management
- Multi-location support
- Kitchen display system
- Delivery management
- Loyalty programs

**Implementation:**
```dart
// In Flutter app
final featureService = ref.watch(featureServiceProvider);

if (await featureService.isEnabled('advanced_inventory')) {
  // Show advanced inventory UI
  Navigator.push(context, AdvancedInventoryPage());
} else {
  // Show upgrade prompt
  showUpgradeDialog(context, feature: 'advanced_inventory');
}
```

**Backend (Go):**
```go
// Check feature flag
isEnabled, err := featureService.IsEnabled(orgID, "advanced_inventory")
if !isEnabled {
    return errors.New("feature not available in your plan")
}
```

**Database:**
```sql
-- Already implemented in your system
SELECT is_feature_enabled(org_id, 'advanced_inventory');
```

### When to Use Plugin System

**Use Case:** Third-party integrations with external APIs

**Examples:**
- Payment gateways (Stripe, Square)
- Accounting software (QuickBooks, Xero)
- E-commerce platforms (Shopify, WooCommerce)
- Marketing tools (Mailchimp, SendGrid)
- Analytics platforms (Google Analytics)

**Implementation:**
```dart
// In Flutter app
final pluginService = ref.watch(pluginServiceProvider);

// Get installed plugins
final plugins = await pluginService.getInstalledPlugins(
  category: 'payment_gateway',
  status: 'active',
);

// Execute plugin
for (final plugin in plugins) {
  if (plugin.key == 'stripe') {
    final result = await plugin.execute(
      action: 'process_payment',
      data: {'amount': 100.00, 'currency': 'USD'},
    );
  }
}
```

### Hybrid Approach: Best of Both Worlds

**Recommendation:** Use BOTH systems together

```dart
// Example: E-commerce integration

// 1. Feature flag controls if e-commerce sync is available
if (featureService.isEnabled('ecommerce_sync')) {

  // 2. Plugin determines WHICH platform to sync with
  final ecommercePlugins = pluginService.getPlugins(
    category: 'ecommerce',
  );

  for (final plugin in ecommercePlugins) {
    if (plugin.isInstalled && plugin.isActive) {
      // Sync products to Shopify, WooCommerce, etc.
      await plugin.syncProducts(products);
    }
  }
}
```

**Benefits:**
- Feature flags = Fast enablement/disablement (no external API calls)
- Plugins = Flexibility to choose providers (Stripe vs PayPal)
- Combined = Maximum control and extensibility

---

## Implementation Approach

### Architecture Decision: Dual System

```
┌─────────────────────────────────────────────────────────┐
│                  Flutter App Layer                       │
│                                                          │
│  ┌─────────────────────┐  ┌────────────────────────┐   │
│  │  FeatureService     │  │  PluginService         │   │
│  │                     │  │                        │   │
│  │  - isEnabled()      │  │  - getInstalled()      │   │
│  │  - getConfig()      │  │  - execute()           │   │
│  │  - checkLimit()     │  │  - install()           │   │
│  └─────────────────────┘  └────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│                  Backend API Layer                       │
│                                                          │
│  ┌─────────────────────┐  ┌────────────────────────┐   │
│  │  Feature Module     │  │  Plugin Module         │   │
│  │                     │  │                        │   │
│  │  /features/check    │  │  /plugins/list         │   │
│  │  /features/enable   │  │  /plugins/install      │   │
│  └─────────────────────┘  └────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│                  Database Layer                          │
│                                                          │
│  ┌─────────────────────┐  ┌────────────────────────┐   │
│  │ organization_       │  │ marketplace_plugins    │   │
│  │   features          │  │ organization_plugins   │   │
│  └─────────────────────┘  └────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## Phase 1: Database Infrastructure

**Timeline:** 1-2 weeks
**Location:** `Flutter-Database/postgres/migrations/`

### Step 1.1: Create Plugin Registry Tables

Create new migration: `V025_20251116_create_plugin_marketplace.sql`

```sql
-- ============================================================================
-- MARKETPLACE PLUGIN REGISTRY
-- ============================================================================

-- Plugin catalog (available in marketplace)
CREATE TABLE marketplace_plugins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Identity
    plugin_key VARCHAR(100) UNIQUE NOT NULL,  -- 'payment_stripe', 'accounting_quickbooks'
    plugin_name VARCHAR(255) NOT NULL,
    plugin_slug VARCHAR(100) UNIQUE NOT NULL,

    -- Developer
    developer_organization_id UUID REFERENCES organizations(id),
    developer_name VARCHAR(255),
    developer_email VARCHAR(255),
    developer_website TEXT,

    -- Categorization
    category VARCHAR(50) NOT NULL,  -- 'payment', 'accounting', 'ecommerce', 'marketing'
    subcategory VARCHAR(50),
    tags TEXT[],

    -- Description
    short_description TEXT,
    long_description TEXT,
    features JSONB,  -- ['feature1', 'feature2']

    -- Media
    icon_url TEXT,
    banner_url TEXT,
    screenshots TEXT[],
    video_url TEXT,

    -- Documentation
    documentation_url TEXT,
    changelog_url TEXT,
    support_url TEXT,
    support_email VARCHAR(255),

    -- Technical
    version VARCHAR(20) NOT NULL,
    min_api_version VARCHAR(20),
    max_api_version VARCHAR(20),
    manifest_url TEXT NOT NULL,

    -- Permissions
    required_permissions TEXT[],  -- ['products:read', 'sales:write']
    optional_permissions TEXT[],
    oauth_scopes TEXT[],

    -- Webhooks
    webhook_url TEXT,
    webhook_events TEXT[],  -- ['sale.created', 'payment.completed']

    -- Configuration
    config_schema JSONB,  -- JSON Schema for plugin settings
    default_config JSONB,

    -- Pricing
    pricing_model VARCHAR(50),  -- 'free', 'monthly', 'yearly', 'per_transaction', 'tier_based'
    base_price NUMERIC(10, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    pricing_tiers JSONB,
    trial_days INTEGER DEFAULT 0,

    -- Status
    status VARCHAR(30) DEFAULT 'draft',  -- 'draft', 'pending_review', 'approved', 'rejected', 'suspended'
    is_verified BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,

    -- Stats
    install_count INTEGER DEFAULT 0,
    active_install_count INTEGER DEFAULT 0,
    rating_average NUMERIC(3, 2),
    rating_count INTEGER DEFAULT 0,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_marketplace_plugins_category ON marketplace_plugins(category);
CREATE INDEX idx_marketplace_plugins_status ON marketplace_plugins(status);
CREATE INDEX idx_marketplace_plugins_developer ON marketplace_plugins(developer_organization_id);

-- ============================================================================
-- ORGANIZATION PLUGIN INSTALLATIONS
-- ============================================================================

CREATE TABLE organization_plugins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- References
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    plugin_id UUID NOT NULL REFERENCES marketplace_plugins(id) ON DELETE CASCADE,

    -- Status
    status VARCHAR(30) DEFAULT 'active',  -- 'active', 'paused', 'uninstalled', 'error'
    is_enabled BOOLEAN DEFAULT TRUE,

    -- Configuration
    config JSONB DEFAULT '{}',  -- Plugin-specific settings

    -- Credentials & Access
    api_key_id UUID REFERENCES api_keys(id),
    oauth_token_id UUID,  -- Reference to oauth_tokens (to be created)
    granted_permissions TEXT[],

    -- Subscription
    subscription_status VARCHAR(30),  -- 'trial', 'active', 'past_due', 'canceled'
    subscription_plan VARCHAR(50),
    trial_started_at TIMESTAMP WITH TIME ZONE,
    trial_ends_at TIMESTAMP WITH TIME ZONE,
    subscription_started_at TIMESTAMP WITH TIME ZONE,
    subscription_ends_at TIMESTAMP WITH TIME ZONE,
    next_billing_date TIMESTAMP WITH TIME ZONE,

    -- Sync Status
    last_sync_at TIMESTAMP WITH TIME ZONE,
    sync_frequency VARCHAR(20),  -- 'manual', 'realtime', 'hourly', 'daily'
    sync_status VARCHAR(30),  -- 'idle', 'syncing', 'success', 'error'
    sync_error TEXT,

    -- Usage Tracking
    usage_stats JSONB DEFAULT '{}',
    last_used_at TIMESTAMP WITH TIME ZONE,

    -- Health
    health_status VARCHAR(30) DEFAULT 'healthy',  -- 'healthy', 'degraded', 'error'
    health_message TEXT,
    last_health_check_at TIMESTAMP WITH TIME ZONE,

    -- Audit
    installed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    installed_by UUID REFERENCES users(id),
    uninstalled_at TIMESTAMP WITH TIME ZONE,
    uninstalled_by UUID REFERENCES users(id),

    -- Metadata
    metadata JSONB DEFAULT '{}',

    UNIQUE(organization_id, plugin_id)
);

CREATE INDEX idx_org_plugins_org ON organization_plugins(organization_id);
CREATE INDEX idx_org_plugins_plugin ON organization_plugins(plugin_id);
CREATE INDEX idx_org_plugins_status ON organization_plugins(status, is_enabled);

-- ============================================================================
-- PLUGIN EVENTS & LOGS
-- ============================================================================

CREATE TABLE plugin_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_plugin_id UUID NOT NULL REFERENCES organization_plugins(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id),

    event_type VARCHAR(100) NOT NULL,  -- 'webhook_received', 'api_called', 'sync_completed'
    event_name VARCHAR(255),

    event_data JSONB,

    status VARCHAR(30),  -- 'success', 'error', 'pending'
    error_message TEXT,
    error_code VARCHAR(50),

    duration_ms INTEGER,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_plugin_events_org_plugin ON plugin_events(organization_plugin_id, created_at DESC);
CREATE INDEX idx_plugin_events_type ON plugin_events(event_type, created_at DESC);

-- ============================================================================
-- PLUGIN REVIEWS & RATINGS
-- ============================================================================

CREATE TABLE plugin_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    plugin_id UUID NOT NULL REFERENCES marketplace_plugins(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_title VARCHAR(255),
    review_text TEXT,

    is_verified_purchase BOOLEAN DEFAULT FALSE,

    -- Helpfulness
    helpful_count INTEGER DEFAULT 0,
    not_helpful_count INTEGER DEFAULT 0,

    -- Developer Response
    developer_response TEXT,
    developer_responded_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    UNIQUE(plugin_id, organization_id)
);

CREATE INDEX idx_plugin_reviews_plugin ON plugin_reviews(plugin_id, created_at DESC);
CREATE INDEX idx_plugin_reviews_rating ON plugin_reviews(plugin_id, rating);

-- ============================================================================
-- OAUTH2 SUPPORT (for third-party auth)
-- ============================================================================

CREATE TABLE oauth_providers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    provider_key VARCHAR(50) UNIQUE NOT NULL,  -- 'quickbooks', 'shopify', 'stripe'
    provider_name VARCHAR(255) NOT NULL,

    -- OAuth Configuration
    client_id VARCHAR(255),  -- Encrypted
    client_secret VARCHAR(255),  -- Encrypted
    authorization_url TEXT,
    token_url TEXT,
    revoke_url TEXT,
    scopes TEXT[],

    -- Plugin Association
    plugin_id UUID REFERENCES marketplace_plugins(id),

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE oauth_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    organization_plugin_id UUID REFERENCES organization_plugins(id) ON DELETE CASCADE,
    oauth_provider_id UUID NOT NULL REFERENCES oauth_providers(id),

    -- Tokens (encrypted)
    access_token TEXT NOT NULL,
    refresh_token TEXT,
    token_type VARCHAR(50) DEFAULT 'Bearer',

    -- Expiration
    expires_at TIMESTAMP WITH TIME ZONE,

    -- Scope
    scope TEXT[],

    -- OAuth State
    state VARCHAR(255),

    -- Metadata
    user_id UUID REFERENCES users(id),
    metadata JSONB DEFAULT '{}',

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_oauth_tokens_org ON oauth_tokens(organization_id);
CREATE INDEX idx_oauth_tokens_plugin ON oauth_tokens(organization_plugin_id);

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Check if plugin is installed and active
CREATE OR REPLACE FUNCTION is_plugin_active(
    p_organization_id UUID,
    p_plugin_key VARCHAR
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM organization_plugins op
        JOIN marketplace_plugins mp ON op.plugin_id = mp.id
        WHERE op.organization_id = p_organization_id
          AND mp.plugin_key = p_plugin_key
          AND op.status = 'active'
          AND op.is_enabled = TRUE
          AND op.deleted_at IS NULL
    );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get plugin configuration
CREATE OR REPLACE FUNCTION get_plugin_config(
    p_organization_id UUID,
    p_plugin_key VARCHAR
) RETURNS JSONB AS $$
DECLARE
    v_config JSONB;
BEGIN
    SELECT op.config INTO v_config
    FROM organization_plugins op
    JOIN marketplace_plugins mp ON op.plugin_id = mp.id
    WHERE op.organization_id = p_organization_id
      AND mp.plugin_key = p_plugin_key
      AND op.status = 'active'
      AND op.is_enabled = TRUE;

    RETURN COALESCE(v_config, '{}'::JSONB);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Update plugin rating average (trigger)
CREATE OR REPLACE FUNCTION update_plugin_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE marketplace_plugins
    SET rating_average = (
            SELECT ROUND(AVG(rating)::NUMERIC, 2)
            FROM plugin_reviews
            WHERE plugin_id = NEW.plugin_id AND deleted_at IS NULL
        ),
        rating_count = (
            SELECT COUNT(*)
            FROM plugin_reviews
            WHERE plugin_id = NEW.plugin_id AND deleted_at IS NULL
        )
    WHERE id = NEW.plugin_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_plugin_rating
    AFTER INSERT OR UPDATE OR DELETE ON plugin_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_plugin_rating();

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE organization_plugins ENABLE ROW LEVEL SECURITY;

CREATE POLICY organization_plugins_tenant_isolation ON organization_plugins
    USING (organization_id = current_user_organization_id());

CREATE POLICY organization_plugins_super_admin_all ON organization_plugins
    FOR ALL TO PUBLIC
    USING (is_super_admin());

ALTER TABLE plugin_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY plugin_events_tenant_isolation ON plugin_events
    USING (organization_id = current_user_organization_id());

ALTER TABLE plugin_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY plugin_reviews_tenant_isolation ON plugin_reviews
    USING (organization_id = current_user_organization_id());

ALTER TABLE oauth_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY oauth_tokens_tenant_isolation ON oauth_tokens
    USING (organization_id = current_user_organization_id());

-- ============================================================================
-- SEED DATA: Example Plugins
-- ============================================================================

INSERT INTO marketplace_plugins (
    plugin_key, plugin_name, plugin_slug, category,
    short_description, version, manifest_url,
    required_permissions, pricing_model, status, is_verified
) VALUES
-- Payment Gateways
('payment_stripe', 'Stripe Payment Gateway', 'stripe', 'payment',
 'Accept credit cards and digital wallets with Stripe', '1.0.0',
 'https://plugins.example.com/stripe/manifest.json',
 ARRAY['payments:read', 'payments:write'],
 'per_transaction', 'approved', TRUE),

('payment_square', 'Square Payment Gateway', 'square', 'payment',
 'Process payments with Square', '1.0.0',
 'https://plugins.example.com/square/manifest.json',
 ARRAY['payments:read', 'payments:write'],
 'monthly', 'approved', TRUE),

-- Accounting
('accounting_quickbooks', 'QuickBooks Online', 'quickbooks', 'accounting',
 'Sync sales and expenses to QuickBooks', '1.0.0',
 'https://plugins.example.com/quickbooks/manifest.json',
 ARRAY['sales:read', 'customers:read', 'invoices:write'],
 'monthly', 'approved', TRUE),

('accounting_xero', 'Xero Accounting', 'xero', 'accounting',
 'Connect your POS to Xero', '1.0.0',
 'https://plugins.example.com/xero/manifest.json',
 ARRAY['sales:read', 'customers:read', 'invoices:write'],
 'monthly', 'approved', TRUE),

-- E-commerce
('ecommerce_shopify', 'Shopify Integration', 'shopify', 'ecommerce',
 'Sync products and orders with Shopify', '1.0.0',
 'https://plugins.example.com/shopify/manifest.json',
 ARRAY['products:read', 'products:write', 'inventory:read', 'inventory:write'],
 'monthly', 'approved', TRUE),

-- Marketing
('marketing_mailchimp', 'Mailchimp Email Marketing', 'mailchimp', 'marketing',
 'Send customer receipts and marketing emails', '1.0.0',
 'https://plugins.example.com/mailchimp/manifest.json',
 ARRAY['customers:read', 'sales:read'],
 'free', 'approved', TRUE);
```

### Step 1.2: Enhance Existing Tables

Add plugin support to existing tables:

```sql
-- Add plugin reference to payments table
ALTER TABLE payments
ADD COLUMN plugin_payment_id VARCHAR(255),  -- External payment ID (e.g., Stripe charge ID)
ADD COLUMN plugin_metadata JSONB DEFAULT '{}';

-- Add plugin reference to customers table
ALTER TABLE customers
ADD COLUMN plugin_customer_ids JSONB DEFAULT '{}';  -- {'shopify': '123', 'mailchimp': '456'}

-- Add plugin reference to products table
ALTER TABLE products
ADD COLUMN plugin_product_ids JSONB DEFAULT '{}';  -- {'shopify': '789', 'woocommerce': '101'}
```

---

## Phase 2: Backend API Development

**Timeline:** 2-3 weeks
**Location:** `Flutter-Database/backend/internal/`

### Step 2.1: Create Plugin Module

Create directory structure:
```
backend/internal/plugin/
├── dto.go              # Data Transfer Objects
├── handler.go          # HTTP handlers
├── repository.go       # Database layer
├── service.go          # Business logic
├── validator.go        # Input validation
├── executor.go         # Plugin execution engine
└── webhook_handler.go  # Webhook receiver
```

**File: `dto.go`**
```go
package plugin

import (
    "time"
    "github.com/google/uuid"
)

type MarketplacePluginDTO struct {
    ID                 uuid.UUID              `json:"id"`
    PluginKey          string                 `json:"plugin_key"`
    PluginName         string                 `json:"plugin_name"`
    Category           string                 `json:"category"`
    ShortDescription   string                 `json:"short_description"`
    IconURL            string                 `json:"icon_url"`
    Version            string                 `json:"version"`
    PricingModel       string                 `json:"pricing_model"`
    BasePrice          float64                `json:"base_price"`
    RatingAverage      float64                `json:"rating_average"`
    RatingCount        int                    `json:"rating_count"`
    InstallCount       int                    `json:"install_count"`
    IsVerified         bool                   `json:"is_verified"`
    IsFeatured         bool                   `json:"is_featured"`
    RequiredPermissions []string              `json:"required_permissions"`
}

type OrganizationPluginDTO struct {
    ID                  uuid.UUID              `json:"id"`
    OrganizationID      uuid.UUID              `json:"organization_id"`
    Plugin              *MarketplacePluginDTO  `json:"plugin"`
    Status              string                 `json:"status"`
    IsEnabled           bool                   `json:"is_enabled"`
    Config              map[string]interface{} `json:"config"`
    SubscriptionStatus  string                 `json:"subscription_status"`
    TrialEndsAt         *time.Time             `json:"trial_ends_at,omitempty"`
    InstalledAt         time.Time              `json:"installed_at"`
}

type InstallPluginRequest struct {
    PluginKey string                 `json:"plugin_key" validate:"required"`
    Config    map[string]interface{} `json:"config"`
}

type UpdatePluginConfigRequest struct {
    Config    map[string]interface{} `json:"config" validate:"required"`
    IsEnabled *bool                  `json:"is_enabled,omitempty"`
}

type ExecutePluginRequest struct {
    Action string                 `json:"action" validate:"required"`
    Data   map[string]interface{} `json:"data"`
}

type ExecutePluginResponse struct {
    Success bool                   `json:"success"`
    Data    map[string]interface{} `json:"data,omitempty"`
    Error   string                 `json:"error,omitempty"`
}
```

**File: `service.go`**
```go
package plugin

import (
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    "time"

    "github.com/google/uuid"
)

type Service struct {
    repo   *Repository
    logger Logger
    http   *http.Client
}

func NewService(repo *Repository, logger Logger) *Service {
    return &Service{
        repo:   repo,
        logger: logger,
        http:   &http.Client{Timeout: 30 * time.Second},
    }
}

// ListMarketplacePlugins returns all available plugins
func (s *Service) ListMarketplacePlugins(ctx context.Context, category string) ([]*MarketplacePluginDTO, error) {
    return s.repo.ListMarketplacePlugins(ctx, category)
}

// GetInstalledPlugins returns plugins installed for an organization
func (s *Service) GetInstalledPlugins(ctx context.Context, orgID uuid.UUID) ([]*OrganizationPluginDTO, error) {
    return s.repo.GetInstalledPlugins(ctx, orgID)
}

// InstallPlugin installs a plugin for an organization
func (s *Service) InstallPlugin(ctx context.Context, orgID uuid.UUID, req *InstallPluginRequest, userID uuid.UUID) (*OrganizationPluginDTO, error) {
    // 1. Get plugin from marketplace
    plugin, err := s.repo.GetMarketplacePluginByKey(ctx, req.PluginKey)
    if err != nil {
        return nil, fmt.Errorf("plugin not found: %w", err)
    }

    // 2. Check if already installed
    existing, err := s.repo.GetOrganizationPlugin(ctx, orgID, plugin.ID)
    if err == nil && existing != nil {
        return nil, fmt.Errorf("plugin already installed")
    }

    // 3. Validate config against schema
    if err := s.validateConfig(plugin.ConfigSchema, req.Config); err != nil {
        return nil, fmt.Errorf("invalid config: %w", err)
    }

    // 4. Install plugin
    orgPlugin := &OrganizationPlugin{
        OrganizationID: orgID,
        PluginID:       plugin.ID,
        Status:         "active",
        IsEnabled:      true,
        Config:         req.Config,
        InstalledBy:    userID,
    }

    if err := s.repo.CreateOrganizationPlugin(ctx, orgPlugin); err != nil {
        return nil, err
    }

    // 5. Log event
    s.logPluginEvent(ctx, orgPlugin.ID, "plugin_installed", nil)

    return s.repo.GetOrganizationPluginDTO(ctx, orgPlugin.ID)
}

// ExecutePlugin executes a plugin action
func (s *Service) ExecutePlugin(ctx context.Context, orgID uuid.UUID, pluginKey string, req *ExecutePluginRequest) (*ExecutePluginResponse, error) {
    // 1. Get plugin installation
    orgPlugin, err := s.repo.GetOrganizationPluginByKey(ctx, orgID, pluginKey)
    if err != nil {
        return nil, fmt.Errorf("plugin not installed: %w", err)
    }

    if !orgPlugin.IsEnabled || orgPlugin.Status != "active" {
        return nil, fmt.Errorf("plugin is not active")
    }

    // 2. Get plugin manifest
    manifest, err := s.fetchPluginManifest(ctx, orgPlugin.Plugin.ManifestURL)
    if err != nil {
        return nil, fmt.Errorf("failed to fetch manifest: %w", err)
    }

    // 3. Find action endpoint
    actionEndpoint, ok := manifest.Actions[req.Action]
    if !ok {
        return nil, fmt.Errorf("action not supported: %s", req.Action)
    }

    // 4. Execute HTTP request to plugin endpoint
    result, err := s.executeHTTPRequest(ctx, actionEndpoint, req.Data, orgPlugin.Config)
    if err != nil {
        s.logPluginEvent(ctx, orgPlugin.ID, "execution_failed", map[string]interface{}{
            "action": req.Action,
            "error":  err.Error(),
        })
        return &ExecutePluginResponse{
            Success: false,
            Error:   err.Error(),
        }, nil
    }

    // 5. Log success
    s.logPluginEvent(ctx, orgPlugin.ID, "execution_success", map[string]interface{}{
        "action": req.Action,
    })

    return &ExecutePluginResponse{
        Success: true,
        Data:    result,
    }, nil
}

// Helper: Fetch plugin manifest from URL
func (s *Service) fetchPluginManifest(ctx context.Context, manifestURL string) (*PluginManifest, error) {
    req, err := http.NewRequestWithContext(ctx, "GET", manifestURL, nil)
    if err != nil {
        return nil, err
    }

    resp, err := s.http.Do(req)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        return nil, fmt.Errorf("manifest fetch failed: %d", resp.StatusCode)
    }

    var manifest PluginManifest
    if err := json.NewDecoder(resp.Body).Decode(&manifest); err != nil {
        return nil, err
    }

    return &manifest, nil
}

// Helper: Execute HTTP request to plugin
func (s *Service) executeHTTPRequest(ctx context.Context, endpoint string, data, config map[string]interface{}) (map[string]interface{}, error) {
    // Merge data with config
    payload := map[string]interface{}{
        "data":   data,
        "config": config,
    }

    body, err := json.Marshal(payload)
    if err != nil {
        return nil, err
    }

    req, err := http.NewRequestWithContext(ctx, "POST", endpoint, bytes.NewReader(body))
    if err != nil {
        return nil, err
    }
    req.Header.Set("Content-Type", "application/json")

    resp, err := s.http.Do(req)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        return nil, fmt.Errorf("plugin returned status: %d", resp.StatusCode)
    }

    var result map[string]interface{}
    if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
        return nil, err
    }

    return result, nil
}

// Helper: Log plugin event
func (s *Service) logPluginEvent(ctx context.Context, orgPluginID uuid.UUID, eventType string, data map[string]interface{}) {
    event := &PluginEvent{
        OrganizationPluginID: orgPluginID,
        EventType:            eventType,
        EventData:            data,
        Status:               "success",
    }
    _ = s.repo.CreatePluginEvent(ctx, event)
}

// Helper: Validate config against JSON schema
func (s *Service) validateConfig(schema, config map[string]interface{}) error {
    // TODO: Implement JSON schema validation
    // Use library like https://github.com/xeipuuv/gojsonschema
    return nil
}

type PluginManifest struct {
    PluginKey string                            `json:"plugin_key"`
    Version   string                            `json:"version"`
    Actions   map[string]string                 `json:"actions"` // action name -> endpoint URL
    Webhooks  map[string]string                 `json:"webhooks"`
}
```

**File: `handler.go`**
```go
package plugin

import (
    "encoding/json"
    "net/http"

    "github.com/go-chi/chi/v5"
    "github.com/google/uuid"
)

type Handler struct {
    service *Service
    logger  Logger
}

func NewHandler(service *Service, logger Logger) *Handler {
    return &Handler{
        service: service,
        logger:  logger,
    }
}

// GET /api/v1/marketplace/plugins
func (h *Handler) ListMarketplacePlugins(w http.ResponseWriter, r *http.Request) {
    category := r.URL.Query().Get("category")

    plugins, err := h.service.ListMarketplacePlugins(r.Context(), category)
    if err != nil {
        h.sendError(w, http.StatusInternalServerError, err.Error())
        return
    }

    h.sendJSON(w, http.StatusOK, plugins)
}

// GET /api/v1/organizations/{org_id}/plugins
func (h *Handler) GetInstalledPlugins(w http.ResponseWriter, r *http.Request) {
    orgID, err := uuid.Parse(chi.URLParam(r, "org_id"))
    if err != nil {
        h.sendError(w, http.StatusBadRequest, "invalid organization ID")
        return
    }

    plugins, err := h.service.GetInstalledPlugins(r.Context(), orgID)
    if err != nil {
        h.sendError(w, http.StatusInternalServerError, err.Error())
        return
    }

    h.sendJSON(w, http.StatusOK, plugins)
}

// POST /api/v1/organizations/{org_id}/plugins
func (h *Handler) InstallPlugin(w http.ResponseWriter, r *http.Request) {
    orgID, err := uuid.Parse(chi.URLParam(r, "org_id"))
    if err != nil {
        h.sendError(w, http.StatusBadRequest, "invalid organization ID")
        return
    }

    var req InstallPluginRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        h.sendError(w, http.StatusBadRequest, err.Error())
        return
    }

    userID := getUserIDFromContext(r.Context()) // From JWT middleware

    plugin, err := h.service.InstallPlugin(r.Context(), orgID, &req, userID)
    if err != nil {
        h.sendError(w, http.StatusBadRequest, err.Error())
        return
    }

    h.sendJSON(w, http.StatusCreated, plugin)
}

// POST /api/v1/organizations/{org_id}/plugins/{plugin_key}/execute
func (h *Handler) ExecutePlugin(w http.ResponseWriter, r *http.Request) {
    orgID, err := uuid.Parse(chi.URLParam(r, "org_id"))
    if err != nil {
        h.sendError(w, http.StatusBadRequest, "invalid organization ID")
        return
    }

    pluginKey := chi.URLParam(r, "plugin_key")

    var req ExecutePluginRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        h.sendError(w, http.StatusBadRequest, err.Error())
        return
    }

    result, err := h.service.ExecutePlugin(r.Context(), orgID, pluginKey, &req)
    if err != nil {
        h.sendError(w, http.StatusBadRequest, err.Error())
        return
    }

    h.sendJSON(w, http.StatusOK, result)
}

func (h *Handler) sendJSON(w http.ResponseWriter, status int, data interface{}) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(data)
}

func (h *Handler) sendError(w http.ResponseWriter, status int, message string) {
    h.sendJSON(w, status, map[string]string{"error": message})
}
```

### Step 2.2: Register Routes

**File: `backend/cmd/api/main.go`** (add to existing routes)
```go
// Plugin routes
pluginRepo := plugin.NewRepository(db, logger)
pluginService := plugin.NewService(pluginRepo, logger)
pluginHandler := plugin.NewHandler(pluginService, logger)

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
```

---

## Phase 3: Flutter Plugin SDK

**Timeline:** 2-3 weeks
**Location:** `packages/plugin_manager/`

### Step 3.1: Create Plugin Manager Package

```bash
cd packages
flutter create plugin_manager --template=package
```

**File: `packages/plugin_manager/pubspec.yaml`**
```yaml
name: plugin_manager
description: Plugin system for Flutter-Base POS
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter

  # Networking
  dio: ^5.0.0

  # State Management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0

  # JSON
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0

  # Storage
  shared_preferences: ^2.2.0

  # Utilities
  logger: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
```

### Step 3.2: Create Plugin Models

**File: `lib/src/models/marketplace_plugin.dart`**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_plugin.freezed.dart';
part 'marketplace_plugin.g.dart';

@freezed
class MarketplacePlugin with _$MarketplacePlugin {
  const factory MarketplacePlugin({
    required String id,
    required String pluginKey,
    required String pluginName,
    required String category,
    required String shortDescription,
    String? iconUrl,
    required String version,
    required String pricingModel,
    @Default(0.0) double basePrice,
    @Default(0.0) double ratingAverage,
    @Default(0) int ratingCount,
    @Default(0) int installCount,
    @Default(false) bool isVerified,
    @Default(false) bool isFeatured,
    @Default([]) List<String> requiredPermissions,
  }) = _MarketplacePlugin;

  factory MarketplacePlugin.fromJson(Map<String, dynamic> json) =>
      _$MarketplacePluginFromJson(json);
}

@freezed
class OrganizationPlugin with _$OrganizationPlugin {
  const factory OrganizationPlugin({
    required String id,
    required String organizationId,
    required MarketplacePlugin plugin,
    required String status,
    @Default(true) bool isEnabled,
    @Default({}) Map<String, dynamic> config,
    String? subscriptionStatus,
    DateTime? trialEndsAt,
    required DateTime installedAt,
  }) = _OrganizationPlugin;

  factory OrganizationPlugin.fromJson(Map<String, dynamic> json) =>
      _$OrganizationPluginFromJson(json);
}
```

### Step 3.3: Create Plugin Service

**File: `lib/src/services/plugin_service.dart`**
```dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/marketplace_plugin.dart';

class PluginService {
  final Dio _dio;
  final Logger _logger;
  final String _baseUrl;

  PluginService({
    required Dio dio,
    required Logger logger,
    required String baseUrl,
  })  : _dio = dio,
        _logger = logger,
        _baseUrl = baseUrl;

  // Get all marketplace plugins
  Future<List<MarketplacePlugin>> getMarketplacePlugins({
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/marketplace/plugins',
        queryParameters: category != null ? {'category': category} : null,
      );

      final data = response.data as List;
      return data.map((json) => MarketplacePlugin.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Failed to fetch marketplace plugins', error: e);
      rethrow;
    }
  }

  // Get installed plugins for organization
  Future<List<OrganizationPlugin>> getInstalledPlugins(
    String organizationId,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/organizations/$organizationId/plugins',
      );

      final data = response.data as List;
      return data.map((json) => OrganizationPlugin.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Failed to fetch installed plugins', error: e);
      rethrow;
    }
  }

  // Install a plugin
  Future<OrganizationPlugin> installPlugin(
    String organizationId,
    String pluginKey, {
    Map<String, dynamic>? config,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/organizations/$organizationId/plugins',
        data: {
          'plugin_key': pluginKey,
          if (config != null) 'config': config,
        },
      );

      return OrganizationPlugin.fromJson(response.data);
    } catch (e) {
      _logger.e('Failed to install plugin', error: e);
      rethrow;
    }
  }

  // Uninstall a plugin
  Future<void> uninstallPlugin(
    String organizationId,
    String pluginId,
  ) async {
    try {
      await _dio.delete(
        '$_baseUrl/organizations/$organizationId/plugins/$pluginId',
      );
    } catch (e) {
      _logger.e('Failed to uninstall plugin', error: e);
      rethrow;
    }
  }

  // Update plugin configuration
  Future<OrganizationPlugin> updatePluginConfig(
    String organizationId,
    String pluginId,
    Map<String, dynamic> config,
  ) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/organizations/$organizationId/plugins/$pluginId',
        data: {'config': config},
      );

      return OrganizationPlugin.fromJson(response.data);
    } catch (e) {
      _logger.e('Failed to update plugin config', error: e);
      rethrow;
    }
  }

  // Execute plugin action
  Future<Map<String, dynamic>> executePlugin(
    String organizationId,
    String pluginKey,
    String action,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/organizations/$organizationId/plugins/$pluginKey/execute',
        data: {
          'action': action,
          'data': data,
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Failed to execute plugin', error: e);
      rethrow;
    }
  }

  // Check if plugin is installed and active
  Future<bool> isPluginActive(
    String organizationId,
    String pluginKey,
  ) async {
    try {
      final plugins = await getInstalledPlugins(organizationId);
      return plugins.any(
        (p) =>
            p.plugin.pluginKey == pluginKey &&
            p.isEnabled &&
            p.status == 'active',
      );
    } catch (e) {
      _logger.e('Failed to check plugin status', error: e);
      return false;
    }
  }
}
```

### Step 3.4: Create Plugin Providers (Riverpod)

**File: `lib/src/providers/plugin_providers.dart`**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../services/plugin_service.dart';
import '../models/marketplace_plugin.dart';

// Plugin service provider
final pluginServiceProvider = Provider<PluginService>((ref) {
  final dio = ref.watch(dioProvider); // From your existing network layer
  final logger = Logger();
  final baseUrl = ref.watch(apiBaseUrlProvider);

  return PluginService(
    dio: dio,
    logger: logger,
    baseUrl: baseUrl,
  );
});

// Marketplace plugins provider
final marketplacePluginsProvider = FutureProvider.autoDispose
    .family<List<MarketplacePlugin>, String?>((ref, category) async {
  final service = ref.watch(pluginServiceProvider);
  return service.getMarketplacePlugins(category: category);
});

// Installed plugins provider
final installedPluginsProvider =
    FutureProvider.autoDispose<List<OrganizationPlugin>>((ref) async {
  final service = ref.watch(pluginServiceProvider);
  final orgId = ref.watch(currentOrganizationIdProvider);
  return service.getInstalledPlugins(orgId);
});

// Plugin active check provider
final isPluginActiveProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, pluginKey) async {
  final service = ref.watch(pluginServiceProvider);
  final orgId = ref.watch(currentOrganizationIdProvider);
  return service.isPluginActive(orgId, pluginKey);
});

// Plugin executor
class PluginExecutor {
  final PluginService _service;
  final String _organizationId;

  PluginExecutor(this._service, this._organizationId);

  Future<T?> execute<T>({
    required String pluginKey,
    required String action,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    final result = await _service.executePlugin(
      _organizationId,
      pluginKey,
      action,
      data,
    );

    if (result['success'] == true && result['data'] != null) {
      return parser(result['data']);
    }

    return null;
  }
}

final pluginExecutorProvider = Provider<PluginExecutor>((ref) {
  final service = ref.watch(pluginServiceProvider);
  final orgId = ref.watch(currentOrganizationIdProvider);
  return PluginExecutor(service, orgId);
});
```

### Step 3.5: Create Plugin Widgets

**File: `lib/src/widgets/plugin_marketplace_grid.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/plugin_providers.dart';

class PluginMarketplaceGrid extends ConsumerWidget {
  final String? category;
  final void Function(String pluginKey)? onPluginTap;

  const PluginMarketplaceGrid({
    Key? key,
    this.category,
    this.onPluginTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pluginsAsync = ref.watch(marketplacePluginsProvider(category));

    return pluginsAsync.when(
      data: (plugins) => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: plugins.length,
        itemBuilder: (context, index) {
          final plugin = plugins[index];
          return PluginCard(
            plugin: plugin,
            onTap: () => onPluginTap?.call(plugin.pluginKey),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class PluginCard extends StatelessWidget {
  final MarketplacePlugin plugin;
  final VoidCallback? onTap;

  const PluginCard({
    Key? key,
    required this.plugin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              if (plugin.iconUrl != null)
                Image.network(
                  plugin.iconUrl!,
                  height: 64,
                  width: 64,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.extension, size: 64),
                )
              else
                const Icon(Icons.extension, size: 64),

              const SizedBox(height: 12),

              // Name
              Text(
                plugin.pluginName,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Description
              Expanded(
                child: Text(
                  plugin.shortDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

              // Rating & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        plugin.ratingAverage.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (plugin.pricingModel == 'free')
                    const Text(
                      'FREE',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      '\$${plugin.basePrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Install button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Phase 4: Marketplace UI

**Timeline:** 2-3 weeks
**Location:** `apps/manager_dashboard/`

### Step 4.1: Create Marketplace Pages

**File: `apps/manager_dashboard/lib/src/features/marketplace/presentation/pages/marketplace_page.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_manager/plugin_manager.dart';

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({Key? key}) : super(key: key);

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/marketplace/installed');
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Category sidebar
          SizedBox(
            width: 200,
            child: _buildCategorySidebar(),
          ),

          const VerticalDivider(width: 1),

          // Plugin grid
          Expanded(
            child: PluginMarketplaceGrid(
              category: _selectedCategory,
              onPluginTap: (pluginKey) {
                Navigator.pushNamed(
                  context,
                  '/marketplace/plugin-details',
                  arguments: pluginKey,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySidebar() {
    final categories = [
      ('All', null),
      ('Payment Gateways', 'payment'),
      ('Accounting', 'accounting'),
      ('E-commerce', 'ecommerce'),
      ('Marketing', 'marketing'),
      ('Delivery', 'delivery'),
      ('Analytics', 'analytics'),
    ];

    return ListView(
      children: categories.map((category) {
        final (name, key) = category;
        final isSelected = _selectedCategory == key;

        return ListTile(
          selected: isSelected,
          title: Text(name),
          onTap: () {
            setState(() {
              _selectedCategory = key;
            });
          },
        );
      }).toList(),
    );
  }
}
```

**File: `apps/manager_dashboard/lib/src/features/marketplace/presentation/pages/plugin_details_page.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_manager/plugin_manager.dart';

class PluginDetailsPage extends ConsumerWidget {
  final String pluginKey;

  const PluginDetailsPage({
    Key? key,
    required this.pluginKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch plugin details
    final pluginsAsync = ref.watch(marketplacePluginsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Details'),
      ),
      body: pluginsAsync.when(
        data: (plugins) {
          final plugin = plugins.firstWhere(
            (p) => p.pluginKey == pluginKey,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    if (plugin.iconUrl != null)
                      Image.network(
                        plugin.iconUrl!,
                        height: 80,
                        width: 80,
                      )
                    else
                      const Icon(Icons.extension, size: 80),

                    const SizedBox(width: 24),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plugin.pluginName,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            plugin.shortDescription,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildRatingChip(plugin.ratingAverage),
                              const SizedBox(width: 16),
                              _buildInstallsChip(plugin.installCount),
                              const SizedBox(width: 16),
                              if (plugin.isVerified)
                                const Chip(
                                  avatar: Icon(Icons.verified, size: 16),
                                  label: Text('Verified'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Install button
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(
                      plugin.pricingModel == 'free'
                          ? 'Install Free'
                          : 'Install - \$${plugin.basePrice}/month',
                    ),
                    onPressed: () => _installPlugin(context, ref, plugin),
                  ),
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 32),

                // Tabs
                DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Overview'),
                          Tab(text: 'Reviews'),
                          Tab(text: 'Support'),
                        ],
                      ),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          children: [
                            _buildOverviewTab(plugin),
                            _buildReviewsTab(plugin),
                            _buildSupportTab(plugin),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildRatingChip(double rating) {
    return Chip(
      avatar: const Icon(Icons.star, color: Colors.amber, size: 16),
      label: Text('$rating'),
    );
  }

  Widget _buildInstallsChip(int installs) {
    return Chip(
      avatar: const Icon(Icons.download, size: 16),
      label: Text('$installs installs'),
    );
  }

  Widget _buildOverviewTab(MarketplacePlugin plugin) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Version: ${plugin.version}'),
        const SizedBox(height: 16),
        const Text('Required Permissions:'),
        ...plugin.requiredPermissions.map(
          (p) => ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(p),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab(MarketplacePlugin plugin) {
    return const Center(child: Text('Reviews coming soon...'));
  }

  Widget _buildSupportTab(MarketplacePlugin plugin) {
    return const Center(child: Text('Support info coming soon...'));
  }

  Future<void> _installPlugin(
    BuildContext context,
    WidgetRef ref,
    MarketplacePlugin plugin,
  ) async {
    final service = ref.read(pluginServiceProvider);
    final orgId = ref.read(currentOrganizationIdProvider);

    try {
      await service.installPlugin(orgId, plugin.pluginKey);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plugin.pluginName} installed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to install: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

---

## Phase 5: Plugin Examples

### Example 1: Stripe Payment Plugin

**How to integrate Stripe with your POS:**

```dart
// In your checkout flow
class CheckoutController extends StateNotifier<CheckoutState> {
  final PluginExecutor _pluginExecutor;

  Future<void> processPayment(double amount) async {
    // 1. Check if Stripe is installed
    final isStripeActive = await ref.read(
      isPluginActiveProvider('payment_stripe').future,
    );

    if (!isStripeActive) {
      state = state.copyWith(
        error: 'Stripe plugin not installed',
      );
      return;
    }

    // 2. Execute Stripe payment
    try {
      final result = await _pluginExecutor.execute<PaymentResult>(
        pluginKey: 'payment_stripe',
        action: 'create_payment_intent',
        data: {
          'amount': amount,
          'currency': 'USD',
          'customer_id': state.customerId,
        },
        parser: (json) => PaymentResult.fromJson(json),
      );

      if (result != null && result.success) {
        // Payment succeeded
        state = state.copyWith(
          paymentStatus: PaymentStatus.completed,
          paymentId: result.paymentId,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Payment failed: $e');
    }
  }
}
```

### Example 2: QuickBooks Integration

```dart
// Sync sale to QuickBooks
class SalesController extends StateNotifier<SalesState> {
  final PluginExecutor _pluginExecutor;

  Future<void> completeSale(Sale sale) async {
    // 1. Save sale to local database
    await _salesRepository.createSale(sale);

    // 2. Check if QuickBooks is active
    final isQBActive = await ref.read(
      isPluginActiveProvider('accounting_quickbooks').future,
    );

    if (isQBActive) {
      // 3. Sync to QuickBooks
      await _pluginExecutor.execute(
        pluginKey: 'accounting_quickbooks',
        action: 'create_invoice',
        data: {
          'sale_id': sale.id,
          'customer_name': sale.customerName,
          'items': sale.items.map((i) => {
            'name': i.productName,
            'quantity': i.quantity,
            'unit_price': i.unitPrice,
          }).toList(),
          'total': sale.total,
        },
        parser: (json) => json,
      );
    }
  }
}
```

### Example 3: Shopify Product Sync

```dart
// Sync products to Shopify
class ProductSyncService {
  final PluginExecutor _pluginExecutor;

  Future<void> syncProductToShopify(Product product) async {
    await _pluginExecutor.execute(
      pluginKey: 'ecommerce_shopify',
      action: 'sync_product',
      data: {
        'sku': product.sku,
        'name': product.name,
        'description': product.description,
        'price': product.sellingPrice,
        'inventory_quantity': product.stockQuantity,
        'images': product.imageUrls,
      },
      parser: (json) => json,
    );
  }

  Future<void> syncAllProducts() async {
    final products = await _productRepository.getAllProducts();

    for (final product in products) {
      try {
        await syncProductToShopify(product);
      } catch (e) {
        print('Failed to sync ${product.sku}: $e');
      }
    }
  }
}
```

---

## Security & Isolation

### 1. Plugin Permissions System

**Implementation:**

```dart
// Permission checker
class PluginPermissionChecker {
  final PluginService _pluginService;

  Future<bool> canPluginAccess({
    required String organizationId,
    required String pluginKey,
    required String permission,  // e.g., 'products:write'
  }) async {
    final plugins = await _pluginService.getInstalledPlugins(organizationId);

    final plugin = plugins.firstWhere(
      (p) => p.plugin.pluginKey == pluginKey,
      orElse: () => throw Exception('Plugin not installed'),
    );

    // Check if granted permissions include this permission
    return plugin.grantedPermissions?.contains(permission) ?? false;
  }
}
```

**In Backend (Go):**

```go
// Middleware to check plugin permissions
func PluginPermissionMiddleware(requiredPermission string) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            pluginAPIKey := r.Header.Get("X-Plugin-API-Key")

            // Get plugin from API key
            plugin, err := getPluginFromAPIKey(pluginAPIKey)
            if err != nil {
                http.Error(w, "Unauthorized", http.StatusUnauthorized)
                return
            }

            // Check permission
            if !hasPermission(plugin.GrantedPermissions, requiredPermission) {
                http.Error(w, "Forbidden", http.StatusForbidden)
                return
            }

            next.ServeHTTP(w, r)
        })
    }
}
```

### 2. Data Isolation with RLS

**Already implemented in your database!**

Plugins can only access data for their organization:

```sql
-- RLS automatically enforces this
SELECT * FROM products WHERE organization_id = current_user_organization_id();
```

### 3. Rate Limiting per Plugin

```go
// Rate limiter per plugin
type PluginRateLimiter struct {
    cache *redis.Client
}

func (r *PluginRateLimiter) CheckLimit(pluginID string, orgID string) error {
    key := fmt.Sprintf("plugin_rate:%s:%s", pluginID, orgID)

    count, err := r.cache.Incr(context.Background(), key).Result()
    if err != nil {
        return err
    }

    if count == 1 {
        r.cache.Expire(context.Background(), key, time.Hour)
    }

    if count > 1000 {  // 1000 requests per hour
        return errors.New("rate limit exceeded")
    }

    return nil
}
```

---

## Testing Strategy

### 1. Unit Tests for Plugin Service

```dart
// Test file: test/plugin_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('PluginService', () {
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

    test('getMarketplacePlugins returns list of plugins', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: [
            {
              'id': '1',
              'plugin_key': 'payment_stripe',
              'plugin_name': 'Stripe',
              // ... more fields
            },
          ],
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await service.getMarketplacePlugins();

      // Assert
      expect(result, hasLength(1));
      expect(result.first.pluginKey, 'payment_stripe');
    });
  });
}
```

### 2. Integration Tests for Plugin Installation

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Install and execute Stripe plugin', (tester) async {
    // 1. Launch app
    await tester.pumpWidget(MyApp());

    // 2. Navigate to marketplace
    await tester.tap(find.text('Marketplace'));
    await tester.pumpAndSettle();

    // 3. Find Stripe plugin
    await tester.tap(find.text('Stripe Payment Gateway'));
    await tester.pumpAndSettle();

    // 4. Install plugin
    await tester.tap(find.text('Install'));
    await tester.pumpAndSettle();

    // 5. Verify installation
    expect(find.text('Installed successfully'), findsOneWidget);

    // 6. Execute payment
    // ... test payment flow
  });
}
```

---

## Deployment & DevOps

### 1. Database Migration

```bash
# Apply plugin tables migration
cd Flutter-Database
make migrate-up
```

### 2. Backend Deployment

```bash
# Build backend with plugin support
cd backend
go build -o bin/api cmd/api/main.go

# Run
./bin/api
```

### 3. Flutter App Build

```bash
# Build with plugin manager
cd apps/manager_dashboard
flutter pub get
flutter build web  # or ios, android, etc.
```

---

## Timeline & Resources

### Phase 1: Database (1-2 weeks)
- **Tasks**: Create plugin tables, helper functions, RLS policies
- **Team**: 1 backend developer
- **Deliverable**: Migration file, SQL functions

### Phase 2: Backend API (2-3 weeks)
- **Tasks**: Plugin module, API endpoints, webhook handler
- **Team**: 1-2 backend developers (Go)
- **Deliverable**: REST API endpoints, Swagger docs

### Phase 3: Flutter SDK (2-3 weeks)
- **Tasks**: Plugin manager package, models, services, providers
- **Team**: 1-2 Flutter developers
- **Deliverable**: `plugin_manager` package

### Phase 4: Marketplace UI (2-3 weeks)
- **Tasks**: Marketplace pages, plugin details, installation flow
- **Team**: 1-2 Flutter developers
- **Deliverable**: Marketplace app screens

### Phase 5: Plugin Examples (1-2 weeks)
- **Tasks**: Stripe, QuickBooks, Shopify example integrations
- **Team**: 1 integration developer
- **Deliverable**: 3 example plugins

### Phase 6: Testing & Documentation (1-2 weeks)
- **Tasks**: Unit tests, integration tests, developer docs
- **Team**: 1 QA engineer, 1 technical writer
- **Deliverable**: Test suite, plugin developer guide

**Total Timeline: 9-15 weeks (2-4 months)**

**Team Size: 3-5 developers**

---

## Summary

This implementation plan provides a complete roadmap for building an **Odoo-style marketplace/plugin system** for your Flutter POS:

**Key Features:**
✅ Dual system: Feature flags + Plugin marketplace
✅ Third-party plugin support (Stripe, QuickBooks, etc.)
✅ Secure multi-tenant isolation with RLS
✅ Flutter SDK for easy integration
✅ Marketplace UI for discovery and installation
✅ Webhook-based event system
✅ OAuth2 support for external services

**Next Steps:**
1. Review this plan with your team
2. Start with Phase 1 (Database infrastructure)
3. Build incrementally, testing each phase
4. Launch with 3-5 example plugins (Stripe, QuickBooks, Shopify)
5. Open to third-party developers with SDK documentation

Your existing architecture is **excellent** for this expansion. The multi-tenant RLS, JSONB flexibility, and clean API design make plugin integration straightforward.

Good luck with your implementation!
