package plugin

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/google/uuid"
)

type Service struct {
	repo       Repository
	httpClient *http.Client
}

func NewService(repo Repository) *Service {
	return &Service{
		repo: repo,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// ListMarketplacePlugins returns all available plugins in the marketplace
func (s *Service) ListMarketplacePlugins(ctx context.Context, category *string, page, limit int) (*MarketplacePluginListResponse, error) {
	offset := (page - 1) * limit

	plugins, total, err := s.repo.ListMarketplacePlugins(ctx, category, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list marketplace plugins: %w", err)
	}

	totalPages := (total + limit - 1) / limit

	return &MarketplacePluginListResponse{
		Items: plugins,
		Pagination: Pagination{
			Page:       page,
			Limit:      limit,
			Total:      total,
			TotalPages: totalPages,
			HasNext:    page < totalPages,
			HasPrev:    page > 1,
		},
	}, nil
}

// GetMarketplacePlugin returns a single marketplace plugin by ID
func (s *Service) GetMarketplacePlugin(ctx context.Context, pluginID uuid.UUID) (*MarketplacePluginResponse, error) {
	return s.repo.GetMarketplacePlugin(ctx, pluginID)
}

// GetMarketplacePluginByKey returns a single marketplace plugin by key
func (s *Service) GetMarketplacePluginByKey(ctx context.Context, pluginKey string) (*MarketplacePluginResponse, error) {
	return s.repo.GetMarketplacePluginByKey(ctx, pluginKey)
}

// ListInstalledPlugins returns all plugins installed for an organization
func (s *Service) ListInstalledPlugins(ctx context.Context, orgID uuid.UUID, page, limit int) (*OrganizationPluginListResponse, error) {
	offset := (page - 1) * limit

	plugins, total, err := s.repo.ListInstalledPlugins(ctx, orgID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list installed plugins: %w", err)
	}

	totalPages := (total + limit - 1) / limit

	return &OrganizationPluginListResponse{
		Items: plugins,
		Pagination: Pagination{
			Page:       page,
			Limit:      limit,
			Total:      total,
			TotalPages: totalPages,
			HasNext:    page < totalPages,
			HasPrev:    page > 1,
		},
	}, nil
}

// GetInstalledPlugin returns a single installed plugin
func (s *Service) GetInstalledPlugin(ctx context.Context, orgID, pluginID uuid.UUID) (*OrganizationPluginResponse, error) {
	plugin, err := s.repo.GetInstalledPlugin(ctx, orgID, pluginID)
	if err != nil {
		return nil, fmt.Errorf("failed to get installed plugin: %w", err)
	}

	// Check ownership
	if plugin.OrganizationID != orgID {
		return nil, fmt.Errorf("plugin not found")
	}

	return plugin, nil
}

// InstallPlugin installs a plugin for an organization
func (s *Service) InstallPlugin(ctx context.Context, orgID uuid.UUID, req *InstallPluginRequest, userID uuid.UUID) (*OrganizationPluginResponse, error) {
	// 1. Get plugin from marketplace
	marketplacePlugin, err := s.repo.GetMarketplacePluginByKey(ctx, req.PluginKey)
	if err != nil {
		return nil, fmt.Errorf("plugin not found in marketplace: %w", err)
	}

	// 2. Check if plugin is approved and active
	if marketplacePlugin.Status != "approved" || !marketplacePlugin.IsActive {
		return nil, fmt.Errorf("plugin is not available for installation")
	}

	// 3. Check if already installed
	existing, err := s.repo.GetInstalledPluginByKey(ctx, orgID, req.PluginKey)
	if err == nil && existing != nil {
		return nil, fmt.Errorf("plugin already installed")
	}

	// 4. Validate config against schema
	if marketplacePlugin.ConfigSchema != nil {
		if err := s.validateConfig(marketplacePlugin.ConfigSchema, req.Config); err != nil {
			return nil, fmt.Errorf("invalid config: %w", err)
		}
	}

	// 5. Create organization plugin record
	orgPlugin := &OrganizationPlugin{
		OrganizationID:     orgID,
		PluginID:           marketplacePlugin.ID,
		Status:             "active",
		IsEnabled:          true,
		Config:             req.Config,
		GrantedPermissions: marketplacePlugin.RequiredPermissions,
		HealthStatus:       "healthy",
		InstalledBy:        &userID,
	}

	// 6. Insert into database
	if err := s.repo.CreateOrganizationPlugin(ctx, orgPlugin); err != nil {
		return nil, fmt.Errorf("failed to install plugin: %w", err)
	}

	// 7. Log installation event
	s.logPluginEvent(ctx, orgPlugin.ID, orgID, "plugin_installed", nil, "success")

	// 8. Return installed plugin with marketplace details
	return s.repo.GetInstalledPlugin(ctx, orgID, orgPlugin.ID)
}

// UninstallPlugin removes a plugin from an organization
func (s *Service) UninstallPlugin(ctx context.Context, orgID, pluginID uuid.UUID, userID uuid.UUID) error {
	// 1. Get plugin
	plugin, err := s.repo.GetInstalledPlugin(ctx, orgID, pluginID)
	if err != nil {
		return fmt.Errorf("plugin not found: %w", err)
	}

	// 2. Check ownership
	if plugin.OrganizationID != orgID {
		return fmt.Errorf("plugin not found")
	}

	// 3. Soft delete (set uninstalled_at timestamp)
	if err := s.repo.UninstallPlugin(ctx, pluginID, userID); err != nil {
		return fmt.Errorf("failed to uninstall plugin: %w", err)
	}

	// 4. Log event
	s.logPluginEvent(ctx, pluginID, orgID, "plugin_uninstalled", nil, "success")

	return nil
}

// UpdatePluginConfig updates plugin configuration
func (s *Service) UpdatePluginConfig(ctx context.Context, orgID, pluginID uuid.UUID, req *UpdatePluginConfigRequest, userID uuid.UUID) (*OrganizationPluginResponse, error) {
	// 1. Get plugin
	plugin, err := s.repo.GetInstalledPlugin(ctx, orgID, pluginID)
	if err != nil {
		return nil, fmt.Errorf("plugin not found: %w", err)
	}

	// 2. Check ownership
	if plugin.OrganizationID != orgID {
		return nil, fmt.Errorf("plugin not found")
	}

	// 3. Validate config if provided
	if req.Config != nil && plugin.Plugin != nil && plugin.Plugin.ConfigSchema != nil {
		if err := s.validateConfig(plugin.Plugin.ConfigSchema, req.Config); err != nil {
			return nil, fmt.Errorf("invalid config: %w", err)
		}
	}

	// 4. Update plugin
	if err := s.repo.UpdatePluginConfig(ctx, pluginID, req.Config, req.IsEnabled, userID); err != nil {
		return nil, fmt.Errorf("failed to update plugin config: %w", err)
	}

	// 5. Log event
	s.logPluginEvent(ctx, pluginID, orgID, "plugin_config_updated", nil, "success")

	// 6. Return updated plugin
	return s.repo.GetInstalledPlugin(ctx, orgID, pluginID)
}

// ExecutePlugin executes a plugin action
func (s *Service) ExecutePlugin(ctx context.Context, orgID uuid.UUID, pluginKey string, req *ExecutePluginRequest) (*ExecutePluginResponse, error) {
	startTime := time.Now()

	// 1. Get installed plugin
	plugin, err := s.repo.GetInstalledPluginByKey(ctx, orgID, pluginKey)
	if err != nil {
		return &ExecutePluginResponse{
			Success: false,
			Error:   stringPtr("plugin not installed"),
		}, nil
	}

	// 2. Check if plugin is active and enabled
	if plugin.Status != "active" || !plugin.IsEnabled {
		return &ExecutePluginResponse{
			Success: false,
			Error:   stringPtr("plugin is not active"),
		}, nil
	}

	// 3. Fetch plugin manifest
	manifest, err := s.fetchPluginManifest(ctx, plugin.Plugin.ManifestURL)
	if err != nil {
		s.logPluginEvent(ctx, plugin.ID, orgID, "execution_failed", map[string]interface{}{
			"action": req.Action,
			"error":  err.Error(),
		}, "error")
		return &ExecutePluginResponse{
			Success: false,
			Error:   stringPtr(fmt.Sprintf("failed to fetch manifest: %v", err)),
		}, nil
	}

	// 4. Find action endpoint
	actionEndpoint, ok := manifest.Actions[req.Action]
	if !ok {
		s.logPluginEvent(ctx, plugin.ID, orgID, "execution_failed", map[string]interface{}{
			"action": req.Action,
			"error":  "action not found",
		}, "error")
		return &ExecutePluginResponse{
			Success: false,
			Error:   stringPtr(fmt.Sprintf("action not supported: %s", req.Action)),
		}, nil
	}

	// 5. Execute HTTP request to plugin endpoint
	result, err := s.executeHTTPRequest(ctx, actionEndpoint, req.Data, plugin.Config)
	if err != nil {
		duration := int(time.Since(startTime).Milliseconds())
		s.logPluginEvent(ctx, plugin.ID, orgID, "execution_failed", map[string]interface{}{
			"action": req.Action,
			"error":  err.Error(),
		}, "error")

		// Update health status
		s.repo.UpdatePluginHealth(ctx, plugin.ID, "degraded", err.Error())

		return &ExecutePluginResponse{
			Success: false,
			Error:   stringPtr(err.Error()),
		}, nil
	}

	// 6. Log success
	duration := int(time.Since(startTime).Milliseconds())
	eventData := map[string]interface{}{
		"action": req.Action,
		"duration_ms": duration,
	}
	s.logPluginEventWithDuration(ctx, plugin.ID, orgID, "execution_success", eventData, "success", duration)

	// 7. Update health status and last used
	s.repo.UpdatePluginHealth(ctx, plugin.ID, "healthy", "")
	s.repo.UpdatePluginLastUsed(ctx, plugin.ID)

	return &ExecutePluginResponse{
		Success: true,
		Data:    result,
	}, nil
}

// fetchPluginManifest fetches plugin manifest from URL
func (s *Service) fetchPluginManifest(ctx context.Context, manifestURL string) (*PluginManifest, error) {
	req, err := http.NewRequestWithContext(ctx, "GET", manifestURL, nil)
	if err != nil {
		return nil, err
	}

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("manifest fetch failed with status: %d", resp.StatusCode)
	}

	var manifest PluginManifest
	if err := json.NewDecoder(resp.Body).Decode(&manifest); err != nil {
		return nil, err
	}

	return &manifest, nil
}

// executeHTTPRequest executes HTTP request to plugin endpoint
func (s *Service) executeHTTPRequest(ctx context.Context, endpoint string, data, config json.RawMessage) (json.RawMessage, error) {
	// Merge data with config
	payload := map[string]json.RawMessage{
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

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("plugin returned status %d: %s", resp.StatusCode, string(bodyBytes))
	}

	result, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return json.RawMessage(result), nil
}

// validateConfig validates config against JSON schema
func (s *Service) validateConfig(schema, config json.RawMessage) error {
	// TODO: Implement JSON schema validation
	// Use library like https://github.com/xeipuuv/gojsonschema
	// For now, just check if it's valid JSON
	if config != nil && len(config) > 0 {
		var temp interface{}
		if err := json.Unmarshal(config, &temp); err != nil {
			return fmt.Errorf("invalid JSON: %w", err)
		}
	}
	return nil
}

// logPluginEvent logs a plugin event
func (s *Service) logPluginEvent(ctx context.Context, pluginID, orgID uuid.UUID, eventType string, eventData map[string]interface{}, status string) {
	var jsonData json.RawMessage
	if eventData != nil {
		data, _ := json.Marshal(eventData)
		jsonData = json.RawMessage(data)
	}

	event := &PluginEvent{
		OrganizationPluginID: pluginID,
		OrganizationID:       orgID,
		EventType:            eventType,
		EventData:            jsonData,
		Status:               status,
	}

	_ = s.repo.CreatePluginEvent(ctx, event)
}

// logPluginEventWithDuration logs a plugin event with duration
func (s *Service) logPluginEventWithDuration(ctx context.Context, pluginID, orgID uuid.UUID, eventType string, eventData map[string]interface{}, status string, durationMs int) {
	var jsonData json.RawMessage
	if eventData != nil {
		data, _ := json.Marshal(eventData)
		jsonData = json.RawMessage(data)
	}

	event := &PluginEvent{
		OrganizationPluginID: pluginID,
		OrganizationID:       orgID,
		EventType:            eventType,
		EventData:            jsonData,
		Status:               status,
		DurationMs:           &durationMs,
	}

	_ = s.repo.CreatePluginEvent(ctx, event)
}

// Helper function
func stringPtr(s string) *string {
	return &s
}

// Domain models (used internally)
type OrganizationPlugin struct {
	ID                 uuid.UUID
	OrganizationID     uuid.UUID
	PluginID           uuid.UUID
	Status             string
	IsEnabled          bool
	Config             json.RawMessage
	GrantedPermissions []string
	HealthStatus       string
	InstalledBy        *uuid.UUID
}

type PluginEvent struct {
	ID                   uuid.UUID
	OrganizationPluginID uuid.UUID
	OrganizationID       uuid.UUID
	EventType            string
	EventData            json.RawMessage
	Status               string
	ErrorMessage         *string
	DurationMs           *int
}
