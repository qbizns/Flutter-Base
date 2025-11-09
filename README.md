# Flutter Starter

**Your Production-Ready Flutter Foundation**

A production-grade Flutter starter template featuring clean architecture, Material 3 design, multi-platform support, and a scalable foundation for building modern cross-platform applications.

## ✨ Features

- **🎯 Clean Architecture**: Feature-first organization with clear separation of concerns (Presentation, Application, Domain, Data layers)
- **🎨 Material 3 Design**: Modern UI with dynamic theming and dark mode support
- **📱 Multi-Platform**: Single codebase supporting Web, iOS, Android, Windows, macOS, and Linux
- **🔄 State Management**: Riverpod for robust state management and dependency injection
- **🧭 Type-Safe Routing**: go_router with typed routes and navigation
- **📐 Responsive Design**: Adaptive layouts for mobile, tablet, and desktop
- **✅ Testing Ready**: Example unit tests and widget tests included
- **🔍 Linting**: Comprehensive linting rules with flutter_lints
- **🏗️ Scalable**: Ready to grow from a simple app to a large-scale application

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
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
    │   ├── config/
    │   │   ├── app_config.dart        # App configuration
    │   │   └── env.dart               # Environment management
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
            │   └── usecases/
            │       └── load_welcome_content.dart
            └── data/                  # Data layer
                ├── repositories/
                │   └── welcome_repository_impl.dart
                └── sources/
                    └── local_welcome_source.dart

test/
├── unit/                              # Unit tests
│   └── welcome_repository_test.dart
└── widget/                            # Widget tests
    └── welcome_page_test.dart

assets/
├── logo/                              # App logo assets
├── images/                            # Image assets
└── fonts/                             # Font assets
```

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
   │   └── usecases/
   └── data/
       ├── repositories/
       └── sources/
   ```

2. **Define domain entities** (business models)

3. **Create use cases** (business logic)

4. **Implement data layer** (repositories, data sources)

5. **Build application layer** (controllers with Riverpod)

6. **Create presentation layer** (pages and widgets)

7. **Add routes** in `lib/src/core/routing/`

8. **Write tests** in `test/` directory

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
