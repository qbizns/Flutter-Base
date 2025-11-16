package plugin

import (
	"time"

	"github.com/google/uuid"
)

// MarketplacePluginDTO represents a plugin in the marketplace
type MarketplacePluginDTO struct {
	ID                   uuid.UUID              `json:"id"`
	PluginKey            string                 `json:"plugin_key"`
	PluginName           string                 `json:"plugin_name"`
	PluginSlug           string                 `json:"plugin_slug"`
	Category             string                 `json:"category"`
	Subcategory          string                 `json:"subcategory,omitempty"`
	ShortDescription     string                 `json:"short_description"`
	LongDescription      string                 `json:"long_description,omitempty"`
	Features             []string               `json:"features,omitempty"`
	IconURL              string                 `json:"icon_url,omitempty"`
	BannerURL            string                 `json:"banner_url,omitempty"`
	Version              string                 `json:"version"`
	PricingModel         string                 `json:"pricing_model"`
	BasePrice            float64                `json:"base_price"`
	Currency             string                 `json:"currency"`
	TrialDays            int                    `json:"trial_days"`
	RatingAverage        float64                `json:"rating_average"`
	RatingCount          int                    `json:"rating_count"`
	InstallCount         int                    `json:"install_count"`
	ActiveInstallCount   int                    `json:"active_install_count"`
	IsVerified           bool                   `json:"is_verified"`
	IsFeatured           bool                   `json:"is_featured"`
	RequiredPermissions  []string               `json:"required_permissions"`
	OptionalPermissions  []string               `json:"optional_permissions,omitempty"`
	ConfigSchema         map[string]interface{} `json:"config_schema,omitempty"`
	DeveloperName        string                 `json:"developer_name,omitempty"`
	SupportEmail         string                 `json:"support_email,omitempty"`
	DocumentationURL     string                 `json:"documentation_url,omitempty"`
	CreatedAt            time.Time              `json:"created_at"`
	UpdatedAt            time.Time              `json:"updated_at"`
}

// OrganizationPluginDTO represents an installed plugin
type OrganizationPluginDTO struct {
	ID                  uuid.UUID              `json:"id"`
	OrganizationID      uuid.UUID              `json:"organization_id"`
	Plugin              *MarketplacePluginDTO  `json:"plugin"`
	Status              string                 `json:"status"`
	IsEnabled           bool                   `json:"is_enabled"`
	Config              map[string]interface{} `json:"config"`
	GrantedPermissions  []string               `json:"granted_permissions,omitempty"`
	SubscriptionStatus  string                 `json:"subscription_status,omitempty"`
	TrialEndsAt         *time.Time             `json:"trial_ends_at,omitempty"`
	SubscriptionEndsAt  *time.Time             `json:"subscription_ends_at,omitempty"`
	NextBillingDate     *time.Time             `json:"next_billing_date,omitempty"`
	LastSyncAt          *time.Time             `json:"last_sync_at,omitempty"`
	SyncStatus          string                 `json:"sync_status,omitempty"`
	HealthStatus        string                 `json:"health_status"`
	HealthMessage       string                 `json:"health_message,omitempty"`
	InstalledAt         time.Time              `json:"installed_at"`
	InstalledBy         uuid.UUID              `json:"installed_by,omitempty"`
}

// InstallPluginRequest represents a request to install a plugin
type InstallPluginRequest struct {
	PluginKey string                 `json:"plugin_key" validate:"required"`
	Config    map[string]interface{} `json:"config"`
}

// UpdatePluginConfigRequest represents a request to update plugin config
type UpdatePluginConfigRequest struct {
	Config    map[string]interface{} `json:"config" validate:"required"`
	IsEnabled *bool                  `json:"is_enabled,omitempty"`
}

// ExecutePluginRequest represents a request to execute a plugin action
type ExecutePluginRequest struct {
	Action string                 `json:"action" validate:"required"`
	Data   map[string]interface{} `json:"data"`
}

// ExecutePluginResponse represents the response from plugin execution
type ExecutePluginResponse struct {
	Success bool                   `json:"success"`
	Data    map[string]interface{} `json:"data,omitempty"`
	Error   string                 `json:"error,omitempty"`
}

// PluginEventDTO represents a plugin event log
type PluginEventDTO struct {
	ID                   uuid.UUID              `json:"id"`
	OrganizationPluginID uuid.UUID              `json:"organization_plugin_id"`
	OrganizationID       uuid.UUID              `json:"organization_id"`
	EventType            string                 `json:"event_type"`
	EventName            string                 `json:"event_name,omitempty"`
	EventData            map[string]interface{} `json:"event_data,omitempty"`
	Status               string                 `json:"status"`
	ErrorMessage         string                 `json:"error_message,omitempty"`
	DurationMs           int                    `json:"duration_ms,omitempty"`
	CreatedAt            time.Time              `json:"created_at"`
}

// PluginManifest represents the manifest structure from plugin's manifest.json
type PluginManifest struct {
	PluginKey string            `json:"plugin_key"`
	Version   string            `json:"version"`
	Actions   map[string]string `json:"actions"`   // action name -> endpoint URL
	Webhooks  map[string]string `json:"webhooks"`  // event name -> webhook URL
	Health    string            `json:"health"`    // health check endpoint
}

// PluginStatsDTO represents plugin statistics
type PluginStatsDTO struct {
	PluginID           uuid.UUID `json:"plugin_id"`
	InstallCount       int       `json:"install_count"`
	ActiveInstallCount int       `json:"active_install_count"`
	RatingAverage      float64   `json:"rating_average"`
	RatingCount        int       `json:"rating_count"`
	TotalEvents        int       `json:"total_events"`
	SuccessfulEvents   int       `json:"successful_events"`
	FailedEvents       int       `json:"failed_events"`
}

// MarketplaceFilters represents filters for marketplace search
type MarketplaceFilters struct {
	Category   string  `json:"category,omitempty"`
	Search     string  `json:"search,omitempty"`
	MinRating  float64 `json:"min_rating,omitempty"`
	IsFeatured *bool   `json:"is_featured,omitempty"`
	IsVerified *bool   `json:"is_verified,omitempty"`
	PriceMin   float64 `json:"price_min,omitempty"`
	PriceMax   float64 `json:"price_max,omitempty"`
	Limit      int     `json:"limit,omitempty"`
	Offset     int     `json:"offset,omitempty"`
}
