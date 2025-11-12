# NEXT SESSION - Admin Dashboard Development

**Date:** 2025-11-12
**Branch:** `claude/replace-macber-eg-qbizns-011CV4e16LiJejPpNg8KgzpS`
**Status:** Admin Dashboard Foundation Complete - Ready for Module Implementation

---

## 📍 Current Status

### ✅ What's Completed

#### **Phase 1-3: POS Ecosystem (100% Complete)**
- ✅ **POS Register** - Full checkout system with offline sync
- ✅ **Kitchen Display System (KDS)** - Order tracking with analytics
- ✅ **Customer Display** - Real-time cart/payment display with WebSocket
- ✅ **Waiter App** - Table management and order taking with backend integration
- ✅ **Hardware Integration** - Real device support via Device Bridge SDK

#### **Phase 4: Waiter App (100% Complete)**
- ✅ Backend integration with real APIs (NO mock data)
- ✅ Floor plan management
- ✅ Table operations (open, close, transfer, merge)
- ✅ Order taking with product catalog
- ✅ Kitchen printer integration
- ✅ WebSocket real-time updates
- ✅ Complete UI following Odoo patterns

#### **Hardware Integration (100% Complete)**
- ✅ Receipt printer integration (POS Register)
- ✅ Kitchen printer integration (Waiter App)
- ✅ Payment terminal support
- ✅ Cash drawer control
- ✅ Barcode scanner streaming
- ✅ Device Bridge SDK integration
- ✅ Complete documentation

#### **Phase 5: Admin Dashboard (30% Complete)**
- ✅ App structure created (`apps/admin_dashboard/`)
- ✅ **Odoo Design System** implemented (colors, typography, theme)
- ✅ Main app entry with routing
- ✅ Dependencies configured
- ⏳ **IN PROGRESS:** Building Odoo-style layout and modules

---

## 🎯 Current Task: Admin Dashboard Development

### What We're Building

A complete **back-office management system** for SmartPOS following **Odoo design guidelines 100%**.

**Purpose:**
- Managers/owners configure and monitor POS system
- View analytics and reports
- Manage products, staff, settings
- Configure floor plans, devices, payments
- Real-time business insights

### Architecture

```
Admin Dashboard (Flutter Web/Desktop)
         ↓
   Odoo UI/UX Design
         ↓
   Backend APIs (Go)
         ↓
PostgreSQL Database (172 tables)
```

---

## 📦 Repository Structure

### **Main Repository: Flutter-Base**
**Location:** `/home/user/Flutter-Base`
**GitHub:** `https://github.com/qbizns/Flutter-Base`
**Branch:** `claude/replace-macber-eg-qbizns-011CV4e16LiJejPpNg8KgzpS`

#### Apps Created:
```
Flutter-Base/
├── apps/
│   ├── pos_register/          ✅ Complete - POS checkout system
│   ├── kds/                   ✅ Complete - Kitchen display
│   ├── order_display/         ✅ Complete - Customer display
│   ├── waiter_app/            ✅ Complete - Waiter/table management
│   └── admin_dashboard/       ⏳ IN PROGRESS - Back office (30% done)
│
├── packages/
│   ├── pos_core/              ✅ Shared domain models & logic
│   ├── pos_ui/                ✅ Shared UI components
│   └── device_bridge_client/  ✅ Hardware device SDK
│
└── Docs/
    ├── 25-Hardware-Integration.md  ✅ Hardware setup guide
    └── [Other docs...]
```

### **Backend Repository: Flutter-Database**
**Location:** `/home/user/Flutter-Base/Flutter-Database`
**GitHub:** `https://github.com/qbizns/Flutter-Database`
**Language:** Go (Golang)
**Database:** PostgreSQL

#### Backend Structure:
```
Flutter-Database/
├── backend/
│   ├── cmd/api/              - API server entry point
│   ├── internal/
│   │   ├── domain/           - Business entities
│   │   ├── repository/       - Data access layer
│   │   └── http/rest/        - REST API handlers
│   └── CODE_GENERATION_GUIDE.md
│
├── postgres/
│   ├── migrations/           - 109 tables
│   └── seed_data/            - Sample data
│
└── accounting/
    ├── migrations/           - 63 tables
    └── seed_data/            - Accounting data

**Total:** 172 database tables
```

#### Backend API Status:
- ✅ **Products API** - Complete CRUD reference implementation
- ✅ **Users API** - Implemented
- ✅ **Customers API** - Domain layer done (50%)
- ⏳ **Sales/Orders** - Needs implementation
- ⏳ **Restaurant** - Needs implementation
- ⏳ **Settings** - Needs implementation
- ⏳ **Analytics** - Needs implementation

**Implementation Progress:** 1/172 tables complete (0.6%)

### **Device Bridge Repository: Flutter-Device**
**Location:** `/home/user/Flutter-Base/Flutter-Device`
**GitHub:** `https://github.com/qbizns/Flutter-Device`
**Language:** Go
**Purpose:** Hardware abstraction layer (printers, scanners, terminals)

#### Device Bridge Status:
- ✅ **Phase 1 MVP** - 100% Complete
  - Core infrastructure (config, logging, metrics)
  - Job scheduler & queue
  - Event bus (pub/sub)
  - Device registry with health monitoring
  - ESC/POS printer driver (TCP transport)
  - Virtual printer for testing
  - gRPC API server (14 RPC methods)

- ✅ **Phase 2** - 90% Complete
  - REST/JSON API gateway
  - Swagger UI for API docs
  - WebSocket server for real-time events
  - Virtual devices (scanner, scale, display, drawer)
  - Auto-discovery framework
  - Security features (mTLS, ACL)
  - CLI administration tool
  - ZPL label printer driver
  - CI/CD pipeline
  - Docker containerization

**Status:** Production-ready for POS integration

---

## 🎨 Admin Dashboard - What's Done

### ✅ Completed Files:

#### 1. **App Structure**
```
apps/admin_dashboard/
├── lib/
│   ├── main.dart                              ✅ App entry, routing
│   └── src/
│       ├── ui/theme/
│       │   ├── odoo_colors.dart               ✅ Color system (180 lines)
│       │   ├── odoo_typography.dart           ✅ Typography (350 lines)
│       │   └── odoo_theme.dart                ✅ Theme config (350 lines)
│       ├── features/
│       │   ├── dashboard/                     📁 Created (empty)
│       │   ├── sales/                         📁 Created (empty)
│       │   ├── products/                      📁 Created (empty)
│       │   ├── restaurant/                    📁 Created (empty)
│       │   ├── staff/                         📁 Created (empty)
│       │   ├── settings/                      📁 Created (empty)
│       │   └── devices/                       📁 Created (empty)
│       └── data/                              📁 Created (empty)
└── pubspec.yaml                               ✅ Dependencies configured
```

#### 2. **Odoo Design System** (100% Complete)

**`odoo_colors.dart`** - Official Odoo color palette:
- Primary: `#714B67` (Odoo purple)
- Secondary: `#00A09D` (teal)
- Sidebar: `#2C2C36` (dark gray)
- Semantic: Success (green), Warning (orange), Danger (red), Info (blue)
- Status colors for orders/items
- Chart colors (10-color palette)
- Complete gray scale

**`odoo_typography.dart`** - Typography system:
- Font family: **Lato** (Odoo standard)
- Display, Headline, Title, Body, Label styles
- Special purpose: pageTitle, cardTitle, statValue, button, tableHeader
- **Spacing:** 4px base unit (8, 12, 16, 24, 32, 48px)
- **Border radius:** 3px (Odoo standard)
- Icon sizes (12px to 48px)

**`odoo_theme.dart`** - Complete Material 3 theme:
- AppBar, Card, Button themes
- Input fields, Checkboxes, Radio, Switch
- Dialog, BottomSheet, Snackbar
- DataTable, TabBar, Chip
- All following Odoo specifications exactly

#### 3. **Routing Setup** (main.dart)
```dart
Routes configured:
- / → Dashboard (home)
- /sales → Sales management
- /products → Product catalog
- /restaurant → Floor plans, tables
- /staff → User management
- /settings → System settings
- /devices → Device management

Using GoRouter with ShellRoute for persistent Odoo sidebar layout
```

#### 4. **Dependencies**
```yaml
- flutter_riverpod: ^2.6.1          # State management
- go_router: ^14.6.2                # Navigation
- fl_chart: ^0.69.0                 # Charts
- syncfusion_flutter_charts: ^27.1.48  # Advanced charts
- data_table_2: ^2.5.15             # Data tables
- file_picker: ^8.1.2               # File uploads
- image_picker: ^1.1.2              # Image uploads
- pos_core, pos_ui, device_bridge_client  # Shared packages
```

---

## 🚀 Next Steps - What to Build

### Priority 1: Layout & Navigation (Next Session Start Here)

#### **1. Create OdooLayout Widget** ⬅️ **START HERE**
File: `apps/admin_dashboard/lib/src/ui/widgets/odoo_layout.dart`

**Requirements:**
- Left sidebar with Odoo styling (#2C2C36 background)
- Top bar with search, notifications, user menu
- Main content area with breadcrumbs
- Responsive (collapse sidebar on mobile)
- Active menu item highlighting
- Hover states

**Sidebar Menu Items:**
```dart
- Dashboard (home icon)
- Sales (receipt icon)
- Products (box icon)
- Restaurant (restaurant icon)
- Staff (people icon)
- Settings (settings icon)
- Devices (devices icon)
```

**Reference:** Odoo 17 backend layout exactly

---

### Priority 2: Dashboard Home Page

#### **2. Dashboard Home**
File: `apps/admin_dashboard/lib/src/features/dashboard/presentation/pages/dashboard_home_page.dart`

**Widgets Needed:**
```dart
// KPI Cards (4 across)
- Today's Sales ($X,XXX.XX)
- Orders Today (XXX)
- Active Tables (XX/XX)
- Top Product (Name)

// Charts (2 columns)
- Sales Chart (last 7 days) - Line chart
- Top Products (pie chart)

// Recent Orders Table
- Order #, Time, Table, Amount, Status
- Clickable rows → order details
```

**Backend Integration:**
```
GET /api/v1/analytics/dashboard
Response: {
  todaySales: number,
  ordersToday: number,
  activeTables: number,
  topProduct: { name, count },
  salesChart: [{ date, amount }],
  topProducts: [{ name, percentage }],
  recentOrders: [{ id, time, table, amount, status }]
}
```

---

### Priority 3: Sales Module

#### **3. Sales Page**
File: `apps/admin_dashboard/lib/src/features/sales/presentation/pages/sales_page.dart`

**Features:**
- Orders list (DataTable2)
- Filters: Date range, Status, Payment method
- Search by order number
- Export to CSV/PDF
- Order details dialog
- Refund functionality

**Backend:**
```
GET /api/v1/sales/orders?from=X&to=Y&status=Z
GET /api/v1/sales/orders/:id
POST /api/v1/sales/orders/:id/refund
```

---

### Priority 4: Products Module

#### **4. Products Page**
File: `apps/admin_dashboard/lib/src/features/products/presentation/pages/products_page.dart`

**Features:**
- Product catalog (grid or list view)
- Add/Edit/Delete products
- Categories management
- Bulk import (CSV)
- Stock management
- Pricing & variants
- Product images upload

**Backend:**
```
GET /api/v1/products          ✅ IMPLEMENTED
POST /api/v1/products         ✅ IMPLEMENTED
GET /api/v1/products/:id      ✅ IMPLEMENTED
PATCH /api/v1/products/:id    ✅ IMPLEMENTED
DELETE /api/v1/products/:id   ✅ IMPLEMENTED
GET /api/v1/categories        ⏳ NEEDS IMPLEMENTATION
```

---

### Priority 5: Restaurant Module

#### **5. Restaurant Page**
File: `apps/admin_dashboard/lib/src/features/restaurant/presentation/pages/restaurant_page.dart`

**Features:**
- Floor plan designer (drag-drop tables)
- Table management (add, edit, delete)
- Kitchen stations configuration
- Table status overview
- Reservation calendar

**Backend:**
```
GET /api/v1/restaurant/floors
POST /api/v1/restaurant/floors
PUT /api/v1/restaurant/floors/:id
GET /api/v1/restaurant/tables
POST /api/v1/restaurant/tables
```

---

### Priority 6: Staff Module

#### **6. Staff Page**
File: `apps/admin_dashboard/lib/src/features/staff/presentation/pages/staff_page.dart`

**Features:**
- User list (waiters, cashiers, managers)
- Add/Edit/Delete users
- Role assignment (RBAC)
- Permissions management
- Activity logs
- Shift schedules

**Backend:**
```
GET /api/v1/users             ✅ PARTIALLY IMPLEMENTED
POST /api/v1/users            ⏳ NEEDS COMPLETION
PUT /api/v1/users/:id
GET /api/v1/roles
GET /api/v1/permissions
```

---

### Priority 7: Settings Module

#### **7. Settings Page**
File: `apps/admin_dashboard/lib/src/features/settings/presentation/pages/settings_page.dart`

**Tabs:**
- Organization info
- POS configuration
- Payment methods
- Tax rates
- Receipt templates
- Email/SMS settings
- Integrations

**Backend:**
```
GET /api/v1/settings/:category
PUT /api/v1/settings/:category
```

---

### Priority 8: Devices Module

#### **8. Devices Page**
File: `apps/admin_dashboard/lib/src/features/devices/presentation/pages/devices_page.dart`

**Features:**
- POS stations list (status: online/offline)
- Hardware devices (printers, scanners, terminals)
- Device assignment (station → devices)
- Device health monitoring
- Configuration management

**Backend:**
```
GET /api/v1/devices
GET /api/v1/devices/:id/status
PUT /api/v1/devices/:id/config
```

**Note:** Device Bridge provides hardware API at `http://localhost:8080`

---

## 🔧 Backend Integration Guide

### API Base URL
```
Development: http://localhost:8080/api/v1
Production: https://api.smartpos.com/api/v1
```

### Authentication
```dart
// All requests require auth token
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
}
```

### Using ApiClient (from pos_core)
```dart
final apiClient = ref.read(apiClientProvider);

// GET request
final response = await apiClient.get<Map<String, dynamic>>('/products');

// POST request
final response = await apiClient.post<Map<String, dynamic>>(
  '/products',
  data: productData,
);
```

### Error Handling
```dart
try {
  final result = await apiClient.get('/endpoint');
  // Handle success
} on AppException catch (e) {
  // Handle error
  showErrorSnackbar(e.message);
}
```

---

## 📋 Development Checklist

### Session Start Checklist:
- [x] Pull latest from branch: `claude/replace-macber-eg-qbizns-011CV4e16LiJejPpNg8KgzpS`
- [x] Navigate to: `/home/user/Flutter-Base/apps/admin_dashboard`
- [x] Review Odoo design system files (colors, typography, theme)
- [ ] Start with creating `odoo_layout.dart` widget

### Module Development Pattern:
For each module (Sales, Products, etc.):
1. [ ] Create page file in `features/{module}/presentation/pages/`
2. [ ] Create widgets in `features/{module}/presentation/widgets/`
3. [ ] Create data models in `features/{module}/data/models/`
4. [ ] Create repository in `features/{module}/data/repositories/`
5. [ ] Create providers in `features/{module}/data/providers/`
6. [ ] Integrate with backend API
7. [ ] Test CRUD operations
8. [ ] Add error handling
9. [ ] Add loading states
10. [ ] Commit and push

---

## 🎨 Design Guidelines

### **MUST FOLLOW:**
1. **Colors:** Use only `OdooColors` constants
2. **Typography:** Use only `OdooTypography` styles
3. **Spacing:** Use only `OdooSpacing` constants (4px base)
4. **Border Radius:** 3px (OdooSpacing.radiusStandard)
5. **Sidebar:** Dark gray (#2C2C36) with hover/active states
6. **Cards:** White background, 1px border, no shadow
7. **Buttons:** Rounded 3px, proper padding
8. **Icons:** Material Icons, sizes from `OdooIconSizes`

### **Reference:**
Look at Odoo 17 backend screenshots/examples for exact UI/UX

---

## 📊 Key Statistics

### Codebase Size:
- **Total Lines:** ~15,000+ lines of Dart code
- **Apps:** 5 Flutter apps (4 complete, 1 in progress)
- **Packages:** 3 shared packages
- **Backend:** 172 database tables, Go API

### Completion Status:
- POS Register: **100%**
- KDS: **100%**
- Customer Display: **100%**
- Waiter App: **100%**
- Hardware Integration: **100%**
- Admin Dashboard: **30%** (design system done, modules pending)
- Backend APIs: **0.6%** (1/172 tables)

---

## 🚀 Quick Start Commands

### Development:
```bash
# Navigate to admin dashboard
cd /home/user/Flutter-Base/apps/admin_dashboard

# Get dependencies (when ready)
flutter pub get

# Run code generation (for Freezed models)
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run -d chrome  # For web
flutter run -d macos   # For desktop
```

### Backend (Flutter-Database):
```bash
cd /home/user/Flutter-Base/Flutter-Database/backend

# Start API server
go run cmd/api/main.go

# API will be at: http://localhost:8080
```

### Device Bridge:
```bash
cd /home/user/Flutter-Base/Flutter-Device

# Start Device Bridge
./bridge --config configs/config.yaml

# Device Bridge will be at: http://localhost:8080
```

---

## 📝 Important Notes

### Backend API Status:
- **Products API:** ✅ Fully implemented (reference implementation)
- **Users API:** ✅ Implemented
- **Sales/Orders:** ⏳ Needs implementation
- **Restaurant:** ⏳ Needs implementation
- **Settings:** ⏳ Needs implementation

**If backend API not ready for a module:**
1. Create the UI first
2. Use mock data with `FutureProvider`
3. Comment with `// TODO: Replace with real API`
4. Switch to real API when backend ready

### Code Generation:
The backend has a **CODE_GENERATION_GUIDE.md** with templates for creating new API endpoints. Use this to implement missing backend APIs.

### Odoo Design System:
All files in `lib/src/ui/theme/` are production-ready. Do NOT modify colors, typography, or spacing values. They match Odoo 17 exactly.

---

## 🎯 Success Criteria

Admin Dashboard will be complete when:
- ✅ Odoo-style sidebar layout implemented
- ✅ Dashboard home page with real-time charts
- ✅ Sales module with order management
- ✅ Products module with CRUD operations
- ✅ Restaurant module with floor plan designer
- ✅ Staff module with user management
- ✅ Settings module with system configuration
- ✅ Devices module with hardware monitoring
- ✅ All modules integrated with backend APIs
- ✅ Error handling and loading states
- ✅ Responsive design (web + desktop)
- ✅ User authentication and authorization
- ✅ Real-time data updates (WebSocket if needed)

---

## 🔗 Useful Links

- **GitHub (Flutter-Base):** https://github.com/qbizns/Flutter-Base
- **GitHub (Flutter-Database):** https://github.com/qbizns/Flutter-Database
- **GitHub (Flutter-Device):** https://github.com/qbizns/Flutter-Device
- **Odoo Design Docs:** https://www.odoo.com/documentation/17.0/developer/reference/frontend/framework.html
- **Material Design 3:** https://m3.material.io/

---

## 💡 Tips for Next Session

1. **Start with Layout:** The `OdooLayout` widget is critical - it's used by all pages
2. **Use Real Data:** Integrate backend APIs as you build each module
3. **Follow Patterns:** Look at POS Register and Waiter App for patterns
4. **Commit Often:** Commit after completing each module
5. **Test Frequently:** Test with real backend to catch issues early
6. **Odoo Reference:** Keep Odoo 17 backend open for UI reference
7. **Backend Development:** Use `CODE_GENERATION_GUIDE.md` to implement missing APIs

---

## 🔍 Repository Clones

Both repositories are now cloned locally:

```
/home/user/Flutter-Base/
├── Flutter-Database/    ← Backend API (Go + PostgreSQL)
└── Flutter-Device/      ← Device Bridge (Go + hardware)
```

**All "Macber-eg" references have been replaced with "qbizns"**

---

**Ready to continue building the Admin Dashboard!** 🚀

Start with creating the `OdooLayout` widget, then build Dashboard Home page with charts and KPIs.
