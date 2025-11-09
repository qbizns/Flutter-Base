# Quick Start Guide

Get your Flutter Starter template up and running in minutes!

## Prerequisites

Before you begin, ensure you have:

- ✅ **Flutter SDK** (3.24.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- ✅ **Dart SDK** (3.5.0 or higher) - Included with Flutter
- ✅ **Code Editor** - VS Code, Android Studio, or IntelliJ IDEA
- ✅ **Git** - For version control

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd flutter_starter
```

### 2. Run Setup Script (Recommended)

**Linux/macOS:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows (PowerShell):**
```powershell
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Manual Setup (Alternative)

If the setup script doesn't work:

```bash
# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Verify installation
flutter doctor
flutter analyze
flutter test
```

## Running the App

### Web (Fastest for Development)

```bash
flutter run -d chrome
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

## Project Structure at a Glance

```
lib/
├── main.dart                    # Entry point
└── src/
    ├── core/                    # Shared utilities
    │   ├── config/              # Configuration
    │   ├── theme/               # App theming
    │   ├── routing/             # Navigation
    │   └── widgets/             # Reusable widgets
    └── features/                # Feature modules
        └── welcome/             # Example feature
```

## First Steps

### 1. Customize Your App

**Update app name and configuration:**

Edit `lib/src/core/config/app_config.dart`:
```dart
factory AppConfig.dev() => const AppConfig(
  appName: 'Your App Name',           // ← Change this
  appTagline: 'Your Amazing Tagline', // ← Change this
  // ...
);
```

### 2. Update Colors

Edit `lib/src/core/theme/app_colors.dart`:
```dart
static const Color primary = Color(0xFF6750A4); // ← Your color
```

### 3. Add Your Logo

1. Place your logo in `assets/logo/logo.png`
2. Update the welcome screen if needed

### 4. Run the App

```bash
flutter run -d chrome
```

You should see the Welcome screen with your changes!

## Development Workflow

### 1. Create a New Feature

```bash
mkdir -p lib/src/features/your_feature/{presentation/{pages,widgets},application,domain/{entities,usecases},data/{repositories,sources}}
```

### 2. Generate Code (After Adding Providers)

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on save)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 3. Run Tests

```bash
# All tests
flutter test

# Specific test
flutter test test/unit/welcome_repository_test.dart

# With coverage
flutter test --coverage
```

### 4. Format Code

```bash
dart format lib/ test/
```

### 5. Analyze Code

```bash
flutter analyze
```

## Common Commands

### Development
```bash
flutter run -d chrome                    # Run on Chrome
flutter run -d chrome --release          # Release mode
flutter pub run build_runner watch       # Auto-generate code
flutter test --watch                     # Watch tests
```

### Building
```bash
flutter build web --release              # Web production build
flutter build apk --release              # Android APK
flutter build appbundle --release        # Android App Bundle
flutter build ios --release              # iOS build
flutter build windows --release          # Windows build
flutter build macos --release            # macOS build
flutter build linux --release            # Linux build
```

### Maintenance
```bash
flutter clean                            # Clean build files
flutter pub get                          # Update dependencies
flutter pub upgrade                      # Upgrade dependencies
flutter doctor                           # Check environment
```

## IDE Setup

### VS Code

1. **Install Extensions:**
   - Flutter
   - Dart
   - Error Lens (optional)
   - Better Comments (optional)

2. **Recommended Settings** (`.vscode/settings.json`):
   ```json
   {
     "dart.lineLength": 80,
     "editor.formatOnSave": true,
     "editor.rulers": [80],
     "dart.previewFlutterUiGuides": true
   }
   ```

### Android Studio / IntelliJ

1. **Install Plugins:**
   - Flutter plugin
   - Dart plugin

2. **Enable:**
   - Format on save
   - Optimize imports on save

## Troubleshooting

### Problem: "flutter: command not found"
**Solution:** Add Flutter to your PATH:
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:`pwd`/flutter/bin"
```

### Problem: "Unable to find git in your PATH"
**Solution:** Install Git from [git-scm.com](https://git-scm.com/)

### Problem: Code generation fails
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Problem: Tests fail
**Solution:**
```bash
flutter clean
flutter pub get
flutter test
```

### Problem: "Unsupported operation: Platform._operatingSystem"
**Solution:** You're trying to use Platform in web code. Use:
```dart
import 'package:flutter/foundation.dart';
if (kIsWeb) {
  // Web code
} else {
  // Native code
}
```

## Next Steps

Now that your app is running:

1. 📖 **Read the [README.md](README.md)** for detailed documentation
2. 🏗️ **Study [ARCHITECTURE.md](ARCHITECTURE.md)** to understand the structure
3. 🚀 **Build your first feature** following the welcome feature pattern
4. 🧪 **Write tests** for your new features
5. 🎨 **Customize the theme** to match your brand
6. 📱 **Test on multiple platforms** to ensure consistency

## Useful Resources

### Official Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)

### State Management
- [Riverpod Documentation](https://riverpod.dev/)
- [Riverpod Examples](https://github.com/rrousselGit/riverpod/tree/master/examples)

### Navigation
- [go_router Documentation](https://pub.dev/packages/go_router)
- [Flutter Navigation Guide](https://docs.flutter.dev/development/ui/navigation)

### Testing
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)

## Getting Help

- 📚 Check the [README.md](README.md) for comprehensive information
- 🏗️ Review [ARCHITECTURE.md](ARCHITECTURE.md) for architecture details
- 🖥️ See [PLATFORM_NOTES.md](PLATFORM_NOTES.md) for platform-specific help
- 📝 Check [CHANGELOG.md](CHANGELOG.md) for version history
- 🐛 Create an issue in the repository for bugs
- 💬 Ask questions in Flutter community forums

## Tips for Success

1. **Start Small**: Begin with the Welcome screen example and build from there
2. **Follow Conventions**: Stick to the established architecture patterns
3. **Write Tests**: Test as you go, don't leave it for later
4. **Use Code Generation**: Let build_runner handle boilerplate
5. **Keep It Clean**: Run `flutter analyze` regularly
6. **Stay Updated**: Keep Flutter and dependencies up to date
7. **Document**: Add comments for complex logic
8. **Version Control**: Commit frequently with clear messages

---

**You're all set! Start building something amazing! 🚀**

For questions or issues, please refer to the main documentation or create an issue in the repository.
