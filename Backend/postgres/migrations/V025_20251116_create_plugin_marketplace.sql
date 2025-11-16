-- ============================================================================
-- MIGRATION: V025 - Plugin Marketplace System
-- Created: 2025-11-16
-- Description: Creates tables and functions for the plugin marketplace system
--              that allows third-party integrations (Stripe, QuickBooks, etc.)
-- ============================================================================

-- ============================================================================
-- MARKETPLACE PLUGIN REGISTRY
-- ============================================================================

CREATE TABLE IF NOT EXISTS marketplace_plugins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Identity
    plugin_key VARCHAR(100) UNIQUE NOT NULL,
    plugin_name VARCHAR(255) NOT NULL,
    plugin_slug VARCHAR(100) UNIQUE NOT NULL,

    -- Developer
    developer_organization_id UUID REFERENCES organizations(id),
    developer_name VARCHAR(255),
    developer_email VARCHAR(255),
    developer_website TEXT,

    -- Categorization
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    tags TEXT[],

    -- Description
    short_description TEXT,
    long_description TEXT,
    features JSONB DEFAULT '[]',

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
    required_permissions TEXT[],
    optional_permissions TEXT[],
    oauth_scopes TEXT[],

    -- Webhooks
    webhook_url TEXT,
    webhook_events TEXT[],

    -- Configuration
    config_schema JSONB DEFAULT '{}',
    default_config JSONB DEFAULT '{}',

    -- Pricing
    pricing_model VARCHAR(50),
    base_price NUMERIC(10, 2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    pricing_tiers JSONB DEFAULT '[]',
    trial_days INTEGER DEFAULT 0,

    -- Status
    status VARCHAR(30) DEFAULT 'draft',
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
    deleted_at TIMESTAMP WITH TIME ZONE,

    -- Constraints
    CONSTRAINT marketplace_plugins_status_check CHECK (status IN ('draft', 'pending_review', 'approved', 'rejected', 'suspended')),
    CONSTRAINT marketplace_plugins_pricing_check CHECK (pricing_model IN ('free', 'monthly', 'yearly', 'per_transaction', 'tier_based'))
);

-- Indexes
CREATE INDEX idx_marketplace_plugins_category ON marketplace_plugins(category) WHERE deleted_at IS NULL;
CREATE INDEX idx_marketplace_plugins_status ON marketplace_plugins(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_marketplace_plugins_developer ON marketplace_plugins(developer_organization_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_marketplace_plugins_featured ON marketplace_plugins(is_featured, rating_average DESC) WHERE deleted_at IS NULL AND is_active = TRUE;

-- Comments
COMMENT ON TABLE marketplace_plugins IS 'Catalog of available plugins in the marketplace';
COMMENT ON COLUMN marketplace_plugins.plugin_key IS 'Unique identifier for the plugin (e.g., payment_stripe)';
COMMENT ON COLUMN marketplace_plugins.manifest_url IS 'URL to plugin manifest JSON file';
COMMENT ON COLUMN marketplace_plugins.config_schema IS 'JSON Schema for plugin configuration';

-- ============================================================================
-- ORGANIZATION PLUGIN INSTALLATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS organization_plugins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- References
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    plugin_id UUID NOT NULL REFERENCES marketplace_plugins(id) ON DELETE CASCADE,

    -- Status
    status VARCHAR(30) DEFAULT 'active',
    is_enabled BOOLEAN DEFAULT TRUE,

    -- Configuration
    config JSONB DEFAULT '{}',

    -- Credentials & Access
    api_key_id UUID REFERENCES api_keys(id),
    oauth_token_id UUID,
    granted_permissions TEXT[],

    -- Subscription
    subscription_status VARCHAR(30),
    subscription_plan VARCHAR(50),
    trial_started_at TIMESTAMP WITH TIME ZONE,
    trial_ends_at TIMESTAMP WITH TIME ZONE,
    subscription_started_at TIMESTAMP WITH TIME ZONE,
    subscription_ends_at TIMESTAMP WITH TIME ZONE,
    next_billing_date TIMESTAMP WITH TIME ZONE,

    -- Sync Status
    last_sync_at TIMESTAMP WITH TIME ZONE,
    sync_frequency VARCHAR(20),
    sync_status VARCHAR(30),
    sync_error TEXT,

    -- Usage Tracking
    usage_stats JSONB DEFAULT '{}',
    last_used_at TIMESTAMP WITH TIME ZONE,

    -- Health
    health_status VARCHAR(30) DEFAULT 'healthy',
    health_message TEXT,
    last_health_check_at TIMESTAMP WITH TIME ZONE,

    -- Audit
    installed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    installed_by UUID REFERENCES users(id),
    uninstalled_at TIMESTAMP WITH TIME ZONE,
    uninstalled_by UUID REFERENCES users(id),

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Constraints
    UNIQUE(organization_id, plugin_id),
    CONSTRAINT organization_plugins_status_check CHECK (status IN ('active', 'paused', 'uninstalled', 'error')),
    CONSTRAINT organization_plugins_subscription_check CHECK (subscription_status IN ('trial', 'active', 'past_due', 'canceled', 'expired')),
    CONSTRAINT organization_plugins_sync_freq_check CHECK (sync_frequency IN ('manual', 'realtime', 'hourly', 'daily', 'weekly')),
    CONSTRAINT organization_plugins_health_check CHECK (health_status IN ('healthy', 'degraded', 'error', 'unknown'))
);

-- Indexes
CREATE INDEX idx_org_plugins_org ON organization_plugins(organization_id) WHERE uninstalled_at IS NULL;
CREATE INDEX idx_org_plugins_plugin ON organization_plugins(plugin_id) WHERE uninstalled_at IS NULL;
CREATE INDEX idx_org_plugins_status ON organization_plugins(organization_id, status, is_enabled) WHERE uninstalled_at IS NULL;
CREATE INDEX idx_org_plugins_subscription ON organization_plugins(subscription_status, next_billing_date) WHERE uninstalled_at IS NULL;

-- Comments
COMMENT ON TABLE organization_plugins IS 'Tracks which plugins are installed for each organization';
COMMENT ON COLUMN organization_plugins.config IS 'Plugin-specific configuration (e.g., API keys, settings)';
COMMENT ON COLUMN organization_plugins.granted_permissions IS 'Permissions granted to this plugin installation';

-- ============================================================================
-- PLUGIN EVENTS & LOGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS plugin_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_plugin_id UUID NOT NULL REFERENCES organization_plugins(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

    event_type VARCHAR(100) NOT NULL,
    event_name VARCHAR(255),

    event_data JSONB DEFAULT '{}',

    status VARCHAR(30),
    error_message TEXT,
    error_code VARCHAR(50),

    duration_ms INTEGER,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT plugin_events_status_check CHECK (status IN ('success', 'error', 'pending', 'timeout'))
);

-- Indexes
CREATE INDEX idx_plugin_events_org_plugin ON plugin_events(organization_plugin_id, created_at DESC);
CREATE INDEX idx_plugin_events_org ON plugin_events(organization_id, created_at DESC);
CREATE INDEX idx_plugin_events_type ON plugin_events(event_type, created_at DESC);
CREATE INDEX idx_plugin_events_status ON plugin_events(status, created_at DESC) WHERE status = 'error';

-- Comments
COMMENT ON TABLE plugin_events IS 'Logs all plugin execution events for debugging and analytics';
COMMENT ON COLUMN plugin_events.event_type IS 'Type of event (e.g., webhook_received, api_called, sync_completed)';

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

    -- Constraints
    UNIQUE(plugin_id, organization_id)
);

-- Indexes
CREATE INDEX idx_plugin_reviews_plugin ON plugin_reviews(plugin_id, created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_plugin_reviews_rating ON plugin_reviews(plugin_id, rating) WHERE deleted_at IS NULL;
CREATE INDEX idx_plugin_reviews_user ON plugin_reviews(user_id, created_at DESC) WHERE deleted_at IS NULL;

-- Comments
COMMENT ON TABLE plugin_reviews IS 'User reviews and ratings for marketplace plugins';

-- ============================================================================
-- OAUTH2 SUPPORT
-- ============================================================================

CREATE TABLE IF NOT EXISTS oauth_providers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    provider_key VARCHAR(50) UNIQUE NOT NULL,
    provider_name VARCHAR(255) NOT NULL,

    -- OAuth Configuration
    client_id VARCHAR(255),
    client_secret VARCHAR(255),
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

-- Indexes
CREATE INDEX idx_oauth_providers_plugin ON oauth_providers(plugin_id) WHERE is_active = TRUE;

-- Comments
COMMENT ON TABLE oauth_providers IS 'OAuth2 provider configurations for third-party authentication';
COMMENT ON COLUMN oauth_providers.client_secret IS 'Should be encrypted at application level';

CREATE TABLE IF NOT EXISTS oauth_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    organization_plugin_id UUID REFERENCES organization_plugins(id) ON DELETE CASCADE,
    oauth_provider_id UUID NOT NULL REFERENCES oauth_providers(id),

    -- Tokens (should be encrypted at application level)
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

-- Indexes
CREATE INDEX idx_oauth_tokens_org ON oauth_tokens(organization_id) WHERE revoked_at IS NULL;
CREATE INDEX idx_oauth_tokens_plugin ON oauth_tokens(organization_plugin_id) WHERE revoked_at IS NULL;
CREATE INDEX idx_oauth_tokens_expires ON oauth_tokens(expires_at) WHERE revoked_at IS NULL AND expires_at IS NOT NULL;

-- Comments
COMMENT ON TABLE oauth_tokens IS 'OAuth2 access and refresh tokens for plugin integrations';
COMMENT ON COLUMN oauth_tokens.access_token IS 'Should be encrypted at application level';
COMMENT ON COLUMN oauth_tokens.refresh_token IS 'Should be encrypted at application level';

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Check if plugin is installed and active
CREATE OR REPLACE FUNCTION is_plugin_active(
    p_organization_id UUID,
    p_plugin_key VARCHAR
) RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
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
          AND mp.deleted_at IS NULL
    );
END;
$$;

COMMENT ON FUNCTION is_plugin_active IS 'Check if a plugin is installed and active for an organization';

-- Get plugin configuration
CREATE OR REPLACE FUNCTION get_plugin_config(
    p_organization_id UUID,
    p_plugin_key VARCHAR
) RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_config JSONB;
BEGIN
    SELECT op.config INTO v_config
    FROM organization_plugins op
    JOIN marketplace_plugins mp ON op.plugin_id = mp.id
    WHERE op.organization_id = p_organization_id
      AND mp.plugin_key = p_plugin_key
      AND op.status = 'active'
      AND op.is_enabled = TRUE
      AND op.uninstalled_at IS NULL;

    RETURN COALESCE(v_config, '{}'::JSONB);
END;
$$;

COMMENT ON FUNCTION get_plugin_config IS 'Get plugin configuration for an organization';

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Update plugin rating average when review is added/updated/deleted
CREATE OR REPLACE FUNCTION update_plugin_rating()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE marketplace_plugins
    SET rating_average = (
            SELECT ROUND(AVG(rating)::NUMERIC, 2)
            FROM plugin_reviews
            WHERE plugin_id = COALESCE(NEW.plugin_id, OLD.plugin_id)
              AND deleted_at IS NULL
        ),
        rating_count = (
            SELECT COUNT(*)
            FROM plugin_reviews
            WHERE plugin_id = COALESCE(NEW.plugin_id, OLD.plugin_id)
              AND deleted_at IS NULL
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = COALESCE(NEW.plugin_id, OLD.plugin_id);

    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trigger_update_plugin_rating
    AFTER INSERT OR UPDATE OR DELETE ON plugin_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_plugin_rating();

COMMENT ON FUNCTION update_plugin_rating IS 'Automatically updates plugin rating average when reviews change';

-- Update plugin install count when plugin is installed/uninstalled
CREATE OR REPLACE FUNCTION update_plugin_install_count()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE marketplace_plugins
        SET install_count = install_count + 1,
            active_install_count = active_install_count + 1,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.plugin_id;
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.uninstalled_at IS NOT NULL AND OLD.uninstalled_at IS NULL THEN
            UPDATE marketplace_plugins
            SET active_install_count = GREATEST(active_install_count - 1, 0),
                updated_at = CURRENT_TIMESTAMP
            WHERE id = NEW.plugin_id;
        ELSIF NEW.uninstalled_at IS NULL AND OLD.uninstalled_at IS NOT NULL THEN
            UPDATE marketplace_plugins
            SET active_install_count = active_install_count + 1,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = NEW.plugin_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_update_plugin_install_count
    AFTER INSERT OR UPDATE ON organization_plugins
    FOR EACH ROW
    EXECUTE FUNCTION update_plugin_install_count();

COMMENT ON FUNCTION update_plugin_install_count IS 'Automatically updates plugin install counts';

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

CREATE POLICY plugin_events_super_admin_all ON plugin_events
    FOR ALL TO PUBLIC
    USING (is_super_admin());

ALTER TABLE plugin_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY plugin_reviews_tenant_isolation ON plugin_reviews
    USING (organization_id = current_user_organization_id());

CREATE POLICY plugin_reviews_super_admin_all ON plugin_reviews
    FOR ALL TO PUBLIC
    USING (is_super_admin());

-- Marketplace plugins are public (read-only for all)
ALTER TABLE marketplace_plugins ENABLE ROW LEVEL SECURITY;

CREATE POLICY marketplace_plugins_public_read ON marketplace_plugins
    FOR SELECT TO PUBLIC
    USING (status = 'approved' AND is_active = TRUE AND deleted_at IS NULL);

CREATE POLICY marketplace_plugins_developer_manage ON marketplace_plugins
    FOR ALL TO PUBLIC
    USING (developer_organization_id = current_user_organization_id() OR is_super_admin());

ALTER TABLE oauth_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY oauth_tokens_tenant_isolation ON oauth_tokens
    USING (organization_id = current_user_organization_id());

CREATE POLICY oauth_tokens_super_admin_all ON oauth_tokens
    FOR ALL TO PUBLIC
    USING (is_super_admin());

-- ============================================================================
-- SEED DATA: Example Plugins
-- ============================================================================

INSERT INTO marketplace_plugins (
    plugin_key, plugin_name, plugin_slug, category, subcategory,
    short_description, long_description,
    version, manifest_url, icon_url,
    required_permissions, webhook_events,
    config_schema, pricing_model, base_price, status, is_verified, is_featured
) VALUES
-- Payment Gateways
('payment_stripe', 'Stripe Payment Gateway', 'stripe', 'payment', 'payment_gateway',
 'Accept credit cards and digital wallets with Stripe',
 'Stripe is the best software platform for running an internet business. We handle billions of dollars every year for forward-thinking businesses around the world.',
 '1.0.0', 'https://plugins.yourpos.com/stripe/manifest.json', 'https://plugins.yourpos.com/stripe/icon.png',
 ARRAY['payments:read', 'payments:write', 'sales:read'],
 ARRAY['sale.completed', 'payment.completed', 'payment.refunded'],
 '{"type":"object","properties":{"api_key":{"type":"string","title":"Stripe Secret Key"},"webhook_secret":{"type":"string","title":"Webhook Secret"}},"required":["api_key"]}',
 'per_transaction', 2.90, 'approved', TRUE, TRUE),

('payment_square', 'Square Payment Gateway', 'square', 'payment', 'payment_gateway',
 'Process payments with Square',
 'Square helps millions of sellers run their business - from secure credit card processing to point of sale solutions.',
 '1.0.0', 'https://plugins.yourpos.com/square/manifest.json', 'https://plugins.yourpos.com/square/icon.png',
 ARRAY['payments:read', 'payments:write'],
 ARRAY['sale.completed', 'payment.completed'],
 '{"type":"object","properties":{"access_token":{"type":"string","title":"Access Token"},"location_id":{"type":"string","title":"Location ID"}},"required":["access_token"]}',
 'monthly', 29.00, 'approved', TRUE, FALSE),

-- Accounting
('accounting_quickbooks', 'QuickBooks Online', 'quickbooks', 'accounting', 'accounting_software',
 'Sync sales and expenses to QuickBooks',
 'QuickBooks Online is cloud-based accounting software that helps you manage your business finances anywhere, anytime.',
 '1.0.0', 'https://plugins.yourpos.com/quickbooks/manifest.json', 'https://plugins.yourpos.com/quickbooks/icon.png',
 ARRAY['sales:read', 'customers:read', 'invoices:write', 'products:read'],
 ARRAY['sale.completed', 'invoice.created', 'payment.completed'],
 '{"type":"object","properties":{"company_id":{"type":"string","title":"Company ID"},"sync_frequency":{"type":"string","enum":["realtime","hourly","daily"]}},"required":["company_id"]}',
 'monthly', 49.00, 'approved', TRUE, TRUE),

('accounting_xero', 'Xero Accounting', 'xero', 'accounting', 'accounting_software',
 'Connect your POS to Xero',
 'Beautiful accounting software for small businesses. Xero is always up to date and available on any device.',
 '1.0.0', 'https://plugins.yourpos.com/xero/manifest.json', 'https://plugins.yourpos.com/xero/icon.png',
 ARRAY['sales:read', 'customers:read', 'invoices:write'],
 ARRAY['sale.completed', 'payment.completed'],
 '{"type":"object","properties":{"tenant_id":{"type":"string","title":"Tenant ID"}}}',
 'monthly', 39.00, 'approved', TRUE, FALSE),

-- E-commerce
('ecommerce_shopify', 'Shopify Integration', 'shopify', 'ecommerce', 'ecommerce_platform',
 'Sync products and orders with Shopify',
 'Shopify is a complete commerce platform that lets you start, grow, and manage a business.',
 '1.0.0', 'https://plugins.yourpos.com/shopify/manifest.json', 'https://plugins.yourpos.com/shopify/icon.png',
 ARRAY['products:read', 'products:write', 'inventory:read', 'inventory:write', 'orders:read'],
 ARRAY['product.created', 'product.updated', 'inventory.updated'],
 '{"type":"object","properties":{"shop_name":{"type":"string","title":"Shop Name"},"api_key":{"type":"string","title":"API Key"}},"required":["shop_name","api_key"]}',
 'monthly', 59.00, 'approved', TRUE, TRUE),

-- Marketing
('marketing_mailchimp', 'Mailchimp Email Marketing', 'mailchimp', 'marketing', 'email_marketing',
 'Send customer receipts and marketing emails',
 'Mailchimp helps you market smarter so you can grow faster. Send the right message at the right time.',
 '1.0.0', 'https://plugins.yourpos.com/mailchimp/manifest.json', 'https://plugins.yourpos.com/mailchimp/icon.png',
 ARRAY['customers:read', 'sales:read'],
 ARRAY['customer.created', 'sale.completed'],
 '{"type":"object","properties":{"api_key":{"type":"string","title":"API Key"},"list_id":{"type":"string","title":"Audience ID"}},"required":["api_key","list_id"]}',
 'free', 0.00, 'approved', TRUE, FALSE)

ON CONFLICT (plugin_key) DO NOTHING;

-- ============================================================================
-- GRANTS
-- ============================================================================

-- Grant read access to marketplace_plugins to all authenticated users
-- (specific permissions handled by RLS policies)

COMMENT ON SCHEMA public IS 'Public schema containing plugin marketplace tables';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- Log migration
DO $$
BEGIN
    RAISE NOTICE 'Migration V025 completed successfully';
    RAISE NOTICE 'Created tables: marketplace_plugins, organization_plugins, plugin_events, plugin_reviews, oauth_providers, oauth_tokens';
    RAISE NOTICE 'Created functions: is_plugin_active, get_plugin_config';
    RAISE NOTICE 'Seeded 6 example plugins';
END $$;
