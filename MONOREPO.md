# SmartPOS Monorepo

**Single Flutter Monorepo for the Entire SmartPOS Ecosystem**

This repository contains all 16+ POS apps for restaurants and retail, sharing core libraries, UI components, and infrastructure.

---

## 🏗️ Monorepo Structure

```
smartpos_ecosystem/
├── apps/                           # All POS applications
│   └── pos_register/              # Main POS register app ✨ READY
│       ├── lib/
│       │   └── main.dart          # App entry point
│       ├── assets/config/         # App-specific configuration
│       └── pubspec.yaml           # App dependencies
│
├── packages/                       # Shared packages
│   ├── pos_core/                  # Core business logic ✅ COMPLETE
│   │   ├── lib/src/
│   │   │   ├── bootstrap/         # App initialization
│   │   │   ├── core/              # Shared infrastructure
│   │   │   │   ├── auth/          # Authentication
│   │   │   │   ├── context/       # Multi-tenancy context
│   │   │   │   ├── config/        # Configuration system
│   │   │   │   ├── errors/        # Error handling (Result<T>)
│   │   │   │   ├── network/       # API client
│   │   │   │   ├── storage/       # Local storage
│   │   │   │   ├── l10n/          # Localization
│   │   │   │   ├── theme/         # Theming system
│   │   │   │   ├── routing/       # Navigation
│   │   │   │   ├── widgets/       # Shared widgets
│   │   │   │   └── utils/         # Utilities
│   │   │   └── features/          # Shared features
│   │   │       ├── auth/          # Auth UI (splash, sign-in, etc.)
│   │   │       ├── onboarding/    # Onboarding flow
│   │   │       ├── home_shell/    # Main app shell
│   │   │       └── profile/       # User profile
│   │   ├── assets/                # Shared assets
│   │   └── pubspec.yaml
│   │
│   ├── pos_ui/                    # Unified UI component library ✅ COMPLETE
│   │   ├── lib/src/
│   │   │   ├── foundation/        # Base components
│   │   │   │   ├── pos_button.dart
│   │   │   │   ├── pos_card.dart
│   │   │   │   └── pos_text_field.dart
│   │   │   ├── layout/            # Layout components
│   │   │   │   ├── pos_scaffold.dart
│   │   │   │   └── pos_app_bar.dart
│   │   │   └── widgets/           # Domain widgets
│   │   │       ├── empty_state_view.dart
│   │   │       └── error_view.dart
│   │   └── pubspec.yaml
│   │
│   └── device_bridge_client/      # Hardware abstraction ✅ COMPLETE
│       ├── lib/src/
│       │   ├── device_bridge_client.dart
│       │   ├── device_bridge_command.dart
│       │   ├── device_bridge_event.dart
│       │   └── device_types.dart
│       └── pubspec.yaml
│
├── melos.yaml                      # Monorepo configuration
├── README.md                       # Main documentation
├── MONOREPO.md                     # This file
└── PHASE_1_IMPLEMENTATION.md       # Phase 1 details

```

---

## 📦 Package Overview

### pos_core
**Core business logic and shared features**

Contains:
- **Bootstrap**: App initialization system
- **Auth**: Complete authentication system (email/password + PIN)
- **Context**: Multi-tenant context (tenant/branch/device/station)
- **Config**: JSON-driven configuration + feature flags
- **Errors**: Result<T> pattern for type-safe error handling
- **Network**: API client with automatic error handling
- **Storage**: Local storage abstraction
- **L10n**: Localization support (en, ar)
- **Theme**: Material 3 theming system
- **Routing**: go_router integration
- **Features**: Shared UI features (auth, onboarding, home_shell, profile)

**Dependencies**: flutter, riverpod, go_router, dio, shared_preferences, equatable, intl

### pos_ui
**Unified POS UI component library**

Contains:
- **Foundation**: Base components (buttons, cards, text fields)
- **Layout**: Scaffold, app bar, navigation
- **Widgets**: Empty states, error views
- **POS Domain Widgets** (to be added):
  - Table maps
  - Product grids
  - Order/cart views
  - Payment flows
  - KDS displays
  - Kiosk UI

**Dependencies**: flutter, pos_core, riverpod, equatable

### device_bridge_client
**Hardware abstraction client**

Flutter apps NEVER talk directly to hardware. Instead, they communicate with an external Go "device_bridge" service that handles all hardware interactions.

Supports:
- Printers (receipts, labels, KDS)
- Scanners (barcodes, QR codes)
- Cash drawers
- Scales
- Customer displays
- PIN pads
- Card readers

**Dependencies**: flutter, pos_core, dio, equatable

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.24.0 or higher)
- Dart SDK (3.5.0 or higher)
- Melos (for monorepo management)

### Installation

1. **Install Melos**:
   ```bash
   dart pub global activate melos
   ```

2. **Bootstrap the monorepo**:
   ```bash
   melos bootstrap
   ```

   This will:
   - Run `flutter pub get` in all packages and apps
   - Link local package dependencies
   - Set up the monorepo

3. **Generate code** (for Riverpod providers):
   ```bash
   melos run build_runner
   ```

### Running an App

```bash
# Navigate to an app directory
cd apps/pos_register

# Run the app
flutter run -d chrome  # or any device
```

Or use Melos to run from root:
```bash
melos exec --scope=pos_register -- flutter run -d chrome
```

---

## 📝 Creating a New App

To add a new POS app to the ecosystem:

1. **Create app directory**:
   ```bash
   mkdir -p apps/pos_<app_name>/{lib,assets/config,test}
   ```

2. **Create `pubspec.yaml`**:
   ```yaml
   name: pos_<app_name>
   description: <App description>
   version: 1.0.0+1

   dependencies:
     flutter:
       sdk: flutter
     pos_core:
       path: ../../packages/pos_core
     pos_ui:
       path: ../../packages/pos_ui
     device_bridge_client:
       path: ../../packages/device_bridge_client
     flutter_riverpod: ^2.6.1
   ```

3. **Create `lib/main.dart`**:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:pos_core/pos_core.dart';

   void main() {
     AppBootstrap.run(
       environment: Environment.development,
       appBuilder: (config) => const MyPosApp(),
     );
   }

   class MyPosApp extends StatelessWidget {
     const MyPosApp({super.key});

     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         title: 'My POS App',
         theme: AppTheme.lightTheme,
         home: const MyHomePage(),
       );
     }
   }
   ```

4. **Create `assets/config/app_config_dev.json`**:
   ```json
   {
     "appName": "My POS App (Dev)",
     "appId": "com.smartpos.<app_name>",
     "appType": "<app_type>",
     "apiBaseUrl": "https://api-dev.example.com",
     "featureFlags": {
       "enableTables": true,
       "enableOrders": true
     },
     "enabledFeatures": [
       "auth",
       "home_shell",
       "profile"
     ]
   }
   ```

5. **Run bootstrap** to link dependencies:
   ```bash
   melos bootstrap
   ```

---

## 🛠️ Melos Commands

```bash
# Bootstrap monorepo (run after cloning or adding packages)
melos bootstrap

# Run flutter pub get in all packages
melos run get

# Run flutter analyze in all packages
melos run analyze

# Run dart format in all packages
melos run format

# Run tests in all packages
melos run test

# Run build_runner in all packages
melos run build_runner

# Clean all packages
melos run clean

# Execute a command in specific package
melos exec --scope=pos_core -- flutter test

# Execute a command in all apps
melos exec --scope="pos_*" --dir-exists=apps -- flutter build web
```

---

## 🎯 Planned Apps

The ecosystem will contain these apps (16+):

### Restaurant POS
1. **pos_register** ✨ - Main POS register terminal
2. **pos_kds** - Kitchen Display System
3. **pos_kiosk** - Self-service ordering kiosk
4. **pos_handheld** - Waiter/server handheld ordering
5. **pos_customer_display** - Customer-facing display
6. **pos_qr_ordering** - Table/QR ordering app

### Retail POS
7. **pos_retail** - Retail POS mode

### Inventory & Stock
8. **pos_inventory** - Stock management handheld
9. **pos_price_checker** - Price checker kiosk

### Management & Analytics
10. **pos_owner** - Owner/manager analytics dashboard
11. **pos_reporting_console** - Advanced reporting

### Operations
12. **pos_delivery_driver** - Driver delivery app
13. **pos_staff_time** - Staff time & attendance
14. **pos_backoffice_tools** - Internal operations tools

### Customer-Facing
15. **pos_loyalty_customer** - Customer loyalty mobile app

### Development
16. **pos_ui_gallery** - Component showcase for designers/devs

---

## 🔧 Configuration System

Each app is config-driven via JSON files in `assets/config/`:

```json
{
  "appName": "SmartPOS Register",
  "appId": "com.smartpos.register",
  "appType": "register",
  "posMode": "restaurant",
  "apiBaseUrl": "https://api.example.com",
  "realtimeUrl": "wss://realtime.example.com",
  "deviceBridgeUrl": "http://localhost:8080",
  "featureFlags": {
    "enableTables": true,
    "enableKitchenPrinting": true,
    "enableOfflineMode": true,
    "enableDeviceBridge": true
  },
  "enabledFeatures": [
    "auth",
    "onboarding",
    "home_shell",
    "tables",
    "orders",
    "payments"
  ]
}
```

**Benefits**:
- Zero-code rebranding
- Feature toggling per app
- Environment-specific configs (dev/staging/prod)
- Easy customization per tenant/customer

---

## 🏛️ Architecture Principles

### Clean Architecture
- Domain layer (entities, repositories interfaces)
- Data layer (repository implementations, data sources)
- Application layer (use cases, business logic)
- Presentation layer (UI, controllers)

### Dependency Flow
```
Presentation → Application → Domain ← Data
```

**Rule**: Domain NEVER imports Data

### Feature-First Organization
Each feature is self-contained with all layers:
```
features/orders/
├── presentation/  (UI, pages, widgets)
├── application/   (controllers, use cases)
├── domain/        (entities, repository interfaces)
└── data/          (repository impl, data sources)
```

### Shared-First Thinking
- Always push common logic to pos_core
- Always push common UI to pos_ui
- Keep apps thin (configuration + wiring)

---

## 📚 Documentation

- **README.md** - Main project overview and setup
- **MONOREPO.md** - This file (monorepo structure and guidelines)
- **PHASE_1_IMPLEMENTATION.md** - Phase 1 (Auth & Navigation) details
- **packages/pos_core/README.md** - Core package documentation (to be added)
- **packages/pos_ui/README.md** - UI library documentation (to be added)
- **packages/device_bridge_client/README.md** - Device bridge docs (to be added)

---

## 🎨 UI Component Library (pos_ui)

### Foundation Components
- `PosButton` - Styled buttons (primary, secondary, outlined, text)
- `PosCard` - Card component
- `PosTextField` - Text input fields

### Layout Components
- `PosScaffold` - Base scaffold
- `PosAppBar` - App bar

### Domain Widgets
- `EmptyStateView` - Empty state display
- `ErrorView` - Error display

### To Be Added
- Table management widgets
- Product grid/list widgets
- Order/cart widgets
- Payment flow widgets
- KDS display widgets
- Kiosk UI widgets

---

## 🧪 Testing Strategy

Each package and app should have:
- **Unit tests**: Business logic, use cases, repositories
- **Widget tests**: UI components
- **Integration tests**: Feature flows

Run all tests:
```bash
melos run test
```

---

## 🚢 Deployment

### Web
```bash
cd apps/pos_register
flutter build web --release
```

### Mobile
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### Desktop
```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

---

## 📈 Roadmap

### Phase 1: Core UX & Identity ✅ COMPLETE
- Auth system
- Onboarding
- Home shell
- Profile
- Multi-tenancy context

### Phase 2: Communication & Money (Next)
- Notifications
- Messaging
- Payments integration

### Phase 3: POS Power Features
- Realtime sync
- Offline mode
- Advanced RBAC
- Analytics

### Phase 4: Device Bridge & Polish
- Hardware integration
- Responsive design improvements
- Form builders
- Advanced UI components

---

## 🤝 Contributing

1. Create feature branches
2. Keep commits focused and atomic
3. Write tests for new features
4. Update documentation
5. Run `melos run format` and `melos run analyze` before committing

---

## 📄 License

This is proprietary software for SmartPOS ecosystem.

---

**Built with ❤️ using Flutter and Clean Architecture**
