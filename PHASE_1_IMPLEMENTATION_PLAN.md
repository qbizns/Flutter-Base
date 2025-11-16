# Phase 1 MVP Implementation Plan
**Target Completion**: End of December 2025 (6 weeks)
**Focus**: Core POS System (pos_register, manager_dashboard, kds)

---

## Executive Summary

### Current Status
- **Flutter-Base**: 45-50% complete, ALL using mock data
- **Flutter-Database Backend**: 95% infrastructure, 15% functional (missing auth, only 10/181 modules wired)
- **Flutter-Device Bridge**: 100% production-ready (Go service with gRPC/REST/WebSocket)

### Critical Blockers
1. ❌ **No authentication endpoints** - Backend has middleware but no login/register handlers
2. ❌ **Database driver mismatch** - main.go uses `sql.DB`, modules expect `pgxpool.Pool`
3. ❌ **Mock data everywhere** - Flutter-Base not connected to real backend
4. ❌ **Device bridge not integrated** - Ready but not deployed

### Path to MVP
**6 weeks of focused integration work** to connect the three repositories and achieve production-ready Phase 1.

---

## Week 1-2: Backend Authentication & Core Fixes

### Goals
- ✅ Fix database driver mismatch
- ✅ Implement complete authentication system
- ✅ Test auth flow end-to-end

### Tasks

#### Task 1.1: Fix Database Driver Mismatch (Day 1-2)
**Problem**: `main.go` passes `*sql.DB` but all modules expect `*pgxpool.Pool`

**Solution**:
```go
// In main.go, replace:
db, err := sql.Open("postgres", dsn)

// With:
import "github.com/jackc/pgx/v5/pgxpool"

pool, err := pgxpool.New(context.Background(), dsn)
```

**Files to modify**:
- `/tmp/Flutter-Database/backend/cmd/api/main.go` (lines 168-195)
- Update all module initialization functions to pass `pool` instead of `db`

**Impact**: CRITICAL - Without this, backend will crash on first API call

---

#### Task 1.2: Implement Auth Service (Day 2-3)

**Create**: `/tmp/Flutter-Database/backend/internal/auth/service.go`

**Required Functions**:
```go
type Service struct {
    userRepo  *user.Repository
    jwtSecret string
    logger    *logging.Logger
}

// Login validates credentials and returns JWT tokens
func (s *Service) Login(ctx context.Context, email, password string) (*AuthResponse, error)

// Register creates new user and returns JWT tokens
func (s *Service) Register(ctx context.Context, req *RegisterRequest) (*AuthResponse, error)

// RefreshToken generates new access token from refresh token
func (s *Service) RefreshToken(ctx context.Context, refreshToken string) (*TokenResponse, error)

// GenerateTokens creates access + refresh JWT tokens
func (s *Service) GenerateTokens(user *user.Users) (*TokenPair, error)

// HashPassword bcrypts password
func (s *Service) HashPassword(password string) (string, error)

// ComparePassword validates password against hash
func (s *Service) ComparePassword(hash, password string) error
```

**Dependencies**:
```go
import (
    "golang.org/x/crypto/bcrypt"
    "github.com/golang-jwt/jwt/v5"
)
```

---

#### Task 1.3: Implement Auth Handlers (Day 3-4)

**Create**: `/tmp/Flutter-Database/backend/internal/auth/handler.go`

**Endpoints to implement**:
```
POST /api/v1/auth/login
POST /api/v1/auth/register
POST /api/v1/auth/refresh
POST /api/v1/auth/logout (optional for Phase 1)
GET  /api/v1/auth/me (get current user info)
```

**Request/Response DTOs**:
```go
type LoginRequest struct {
    Email    string `json:"email" validate:"required,email"`
    Password string `json:"password" validate:"required,min=8"`
}

type RegisterRequest struct {
    Email           string `json:"email" validate:"required,email"`
    Password        string `json:"password" validate:"required,min=8"`
    FirstName       string `json:"first_name" validate:"required"`
    LastName        string `json:"last_name" validate:"required"`
    OrganizationID  string `json:"organization_id" validate:"required,uuid"`
}

type AuthResponse struct {
    AccessToken  string        `json:"access_token"`
    RefreshToken string        `json:"refresh_token"`
    ExpiresIn    int           `json:"expires_in"`
    User         *UserResponse `json:"user"`
}

type RefreshRequest struct {
    RefreshToken string `json:"refresh_token" validate:"required"`
}
```

---

#### Task 1.4: Add User Lookup by Email (Day 4)

**Modify**: `/tmp/Flutter-Database/backend/internal/user/repository.go`

**Add function**:
```go
// GetByEmail retrieves user by email address
func (r *Repository) GetByEmail(ctx context.Context, orgID uuid.UUID, email string) (*Users, error) {
    query := `
        SELECT id, organization_id, email, password_hash, first_name, last_name,
               phone, avatar_url, status, email_verified, created_at, updated_at
        FROM users
        WHERE organization_id = $1 AND email = $2 AND deleted_at IS NULL
    `

    var user Users
    err := r.db.QueryRow(ctx, query, orgID, email).Scan(...)

    if err == pgx.ErrNoRows {
        return nil, fmt.Errorf("user not found")
    }

    return &user, nil
}
```

---

#### Task 1.5: Wire Up Auth Routes (Day 5)

**Modify**: `/tmp/Flutter-Database/backend/cmd/api/main.go`

**Replace lines 213-217 with**:
```go
// Initialize auth service and handler
authService := auth.NewService(
    user.NewRepository(pool, logger),
    cfg.JWT.Secret,
    cfg.JWT.AccessTokenDuration,
    cfg.JWT.RefreshTokenDuration,
    logger,
)
authHandler := auth.NewHandler(authService, logger)

// Public routes (no auth, but stricter rate limiting)
r.Group(func(r chi.Router) {
    // Stricter rate limiting for auth endpoints (anti-brute force)
    r.Use(rateLimiter.StrictLimit())

    r.Post("/auth/login", authHandler.Login)
    r.Post("/auth/register", authHandler.Register)
    r.Post("/auth/refresh", authHandler.RefreshToken)
})

// Semi-protected route (requires valid token, no org check)
r.Group(func(r chi.Router) {
    r.Use(authMiddleware.Authenticate)
    r.Get("/auth/me", authHandler.GetMe)
})
```

---

#### Task 1.6: Test Authentication Flow (Day 6-7)

**Test Cases**:
1. Register new user → receive tokens
2. Login with email/password → receive tokens
3. Access protected endpoint with access token → success
4. Refresh access token with refresh token → receive new access token
5. Login with wrong password → 401 error
6. Access protected endpoint without token → 401 error
7. Access protected endpoint with expired token → 401 error

**Tools**:
```bash
# Register
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "SecurePass123!",
    "first_name": "Admin",
    "last_name": "User",
    "organization_id": "123e4567-e89b-12d3-a456-426614174000"
  }'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "SecurePass123!"
  }'

# Get products (with token)
curl -X GET "http://localhost:8080/api/v1/organizations/{org_id}/products" \
  -H "Authorization: Bearer {access_token}"
```

---

## Week 3: Connect Flutter-Base to Backend

### Goals
- ✅ Update API client configuration
- ✅ Replace mock data sources with HTTP
- ✅ Test all core module APIs

### Tasks

#### Task 3.1: Update API Client Configuration (Day 1)

**Modify**: `/home/user/Flutter-Base/lib/src/core/config/app_config.dart`

**Update base URLs**:
```dart
class AppConfig {
  final String apiBaseUrl;
  final String deviceBridgeUrl;

  const AppConfig({
    required this.apiBaseUrl,
    required this.deviceBridgeUrl,
  });

  static AppConfig development() => AppConfig(
    apiBaseUrl: 'http://localhost:8080/api/v1',
    deviceBridgeUrl: 'http://localhost:8080', // Device Bridge
  );

  static AppConfig production() => AppConfig(
    apiBaseUrl: 'https://api.yourcompany.com/api/v1',
    deviceBridgeUrl: 'http://localhost:8080', // Local device bridge
  );
}
```

---

#### Task 3.2: Implement Auth API Service (Day 1-2)

**Create**: `/home/user/Flutter-Base/packages/pos_core/lib/src/data/auth/auth_api_service.dart`

**Implement**:
```dart
class AuthApiService {
  final ApiClient _client;

  AuthApiService(this._client);

  Future<Result<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return Result.success(AuthResponse.fromJson(response.data));
    } on ApiException catch (e) {
      return Result.failure(Failure.network(e.message));
    }
  }

  Future<Result<AuthResponse>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String organizationId,
  }) async {
    // Similar implementation
  }

  Future<Result<TokenResponse>> refreshToken(String refreshToken) async {
    // Similar implementation
  }
}
```

---

#### Task 3.3: Replace Products Data Source (Day 2-3)

**Modify**: `/home/user/Flutter-Base/packages/pos_core/lib/src/data/products/products_remote_data_source.dart`

**Replace mock implementation**:
```dart
class ProductsRemoteDataSource {
  final ApiClient _client;
  final String _orgId;

  Future<Result<List<Product>>> getProducts({
    String? categoryId,
    String? search,
  }) async {
    try {
      final response = await _client.get(
        '/organizations/$_orgId/products',
        queryParameters: {
          if (categoryId != null) 'category_id': categoryId,
          if (search != null) 'search': search,
        },
      );

      final products = (response.data['items'] as List)
          .map((json) => Product.fromJson(json))
          .toList();

      return Result.success(products);
    } on ApiException catch (e) {
      return Result.failure(Failure.network(e.message));
    }
  }

  // Implement other methods: getById, create, update, delete, etc.
}
```

**Same pattern for**:
- `orders_remote_data_source.dart`
- `payments_remote_data_source.dart`
- `tables_remote_data_source.dart`
- `categories_remote_data_source.dart`
- `customers_remote_data_source.dart`

---

#### Task 3.4: Update Repository Implementations (Day 3-4)

**Modify**: All repository implementations to use remote data source instead of mock

**Example** - `/home/user/Flutter-Base/packages/pos_core/lib/src/data/products/products_repository_impl.dart`:

```dart
class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remoteDataSource;
  final ProductsLocalDataSource _localDataSource; // For offline

  @override
  Future<Result<List<Product>>> getProducts({
    String? categoryId,
    String? search,
  }) async {
    // Try remote first
    final result = await _remoteDataSource.getProducts(
      categoryId: categoryId,
      search: search,
    );

    // Cache locally for offline
    result.when(
      success: (products) => _localDataSource.saveProducts(products),
      failure: (_) {}, // Use cached data on failure
    );

    return result;
  }
}
```

---

#### Task 3.5: Test API Integration (Day 5)

**Test each module**:
```dart
// Test Products API
final productsRepo = ref.read(productsRepositoryProvider);
final result = await productsRepo.getProducts();
result.when(
  success: (products) => print('Got ${products.length} products'),
  failure: (error) => print('Error: $error'),
);

// Test Orders API
final ordersRepo = ref.read(ordersRepositoryProvider);
final createResult = await ordersRepo.createOrder(order);

// Test Payments API
final paymentsRepo = ref.read(paymentsRepositoryProvider);
final paymentResult = await paymentsRepo.processPayment(payment);
```

---

## Week 4: Device Bridge Integration

### Goals
- ✅ Deploy Flutter-Device bridge locally
- ✅ Configure virtual devices
- ✅ Integrate with POS apps
- ✅ Test hardware workflows

### Tasks

#### Task 4.1: Deploy Device Bridge (Day 1)

**Location**: `/tmp/Flutter-Device`

**Build and run**:
```bash
cd /tmp/Flutter-Device

# Build
go build -o device-bridge ./cmd/device-bridge

# Create config
cp config.example.yaml config.yaml

# Edit config.yaml - enable virtual devices
nano config.yaml

# Run
./device-bridge --config config.yaml
```

**Verify**:
```bash
# Health check
curl http://localhost:8080/v1/ping

# List devices
curl http://localhost:8080/v1/devices
```

---

#### Task 4.2: Configure Virtual Devices (Day 1-2)

**Edit**: `/tmp/Flutter-Device/config.yaml`

```yaml
devices:
  - id: "printer-01"
    name: "Main Receipt Printer"
    type: "escpos_printer"
    enabled: true
    virtual: true  # Virtual printer for testing

  - id: "scanner-01"
    name: "Barcode Scanner"
    type: "barcode_scanner"
    enabled: true
    virtual: true  # Auto-scan every 15s

  - id: "display-01"
    name: "Customer Display"
    type: "customer_display"
    enabled: true
    virtual: true

  - id: "drawer-01"
    name: "Cash Drawer"
    type: "cash_drawer"
    enabled: true
    virtual: true

  - id: "payment-01"
    name: "Payment Terminal"
    type: "payment_terminal"
    enabled: true
    virtual: true
```

---

#### Task 4.3: Integrate with Flutter-Base (Day 2-3)

**Update**: `/home/user/Flutter-Base/packages/pos_core/lib/src/core/config/app_config.dart`

```dart
class AppConfig {
  final String deviceBridgeUrl;

  static AppConfig development() => AppConfig(
    deviceBridgeUrl: 'http://localhost:8080',
  );
}
```

**Update device_bridge_client configuration**:
```dart
// In POS register app initialization
final deviceBridge = DeviceBridgeClient(
  baseUrl: appConfig.deviceBridgeUrl,
  timeout: Duration(seconds: 30),
);

// Register printer
final printer = deviceBridge.printer('printer-01');

// Register scanner
final scanner = deviceBridge.scanner('scanner-01');

// Listen for scans
scanner.events().listen((scanEvent) {
  print('Scanned: ${scanEvent.barcode}');
  // Add product to cart
});
```

---

#### Task 4.4: Implement Print Receipt (Day 3-4)

**Location**: `/home/user/Flutter-Base/apps/pos_register/lib/src/features/session/services/receipt_service.dart`

```dart
class ReceiptService {
  final DeviceBridgeClient _deviceBridge;

  Future<void> printReceipt(Order order) async {
    final printer = _deviceBridge.printer('printer-01');

    // Build receipt content
    final content = _buildReceiptContent(order);

    // Print
    await printer.print(
      content: content,
      cut: true,
      openDrawer: true, // Open cash drawer after print
    );
  }

  String _buildReceiptContent(Order order) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('=====================================');
    buffer.writeln('        YOUR RESTAURANT NAME         ');
    buffer.writeln('=====================================');
    buffer.writeln('');

    // Order details
    buffer.writeln('Order #${order.orderNumber}');
    buffer.writeln('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)}');
    buffer.writeln('');

    // Items
    buffer.writeln('Items:');
    buffer.writeln('-------------------------------------');
    for (final item in order.items) {
      buffer.writeln('${item.quantity}x ${item.product.name}');
      buffer.writeln('    ${currencyFormat.format(item.totalPrice)}');

      // Modifiers
      for (final mod in item.modifiers) {
        buffer.writeln('  + ${mod.name}');
      }
    }

    buffer.writeln('-------------------------------------');

    // Totals
    buffer.writeln('Subtotal: ${currencyFormat.format(order.subtotal)}');
    buffer.writeln('Tax:      ${currencyFormat.format(order.tax)}');
    buffer.writeln('Total:    ${currencyFormat.format(order.total)}');
    buffer.writeln('');

    // Footer
    buffer.writeln('     Thank you for your visit!      ');
    buffer.writeln('=====================================');

    return buffer.toString();
  }
}
```

---

#### Task 4.5: Test Hardware Integration (Day 4-5)

**Test scenarios**:

1. **Scan product barcode** → Product added to cart
2. **Print receipt** → Receipt prints on virtual printer (console output)
3. **Open cash drawer** → Drawer opens (virtual auto-closes after 5s)
4. **Process payment** → Payment terminal shows transaction (virtual)
5. **Update customer display** → Display shows order total

**Integration test**:
```dart
void main() async {
  // Setup
  final deviceBridge = DeviceBridgeClient(baseUrl: 'http://localhost:8080');

  // Test 1: Scan barcode
  print('Test 1: Listening for barcode scans...');
  final scanner = deviceBridge.scanner('scanner-01');
  scanner.events().listen((scan) {
    print('✓ Scanned: ${scan.barcode}');
  });

  await Future.delayed(Duration(seconds: 20)); // Wait for virtual scan

  // Test 2: Print receipt
  print('Test 2: Printing receipt...');
  final printer = deviceBridge.printer('printer-01');
  await printer.print(
    content: 'Test Receipt\n\nTotal: \$10.00\n',
    cut: true,
  );
  print('✓ Receipt printed');

  // Test 3: Open drawer
  print('Test 3: Opening cash drawer...');
  await printer.openDrawer('drawer-01');
  print('✓ Drawer opened');

  // Test 4: Update display
  print('Test 4: Updating customer display...');
  final display = deviceBridge.display('display-01');
  await display.show(line1: 'Total', line2: '\$10.00');
  print('✓ Display updated');

  print('\n✅ All hardware tests passed!');
}
```

---

## Week 5: End-to-End Testing

### Goals
- ✅ Test complete POS flow
- ✅ Test offline mode and sync
- ✅ Performance testing
- ✅ Bug fixes

### Test Cases

#### E2E Test 1: Complete Order Flow
```
1. Open POS session with cash count
2. Scan product barcode → Product added to cart
3. Add modifier to product
4. Apply discount
5. Checkout
6. Process payment (cash)
7. Print receipt
8. Receipt displays correct totals
9. Cash drawer opens
10. Order saved to database
11. Kitchen receives order (KDS)
12. Close session with cash count
```

#### E2E Test 2: Table Service Flow
```
1. Waiter selects table on floor plan
2. Takes order for table
3. Sends to kitchen
4. Kitchen marks order as preparing
5. Kitchen bumps order to ready
6. Waiter processes payment
7. Table cleared
```

#### E2E Test 3: Offline Mode
```
1. Disconnect from internet
2. Create order in POS
3. Process payment
4. Order saved to local database
5. Reconnect to internet
6. Sync service uploads order
7. Order appears in manager dashboard
```

---

## Week 6: Polish & Deployment

### Goals
- ✅ Bug fixes from testing
- ✅ Performance optimization
- ✅ Deployment preparation
- ✅ Documentation
- ✅ Client demo ready

### Tasks

#### Task 6.1: Create Deployment Guides (Day 1)

**Documents to create**:
1. `BACKEND_DEPLOYMENT.md` - How to deploy Go backend
2. `DEVICE_BRIDGE_DEPLOYMENT.md` - How to deploy device bridge
3. `POS_SETUP.md` - How to set up POS terminals
4. `TROUBLESHOOTING.md` - Common issues and fixes

---

#### Task 6.2: Add Dockerfile for Backend (Day 1)

**Create**: `/tmp/Flutter-Database/backend/Dockerfile`

```dockerfile
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o api ./cmd/api

# Runtime image
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/api .
COPY --from=builder /app/.env.example .env

EXPOSE 8080

CMD ["./api"]
```

---

#### Task 6.3: Create Docker Compose for Full Stack (Day 2)

**Create**: `docker-compose.yml`

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: pos_saas
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build: ./Flutter-Database/backend
    ports:
      - "8080:8080"
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      REDIS_HOST: redis
      REDIS_PORT: 6379
    depends_on:
      - postgres
      - redis

  device-bridge:
    build: ./Flutter-Device
    ports:
      - "50051:50051"  # gRPC
      - "8081:8080"    # HTTP
    volumes:
      - ./device-bridge-config.yaml:/config.yaml

volumes:
  postgres_data:
```

---

#### Task 6.4: Final Testing & Bug Fixes (Day 3-4)

**Testing checklist**:
- [ ] Authentication works
- [ ] All API endpoints return correct data
- [ ] Products load and display
- [ ] Orders can be created
- [ ] Payments process correctly
- [ ] Tables update in real-time
- [ ] Kitchen display receives orders
- [ ] Manager dashboard shows analytics
- [ ] Hardware integration works
- [ ] Offline mode works
- [ ] Sync service works
- [ ] No crashes or errors

---

#### Task 6.5: Client Demo Preparation (Day 5-6)

**Demo script**:
```
1. Introduction (2 min)
   - Overview of Phase 1 MVP
   - 3 core apps: POS, Manager Dashboard, Kitchen Display

2. POS Register Demo (10 min)
   - Open session
   - Scan products (barcode scanner)
   - Add to cart
   - Modify items
   - Apply discounts
   - Process payment
   - Print receipt
   - Close session

3. Kitchen Display Demo (5 min)
   - Receive order
   - Mark as preparing
   - Bump to ready
   - Complete order

4. Manager Dashboard Demo (10 min)
   - View sales analytics
   - Product management
   - Table management
   - Staff management
   - System settings

5. Offline Mode Demo (5 min)
   - Disconnect internet
   - Create order
   - Reconnect
   - Show auto-sync

6. Q&A (8 min)
```

**Demo environment setup**:
- Populate database with sample data (products, categories, staff)
- Configure virtual devices
- Prepare test scenarios
- Set up display screens

---

## Success Criteria

### Phase 1 Complete When:
- [x] Backend authentication works (login, register, refresh)
- [x] All 10 core modules accessible via API
- [x] Flutter-Base apps connect to real backend
- [x] Device bridge integrated and working
- [x] Complete order flow works end-to-end:
  - Scan → Cart → Payment → Receipt → Kitchen
- [x] Offline mode works with sync
- [x] Manager dashboard shows real data
- [x] No critical bugs
- [x] Client demo successful

---

## Risk Mitigation

### Risk 1: Database Migration Issues
**Mitigation**: Test migrations on staging database first, create backup before production

### Risk 2: Performance Issues with Real Data
**Mitigation**: Load test with 1000+ products, 100+ concurrent orders

### Risk 3: Hardware Integration Fails
**Mitigation**: Virtual devices for testing, fallback to manual receipt generation

### Risk 4: Offline Sync Conflicts
**Mitigation**: Last-write-wins strategy, conflict resolution UI for edge cases

### Risk 5: Timeline Slippage
**Mitigation**: Focus on core features only, defer nice-to-haves to Phase 2

---

## Phase 2 & 3 Preview

### Phase 2 (Weeks 7-12): Customer Experience
- waiter_app
- customer_kiosk
- order_display
- customer_app
- WebSocket real-time updates
- Loyalty program basics

### Phase 3 (Weeks 13-20): Admin & Operations
- admin_portal
- menu_manager
- analytics_dashboard
- inventory_management
- Advanced reporting
- Multi-location support

---

## Next Steps

1. **Approve this plan** ✓
2. **Start Week 1 tasks** - Fix backend auth
3. **Daily standup** - Track progress, address blockers
4. **Weekly demo** - Show working features to stakeholders
5. **Iterate based on feedback**

---

**Let's build this MVP! 🚀**
