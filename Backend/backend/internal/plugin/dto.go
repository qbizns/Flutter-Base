package plugin

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
)

// MarketplacePluginResponse represents a marketplace plugin
type MarketplacePluginResponse struct {
	ID                   uuid.UUID       `json:"id"`
	PluginKey            string          `json:"plugin_key"`
	PluginName           string          `json:"plugin_name"`
	PluginSlug           string          `json:"plugin_slug"`
	Category             string          `json:"category"`
	Subcategory          *string         `json:"subcategory,omitempty"`
	ShortDescription     string          `json:"short_description"`
	LongDescription      *string         `json:"long_description,omitempty"`
	IconURL              *string         `json:"icon_url,omitempty"`
	BannerURL            *string         `json:"banner_url,omitempty"`
	Version              string          `json:"version"`
	ManifestURL          string          `json:"manifest_url"`
	RequiredPermissions  []string        `json:"required_permissions"`
	OptionalPermissions  []string        `json:"optional_permissions"`
	WebhookEvents        []string        `json:"webhook_events"`
	PricingModel         string          `json:"pricing_model"`
	BasePrice            float64         `json:"base_price"`
	Currency             string          `json:"currency"`
	TrialDays            int             `json:"trial_days"`
	Status               string          `json:"status"`
	IsVerified           bool            `json:"is_verified"`
	IsFeatured           bool            `json:"is_featured"`
	RatingAverage        *float64        `json:"rating_average,omitempty"`
	RatingCount          int             `json:"rating_count"`
	InstallCount         int             `json:"install_count"`
	ActiveInstallCount   int             `json:"active_install_count"`
	CreatedAt            time.Time       `json:"created_at"`
	UpdatedAt            time.Time       `json:"updated_at"`
	PublishedAt          *time.Time      `json:"published_at,omitempty"`
}

// OrganizationPluginResponse represents an installed plugin
type OrganizationPluginResponse struct {
	ID                   uuid.UUID                  `json:"id"`
	OrganizationID       uuid.UUID                  `json:"organization_id"`
	Plugin               *MarketplacePluginResponse `json:"plugin"`
	Status               string                     `json:"status"`
	IsEnabled            bool                       `json:"is_enabled"`
	Config               json.RawMessage            `json:"config"`
	GrantedPermissions   []string                   `json:"granted_permissions"`
	SubscriptionStatus   *string                    `json:"subscription_status,omitempty"`
	SubscriptionPlan     *string                    `json:"subscription_plan,omitempty"`
	TrialEndsAt          *time.Time                 `json:"trial_ends_at,omitempty"`
	SubscriptionStartedAt *time.Time                `json:"subscription_started_at,omitempty"`
	LastSyncAt           *time.Time                 `json:"last_sync_at,omitempty"`
	SyncFrequency        *string                    `json:"sync_frequency,omitempty"`
	SyncStatus           *string                    `json:"sync_status,omitempty"`
	HealthStatus         string                     `json:"health_status"`
	LastHealthCheckAt    *time.Time                 `json:"last_health_check_at,omitempty"`
	InstalledAt          time.Time                  `json:"installed_at"`
	InstalledBy          *uuid.UUID                 `json:"installed_by,omitempty"`
}

// InstallPluginRequest represents a request to install a plugin
type InstallPluginRequest struct {
	PluginKey string          `json:"plugin_key" validate:"required"`
	Config    json.RawMessage `json:"config"`
}

// Validate validates the install request
func (r *InstallPluginRequest) Validate() error {
	if r.PluginKey == "" {
		return fmt.Errorf("plugin_key is required")
	}
	return nil
}

// UpdatePluginConfigRequest represents a request to update plugin config
type UpdatePluginConfigRequest struct {
	Config    json.RawMessage `json:"config"`
	IsEnabled *bool           `json:"is_enabled,omitempty"`
}

// Validate validates the update config request
func (r *UpdatePluginConfigRequest) Validate() error {
	if r.Config == nil && r.IsEnabled == nil {
		return fmt.Errorf("at least one field must be provided for update")
	}
	return nil
}

// ExecutePluginRequest represents a request to execute a plugin action
type ExecutePluginRequest struct {
	Action string          `json:"action" validate:"required"`
	Data   json.RawMessage `json:"data"`
}

// Validate validates the execute request
func (r *ExecutePluginRequest) Validate() error {
	if r.Action == "" {
		return fmt.Errorf("action is required")
	}
	return nil
}

// ExecutePluginResponse represents the result of plugin execution
type ExecutePluginResponse struct {
	Success bool            `json:"success"`
	Data    json.RawMessage `json:"data,omitempty"`
	Error   *string         `json:"error,omitempty"`
}

// PluginEventResponse represents a plugin event log
type PluginEventResponse struct {
	ID                   uuid.UUID       `json:"id"`
	OrganizationPluginID uuid.UUID       `json:"organization_plugin_id"`
	OrganizationID       uuid.UUID       `json:"organization_id"`
	EventType            string          `json:"event_type"`
	EventName            *string         `json:"event_name,omitempty"`
	EventData            json.RawMessage `json:"event_data"`
	Status               string          `json:"status"`
	ErrorMessage         *string         `json:"error_message,omitempty"`
	ErrorCode            *string         `json:"error_code,omitempty"`
	DurationMs           *int            `json:"duration_ms,omitempty"`
	CreatedAt            time.Time       `json:"created_at"`
}

// PluginManifest represents the structure of a plugin manifest file
type PluginManifest struct {
	PluginKey   string                       `json:"plugin_key"`
	Version     string                       `json:"version"`
	APIVersion  string                       `json:"api_version"`
	Actions     map[string]string            `json:"actions"` // action name -> endpoint URL
	Webhooks    map[string]string            `json:"webhooks"`
	Permissions []string                     `json:"permissions"`
	ConfigSchema json.RawMessage             `json:"config_schema"`
}

// Pagination represents pagination information
type Pagination struct {
	Page       int  `json:"page"`
	Limit      int  `json:"limit"`
	Total      int  `json:"total"`
	TotalPages int  `json:"total_pages"`
	HasNext    bool `json:"has_next"`
	HasPrev    bool `json:"has_prev"`
}

// MarketplacePluginListResponse represents a paginated list of marketplace plugins
type MarketplacePluginListResponse struct {
	Items      []*MarketplacePluginResponse `json:"items"`
	Pagination Pagination                   `json:"pagination"`
}

// OrganizationPluginListResponse represents a paginated list of installed plugins
type OrganizationPluginListResponse struct {
	Items      []*OrganizationPluginResponse `json:"items"`
	Pagination Pagination                    `json:"pagination"`
}

// PluginEventListResponse represents a paginated list of plugin events
type PluginEventListResponse struct {
	Items      []*PluginEventResponse `json:"items"`
	Pagination Pagination             `json:"pagination"`
}
