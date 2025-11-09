# Flutter Starter

**Your Production-Ready Flutter Foundation**

A production-grade Flutter starter template featuring clean architecture, Material 3 design, multi-platform support, complete authentication system, and a scalable foundation for building modern cross-platform applications.

## ✨ Features

### Core Features
- **🎯 Clean Architecture**: Feature-first organization with clear separation of concerns (Presentation, Application, Domain, Data layers)
- **🔐 Authentication System**: Complete auth flow with email/password and PIN login, sign-up, password reset with OTP
- **👤 User Management**: Session persistence, multi-tenant support, RBAC (roles & permissions)
- **🎨 Material 3 Design**: Modern UI with dynamic theming and dark mode support
- **📱 Multi-Platform**: Single codebase supporting Web, iOS, Android, Windows, macOS, and Linux
- **🔄 State Management**: Riverpod for robust state management and dependency injection
- **🧭 Type-Safe Routing**: go_router with typed routes and navigation
- **📐 Responsive Design**: Adaptive layouts for mobile, tablet, and desktop
- **🌐 Multi-Tenancy**: Built-in support for tenant/branch/device/station tracking
- **🔧 Configuration-Driven**: JSON-based configuration for zero-code rebranding
- **✅ Testing Ready**: Example unit tests and widget tests included
- **🔍 Linting**: Comprehensive linting rules with flutter_lints
- **🏗️ Scalable**: Ready to grow from a simple app to a large-scale application

### Authentication Features
- **Email/Password Login**: Traditional authentication with validation
- **PIN Login**: Quick access for POS terminals and kiosks
- **User Registration**: Sign-up with email verification flow
- **Password Recovery**: Forgot password with OTP verification
- **Session Management**: Automatic session persistence and restoration
- **Token Refresh**: Automatic auth token renewal
- **Logout**: Secure sign-out with confirmation

### Infrastructure
- **Network Layer**: Dio-based API client with automatic error handling
- **Storage Layer**: SharedPreferences abstraction for local data
- **Error Handling**: Result<T> pattern for type-safe error handling
- **Localization**: i18n support with English and Arabic (extensible)
- **Feature Flags**: Configuration-based feature toggles

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Phase 1: Core UX & Identity](#phase-1-core-ux--identity)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Authentication Flow](#authentication-flow)
- [API Contract](#api-contract)
- [Running the App](#running-the-app)
- [Platform-Specific Setup](#platform-specific-setup)
- [Testing](#testing)
- [Adding New Features](#adding-new-features)
- [Customization](#customization)
- [Best Practices](#best-practices)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.24.0 or higher)
- Dart SDK (3.5.0 or higher)
- Platform-specific requirements (see [Platform-Specific Setup](#platform-specific-setup))

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_starter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   # For web
   flutter run -d chrome

   # For mobile
   flutter run

   # For desktop
   flutter run -d windows  # or macos, linux
   ```

## 🎯 Phase 1: Core UX & Identity

The template now includes a complete **Phase 1 implementation** providing authentication and navigation infrastructure ready for production use.

### What's Included

#### 🔐 Authentication System (`core/auth/`)
- **AuthState**: User session management with multi-tenancy and RBAC
- **AuthRepository**: Clean architecture interface for auth operations
- **SessionManager**: Automatic session persistence and restoration
- **Supported Operations**:
  - Email/password login
  - PIN login (for POS terminals)
  - User registration
  - Password reset with OTP
  - Token refresh
  - Logout

#### 🏢 Multi-Tenancy (`core/context/`)
- **AppContext**: Track tenant, branch, device, and station information
- Persistent context across app restarts
- Perfect for POS systems and multi-location apps

#### 📱 Authentication UI (`features/auth/`)
- Splash screen with session check
- Sign-in page (dual mode: email/password or PIN)
- Sign-up page with validation
- Forgot password flow
- OTP verification page
- Material 3 design throughout

#### 🚀 Onboarding (`features/onboarding/`)
- Swipeable introduction slides
- Skip option
- Completion tracking

#### 🏠 Home Shell (`features/home_shell/`)
- Bottom navigation container
- 4 configurable tabs (Home, Analytics, Orders, More)
- Profile access from app bar

#### 👤 Profile Page (`features/profile/`)
- User information display
- RBAC visibility (roles & permissions)
- Logout with confirmation

### Backend Integration

The app expects a REST API with the following endpoints:
- `POST /auth/login` - Email/password authentication
- `POST /auth/login/pin` - PIN authentication
- `POST /auth/signup` - User registration
- `POST /auth/refresh` - Token refresh
- `POST /auth/password/reset/request` - Request password reset
- `POST /auth/verify` - Verify OTP code
- `POST /auth/password/reset` - Complete password reset
- `POST /auth/logout` - Sign out
- `GET /auth/me` - Get current user info

See [PHASE_1_IMPLEMENTATION.md](PHASE_1_IMPLEMENTATION.md) for detailed API contract specifications.

### Quick Start with Phase 1

1. **Run code generation** (required):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Configure your API**:
   - Update `apiBaseUrl` in `assets/config/app_config_dev.json`

3. **Run the app**:
   ```bash
   flutter run
   ```

4. **Test the flow**:
   - App starts at splash screen
   - Auto-navigates to sign-in (if not logged in)
   - Sign up or sign in
   - Explore home shell with bottom navigation
   - View profile and logout

## 🏛️ Architecture

This template follows **Clean Architecture** principles with a **feature-first** approach:

### Layer Separation

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│   (UI, Pages, Widgets, Controllers)     │
├─────────────────────────────────────────┤
│         Application Layer               │
│    (Use Cases, Business Logic)          │
├─────────────────────────────────────────┤
│           Domain Layer                  │
│      (Entities, Interfaces)             │
├─────────────────────────────────────────┤
│            Data Layer                   │
│  (Repositories, Data Sources, DTOs)     │
└─────────────────────────────────────────┘
```

### Key Architectural Decisions

1. **Feature-First Organization**: Each feature is self-contained with all its layers
2. **Dependency Injection**: Riverpod providers for all dependencies
3. **Separation of Concerns**: Clear boundaries between layers
4. **Testability**: Each layer can be tested independently
5. **Scalability**: Easy to add new features without affecting existing code

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
└── src/
    ├── bootstrap/
    │   └── app_bootstrap.dart         # App initialization
    ├── core/                          # Core/shared functionality
    │   ├── auth/                      # Authentication module ✨ NEW
    │   │   ├── auth_state.dart        # User session state
    │   │   ├── auth_repository.dart   # Auth interface
    │   │   ├── auth_repository_impl.dart # Auth implementation
    │   │   ├── session_manager.dart   # Session persistence
    │   │   └── auth_providers.dart    # Riverpod providers
    │   ├── context/                   # App context module ✨ NEW
    │   │   ├── app_context.dart       # Multi-tenant context
    │   │   └── context_providers.dart # Context providers
    │   ├── config/
    │   │   ├── app_config.dart        # App configuration
    │   │   ├── config_loader.dart     # JSON config loader
    │   │   ├── config_providers.dart  # Config providers
    │   │   ├── env.dart               # Environment management
    │   │   └── feature_flags.dart     # Feature toggles
    │   ├── errors/                    # Error handling ✨ NEW
    │   │   ├── result.dart            # Result<T> pattern
    │   │   ├── failure.dart           # Failure types
    │   │   └── app_exception.dart     # Custom exceptions
    │   ├── network/                   # Network layer ✨ NEW
    │   │   ├── api_client.dart        # HTTP client
    │   │   └── api_providers.dart     # Network providers
    │   ├── storage/                   # Storage layer ✨ NEW
    │   │   ├── app_storage.dart       # Storage interface
    │   │   ├── shared_prefs_storage.dart # Implementation
    │   │   └── storage_providers.dart # Storage providers
    │   ├── l10n/                      # Localization ✨ NEW
    │   │   └── app_localizations.dart # i18n support
    │   ├── theme/
    │   │   ├── app_theme.dart         # Theme configuration
    │   │   ├── app_colors.dart        # Color palette
    │   │   └── app_typography.dart    # Typography system
    │   ├── routing/
    │   │   ├── app_router.dart        # Router configuration
    │   │   └── routes.dart            # Route definitions
    │   ├── widgets/
    │   │   ├── app_scaffold.dart      # Base scaffold
    │   │   └── responsive_layout.dart # Responsive utilities
    │   └── utils/
    │       ├── logger.dart            # Logging utility
    │       └── platform_info.dart     # Platform detection
    └── features/                      # Feature modules
        ├── auth/                      # Auth features ✨ NEW
        │   └── presentation/
        │       └── pages/
        │           ├── splash_page.dart        # Splash/loading
        │           ├── sign_in_page.dart       # Sign in
        │           ├── sign_up_page.dart       # Registration
        │           ├── forgot_password_page.dart # Password reset
        │           └── verification_page.dart  # OTP verification
        ├── onboarding/                # Onboarding ✨ NEW
        │   └── presentation/
        │       └── pages/
        │           └── onboarding_page.dart    # Intro slides
        ├── home_shell/                # Main shell ✨ NEW
        │   └── presentation/
        │       └── pages/
        │           └── home_shell_page.dart    # Bottom nav
        ├── profile/                   # User profile ✨ NEW
        │   └── presentation/
        │       └── pages/
        │           └── profile_page.dart       # Profile view
        └── welcome/                   # Welcome feature example
            ├── presentation/          # UI layer
            │   ├── pages/
            │   │   └── welcome_page.dart
            │   └── widgets/
            │       ├── welcome_header.dart
            │       └── welcome_cta_section.dart
            ├── application/           # Application logic
            │   └── welcome_controller.dart
            ├── domain/                # Business logic
            │   ├── entities/
            │   │   └── welcome_message.dart
            │   ├── repositories/
            │   │   └── welcome_repository.dart
            │   └── usecases/
            │       └── load_welcome_content.dart
            └── data/                  # Data layer
                ├── repositories/
                │   └── welcome_repository_impl.dart
                └── sources/
                    └── local_welcome_source.dart

test/
├── unit/                              # Unit tests
│   ├── core/
│   │   └── result_test.dart          # Result pattern tests ✨ NEW
│   └── welcome_repository_test.dart
└── widget/                            # Widget tests
    └── welcome_page_test.dart

assets/
├── config/                            # Configuration files ✨ NEW
│   ├── app_config_dev.json           # Dev config
│   ├── app_config_staging.json       # Staging config
│   └── app_config_prod.json          # Production config
├── l10n/                              # Translations ✨ NEW
│   ├── en.json                        # English
│   └── ar.json                        # Arabic
├── logo/                              # App logo assets
├── images/                            # Image assets
└── fonts/                             # Font assets
```

## 🔐 Authentication Flow

The app implements a complete authentication flow with multiple entry points:

### Initial App Launch Flow

```
App Start
    ↓
Splash Screen (checks saved session)
    ↓
    ├─→ Session Found & Valid → Home Shell
    │                             ↓
    │                          Bottom Nav (4 tabs)
    │                             ↓
    │                          Profile (via app bar)
    │
    └─→ No Session → Sign In Page
                        ↓
                        ├─→ Sign Up → Create Account → Home Shell
                        ├─→ Forgot Password → OTP → Reset → Sign In
                        └─→ Login (Email/PIN) → Home Shell
```

### Sign In Options

1. **Email/Password Mode**:
   - Standard authentication
   - Form validation
   - "Forgot Password?" link
   - "Sign Up" link

2. **PIN Mode**:
   - Quick access for POS terminals
   - 4+ digit PIN
   - Device and branch association

### Password Reset Flow

```
Sign In → Forgot Password → Enter Email/Phone → Send Code
    ↓
Verification Page → Enter OTP → Verify
    ↓
Success → Enter New Password → Reset → Sign In
```

### Session Management

- **Auto-Restore**: Sessions are automatically restored on app restart
- **Token Refresh**: Auth tokens are automatically renewed
- **Secure Logout**: Clears both local session and server-side token

## 📡 API Contract

The app expects a REST API with these endpoints. See [PHASE_1_IMPLEMENTATION.md](PHASE_1_IMPLEMENTATION.md) for detailed request/response formats.

### Authentication Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/login` | POST | Email/password authentication |
| `/auth/login/pin` | POST | PIN authentication for POS |
| `/auth/signup` | POST | User registration |
| `/auth/refresh` | POST | Refresh auth token |
| `/auth/password/reset/request` | POST | Request password reset code |
| `/auth/verify` | POST | Verify OTP code |
| `/auth/password/reset` | POST | Complete password reset |
| `/auth/logout` | POST | Sign out user |
| `/auth/me` | GET | Get current user info |

### Expected Response Format

All auth endpoints should return user data in this format:

```json
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "user": {
    "id": "user123",
    "email": "user@example.com",
    "name": "John Doe",
    "phone": "+1234567890",
    "avatarUrl": "https://...",
    "tenantId": "tenant123",
    "branchId": "branch456",
    "roles": ["cashier", "manager"],
    "permissions": ["view_orders", "create_orders"]
  }
}
```

### Error Handling

The app uses a `Result<T>` pattern for type-safe error handling:

- **Success**: Returns the expected data
- **Failure**: Returns typed failure (network, server, auth, validation)
- No exceptions for control flow

## 🏃 Running the App

### All Platforms

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release -d <device-id>
```

### Web

```bash
# Chrome
flutter run -d chrome

# Choose web renderer
flutter run -d chrome --web-renderer html      # HTML renderer
flutter run -d chrome --web-renderer canvaskit # CanvasKit renderer (default)
```

### Mobile

```bash
# iOS (requires macOS with Xcode)
flutter run -d ios

# Android
flutter run -d android
```

### Desktop

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## 🔧 Platform-Specific Setup

### iOS

1. **Requirements**:
   - macOS with Xcode installed
   - CocoaPods (`sudo gem install cocoapods`)

2. **Setup**:
   ```bash
   cd ios
   pod install
   cd ..
   ```

3. **Configuration**:
   - Update bundle identifier in `ios/Runner.xcodeproj`
   - Configure signing in Xcode

### Android

1. **Requirements**:
   - Android Studio
   - Android SDK

2. **Configuration**:
   - Update `applicationId` in `android/app/build.gradle`
   - Update app name in `android/app/src/main/AndroidManifest.xml`

### Web

1. **Optimization**:
   ```bash
   # Build for production
   flutter build web --release

   # Build with specific renderer
   flutter build web --web-renderer canvaskit
   ```

2. **Configuration**:
   - Update `index.html` in `web/` directory
   - Configure manifest.json for PWA support

### Windows

1. **Requirements**:
   - Visual Studio 2022 with C++ desktop development

2. **Build**:
   ```bash
   flutter build windows --release
   ```

### macOS

1. **Requirements**:
   - Xcode command line tools

2. **Configuration**:
   - Update bundle identifier in `macos/Runner.xcodeproj`
   - Configure entitlements for required permissions

3. **Build**:
   ```bash
   flutter build macos --release
   ```

### Linux

1. **Requirements**:
   - Linux development libraries
   ```bash
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
   ```

2. **Build**:
   ```bash
   flutter build linux --release
   ```

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Tests

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Specific test file
flutter test test/unit/welcome_repository_test.dart
```

### Coverage

```bash
# Generate coverage
flutter test --coverage

# View coverage (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## ➕ Adding New Features

Follow the welcome feature structure to add new features:

1. **Create feature directory structure**:
   ```bash
   lib/src/features/your_feature/
   ├── presentation/
   │   ├── pages/
   │   └── widgets/
   ├── application/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/      # Repository interfaces
   │   └── usecases/
   └── data/
       ├── repositories/      # Repository implementations
       └── sources/
   ```

2. **Define domain entities** (business models in `domain/entities/`)

3. **Define repository interfaces** (contracts in `domain/repositories/`)

4. **Create use cases** (business logic in `domain/usecases/`)

5. **Implement data layer** (repository implementations in `data/repositories/`, data sources in `data/sources/`)

6. **Build application layer** (controllers with Riverpod)

7. **Create presentation layer** (pages and widgets)

8. **Add routes** in `lib/src/core/routing/`

9. **Write tests** in `test/` directory

## 🎨 Customization

### Theme

- **Colors**: Edit `lib/src/core/theme/app_colors.dart`
- **Typography**: Edit `lib/src/core/theme/app_typography.dart`
- **Theme**: Edit `lib/src/core/theme/app_theme.dart`

### App Name & Identity

1. **Update `pubspec.yaml`**:
   ```yaml
   name: your_app_name
   description: Your app description
   ```

2. **Update app display name**:
   - iOS: `ios/Runner/Info.plist`
   - Android: `android/app/src/main/AndroidManifest.xml`
   - Web: `web/index.html` and `web/manifest.json`
   - Windows: `windows/runner/Runner.rc`
   - macOS: `macos/Runner/Info.plist`
   - Linux: `linux/my_application.cc`

### Fonts

1. Place font files in `assets/fonts/`
2. Update `pubspec.yaml` fonts section
3. Update `_fontFamily` in `app_typography.dart`

### Logo

1. Place logo files in `assets/logo/`
2. Update Welcome screen in `welcome_page.dart`

## 📚 Best Practices

### Code Organization

- Keep features self-contained and independent
- Use barrel files (`index.dart`) for cleaner imports
- Follow Dart style guide and linting rules

### State Management

- Use Riverpod providers for all state and dependencies
- Keep controllers thin, move logic to use cases
- Use code generation for providers when possible

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `lowerCamelCase` or `SCREAMING_SNAKE_CASE`

### Testing

- Write tests for all business logic
- Test edge cases and error scenarios
- Mock dependencies in tests
- Aim for high code coverage

### Performance

- Use `const` constructors where possible
- Optimize images and assets
- Use lazy loading for expensive operations
- Profile your app regularly

### Git Workflow

- Keep commits atomic and focused
- Write descriptive commit messages
- Create feature branches for new work
- Review code before merging

## 🔒 Security

- Never commit sensitive data (API keys, credentials)
- Use environment variables for configuration
- Validate all user inputs
- Keep dependencies up to date

## 📄 License

This template is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please follow the existing code style and add tests for new features.

## 📞 Support

For issues and questions, please create an issue in the repository.

---

**Happy coding! 🚀**
