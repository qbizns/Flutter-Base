package plugin

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{
		service: service,
	}
}

// ListMarketplacePlugins handles GET /api/v1/marketplace/plugins
func (h *Handler) ListMarketplacePlugins(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Parse query parameters
	category := r.URL.Query().Get("category")
	var categoryPtr *string
	if category != "" {
		categoryPtr = &category
	}

	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	if page < 1 {
		page = 1
	}

	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if limit < 1 || limit > 100 {
		limit = 20
	}

	// Get plugins from service
	result, err := h.service.ListMarketplacePlugins(ctx, categoryPtr, page, limit)
	if err != nil {
		h.sendError(w, http.StatusInternalServerError, err.Error())
		return
	}

	h.sendJSON(w, http.StatusOK, result)
}

// GetMarketplacePlugin handles GET /api/v1/marketplace/plugins/{plugin_id}
func (h *Handler) GetMarketplacePlugin(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	pluginID, err := uuid.Parse(chi.URLParam(r, "plugin_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid plugin ID")
		return
	}

	plugin, err := h.service.GetMarketplacePlugin(ctx, pluginID)
	if err != nil {
		h.sendError(w, http.StatusNotFound, "plugin not found")
		return
	}

	h.sendJSON(w, http.StatusOK, plugin)
}

// ListInstalledPlugins handles GET /api/v1/organizations/{org_id}/plugins
func (h *Handler) ListInstalledPlugins(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	orgID, err := uuid.Parse(chi.URLParam(r, "org_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid organization ID")
		return
	}

	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	if page < 1 {
		page = 1
	}

	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if limit < 1 || limit > 100 {
		limit = 20
	}

	result, err := h.service.ListInstalledPlugins(ctx, orgID, page, limit)
	if err != nil {
		h.sendError(w, http.StatusInternalServerError, err.Error())
		return
	}

	h.sendJSON(w, http.StatusOK, result)
}

// GetInstalledPlugin handles GET /api/v1/organizations/{org_id}/plugins/{plugin_id}
func (h *Handler) GetInstalledPlugin(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	orgID, err := uuid.Parse(chi.URLParam(r, "org_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid organization ID")
		return
	}

	pluginID, err := uuid.Parse(chi.URLParam(r, "plugin_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid plugin ID")
		return
	}

	plugin, err := h.service.GetInstalledPlugin(ctx, orgID, pluginID)
	if err != nil {
		h.sendError(w, http.StatusNotFound, "plugin not found")
		return
	}

	h.sendJSON(w, http.StatusOK, plugin)
}

// InstallPlugin handles POST /api/v1/organizations/{org_id}/plugins
func (h *Handler) InstallPlugin(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

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

	if err := req.Validate(); err != nil {
		h.sendError(w, http.StatusBadRequest, err.Error())
		return
	}

	// Get user ID from context (set by auth middleware)
	userID := getUserIDFromContext(ctx)

	plugin, err := h.service.InstallPlugin(ctx, orgID, &req, userID)
	if err != nil {
		h.sendError(w, http.StatusBadRequest, err.Error())
		return
	}

	h.sendJSON(w, http.StatusCreated, plugin)
}

// UpdatePluginConfig handles PATCH /api/v1/organizations/{org_id}/plugins/{plugin_id}
func (h *Handler) UpdatePluginConfig(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	orgID, err := uuid.Parse(chi.URLParam(r, "org_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid organization ID")
		return
	}

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

	if err := req.Validate(); err != nil {
		h.sendError(w, http.StatusBadRequest, err.Error())
		return
	}

	userID := getUserIDFromContext(ctx)

	plugin, err := h.service.UpdatePluginConfig(ctx, orgID, pluginID, &req, userID)
	if err != nil {
		h.sendError(w, http.StatusBadRequest, err.Error())
		return
	}

	h.sendJSON(w, http.StatusOK, plugin)
}

// UninstallPlugin handles DELETE /api/v1/organizations/{org_id}/plugins/{plugin_id}
func (h *Handler) UninstallPlugin(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	orgID, err := uuid.Parse(chi.URLParam(r, "org_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid organization ID")
		return
	}

	pluginID, err := uuid.Parse(chi.URLParam(r, "plugin_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid plugin ID")
		return
	}

	userID := getUserIDFromContext(ctx)

	if err := h.service.UninstallPlugin(ctx, orgID, pluginID, userID); err != nil {
		h.sendError(w, http.StatusBadRequest, err.Error())
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// ExecutePlugin handles POST /api/v1/organizations/{org_id}/plugins/{plugin_key}/execute
func (h *Handler) ExecutePlugin(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	orgID, err := uuid.Parse(chi.URLParam(r, "org_id"))
	if err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid organization ID")
		return
	}

	pluginKey := chi.URLParam(r, "plugin_key")
	if pluginKey == "" {
		h.sendError(w, http.StatusBadRequest, "plugin_key is required")
		return
	}

	var req ExecutePluginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.sendError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := req.Validate(); err != nil {
		h.sendError(w, http.StatusBadRequest, err.Error())
		return
	}

	result, err := h.service.ExecutePlugin(ctx, orgID, pluginKey, &req)
	if err != nil {
		h.sendError(w, http.StatusInternalServerError, err.Error())
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

// getUserIDFromContext extracts user ID from context (set by auth middleware)
func getUserIDFromContext(ctx context.Context) uuid.UUID {
	// TODO: Implement based on your auth middleware
	// For now, return a zero UUID
	return uuid.Nil
}
