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

// Logger interface for logging
type Logger interface {
	Info(msg string, keysAndValues ...interface{})
	Error(msg string, keysAndValues ...interface{})
	Debug(msg string, keysAndValues ...interface{})
}

// Service handles plugin business logic
type Service struct {
	repo   *Repository
	logger Logger
	http   *http.Client
}

// NewService creates a new plugin service
func NewService(repo *Repository, logger Logger) *Service {
	return &Service{
		repo:   repo,
		logger: logger,
		http:   &http.Client{Timeout: 30 * time.Second},
	}
}

// ListMarketplacePlugins returns all available marketplace plugins
func (s *Service) ListMarketplacePlugins(ctx context.Context, filters *MarketplaceFilters) ([]*MarketplacePluginDTO, error) {
	return s.repo.ListMarketplacePlugins(ctx, filters)
}

// GetInstalledPlugins returns all plugins installed by an organization
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

	s.logger.Info("Installing plugin", "plugin_key", req.PluginKey, "org_id", orgID)

	// 2. Check if already installed
	existing, _ := s.repo.GetOrganizationPluginByKey(ctx, orgID, plugin.PluginKey)
	if existing != nil {
		return nil, fmt.Errorf("plugin already installed")
	}

	// 3. Validate config against schema
	if err := s.validateConfig(plugin.ConfigSchema, req.Config); err != nil {
		return nil, fmt.Errorf("invalid config: %w", err)
	}

	// 4. Check permissions
	// TODO: Verify user has permission to install plugins

	// 5. Install plugin
	orgPlugin, err := s.repo.CreateOrganizationPlugin(ctx, orgID, plugin.ID, userID, req.Config)
	if err != nil {
		return nil, fmt.Errorf("failed to install plugin: %w", err)
	}

	// 6. Log event
	s.repo.LogPluginEvent(ctx, orgPlugin.ID, orgID, "plugin_installed", map[string]interface{}{
		"plugin_key": plugin.PluginKey,
		"user_id":    userID.String(),
	})

	s.logger.Info("Plugin installed successfully", "plugin_key", req.PluginKey, "org_id", orgID)

	// Attach marketplace plugin details
	orgPlugin.Plugin = plugin

	return orgPlugin, nil
}

// UpdatePluginConfig updates a plugin's configuration
func (s *Service) UpdatePluginConfig(ctx context.Context, pluginInstallID uuid.UUID, req *UpdatePluginConfigRequest) error {
	// TODO: Validate config against plugin schema

	err := s.repo.UpdatePluginConfig(ctx, pluginInstallID, req.Config, req.IsEnabled)
	if err != nil {
		return fmt.Errorf("failed to update plugin config: %w", err)
	}

	s.logger.Info("Plugin config updated", "plugin_id", pluginInstallID)
	return nil
}

// UninstallPlugin uninstalls a plugin
func (s *Service) UninstallPlugin(ctx context.Context, pluginInstallID, userID uuid.UUID) error {
	err := s.repo.UninstallPlugin(ctx, pluginInstallID, userID)
	if err != nil {
		return fmt.Errorf("failed to uninstall plugin: %w", err)
	}

	s.logger.Info("Plugin uninstalled", "plugin_id", pluginInstallID)
	return nil
}

// ExecutePlugin executes a plugin action
func (s *Service) ExecutePlugin(ctx context.Context, orgID uuid.UUID, pluginKey string, req *ExecutePluginRequest) (*ExecutePluginResponse, error) {
	startTime := time.Now()

	// 1. Get plugin installation
	orgPlugin, err := s.repo.GetOrganizationPluginByKey(ctx, orgID, pluginKey)
	if err != nil {
		return nil, fmt.Errorf("plugin not installed or not active: %w", err)
	}

	s.logger.Info("Executing plugin action",
		"plugin_key", pluginKey,
		"action", req.Action,
		"org_id", orgID)

	// 2. Get plugin manifest
	manifest, err := s.fetchPluginManifest(ctx, orgPlugin.Plugin.PluginKey)
	if err != nil {
		s.logger.Error("Failed to fetch plugin manifest", "error", err, "plugin_key", pluginKey)
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
		duration := int(time.Since(startTime).Milliseconds())
		s.logPluginEventWithError(ctx, orgPlugin.ID, orgID, "execution_failed", map[string]interface{}{
			"action":      req.Action,
			"error":       err.Error(),
			"duration_ms": duration,
		})
		s.logger.Error("Plugin execution failed",
			"plugin_key", pluginKey,
			"action", req.Action,
			"error", err)
		return &ExecutePluginResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	// 5. Log success
	duration := int(time.Since(startTime).Milliseconds())
	s.repo.LogPluginEvent(ctx, orgPlugin.ID, orgID, "execution_success", map[string]interface{}{
		"action":      req.Action,
		"duration_ms": duration,
	})

	s.logger.Info("Plugin execution successful",
		"plugin_key", pluginKey,
		"action", req.Action,
		"duration_ms", duration)

	return &ExecutePluginResponse{
		Success: true,
		Data:    result,
	}, nil
}

// fetchPluginManifest fetches the plugin manifest from the manifest URL
func (s *Service) fetchPluginManifest(ctx context.Context, pluginKey string) (*PluginManifest, error) {
	// In production, this would fetch from the manifest_url
	// For now, return a mock manifest
	// TODO: Implement manifest caching

	// Mock manifest for demonstration
	manifest := &PluginManifest{
		PluginKey: pluginKey,
		Version:   "1.0.0",
		Actions: map[string]string{
			"create_payment_intent": "https://plugins.yourpos.com/stripe/payment-intent",
			"capture_payment":       "https://plugins.yourpos.com/stripe/capture",
			"refund_payment":        "https://plugins.yourpos.com/stripe/refund",
		},
		Webhooks: map[string]string{
			"payment.succeeded": "https://plugins.yourpos.com/stripe/webhook",
		},
		Health: "https://plugins.yourpos.com/stripe/health",
	}

	return manifest, nil
}

// executeHTTPRequest executes an HTTP request to a plugin endpoint
func (s *Service) executeHTTPRequest(ctx context.Context, endpoint string, data, config map[string]interface{}) (map[string]interface{}, error) {
	// Merge data with config
	payload := map[string]interface{}{
		"data":   data,
		"config": config,
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal payload: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", endpoint, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("User-Agent", "Flutter-Base-POS/1.0")

	resp, err := s.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to execute request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("plugin returned status %d: %s", resp.StatusCode, string(bodyBytes))
	}

	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return result, nil
}

// validateConfig validates plugin configuration against JSON schema
func (s *Service) validateConfig(schema, config map[string]interface{}) error {
	// TODO: Implement JSON schema validation
	// Use library like https://github.com/xeipuuv/gojsonschema

	// For now, just check if required fields are present
	if schema == nil {
		return nil
	}

	properties, ok := schema["properties"].(map[string]interface{})
	if !ok {
		return nil
	}

	required, _ := schema["required"].([]interface{})
	for _, req := range required {
		reqField := req.(string)
		if _, ok := properties[reqField]; ok {
			if _, exists := config[reqField]; !exists {
				return fmt.Errorf("required field missing: %s", reqField)
			}
		}
	}

	return nil
}

// logPluginEventWithError logs a plugin event with error details
func (s *Service) logPluginEventWithError(ctx context.Context, orgPluginID, orgID uuid.UUID, eventType string, data map[string]interface{}) {
	s.repo.LogPluginEvent(ctx, orgPluginID, orgID, eventType, data)
}

// GetPluginEvents returns events for a plugin installation
func (s *Service) GetPluginEvents(ctx context.Context, orgPluginID uuid.UUID, limit int) ([]*PluginEventDTO, error) {
	// TODO: Implement event retrieval
	return nil, nil
}

// CheckPluginHealth checks the health of a plugin
func (s *Service) CheckPluginHealth(ctx context.Context, orgPluginID uuid.UUID) (string, error) {
	// TODO: Implement health check
	// Call the plugin's health endpoint
	// Update health_status in organization_plugins table
	return "healthy", nil
}
