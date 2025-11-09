# Platform-Specific Notes

This document provides detailed information about running and building the Flutter Starter template on different platforms.

## 📱 iOS

### Requirements

- **macOS**: Big Sur (11.0) or later
- **Xcode**: 14.0 or later
- **CocoaPods**: Latest version (`sudo gem install cocoapods`)
- **iOS Deployment Target**: iOS 12.0 or later

### Initial Setup

1. **Install Xcode** from the Mac App Store
2. **Install Xcode Command Line Tools**:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. **Accept Xcode License**:
   ```bash
   sudo xcodebuild -license accept
   ```

4. **Install CocoaPods Dependencies**:
   ```bash
   cd ios
   pod install
   cd ..
   ```

### Configuration

1. **Bundle Identifier**: Update in `ios/Runner.xcodeproj` or using Xcode
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner target
   - Update Bundle Identifier in General tab

2. **App Name**: Edit `ios/Runner/Info.plist`
   ```xml
   <key>CFBundleName</key>
   <string>Your App Name</string>
   ```

3. **Signing**: Configure in Xcode
   - Open `ios/Runner.xcworkspace`
   - Select Runner target
   - Go to Signing & Capabilities tab
   - Select your Team and enable Automatically manage signing

### Running & Building

```bash
# Run on simulator
flutter run -d ios

# Run on physical device
flutter run -d <device-id>

# Build for release
flutter build ios --release

# Build IPA for distribution
flutter build ipa --release
```

### Common Issues

- **CocoaPods errors**: Run `pod repo update` and `pod install` again
- **Signing errors**: Ensure you have a valid Apple Developer account
- **Simulator not found**: Open Xcode and download required simulators

---

## 🤖 Android

### Requirements

- **Android Studio**: Latest stable version
- **Android SDK**: API level 21 (Android 5.0) or higher
- **JDK**: OpenJDK 11 or later
- **Gradle**: 7.0 or later (bundled with project)

### Initial Setup

1. **Install Android Studio** from [developer.android.com](https://developer.android.com/studio)

2. **Install Android SDK**:
   - Open Android Studio
   - Go to Tools > SDK Manager
   - Install Android SDK Platform (API 34 recommended)
   - Install Android SDK Build-Tools
   - Install Android SDK Platform-Tools

3. **Accept Android Licenses**:
   ```bash
   flutter doctor --android-licenses
   ```

### Configuration

1. **Application ID**: Edit `android/app/build.gradle`
   ```gradle
   defaultConfig {
       applicationId "com.yourcompany.yourapp"
       // ...
   }
   ```

2. **App Name**: Edit `android/app/src/main/AndroidManifest.xml`
   ```xml
   <application
       android:label="Your App Name"
       ...>
   ```

3. **Minimum SDK**: Edit `android/app/build.gradle`
   ```gradle
   minSdkVersion 21  // Minimum supported
   targetSdkVersion 34  // Latest
   ```

4. **Permissions**: Edit `android/app/src/main/AndroidManifest.xml`
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

### Running & Building

```bash
# Run on emulator or device
flutter run -d android

# Build APK
flutter build apk --release

# Build App Bundle (for Google Play)
flutter build appbundle --release

# Build split APKs
flutter build apk --split-per-abi --release
```

### Common Issues

- **Gradle sync errors**: Run `flutter clean` and rebuild
- **SDK not found**: Set `ANDROID_HOME` environment variable
- **Emulator slow**: Enable hardware acceleration (Intel HAXM or AMD Hypervisor)

---

## 🌐 Web

### Requirements

- **Modern Browser**: Chrome, Firefox, Safari, or Edge
- **Web Server**: For hosting (optional)

### Configuration

1. **Update `web/index.html`**:
   ```html
   <title>Your App Name</title>
   <meta name="description" content="Your app description">
   ```

2. **Update `web/manifest.json`**:
   ```json
   {
     "name": "Your App Name",
     "short_name": "YourApp",
     "description": "Your app description"
   }
   ```

3. **Favicon**: Replace `web/favicon.png` with your logo

### Running & Building

```bash
# Run in Chrome
flutter run -d chrome

# Run with specific renderer
flutter run -d chrome --web-renderer html
flutter run -d chrome --web-renderer canvaskit

# Build for production
flutter build web --release

# Build with specific renderer
flutter build web --web-renderer canvaskit --release

# Build with base href for subdirectory hosting
flutter build web --base-href /myapp/ --release
```

### Web Renderers

- **CanvasKit** (default): Better performance, larger download
- **HTML**: Smaller download, works better on mobile

### Deployment

1. **Static Hosting** (Firebase, Netlify, Vercel):
   - Build: `flutter build web --release`
   - Deploy: Upload `build/web` contents

2. **Custom Server**:
   - Serve `build/web` directory
   - Configure for single-page application (redirect all routes to index.html)

### Common Issues

- **CORS errors**: Use proper web server configuration
- **Asset loading**: Check base-href configuration
- **Performance**: Use CanvasKit renderer for better performance

---

## 🪟 Windows

### Requirements

- **Windows 10** or later (64-bit)
- **Visual Studio 2022** with "Desktop development with C++"
- **Windows 10 SDK**

### Initial Setup

1. **Install Visual Studio 2022**:
   - Download from [visualstudio.microsoft.com](https://visualstudio.microsoft.com/)
   - Select "Desktop development with C++"
   - Install Windows 10 SDK

2. **Enable Flutter Windows Desktop**:
   ```bash
   flutter config --enable-windows-desktop
   ```

### Configuration

1. **App Name**: Edit `windows/runner/Runner.rc`
   ```rc
   #define FLUTTER_APPLICATION_TITLE "Your App Name"
   ```

2. **App Version**: Edit `windows/runner/Runner.rc`
   ```rc
   #define VERSION_AS_NUMBER 1,0,0
   #define VERSION_AS_STRING "1.0.0"
   ```

3. **App Icon**: Replace icon in `windows/runner/resources/`

### Running & Building

```bash
# Run
flutter run -d windows

# Build
flutter build windows --release

# Output location
build/windows/runner/Release/
```

### Distribution

- The Release folder contains all necessary files
- Create an installer using tools like Inno Setup or WiX

### Common Issues

- **Visual Studio not found**: Install required workload
- **Build errors**: Ensure Windows SDK is installed
- **Missing DLLs**: Include all files from Release folder

---

## 🍎 macOS

### Requirements

- **macOS**: Big Sur (11.0) or later
- **Xcode**: 14.0 or later
- **macOS Deployment Target**: 10.14 or later

### Initial Setup

1. **Install Xcode** from Mac App Store

2. **Enable Flutter macOS Desktop**:
   ```bash
   flutter config --enable-macos-desktop
   ```

### Configuration

1. **Bundle Identifier**: Edit `macos/Runner.xcodeproj`
   - Open project in Xcode
   - Update Bundle Identifier

2. **App Name**: Edit `macos/Runner/Info.plist`
   ```xml
   <key>CFBundleName</key>
   <string>Your App Name</string>
   ```

3. **Entitlements**: Edit `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`
   ```xml
   <!-- Add required entitlements -->
   <key>com.apple.security.network.client</key>
   <true/>
   ```

### Running & Building

```bash
# Run
flutter run -d macos

# Build
flutter build macos --release

# Output location
build/macos/Build/Products/Release/
```

### Distribution

1. **App Store**:
   - Configure signing and provisioning
   - Archive in Xcode
   - Upload to App Store Connect

2. **Direct Distribution**:
   - Notarize the app with Apple
   - Create DMG installer

### Common Issues

- **Sandbox restrictions**: Add required entitlements
- **Signing errors**: Configure valid Developer ID
- **Network issues**: Enable network client entitlement

---

## 🐧 Linux

### Requirements

- **Linux Distribution**: Ubuntu 20.04 or later (or equivalent)
- **Development Libraries**: GTK 3, clang, cmake, ninja

### Initial Setup

1. **Install Required Libraries**:
   ```bash
   sudo apt-get update
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
   ```

2. **Enable Flutter Linux Desktop**:
   ```bash
   flutter config --enable-linux-desktop
   ```

### Configuration

1. **App Name**: Edit `linux/my_application.cc`
   ```cpp
   g_set_application_name("Your App Name");
   ```

2. **App ID**: Edit `linux/my_application.cc`
   ```cpp
   gtk_window_set_default_icon_name("com.yourcompany.yourapp");
   ```

### Running & Building

```bash
# Run
flutter run -d linux

# Build
flutter build linux --release

# Output location
build/linux/x64/release/bundle/
```

### Distribution

1. **Snap Package**:
   ```bash
   snapcraft
   ```

2. **AppImage**:
   - Use AppImage tools to package the bundle

3. **Flatpak**:
   - Create Flatpak manifest and build

### Common Issues

- **GTK errors**: Install required GTK development libraries
- **Missing dependencies**: Check with `ldd` command
- **Display issues**: Ensure X11 or Wayland is running

---

## 🔄 Cross-Platform Considerations

### Responsive Design

- Use `ResponsiveLayout` widget for different screen sizes
- Test on all target platforms
- Consider touch vs. mouse/keyboard input

### Platform-Specific Code

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // Web-specific code
} else if (Platform.isIOS) {
  // iOS-specific code
} else if (Platform.isAndroid) {
  // Android-specific code
}
```

### Assets

- Use appropriate asset resolutions (1x, 2x, 3x)
- Test asset loading on all platforms
- Consider platform-specific icons and splash screens

### Performance

- **Mobile**: Optimize for battery and performance
- **Web**: Minimize bundle size, use code splitting
- **Desktop**: Take advantage of more resources

### Testing

- Test on real devices when possible
- Use platform-specific emulators/simulators
- Verify UI/UX on different screen sizes

---

## 📦 Building for Production

### Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+build_number
```

### Release Checklist

- [ ] Update version number
- [ ] Test on all target platforms
- [ ] Update app icons and splash screens
- [ ] Configure app signing/certificates
- [ ] Update app descriptions and metadata
- [ ] Remove debug code and logs
- [ ] Run performance profiling
- [ ] Test release builds
- [ ] Prepare store listings
- [ ] Submit for review (iOS/Android)

---

## 🐛 Debugging

### Platform-Specific Debugging

```bash
# Enable verbose logging
flutter run --verbose

# Run with specific device
flutter run -d <device-id> --verbose

# View logs
flutter logs

# Run DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Platform Logs

- **iOS**: Xcode Console or `idevicesyslog`
- **Android**: Android Studio Logcat or `adb logcat`
- **Web**: Browser DevTools Console
- **Windows**: Visual Studio Output
- **macOS**: Xcode Console or system logs
- **Linux**: Terminal output

---

## 📚 Additional Resources

### Official Documentation

- [Flutter Desktop](https://docs.flutter.dev/desktop)
- [Flutter Web](https://docs.flutter.dev/web)
- [Flutter Platform Integration](https://docs.flutter.dev/platform-integration)

### Platform-Specific Guides

- [iOS App Store Submission](https://developer.apple.com/app-store/submissions/)
- [Google Play Console](https://play.google.com/console)
- [Microsoft Store](https://developer.microsoft.com/microsoft-store)
- [Mac App Store](https://developer.apple.com/macos/submit/)

---

**Last Updated**: 2025-01-09
