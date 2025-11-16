# Backend Directory - Plugin Marketplace System

This directory contains the **backend/database components** of the plugin marketplace system that were originally developed in the `Flutter-Database` repository.

They are copied here for convenience so all plugin system code is available in one repository.

---

## 📁 Directory Structure

```
Backend/
├── postgres/migrations/
│   └── V025_20251116_create_plugin_marketplace.sql
├── backend/internal/plugin/
│   ├── README.md
│   ├── dto.go
│   ├── handler.go
│   ├── repository.go
│   └── service.go
├── UNPUSHED_CHANGES_SUMMARY.md
└── README.md (this file)
```

---

## 🎯 Purpose

This directory contains:

1. **Database Migration** - SQL schema for plugin marketplace tables
2. **Go Backend Module** - Complete REST API for plugin management

---

## 📋 Contents

### 1. Database Migration

**File:** `postgres/migrations/V025_20251116_create_plugin_marketplace.sql`

**Creates:**
- `marketplace_plugins` table (plugin catalog)
- `organization_plugins` table (installed plugins)
- `plugin_events` table (execution logs)
- `plugin_reviews` table (ratings & reviews)
- `oauth_providers` table (OAuth2 configs)
- `oauth_tokens` table (encrypted tokens)

**Includes:**
- Helper functions: `is_plugin_active()`, `get_plugin_config()`
- Triggers for auto-updating ratings and install counts
- Row-Level Security (RLS) policies
- 6 seeded example plugins

### 2. Backend Go Module

**Directory:** `backend/internal/plugin/`

**Files:**
- `dto.go` - Data transfer objects for API
- `service.go` - Business logic and plugin execution
- `repository.go` - Database interface
- `handler.go` - HTTP handlers for REST endpoints
- `README.md` - Module documentation

**API Endpoints:**
```
GET    /api/v1/marketplace/plugins
GET    /api/v1/marketplace/plugins/{plugin_id}
GET    /api/v1/organizations/{org_id}/plugins
POST   /api/v1/organizations/{org_id}/plugins
PATCH  /api/v1/organizations/{org_id}/plugins/{plugin_id}
DELETE /api/v1/organizations/{org_id}/plugins/{plugin_id}
POST   /api/v1/organizations/{org_id}/plugins/{plugin_key}/execute
```

---

## 🚀 How to Use

### Apply Database Migration

**Option 1: Using Flyway/Migrate**
```bash
# In your Flutter-Database repository
cd Flutter-Database
make migrate-up
```

**Option 2: Direct SQL**
```bash
psql -U postgres -d pos_db -f Backend/postgres/migrations/V025_20251116_create_plugin_marketplace.sql
```

### Integrate Backend Module

**Copy to Flutter-Database repository:**
```bash
# Copy this module to your actual backend
cp -r Backend/backend/internal/plugin /path/to/Flutter-Database/backend/internal/
```

**Wire up in your API:**
```go
// In cmd/api/main.go
pluginRepo := plugin.NewRepositoryImpl(db, logger)
pluginService := plugin.NewService(pluginRepo)
pluginHandler := plugin.NewHandler(pluginService)

// Register routes
r.Route("/api/v1/marketplace", func(r chi.Router) {
    r.Get("/plugins", pluginHandler.ListMarketplacePlugins)
})

r.Route("/api/v1/organizations/{org_id}/plugins", func(r chi.Router) {
    r.Use(authMiddleware, orgContextMiddleware)
    r.Get("/", pluginHandler.ListInstalledPlugins)
    r.Post("/", pluginHandler.InstallPlugin)
    r.Patch("/{plugin_id}", pluginHandler.UpdatePluginConfig)
    r.Delete("/{plugin_id}", pluginHandler.UninstallPlugin)
    r.Post("/{plugin_key}/execute", pluginHandler.ExecutePlugin)
})
```

---

## 🔗 Related Files in This Repository

**Flutter Package:**
- `packages/plugin_manager/` - Flutter SDK for consuming the backend API

**Documentation:**
- `MARKETPLACE_PLUGIN_IMPLEMENTATION_PLAN.md` - Complete implementation plan
- `PLUGIN_VS_FEATURE_FLAGS_GUIDE.md` - Decision framework
- `QUICK_START_PLUGIN_GUIDE.md` - Step-by-step tutorial
- `PLUGIN_SYSTEM_IMPLEMENTATION_STATUS.md` - Progress tracker

---

## ⚠️ Important Notes

1. **This is a copy** - The original source is in the `Flutter-Database` repository
2. **For reference only** - Use this to copy files to your actual backend project
3. **Keep in sync** - If you make changes, update both locations
4. **Production deployment** - Deploy from your actual Flutter-Database repository

---

## 📞 Next Steps

1. Copy migration file to `Flutter-Database/postgres/migrations/`
2. Copy backend module to `Flutter-Database/backend/internal/plugin/`
3. Implement `repository_impl.go` with PostgreSQL queries
4. Register routes in `cmd/api/main.go`
5. Run migration: `make migrate-up`
6. Test API endpoints
7. Integrate with Flutter app using `plugin_manager` package

---

**For complete implementation details, see the documentation files in the root of this repository.**
