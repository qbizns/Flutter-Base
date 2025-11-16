-- ============================================================================
-- FLUTTER-BASE POS: MARKETPLACE & PLUGIN SYSTEM
-- Migration: V025_20251116_create_plugin_marketplace.sql
-- Description: Creates tables and functions for plugin marketplace system
-- ============================================================================

-- ============================================================================
-- MARKETPLACE PLUGIN REGISTRY
-- ============================================================================

-- Plugin catalog (available in marketplace)
CREATE TABLE IF NOT EXISTS marketplace_plugins (
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

CREATE TABLE IF NOT EXISTS organization_plugins (
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
    oauth_token_id UUID,  -- Reference to oauth_tokens
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

CREATE TABLE IF NOT EXISTS plugin_events (
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

CREATE TABLE IF NOT EXISTS plugin_reviews (
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

CREATE TABLE IF NOT EXISTS oauth_providers (
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

CREATE TABLE IF NOT EXISTS oauth_tokens (
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
          AND op.uninstalled_at IS NULL
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
            WHERE plugin_id = COALESCE(NEW.plugin_id, OLD.plugin_id) AND deleted_at IS NULL
        ),
        rating_count = (
            SELECT COUNT(*)
            FROM plugin_reviews
            WHERE plugin_id = COALESCE(NEW.plugin_id, OLD.plugin_id) AND deleted_at IS NULL
        )
    WHERE id = COALESCE(NEW.plugin_id, OLD.plugin_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_plugin_rating ON plugin_reviews;
CREATE TRIGGER trigger_update_plugin_rating
    AFTER INSERT OR UPDATE OR DELETE ON plugin_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_plugin_rating();

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE organization_plugins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS organization_plugins_tenant_isolation ON organization_plugins;
CREATE POLICY organization_plugins_tenant_isolation ON organization_plugins
    USING (organization_id = current_setting('app.current_organization_id')::UUID);

DROP POLICY IF EXISTS organization_plugins_super_admin_all ON organization_plugins;
CREATE POLICY organization_plugins_super_admin_all ON organization_plugins
    FOR ALL TO PUBLIC
    USING (current_setting('app.is_super_admin', TRUE)::BOOLEAN = TRUE);

ALTER TABLE plugin_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS plugin_events_tenant_isolation ON plugin_events;
CREATE POLICY plugin_events_tenant_isolation ON plugin_events
    USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE plugin_reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS plugin_reviews_tenant_isolation ON plugin_reviews;
CREATE POLICY plugin_reviews_tenant_isolation ON plugin_reviews
    USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE oauth_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS oauth_tokens_tenant_isolation ON oauth_tokens;
CREATE POLICY oauth_tokens_tenant_isolation ON oauth_tokens
    USING (organization_id = current_setting('app.current_organization_id')::UUID);

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
 'https://plugins.yourpos.com/stripe/manifest.json',
 ARRAY['payments:read', 'payments:write'],
 'per_transaction', 'approved', TRUE),

('payment_square', 'Square Payment Gateway', 'square', 'payment',
 'Process payments with Square', '1.0.0',
 'https://plugins.yourpos.com/square/manifest.json',
 ARRAY['payments:read', 'payments:write'],
 'monthly', 'approved', TRUE),

-- Accounting
('accounting_quickbooks', 'QuickBooks Online', 'quickbooks', 'accounting',
 'Sync sales and expenses to QuickBooks', '1.0.0',
 'https://plugins.yourpos.com/quickbooks/manifest.json',
 ARRAY['sales:read', 'customers:read', 'invoices:write'],
 'monthly', 'approved', TRUE),

('accounting_xero', 'Xero Accounting', 'xero', 'accounting',
 'Connect your POS to Xero', '1.0.0',
 'https://plugins.yourpos.com/xero/manifest.json',
 ARRAY['sales:read', 'customers:read', 'invoices:write'],
 'monthly', 'approved', TRUE),

-- E-commerce
('ecommerce_shopify', 'Shopify Integration', 'shopify', 'ecommerce',
 'Sync products and orders with Shopify', '1.0.0',
 'https://plugins.yourpos.com/shopify/manifest.json',
 ARRAY['products:read', 'products:write', 'inventory:read', 'inventory:write'],
 'monthly', 'approved', TRUE),

-- Marketing
('marketing_mailchimp', 'Mailchimp Email Marketing', 'mailchimp', 'marketing',
 'Send customer receipts and marketing emails', '1.0.0',
 'https://plugins.yourpos.com/mailchimp/manifest.json',
 ARRAY['customers:read', 'sales:read'],
 'free', 'approved', TRUE)
ON CONFLICT (plugin_key) DO NOTHING;

COMMENT ON TABLE marketplace_plugins IS 'Catalog of available plugins in the marketplace';
COMMENT ON TABLE organization_plugins IS 'Plugins installed by organizations';
COMMENT ON TABLE plugin_events IS 'Log of plugin execution events';
COMMENT ON TABLE plugin_reviews IS 'User reviews and ratings for plugins';
COMMENT ON TABLE oauth_providers IS 'OAuth2 provider configurations for plugins';
COMMENT ON TABLE oauth_tokens IS 'OAuth2 tokens for plugin authentication';
