package plugin

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
)

// Handler handles HTTP requests for plugins
type Handler struct {
	service *Service
	logger  Logger
}

// NewHandler creates a new plugin handler
func NewHandler(service *Service, logger Logger) *Handler {
	return &Handler{
		service: service,
		logger:  logger,
	}
}

// ListMarketplacePlugins godoc
// @Summary List marketplace plugins
// @Description Get all available plugins in the marketplace
// @Tags plugins
// @Accept json
// @Produce json
// @Param category query string false "Filter by category"
// @Param search query string false "Search query"
// @Param min_rating query number false "Minimum rating"
// @Param is_featured query boolean false "Filter featured plugins"
// @Param limit query int false "Limit results" default(50)
// @Param offset query int false "Offset for pagination" default(0)
// @Success 200 {array} MarketplacePluginDTO
// @Failure 500 {object} map[string]string
// @Router /api/v1/marketplace/plugins [get]
func (h *Handler) ListMarketplacePlugins(w http.ResponseWriter, r *http.Request) {
	filters := &MarketplaceFilters{
		Category: r.URL.Query().Get("category"),
		Search:   r.URL.Query().Get("search"),
	}

	// Parse query parameters
	if minRating := r.URL.Query().Get("min_rating"); minRating != "" {
		var rating float64
		if err := json.Unmarshal([]byte(minRating), &rating); err == nil {
			filters.MinRating = rating
		}
	}

	if isFeatured := r.URL.Query().Get("is_featured"); isFeatured != "" {
		var featured bool
		if err := json.Unmarshal([]byte(isFeatured), &featured); err == nil {
			filters.IsFeatured = &featured
		}
	}

	plugins, err := h.service.ListMarketplacePlugins(r.Context(), filters)
	if err != nil {
		h.logger.Error("Failed to list marketplace plugins", "error", err)
		h.sendError(w, http.StatusInternalServerError, err.Error())
		return
	}

	h.sendJSON(w, http.StatusOK, plugins)
}

// GetInstalledPlugins godoc
// @Summary Get installed plugins
// @Description Get all plugins installed by the organization
// @Tags plugins
// @Accept json
// @Produce json
// @Param org_id path string true "Organization ID"
// @Success 200 {array} OrganizationPluginDTO
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/organizations/{org_id}/plugins [get]
func (h *Handler) GetInstalledPlugins(w http.ResponseWriter, r *http.Request) {
	orgID, err := uuid.Parse(chi.URLParam(r, "org_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid organization ID")
		return
	}

	plugins, err := h.service.GetInstalledPlugins(r.Context(), orgID)
	if err != nil {
		h.logger.Error("Failed to get installed plugins", "error", err, "org_id", orgID)
		h.sendError(w, http.StatusInternalServerError, err.Error())
		return
	}

	h.sendJSON(w, http.StatusOK, plugins)
}

// InstallPlugin godoc
// @Summary Install a plugin
// @Description Install a plugin for the organization
// @Tags plugins
// @Accept json
// @Produce json
// @Param org_id path string true "Organization ID"
// @Param request body InstallPluginRequest true "Install request"
// @Success 201 {object} OrganizationPluginDTO
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/organizations/{org_id}/plugins [post]
func (h *Handler) InstallPlugin(w http.ResponseWriter, r *http.Request) {
	orgID, err := uuid.Parse(chi.URLParam(r, "org_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid organization ID")
		return
	}

	var req InstallPluginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// Get user ID from context (set by auth middleware)
	userID := h.getUserIDFromContext(r)

	plugin, err := h.service.InstallPlugin(r.Context(), orgID, &req, userID)
	if err != nil {
		h.logger.Error("Failed to install plugin", "error", err, "org_id", orgID)
		h.sendError(w, http.StatusBadRequest, err.Error())
		return
	}

	h.sendJSON(w, http.StatusCreated, plugin)
}

// UpdatePluginConfig godoc
// @Summary Update plugin configuration
// @Description Update the configuration of an installed plugin
// @Tags plugins
// @Accept json
// @Produce json
// @Param org_id path string true "Organization ID"
// @Param plugin_id path string true "Plugin Installation ID"
// @Param request body UpdatePluginConfigRequest true "Update request"
// @Success 200 {object} map[string]string
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/organizations/{org_id}/plugins/{plugin_id} [patch]
func (h *Handler) UpdatePluginConfig(w http.ResponseWriter, r *http.Request) {
	pluginID, err := uuid.Parse(chi.URLParam(r, "plugin_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid plugin ID")
		return
	}

	var req UpdatePluginConfigRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.service.UpdatePluginConfig(r.Context(), pluginID, &req); err != nil {
		h.logger.Error("Failed to update plugin config", "error", err, "plugin_id", pluginID)
		h.sendError(w, http.StatusBadRequest, err.Error())
		return
	}

	h.sendJSON(w, http.StatusOK, map[string]string{"message": "plugin config updated successfully"})
}

// UninstallPlugin godoc
// @Summary Uninstall a plugin
// @Description Uninstall a plugin from the organization
// @Tags plugins
// @Accept json
// @Produce json
// @Param org_id path string true "Organization ID"
// @Param plugin_id path string true "Plugin Installation ID"
// @Success 200 {object} map[string]string
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/organizations/{org_id}/plugins/{plugin_id} [delete]
func (h *Handler) UninstallPlugin(w http.ResponseWriter, r *http.Request) {
	pluginID, err := uuid.Parse(chi.URLParam(r, "plugin_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid plugin ID")
		return
	}

	userID := h.getUserIDFromContext(r)

	if err := h.service.UninstallPlugin(r.Context(), pluginID, userID); err != nil {
		h.logger.Error("Failed to uninstall plugin", "error", err, "plugin_id", pluginID)
		h.sendError(w, http.StatusBadRequest, err.Error())
		return
	}

	h.sendJSON(w, http.StatusOK, map[string]string{"message": "plugin uninstalled successfully"})
}

// ExecutePlugin godoc
// @Summary Execute plugin action
// @Description Execute a specific action provided by the plugin
// @Tags plugins
// @Accept json
// @Produce json
// @Param org_id path string true "Organization ID"
// @Param plugin_key path string true "Plugin Key"
// @Param request body ExecutePluginRequest true "Execute request"
// @Success 200 {object} ExecutePluginResponse
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/organizations/{org_id}/plugins/{plugin_key}/execute [post]
func (h *Handler) ExecutePlugin(w http.ResponseWriter, r *http.Request) {
	orgID, err := uuid.Parse(chi.URLParam(r, "org_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid organization ID")
		return
	}

	pluginKey := chi.URLParam(r, "plugin_key")
	if pluginKey == "" {
		h.sendError(w, http.StatusBadRequest, "plugin key is required")
		return
	}

	var req ExecutePluginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	result, err := h.service.ExecutePlugin(r.Context(), orgID, pluginKey, &req)
	if err != nil {
		h.logger.Error("Failed to execute plugin", "error", err, "plugin_key", pluginKey)
		h.sendError(w, http.StatusBadRequest, err.Error())
		return
	}

	h.sendJSON(w, http.StatusOK, result)
}

// Helper methods

func (h *Handler) sendJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

func (h *Handler) sendError(w http.ResponseWriter, status int, message string) {
	h.sendJSON(w, status, map[string]string{"error": message})
}

func (h *Handler) getUserIDFromContext(r *http.Request) uuid.UUID {
	// In production, extract from JWT token in auth middleware
	// For now, return a mock UUID
	userID, _ := uuid.Parse("00000000-0000-0000-0000-000000000000")
	return userID
}
