package plugin

import (
	"database/sql"

	"github.com/go-chi/chi/v5"
)

// RegisterRoutes registers plugin routes
// Add this to your main.go or routes.go file
//
// Example usage in main.go:
//
//	func main() {
//	    db, _ := sql.Open("postgres", connectionString)
//	    logger := yourLogger
//
//	    pluginRepo := plugin.NewRepository(db)
//	    pluginService := plugin.NewService(pluginRepo, logger)
//	    pluginHandler := plugin.NewHandler(pluginService, logger)
//
//	    r := chi.NewRouter()
//	    plugin.RegisterRoutes(r, pluginHandler, authMiddleware, orgContextMiddleware)
//	}
func RegisterRoutes(r chi.Router, handler *Handler, authMiddleware, orgContextMiddleware func(http.Handler) http.Handler) {
	// Public marketplace routes (no auth required)
	r.Route("/api/v1/marketplace", func(r chi.Router) {
		r.Get("/plugins", handler.ListMarketplacePlugins)
	})

	// Organization plugin routes (require auth)
	r.Route("/api/v1/organizations/{org_id}/plugins", func(r chi.Router) {
		// Apply auth and organization context middleware
		r.Use(authMiddleware)
		r.Use(orgContextMiddleware)

		r.Get("/", handler.GetInstalledPlugins)
		r.Post("/", handler.InstallPlugin)
		r.Patch("/{plugin_id}", handler.UpdatePluginConfig)
		r.Delete("/{plugin_id}", handler.UninstallPlugin)
		r.Post("/{plugin_key}/execute", handler.ExecutePlugin)
	})
}

// Example main.go file structure:

/*
package main

import (
	"database/sql"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	_ "github.com/lib/pq"

	"your-project/internal/plugin"
)

func main() {
	// Database connection
	db, err := sql.Open("postgres", "postgres://user:password@localhost/pos_db?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Logger setup
	logger := &SimpleLogger{}

	// Plugin system initialization
	pluginRepo := plugin.NewRepository(db)
	pluginService := plugin.NewService(pluginRepo, logger)
	pluginHandler := plugin.NewHandler(pluginService, logger)

	// Router setup
	r := chi.NewRouter()

	// Middleware
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"https://*", "http://*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type"},
		AllowCredentials: true,
	}))

	// Register plugin routes
	plugin.RegisterRoutes(r, pluginHandler, authMiddleware, orgContextMiddleware)

	// Start server
	log.Println("Server starting on :8080")
	http.ListenAndServe(":8080", r)
}

// Example auth middleware
func authMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify JWT token
		// Extract user_id and org_id
		// Set in context
		next.ServeHTTP(w, r)
	})
}

// Example organization context middleware
func orgContextMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify user has access to org_id from URL
		// Set PostgreSQL session variables for RLS
		// db.Exec("SET app.current_organization_id = ?", orgID)
		next.ServeHTTP(w, r)
	})
}

// Simple logger implementation
type SimpleLogger struct{}

func (l *SimpleLogger) Info(msg string, keysAndValues ...interface{}) {
	log.Printf("[INFO] %s %v\n", msg, keysAndValues)
}

func (l *SimpleLogger) Error(msg string, keysAndValues ...interface{}) {
	log.Printf("[ERROR] %s %v\n", msg, keysAndValues)
}

func (l *SimpleLogger) Debug(msg string, keysAndValues ...interface{}) {
	log.Printf("[DEBUG] %s %v\n", msg, keysAndValues)
}
*/
