# macOS Deployment Guide - Mac App Store

## 🍎 Complete Guide to Deploy Flutter Apps to macOS

---

## 🎯 Overview

Deploy your SmartPOS Flutter apps to the Mac App Store.

**Timeline:** 2-5 days (including Apple review)
**Cost:** $99/year (same Apple Developer account as iOS)

---

## ✅ Prerequisites

- [ ] macOS computer (Monterey 12.0+)
- [ ] Xcode 14.0+
- [ ] Flutter SDK 3.24.0+
- [ ] Apple Developer Program membership
- [ ] CocoaPods installed

---

## 📋 Step-by-Step Process

### **STEP 1: Enable macOS Support**

```bash
# Enable macOS desktop
flutter config --enable-macos-desktop

# Verify
flutter devices

# Should show:
# macOS (desktop) • macos • darwin-x64
```

---

### **STEP 2: Create macOS Project**

```bash
cd apps/notification_center
flutter create --platforms=macos .
```

Creates `macos/` folder with Xcode project.

---

### **STEP 3: Configure macOS App in Xcode**

#### 3.1 Open Xcode Project

```bash
open macos/Runner.xcworkspace
```

#### 3.2 Configure Project Settings

Select **Runner** → **General**:
- **Bundle Identifier:** com.smartpos.notificationcenter.macos
- **Version:** 1.0.0
- **Build:** 1
- **Minimum macOS Version:** 10.15

**Signing & Capabilities:**
- **Automatically manage signing:** ✅
- **Team:** Select your team
- Add **App Sandbox** capability
- Enable required entitlements:
  - ✅ Network (Incoming/Outgoing)
  - ✅ Camera (if needed)
  - ✅ File Access (if needed)

---

### **STEP 4: Configure Entitlements**

Edit `macos/Runner/DebugProfile.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

Copy to `Release.entitlements` with same content.

---

### **STEP 5: Add App Icon**

1. Create 1024x1024 PNG icon
2. In Xcode: `macos/Runner/Assets.xcassets/AppIcon.appiconset`
3. Drag 1024x1024 icon to "Mac 1024pt" slot

---

### **STEP 6: Build macOS App**

```bash
# Build release
flutter build macos --release

# Output: build/macos/Build/Products/Release/notification_center.app
```

---

### **STEP 7: Create DMG (for distribution outside App Store)**

```bash
# Install create-dmg
brew install create-dmg

# Create DMG
create-dmg \
  --volname "SmartPOS Installer" \
  --volicon "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "SmartPOS.app" 200 190 \
  --hide-extension "SmartPOS.app" \
  --app-drop-link 600 185 \
  "SmartPOS-Installer.dmg" \
  "build/macos/Build/Products/Release/"
```

---

### **STEP 8: Archive for App Store**

#### 8.1 In Xcode

1. Select **Product** → **Scheme** → **Runner**
2. Select **Any Mac** as destination
3. **Product** → **Archive**
4. Wait for archive to complete

#### 8.2 Upload to App Store

1. In Organizer, select archive
2. **Distribute App** → **App Store Connect**
3. **Upload**
4. Wait for processing (30-60 minutes)

---

### **STEP 9: Create App Store Connect Listing**

Same as iOS process:
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new macOS app
3. Fill in metadata:
   - App name
   - Description
   - Screenshots (1280x800 minimum)
   - Keywords
   - Support URL
   - Privacy Policy URL
4. Select build
5. Submit for review

---

### **STEP 10: Notarization (for outside App Store)**

If distributing outside App Store, notarize your app:

```bash
# Create app-specific password at appleid.apple.com

# Notarize
xcrun notarytool submit SmartPOS-Installer.dmg \
  --apple-id "your@email.com" \
  --password "app-specific-password" \
  --team-id "YOUR_TEAM_ID" \
  --wait

# Staple ticket
xcrun stapler staple SmartPOS-Installer.dmg
```

---

## 🔧 Common Issues

### Issue 1: "Code signing failed"
**Solution:** Ensure bundle ID is unique and team is selected

### Issue 2: "Sandbox violation"
**Solution:** Add required entitlements in .entitlements file

### Issue 3: "App crashes on launch"
**Solution:** Check logs in Console.app, verify all dylibs are included

---

## 📊 Post-Launch

- [ ] Test on multiple macOS versions (Catalina, Big Sur, Monterey, Ventura)
- [ ] Monitor crash reports
- [ ] Respond to reviews
- [ ] Plan updates

---

**Last Updated:** 2025-01-10
**Document Version:** 1.0
