package plugin

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"
)

// Repository defines the interface for plugin data access
type Repository interface {
	// Marketplace Plugins
	ListMarketplacePlugins(ctx context.Context, category *string, limit, offset int) ([]*MarketplacePluginResponse, int, error)
	GetMarketplacePlugin(ctx context.Context, pluginID uuid.UUID) (*MarketplacePluginResponse, error)
	GetMarketplacePluginByKey(ctx context.Context, pluginKey string) (*MarketplacePluginResponse, error)

	// Organization Plugins
	ListInstalledPlugins(ctx context.Context, orgID uuid.UUID, limit, offset int) ([]*OrganizationPluginResponse, int, error)
	GetInstalledPlugin(ctx context.Context, orgID, pluginID uuid.UUID) (*OrganizationPluginResponse, error)
	GetInstalledPluginByKey(ctx context.Context, orgID uuid.UUID, pluginKey string) (*OrganizationPluginResponse, error)
	CreateOrganizationPlugin(ctx context.Context, plugin *OrganizationPlugin) error
	UpdatePluginConfig(ctx context.Context, pluginID uuid.UUID, config json.RawMessage, isEnabled *bool, userID uuid.UUID) error
	UninstallPlugin(ctx context.Context, pluginID, userID uuid.UUID) error
	UpdatePluginHealth(ctx context.Context, pluginID uuid.UUID, healthStatus, healthMessage string) error
	UpdatePluginLastUsed(ctx context.Context, pluginID uuid.UUID) error

	// Plugin Events
	CreatePluginEvent(ctx context.Context, event *PluginEvent) error
	ListPluginEvents(ctx context.Context, orgPluginID uuid.UUID, limit, offset int) ([]*PluginEventResponse, int, error)
}

// Note: The actual implementation (repository_impl.go) would contain the PostgreSQL queries
// For now, this interface defines the contract that the service depends on
