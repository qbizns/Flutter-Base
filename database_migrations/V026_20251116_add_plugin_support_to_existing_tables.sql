-- ============================================================================
-- FLUTTER-BASE POS: ADD PLUGIN SUPPORT TO EXISTING TABLES
-- Migration: V026_20251116_add_plugin_support_to_existing_tables.sql
-- Description: Adds plugin reference columns to existing POS tables
-- ============================================================================

-- ============================================================================
-- PAYMENTS TABLE
-- ============================================================================

-- Add plugin payment tracking
ALTER TABLE IF EXISTS payments
ADD COLUMN IF NOT EXISTS plugin_payment_id VARCHAR(255),  -- External payment ID (e.g., Stripe charge ID: ch_...)
ADD COLUMN IF NOT EXISTS plugin_metadata JSONB DEFAULT '{}',  -- Plugin-specific data
ADD COLUMN IF NOT EXISTS plugin_key VARCHAR(100);  -- Which plugin processed this payment

CREATE INDEX IF NOT EXISTS idx_payments_plugin_payment_id ON payments(plugin_payment_id);
CREATE INDEX IF NOT EXISTS idx_payments_plugin_key ON payments(plugin_key);

COMMENT ON COLUMN payments.plugin_payment_id IS 'External payment ID from plugin (e.g., Stripe charge ID)';
COMMENT ON COLUMN payments.plugin_metadata IS 'Additional metadata from payment plugin';
COMMENT ON COLUMN payments.plugin_key IS 'Plugin that processed this payment';

-- ============================================================================
-- CUSTOMERS TABLE
-- ============================================================================

-- Add multi-plugin customer ID mapping
ALTER TABLE IF EXISTS customers
ADD COLUMN IF NOT EXISTS plugin_customer_ids JSONB DEFAULT '{}';  -- {'shopify': '123', 'mailchimp': '456', 'quickbooks': '789'}

CREATE INDEX IF NOT EXISTS idx_customers_plugin_ids ON customers USING gin(plugin_customer_ids);

COMMENT ON COLUMN customers.plugin_customer_ids IS 'Mapping of customer IDs across different plugins';

-- Example plugin_customer_ids structure:
-- {
--   "shopify": "customer_123",
--   "mailchimp": "subscriber_456",
--   "quickbooks": "qbo_customer_789"
-- }

-- ============================================================================
-- PRODUCTS TABLE
-- ============================================================================

-- Add multi-plugin product ID mapping
ALTER TABLE IF EXISTS products
ADD COLUMN IF NOT EXISTS plugin_product_ids JSONB DEFAULT '{}',  -- {'shopify': '789', 'woocommerce': '101'}
ADD COLUMN IF NOT EXISTS plugin_sync_status JSONB DEFAULT '{}';  -- Track sync status per plugin

CREATE INDEX IF NOT EXISTS idx_products_plugin_ids ON products USING gin(plugin_product_ids);
CREATE INDEX IF NOT EXISTS idx_products_plugin_sync_status ON products USING gin(plugin_sync_status);

COMMENT ON COLUMN products.plugin_product_ids IS 'Mapping of product IDs across different e-commerce plugins';
COMMENT ON COLUMN products.plugin_sync_status IS 'Sync status for each plugin integration';

-- Example plugin_sync_status structure:
-- {
--   "shopify": {
--     "last_synced_at": "2024-11-16T10:00:00Z",
--     "status": "success",
--     "error": null
--   },
--   "woocommerce": {
--     "last_synced_at": "2024-11-16T09:30:00Z",
--     "status": "error",
--     "error": "Product not found"
--   }
-- }

-- ============================================================================
-- SALES/ORDERS TABLE
-- ============================================================================

ALTER TABLE IF EXISTS sales
ADD COLUMN IF NOT EXISTS plugin_sale_ids JSONB DEFAULT '{}',  -- External sale/order IDs
ADD COLUMN IF NOT EXISTS plugin_sync_status JSONB DEFAULT '{}';  -- Sync status per plugin

CREATE INDEX IF NOT EXISTS idx_sales_plugin_ids ON sales USING gin(plugin_sale_ids);

COMMENT ON COLUMN sales.plugin_sale_ids IS 'Mapping of sale/order IDs in external systems';
COMMENT ON COLUMN sales.plugin_sync_status IS 'Sync status for accounting/e-commerce plugins';

-- ============================================================================
-- INVOICES TABLE (if exists)
-- ============================================================================

DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'invoices') THEN
        ALTER TABLE invoices
        ADD COLUMN IF NOT EXISTS plugin_invoice_id VARCHAR(255),
        ADD COLUMN IF NOT EXISTS plugin_key VARCHAR(100);

        CREATE INDEX IF NOT EXISTS idx_invoices_plugin_invoice_id ON invoices(plugin_invoice_id);

        COMMENT ON COLUMN invoices.plugin_invoice_id IS 'External invoice ID from accounting plugin';
        COMMENT ON COLUMN invoices.plugin_key IS 'Plugin that created this invoice';
    END IF;
END$$;

-- ============================================================================
-- HELPER FUNCTIONS FOR PLUGIN DATA
-- ============================================================================

-- Get customer ID for a specific plugin
CREATE OR REPLACE FUNCTION get_customer_plugin_id(
    p_customer_id UUID,
    p_plugin_key VARCHAR
) RETURNS VARCHAR AS $$
DECLARE
    v_plugin_ids JSONB;
    v_external_id VARCHAR;
BEGIN
    SELECT plugin_customer_ids INTO v_plugin_ids
    FROM customers
    WHERE id = p_customer_id;

    IF v_plugin_ids IS NULL THEN
        RETURN NULL;
    END IF;

    v_external_id := v_plugin_ids->>p_plugin_key;
    RETURN v_external_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- Set customer ID for a specific plugin
CREATE OR REPLACE FUNCTION set_customer_plugin_id(
    p_customer_id UUID,
    p_plugin_key VARCHAR,
    p_external_id VARCHAR
) RETURNS VOID AS $$
BEGIN
    UPDATE customers
    SET plugin_customer_ids = COALESCE(plugin_customer_ids, '{}'::JSONB) ||
        jsonb_build_object(p_plugin_key, p_external_id)
    WHERE id = p_customer_id;
END;
$$ LANGUAGE plpgsql;

-- Get product ID for a specific plugin
CREATE OR REPLACE FUNCTION get_product_plugin_id(
    p_product_id UUID,
    p_plugin_key VARCHAR
) RETURNS VARCHAR AS $$
DECLARE
    v_plugin_ids JSONB;
    v_external_id VARCHAR;
BEGIN
    SELECT plugin_product_ids INTO v_plugin_ids
    FROM products
    WHERE id = p_product_id;

    IF v_plugin_ids IS NULL THEN
        RETURN NULL;
    END IF;

    v_external_id := v_plugin_ids->>p_plugin_key;
    RETURN v_external_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- Set product ID for a specific plugin
CREATE OR REPLACE FUNCTION set_product_plugin_id(
    p_product_id UUID,
    p_plugin_key VARCHAR,
    p_external_id VARCHAR
) RETURNS VOID AS $$
BEGIN
    UPDATE products
    SET plugin_product_ids = COALESCE(plugin_product_ids, '{}'::JSONB) ||
        jsonb_build_object(p_plugin_key, p_external_id)
    WHERE id = p_product_id;
END;
$$ LANGUAGE plpgsql;

-- Update plugin sync status
CREATE OR REPLACE FUNCTION update_product_sync_status(
    p_product_id UUID,
    p_plugin_key VARCHAR,
    p_status VARCHAR,
    p_error TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    UPDATE products
    SET plugin_sync_status = COALESCE(plugin_sync_status, '{}'::JSONB) ||
        jsonb_build_object(
            p_plugin_key,
            jsonb_build_object(
                'last_synced_at', NOW(),
                'status', p_status,
                'error', p_error
            )
        )
    WHERE id = p_product_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- EXAMPLE USAGE
-- ============================================================================

-- Example 1: Link customer to Shopify
-- SELECT set_customer_plugin_id(
--     'customer-uuid-here',
--     'ecommerce_shopify',
--     'shopify_customer_123456'
-- );

-- Example 2: Get customer's QuickBooks ID
-- SELECT get_customer_plugin_id(
--     'customer-uuid-here',
--     'accounting_quickbooks'
-- );

-- Example 3: Update product sync status
-- SELECT update_product_sync_status(
--     'product-uuid-here',
--     'ecommerce_shopify',
--     'success',
--     NULL
-- );
