package plugin

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

// Repository handles plugin data access
type Repository struct {
	db *sql.DB
}

// NewRepository creates a new plugin repository
func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

// ListMarketplacePlugins returns all available marketplace plugins
func (r *Repository) ListMarketplacePlugins(ctx context.Context, filters *MarketplaceFilters) ([]*MarketplacePluginDTO, error) {
	query := `
		SELECT
			id, plugin_key, plugin_name, plugin_slug, category, subcategory,
			short_description, long_description, features, icon_url, banner_url,
			version, pricing_model, base_price, currency, trial_days,
			rating_average, rating_count, install_count, active_install_count,
			is_verified, is_featured, required_permissions, optional_permissions,
			config_schema, developer_name, support_email, documentation_url,
			created_at, updated_at
		FROM marketplace_plugins
		WHERE status = 'approved'
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($1::VARCHAR IS NULL OR category = $1)
			AND ($2::VARCHAR IS NULL OR
				plugin_name ILIKE '%' || $2 || '%' OR
				short_description ILIKE '%' || $2 || '%')
			AND ($3::NUMERIC IS NULL OR rating_average >= $3)
			AND ($4::BOOLEAN IS NULL OR is_featured = $4)
			AND ($5::BOOLEAN IS NULL OR is_verified = $5)
		ORDER BY
			CASE WHEN is_featured = TRUE THEN 0 ELSE 1 END,
			rating_average DESC,
			install_count DESC
		LIMIT $6 OFFSET $7
	`

	limit := 50
	offset := 0
	if filters != nil {
		if filters.Limit > 0 {
			limit = filters.Limit
		}
		offset = filters.Offset
	}

	var category, search *string
	var minRating *float64
	var isFeatured, isVerified *bool

	if filters != nil {
		if filters.Category != "" {
			category = &filters.Category
		}
		if filters.Search != "" {
			search = &filters.Search
		}
		if filters.MinRating > 0 {
			minRating = &filters.MinRating
		}
		isFeatured = filters.IsFeatured
		isVerified = filters.IsVerified
	}

	rows, err := r.db.QueryContext(ctx, query,
		category, search, minRating, isFeatured, isVerified, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to query plugins: %w", err)
	}
	defer rows.Close()

	var plugins []*MarketplacePluginDTO
	for rows.Next() {
		plugin := &MarketplacePluginDTO{}
		var (
			featuresJSON          []byte
			configSchemaJSON      []byte
			subcategory           sql.NullString
			longDescription       sql.NullString
			iconURL               sql.NullString
			bannerURL             sql.NullString
			developerName         sql.NullString
			supportEmail          sql.NullString
			documentationURL      sql.NullString
			ratingAverage         sql.NullFloat64
			requiredPermissions   pq.StringArray
			optionalPermissions   pq.StringArray
		)

		err := rows.Scan(
			&plugin.ID, &plugin.PluginKey, &plugin.PluginName, &plugin.PluginSlug,
			&plugin.Category, &subcategory, &plugin.ShortDescription, &longDescription,
			&featuresJSON, &iconURL, &bannerURL, &plugin.Version,
			&plugin.PricingModel, &plugin.BasePrice, &plugin.Currency, &plugin.TrialDays,
			&ratingAverage, &plugin.RatingCount, &plugin.InstallCount, &plugin.ActiveInstallCount,
			&plugin.IsVerified, &plugin.IsFeatured, &requiredPermissions, &optionalPermissions,
			&configSchemaJSON, &developerName, &supportEmail, &documentationURL,
			&plugin.CreatedAt, &plugin.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan plugin: %w", err)
		}

		// Handle nullable fields
		if subcategory.Valid {
			plugin.Subcategory = subcategory.String
		}
		if longDescription.Valid {
			plugin.LongDescription = longDescription.String
		}
		if iconURL.Valid {
			plugin.IconURL = iconURL.String
		}
		if bannerURL.Valid {
			plugin.BannerURL = bannerURL.String
		}
		if developerName.Valid {
			plugin.DeveloperName = developerName.String
		}
		if supportEmail.Valid {
			plugin.SupportEmail = supportEmail.String
		}
		if documentationURL.Valid {
			plugin.DocumentationURL = documentationURL.String
		}
		if ratingAverage.Valid {
			plugin.RatingAverage = ratingAverage.Float64
		}

		// Parse JSONB fields
		if len(featuresJSON) > 0 {
			json.Unmarshal(featuresJSON, &plugin.Features)
		}
		if len(configSchemaJSON) > 0 {
			json.Unmarshal(configSchemaJSON, &plugin.ConfigSchema)
		}

		plugin.RequiredPermissions = requiredPermissions
		plugin.OptionalPermissions = optionalPermissions

		plugins = append(plugins, plugin)
	}

	return plugins, nil
}

// GetMarketplacePluginByKey returns a plugin by its key
func (r *Repository) GetMarketplacePluginByKey(ctx context.Context, pluginKey string) (*MarketplacePluginDTO, error) {
	query := `
		SELECT
			id, plugin_key, plugin_name, plugin_slug, category,
			short_description, version, manifest_url, required_permissions,
			pricing_model, base_price, config_schema
		FROM marketplace_plugins
		WHERE plugin_key = $1
			AND status = 'approved'
			AND is_active = TRUE
	`

	plugin := &MarketplacePluginDTO{}
	var (
		manifestURL         string
		configSchemaJSON    []byte
		requiredPermissions pq.StringArray
	)

	err := r.db.QueryRowContext(ctx, query, pluginKey).Scan(
		&plugin.ID, &plugin.PluginKey, &plugin.PluginName, &plugin.PluginSlug,
		&plugin.Category, &plugin.ShortDescription, &plugin.Version,
		&manifestURL, &requiredPermissions, &plugin.PricingModel,
		&plugin.BasePrice, &configSchemaJSON,
	)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("plugin not found: %s", pluginKey)
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get plugin: %w", err)
	}

	plugin.RequiredPermissions = requiredPermissions
	if len(configSchemaJSON) > 0 {
		json.Unmarshal(configSchemaJSON, &plugin.ConfigSchema)
	}

	return plugin, nil
}

// GetInstalledPlugins returns all plugins installed by an organization
func (r *Repository) GetInstalledPlugins(ctx context.Context, orgID uuid.UUID) ([]*OrganizationPluginDTO, error) {
	query := `
		SELECT
			op.id, op.organization_id, op.status, op.is_enabled,
			op.config, op.granted_permissions, op.subscription_status,
			op.trial_ends_at, op.subscription_ends_at, op.next_billing_date,
			op.last_sync_at, op.sync_status, op.health_status, op.health_message,
			op.installed_at, op.installed_by,
			mp.id, mp.plugin_key, mp.plugin_name, mp.category,
			mp.short_description, mp.icon_url, mp.version
		FROM organization_plugins op
		JOIN marketplace_plugins mp ON op.plugin_id = mp.id
		WHERE op.organization_id = $1
			AND op.uninstalled_at IS NULL
		ORDER BY op.installed_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, orgID)
	if err != nil {
		return nil, fmt.Errorf("failed to query installed plugins: %w", err)
	}
	defer rows.Close()

	var plugins []*OrganizationPluginDTO
	for rows.Next() {
		orgPlugin := &OrganizationPluginDTO{}
		marketplacePlugin := &MarketplacePluginDTO{}

		var (
			configJSON          []byte
			grantedPermissions  pq.StringArray
			subscriptionStatus  sql.NullString
			trialEndsAt         sql.NullTime
			subscriptionEndsAt  sql.NullTime
			nextBillingDate     sql.NullTime
			lastSyncAt          sql.NullTime
			syncStatus          sql.NullString
			healthMessage       sql.NullString
			installedBy         uuid.NullUUID
			iconURL             sql.NullString
		)

		err := rows.Scan(
			&orgPlugin.ID, &orgPlugin.OrganizationID, &orgPlugin.Status, &orgPlugin.IsEnabled,
			&configJSON, &grantedPermissions, &subscriptionStatus,
			&trialEndsAt, &subscriptionEndsAt, &nextBillingDate,
			&lastSyncAt, &syncStatus, &orgPlugin.HealthStatus, &healthMessage,
			&orgPlugin.InstalledAt, &installedBy,
			&marketplacePlugin.ID, &marketplacePlugin.PluginKey, &marketplacePlugin.PluginName,
			&marketplacePlugin.Category, &marketplacePlugin.ShortDescription,
			&iconURL, &marketplacePlugin.Version,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan installed plugin: %w", err)
		}

		// Parse config
		if len(configJSON) > 0 {
			json.Unmarshal(configJSON, &orgPlugin.Config)
		}

		// Handle nullable fields
		orgPlugin.GrantedPermissions = grantedPermissions
		if subscriptionStatus.Valid {
			orgPlugin.SubscriptionStatus = subscriptionStatus.String
		}
		if trialEndsAt.Valid {
			orgPlugin.TrialEndsAt = &trialEndsAt.Time
		}
		if subscriptionEndsAt.Valid {
			orgPlugin.SubscriptionEndsAt = &subscriptionEndsAt.Time
		}
		if nextBillingDate.Valid {
			orgPlugin.NextBillingDate = &nextBillingDate.Time
		}
		if lastSyncAt.Valid {
			orgPlugin.LastSyncAt = &lastSyncAt.Time
		}
		if syncStatus.Valid {
			orgPlugin.SyncStatus = syncStatus.String
		}
		if healthMessage.Valid {
			orgPlugin.HealthMessage = healthMessage.String
		}
		if installedBy.Valid {
			orgPlugin.InstalledBy = installedBy.UUID
		}
		if iconURL.Valid {
			marketplacePlugin.IconURL = iconURL.String
		}

		orgPlugin.Plugin = marketplacePlugin
		plugins = append(plugins, orgPlugin)
	}

	return plugins, nil
}

// CreateOrganizationPlugin installs a plugin for an organization
func (r *Repository) CreateOrganizationPlugin(ctx context.Context, orgID, pluginID, userID uuid.UUID, config map[string]interface{}) (*OrganizationPluginDTO, error) {
	configJSON, _ := json.Marshal(config)

	query := `
		INSERT INTO organization_plugins (
			organization_id, plugin_id, status, is_enabled, config, installed_by
		) VALUES ($1, $2, 'active', TRUE, $3, $4)
		RETURNING id, installed_at
	`

	var pluginInstallID uuid.UUID
	var installedAt time.Time

	err := r.db.QueryRowContext(ctx, query, orgID, pluginID, configJSON, userID).Scan(&pluginInstallID, &installedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to install plugin: %w", err)
	}

	// Update install count
	_, err = r.db.ExecContext(ctx, `
		UPDATE marketplace_plugins
		SET install_count = install_count + 1,
			active_install_count = active_install_count + 1
		WHERE id = $1
	`, pluginID)
	if err != nil {
		return nil, fmt.Errorf("failed to update install count: %w", err)
	}

	// Return the installed plugin
	return &OrganizationPluginDTO{
		ID:             pluginInstallID,
		OrganizationID: orgID,
		Status:         "active",
		IsEnabled:      true,
		Config:         config,
		HealthStatus:   "healthy",
		InstalledAt:    installedAt,
		InstalledBy:    userID,
	}, nil
}

// UpdatePluginConfig updates a plugin's configuration
func (r *Repository) UpdatePluginConfig(ctx context.Context, pluginInstallID uuid.UUID, config map[string]interface{}, isEnabled *bool) error {
	configJSON, _ := json.Marshal(config)

	query := `
		UPDATE organization_plugins
		SET config = $1,
			is_enabled = COALESCE($2, is_enabled)
		WHERE id = $3
	`

	_, err := r.db.ExecContext(ctx, query, configJSON, isEnabled, pluginInstallID)
	if err != nil {
		return fmt.Errorf("failed to update plugin config: %w", err)
	}

	return nil
}

// UninstallPlugin uninstalls a plugin
func (r *Repository) UninstallPlugin(ctx context.Context, pluginInstallID, userID uuid.UUID) error {
	query := `
		UPDATE organization_plugins
		SET status = 'uninstalled',
			is_enabled = FALSE,
			uninstalled_at = NOW(),
			uninstalled_by = $1
		WHERE id = $2
	`

	_, err := r.db.ExecContext(ctx, query, userID, pluginInstallID)
	if err != nil {
		return fmt.Errorf("failed to uninstall plugin: %w", err)
	}

	return nil
}

// GetOrganizationPluginByKey gets an installed plugin by key
func (r *Repository) GetOrganizationPluginByKey(ctx context.Context, orgID uuid.UUID, pluginKey string) (*OrganizationPluginDTO, error) {
	query := `
		SELECT
			op.id, op.organization_id, op.status, op.is_enabled,
			op.config, mp.id, mp.plugin_key, mp.manifest_url
		FROM organization_plugins op
		JOIN marketplace_plugins mp ON op.plugin_id = mp.id
		WHERE op.organization_id = $1
			AND mp.plugin_key = $2
			AND op.status = 'active'
			AND op.is_enabled = TRUE
	`

	orgPlugin := &OrganizationPluginDTO{}
	marketplacePlugin := &MarketplacePluginDTO{}
	var configJSON []byte
	var manifestURL string

	err := r.db.QueryRowContext(ctx, query, orgID, pluginKey).Scan(
		&orgPlugin.ID, &orgPlugin.OrganizationID, &orgPlugin.Status, &orgPlugin.IsEnabled,
		&configJSON, &marketplacePlugin.ID, &marketplacePlugin.PluginKey, &manifestURL,
	)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("plugin not installed or not active")
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get installed plugin: %w", err)
	}

	if len(configJSON) > 0 {
		json.Unmarshal(configJSON, &orgPlugin.Config)
	}

	orgPlugin.Plugin = marketplacePlugin
	return orgPlugin, nil
}

// LogPluginEvent creates a plugin event log entry
func (r *Repository) LogPluginEvent(ctx context.Context, orgPluginID, orgID uuid.UUID, eventType string, eventData map[string]interface{}) error {
	eventDataJSON, _ := json.Marshal(eventData)

	query := `
		INSERT INTO plugin_events (
			organization_plugin_id, organization_id, event_type, event_data, status
		) VALUES ($1, $2, $3, $4, 'success')
	`

	_, err := r.db.ExecContext(ctx, query, orgPluginID, orgID, eventType, eventDataJSON)
	return err
}
