# Platform Configuration Checklist

## 📋 Universal Configuration Requirements

Use this checklist to ensure all platforms are properly configured before deployment.

---

## ✅ All Platforms

### pubspec.yaml Configuration

```yaml
name: notification_center  # Replace with your app name
description: SmartPOS Notification Center
publish_to: 'none'
version: 1.0.0+1  # version+buildNumber

environment:
  sdk: '>=3.5.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  # Add your dependencies

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/config/
    - assets/icon/
```

---

## 📱 iOS Configuration Checklist

### Files to Configure:
- [ ] `ios/Runner/Info.plist` - Permissions and app info
- [ ] `ios/Runner/Assets.xcassets/AppIcon.appiconset/` - 1024x1024 icon
- [ ] `ios/Runner/GoogleService-Info.plist` - Firebase config (if using)
- [ ] `ios/Runner.xcodeproj/project.pbxproj` - Bundle ID, version
- [ ] `ios/Podfile` - CocoaPods dependencies

### Xcode Settings:
- [ ] Bundle Identifier: com.smartpos.appname
- [ ] Display Name: SmartPOS App Name
- [ ] Version: 1.0.0
- [ ] Build: 1
- [ ] Deployment Target: iOS 12.0+
- [ ] Team: Your Apple Developer Team
- [ ] Signing: Automatic
- [ ] Capabilities: Push Notifications, Background Modes

### App Store Connect:
- [ ] App created with bundle ID
- [ ] Privacy policy URL added
- [ ] App description (4000 chars max)
- [ ] Screenshots: 1290x2796 (iPhone 6.7")
- [ ] App icon: 1024x1024 PNG
- [ ] Keywords: comma-separated
- [ ] Support URL
- [ ] Marketing URL (optional)

### Build Command:
```bash
flutter build ios --release
# or
flutter build ipa
```

---

## 🤖 Android Configuration Checklist

### Files to Configure:
- [ ] `android/app/build.gradle` - App ID, version, signing
- [ ] `android/build.gradle` - Gradle version, dependencies
- [ ] `android/app/src/main/AndroidManifest.xml` - Permissions, features
- [ ] `android/app/src/main/res/mipmap-*/` - App icons
- [ ] `android/app/google-services.json` - Firebase config (if using)
- [ ] `android/key.properties` - Signing keys (DON'T commit!)
- [ ] `android/app/proguard-rules.pro` - Code shrinking rules

### Key Generation:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

### build.gradle Settings:
- [ ] applicationId: com.smartpos.appname
- [ ] minSdkVersion: 21 (Android 5.0)
- [ ] targetSdkVersion: 34 (latest)
- [ ] versionCode: 1 (increment each release)
- [ ] versionName: "1.0.0"
- [ ] signingConfig: release

### Google Play Console:
- [ ] App created with package name
- [ ] Store listing completed
- [ ] Content rating obtained
- [ ] Data safety section filled
- [ ] Screenshots: 1080x1920 minimum
- [ ] Feature graphic: 1024x500
- [ ] App icon: 512x512 PNG
- [ ] Privacy policy URL
- [ ] Target audience selected

### Build Command:
```bash
flutter build appbundle --release  # For Play Store
# or
flutter build apk --release  # For testing
```

---

## 💻 Windows Configuration Checklist

### Files to Configure:
- [ ] `windows/runner/main.cpp` - Window title
- [ ] `windows/runner/resources/app_icon.ico` - App icon
- [ ] `pubspec.yaml` - msix_config section

### pubspec.yaml msix_config:
```yaml
msix_config:
  display_name: SmartPOS App Name
  publisher_display_name: SmartPOS Inc
  identity_name: SmartPOS.AppName
  msix_version: 1.0.0.0
  logo_path: assets/icon/icon.png
  capabilities: 'internetClient,location'
  store: true
```

### Microsoft Partner Center:
- [ ] App name reserved
- [ ] Package identity configured
- [ ] Age rating completed
- [ ] Privacy policy URL added
- [ ] Screenshots: 1366x768 minimum
- [ ] App description
- [ ] System requirements documented

### Build Command:
```bash
flutter pub run msix:create
```

---

## 🍎 macOS Configuration Checklist

### Files to Configure:
- [ ] `macos/Runner/Info.plist` - App info
- [ ] `macos/Runner/DebugProfile.entitlements` - Sandbox permissions
- [ ] `macos/Runner/Release.entitlements` - Production permissions
- [ ] `macos/Runner/Assets.xcassets/AppIcon.appiconset/` - 1024x1024 icon
- [ ] `macos/Runner/GoogleService-Info.plist` - Firebase (if using)

### Xcode Settings:
- [ ] Bundle Identifier: com.smartpos.appname.macos
- [ ] Version: 1.0.0
- [ ] Build: 1
- [ ] Minimum macOS: 10.15
- [ ] Team: Your Apple Developer Team
- [ ] Signing: Automatic
- [ ] App Sandbox: Enabled
- [ ] Network access: Enabled

### App Store Connect:
- [ ] macOS app created
- [ ] Description and metadata
- [ ] Screenshots: 1280x800 minimum
- [ ] Privacy policy URL

### Build Command:
```bash
flutter build macos --release
```

---

## 🐧 Linux Configuration Checklist

### Files to Configure:
- [ ] `snap/snapcraft.yaml` - Snap package config (if using Snap)
- [ ] Desktop file for app launcher
- [ ] AppImage structure (if using AppImage)

### snapcraft.yaml:
```yaml
name: smartpos-appname
version: '1.0.0'
summary: Short description
description: Long description
grade: stable
confinement: strict
base: core22
```

### Build Command:
```bash
flutter build linux --release
# Then package with snapcraft, appimage-tool, or dpkg
```

---

## 🔐 Security Checklist (All Platforms)

- [ ] No hardcoded API keys
- [ ] Use environment variables for secrets
- [ ] Firebase config files in .gitignore
- [ ] Keystore files in .gitignore
- [ ] SSL/HTTPS only in production
- [ ] Code obfuscation enabled
- [ ] ProGuard/R8 enabled (Android)
- [ ] Bitcode enabled (iOS) - if supported
- [ ] All permissions explained in privacy policy

### .gitignore Entries:
```gitignore
# Secrets
android/key.properties
*.jks
*.keystore
*.p12
*.pfx
ios/Runner/GoogleService-Info.plist
android/app/google-services.json

# Build outputs
build/
*.ipa
*.apk
*.aab
*.msix
*.dmg
*.snap
*.AppImage
*.deb
```

---

## 🎨 Assets Checklist

### App Icons Required:
- [ ] iOS: 1024x1024 PNG (no alpha)
- [ ] Android: 512x512 PNG (with alpha)
- [ ] Windows: 256x256 PNG → convert to ICO
- [ ] macOS: 1024x1024 PNG
- [ ] Linux: 512x512 PNG or SVG

### Screenshots Required:
- [ ] iOS: 1290x2796 (iPhone 6.7")
- [ ] iOS: 2048x2732 (iPad Pro)
- [ ] Android: 1080x1920 (Phone)
- [ ] Android: 1024x500 (Feature graphic)
- [ ] Windows: 1366x768
- [ ] macOS: 1280x800
- [ ] Linux: 1920x1080 (recommended)

---

## 🌐 Backend Configuration

- [ ] Production API endpoints configured
- [ ] Firebase project created and configured
- [ ] Twilio account set up (for SMS)
- [ ] SendGrid account set up (for email)
- [ ] Database ready
- [ ] CDN configured for assets
- [ ] SSL certificates installed
- [ ] Analytics configured
- [ ] Crash reporting configured

---

## 📝 Legal Documents

- [ ] Privacy Policy hosted and URL ready
- [ ] Terms of Service hosted and URL ready
- [ ] GDPR compliance statement (if EU users)
- [ ] CCPA compliance statement (if CA users)
- [ ] Copyright notices
- [ ] Third-party licenses documented

---

## 🧪 Testing Checklist

- [ ] Test on physical iOS device
- [ ] Test on physical Android device
- [ ] Test on Windows 10 and 11
- [ ] Test on macOS Monterey+
- [ ] Test on Ubuntu/Debian Linux
- [ ] Test different screen sizes
- [ ] Test offline functionality
- [ ] Test with poor network
- [ ] Test all permissions
- [ ] Test deep linking
- [ ] Test push notifications
- [ ] Performance testing
- [ ] Memory leak testing
- [ ] Battery usage testing

---

## 📦 Pre-Deployment Final Check

- [ ] All console.log/debugPrint statements removed
- [ ] All TODO comments resolved
- [ ] Version numbers incremented
- [ ] Build numbers incremented
- [ ] Release notes prepared
- [ ] Support email ready
- [ ] Monitoring configured
- [ ] Crash reporting active
- [ ] Rollback plan documented
- [ ] Team notified of deployment

---

## 🚀 Deployment Order (Recommended)

1. **Day 1:** Submit to Google Play (fastest approval)
2. **Day 1:** Submit to Microsoft Store
3. **Day 2:** Submit to iOS App Store
4. **Day 2:** Submit to Mac App Store
5. **Day 3:** Release Linux packages (Snap, AppImage)

This ensures you have experience with faster platforms before tackling Apple's longer review process.

---

**Last Updated:** 2025-01-10
**Document Version:** 1.0
