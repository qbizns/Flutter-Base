# iOS Deployment Guide - Apple App Store

## 📱 Complete Guide to Deploy Flutter Apps to iOS

---

## 🎯 Overview

This guide covers the complete process of deploying your SmartPOS Flutter applications to the Apple App Store.

**Timeline:** 2-5 days (including Apple review time)
**Cost:** $99/year for Apple Developer Program

---

## ✅ Prerequisites

### Required Tools:
- [ ] macOS computer (Monterey 12.0+ recommended)
- [ ] Xcode 14.0+ installed from Mac App Store
- [ ] Flutter SDK 3.24.0+ installed
- [ ] CocoaPods installed (`sudo gem install cocoapods`)
- [ ] Valid Apple Developer Account ($99/year)

### Required Accounts:
- [ ] Apple ID with 2-factor authentication enabled
- [ ] Apple Developer Program membership active

---

## 📋 Step-by-Step Deployment Process

### **STEP 1: Prepare Your Flutter Project**

#### 1.1 Update App Configuration

Navigate to your app folder:
```bash
cd apps/notification_center  # or any of your 26 apps
```

#### 1.2 Configure `pubspec.yaml`
```yaml
name: notification_center
description: SmartPOS Notification Center
version: 1.0.0+1  # version+buildNumber
                   # Increment buildNumber for each submission

environment:
  sdk: '>=3.5.0 <4.0.0'

flutter:
  uses-material-design: true
```

#### 1.3 Clean and Get Dependencies
```bash
flutter clean
flutter pub get
cd ios
pod install
pod update
cd ..
```

---

### **STEP 2: Configure iOS Project in Xcode**

#### 2.1 Open Xcode Project
```bash
open ios/Runner.xcworkspace  # Always use .xcworkspace, NOT .xcodeproj
```

#### 2.2 Configure Project Settings

In Xcode, select **Runner** in the project navigator, then:

**General Tab:**
- **Display Name:** SmartPOS Notification Center
- **Bundle Identifier:** com.smartpos.notificationcenter
  - Must be unique globally
  - Reverse domain notation
  - Use lowercase, no special characters
- **Version:** 1.0.0 (matches pubspec.yaml)
- **Build:** 1 (increment for each submission)
- **Deployment Target:** iOS 12.0 minimum (or higher if needed)
- **Devices:** iPhone and iPad (or iPhone only)

**Signing & Capabilities Tab:**
- **Automatically manage signing:** ✅ Checked (for beginners)
- **Team:** Select your Apple Developer team
- **Bundle Identifier:** Verify it matches above

#### 2.3 Add Required Capabilities

Click **+ Capability** and add:
- **Push Notifications** (for FCM)
- **Background Modes:**
  - ✅ Remote notifications
  - ✅ Background fetch (if needed)
- **Associated Domains** (if you have deep linking)

---

### **STEP 3: Configure Info.plist**

Location: `ios/Runner/Info.plist`

Add required permissions and configurations:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Information -->
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>

    <key>CFBundleDisplayName</key>
    <string>SmartPOS</string>

    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>

    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

    <key>CFBundleName</key>
    <string>notification_center</string>

    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>

    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>

    <!-- Permissions (Required for App Review) -->
    <key>NSCameraUsageDescription</key>
    <string>This app requires camera access to scan QR codes and barcodes for inventory management.</string>

    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs access to your photos to upload receipts and product images.</string>

    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app uses your location to find nearby restaurants and delivery addresses.</string>

    <key>NSContactsUsageDescription</key>
    <string>This app needs access to contacts to send receipts and share order information.</string>

    <!-- Network -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>  <!-- Set to false for production -->
    </dict>

    <!-- Firebase -->
    <key>FirebaseAppDelegateProxyEnabled</key>
    <true/>

    <!-- Other Settings -->
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>

    <key>UIMainStoryboardFile</key>
    <string>Main</string>

    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>

    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
    </array>

    <key>UIViewControllerBasedStatusBarAppearance</key>
    <true/>

    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>
</dict>
</plist>
```

---

### **STEP 4: Add App Icons**

#### 4.1 Prepare Icons

You need a **1024x1024px PNG** icon (no transparency).

#### 4.2 Add to Xcode

1. In Xcode, navigate to `Runner/Assets.xcassets/AppIcon.appiconset`
2. Drag your 1024x1024 icon to the "App Store iOS 1024pt" slot
3. Xcode will auto-generate other sizes

**Or use a tool:**
- [AppIcon.co](https://appicon.co)
- [MakeAppIcon.com](https://makeappicon.com)

Upload your 1024x1024 icon and download the iOS asset catalog.

---

### **STEP 5: Configure Firebase (Required for Push Notifications)**

#### 5.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Name: "SmartPOS Production"
4. Enable Google Analytics (optional)

#### 5.2 Add iOS App to Firebase

1. Click "Add app" → iOS
2. iOS bundle ID: `com.smartpos.notificationcenter` (must match Xcode)
3. App nickname: "SmartPOS iOS"
4. Download `GoogleService-Info.plist`

#### 5.3 Add GoogleService-Info.plist to Project

```bash
# Copy the file to ios/Runner/
cp ~/Downloads/GoogleService-Info.plist ios/Runner/
```

In Xcode:
1. Right-click `Runner` folder
2. "Add Files to Runner"
3. Select `GoogleService-Info.plist`
4. ✅ Check "Copy items if needed"
5. ✅ Check "Runner" target

#### 5.4 Update Podfile

Edit `ios/Podfile`:
```ruby
# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

# Add this at the top
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    # Fix for Xcode 14+
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

Run:
```bash
cd ios
pod install
cd ..
```

---

### **STEP 6: Build and Test**

#### 6.1 Build for Simulator
```bash
flutter build ios --debug --simulator
```

#### 6.2 Run on Simulator
```bash
flutter run -d "iPhone 14 Pro"  # Or any available simulator
```

#### 6.3 Build for Physical Device
```bash
flutter build ios --release
```

#### 6.4 Test on Physical Device

1. Connect iPhone via USB
2. In Xcode, select your device from the device menu
3. Click Run (▶️) button
4. Trust the developer certificate on your iPhone if prompted

---

### **STEP 7: Create App Store Connect Record**

#### 7.1 Log in to App Store Connect

Go to [App Store Connect](https://appstoreconnect.apple.com)

#### 7.2 Create New App

1. Click **"My Apps"** → **"+"** → **"New App"**
2. **Platforms:** iOS
3. **Name:** SmartPOS Notification Center
4. **Primary Language:** English (U.S.)
5. **Bundle ID:** Select com.smartpos.notificationcenter
6. **SKU:** com.smartpos.notificationcenter.2025 (unique identifier)
7. **User Access:** Full Access

#### 7.3 Fill App Information

**App Information:**
- **Name:** SmartPOS Notification Center (max 30 characters)
- **Subtitle:** Manage notifications for SmartPOS (max 30 characters)
- **Privacy Policy URL:** https://smartpos.com/privacy
- **Category:** Primary: Business, Secondary: Productivity
- **Content Rights:** Does not contain third-party content

**Pricing and Availability:**
- **Price:** Free (or set price)
- **Availability:** All territories
- **App Store Distribution:** Available

**App Privacy:**
- Complete the privacy questionnaire
- List all data types collected:
  - Contact Info (email, phone)
  - User Content (messages, photos)
  - Usage Data (product interactions)
  - Identifiers (device ID, user ID)

---

### **STEP 8: Prepare App Store Assets**

#### 8.1 Screenshots Required

**iPhone 6.7" Display (iPhone 14 Pro Max, 15 Pro Max):**
- Size: 1290 x 2796 pixels
- Minimum: 1 screenshot
- Maximum: 10 screenshots

**iPhone 6.5" Display (iPhone 11 Pro Max, Xs Max):**
- Size: 1242 x 2688 pixels
- Required if different from 6.7"

**iPad Pro 12.9" (3rd gen):**
- Size: 2048 x 2732 pixels
- Required if iPad supported

**How to create screenshots:**
```bash
# Run on simulator
flutter run -d "iPhone 15 Pro Max"

# Take screenshots: Cmd + S in Simulator
# Screenshots saved to ~/Desktop
```

#### 8.2 App Preview Video (Optional but Recommended)

- Duration: 15-30 seconds
- Same resolutions as screenshots
- Show key features and user flow

#### 8.3 App Description

**Description (max 4000 characters):**
```
SmartPOS Notification Center is your central hub for managing all notifications across the SmartPOS restaurant management ecosystem.

KEY FEATURES:
• Real-time push notifications for orders, kitchen updates, and deliveries
• Multi-channel notifications (Push, SMS, Email, In-App)
• Customizable notification preferences
• Do-not-disturb scheduling
• Notification history and analytics
• Priority-based alerts for urgent matters
• Type-specific filtering (Orders, Kitchen, Delivery, Reservations, etc.)

PERFECT FOR:
• Restaurant managers staying on top of operations
• Kitchen staff receiving real-time order updates
• Delivery drivers tracking assignments
• Front-of-house staff managing reservations
• Inventory managers monitoring stock levels

BENEFITS:
• Never miss critical updates
• Reduce response times
• Improve operational efficiency
• Customize notifications to your preferences
• Stay connected from anywhere

Download SmartPOS Notification Center today and streamline your restaurant operations!
```

**Keywords (max 100 characters, comma-separated):**
```
restaurant,pos,notifications,orders,kitchen,delivery,alerts,business
```

**Promotional Text (max 170 characters):**
```
Stay on top of your restaurant operations with real-time notifications. Never miss an order, delivery, or critical alert again!
```

---

### **STEP 9: Build for App Store (Archive)**

#### 9.1 Update Build Configuration

Edit `ios/Runner.xcodeproj/project.pbxproj` or use Xcode:
- Set build configuration to **Release**
- Enable **Bitcode**: NO (Flutter doesn't support it)
- Set **Optimization Level**: -Os (Optimize for Size)

#### 9.2 Build Archive via Command Line

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build iOS release
flutter build ios --release --no-codesign

# Or build with specific bundle ID
flutter build ios --release --bundle-id=com.smartpos.notificationcenter
```

#### 9.3 Create Archive in Xcode

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select **"Any iOS Device (arm64)"** as destination
3. Menu: **Product** → **Archive**
4. Wait for build to complete (5-15 minutes)
5. Xcode Organizer opens automatically

---

### **STEP 10: Upload to App Store Connect**

#### 10.1 Using Xcode Organizer

1. In Organizer, select your archive
2. Click **"Distribute App"**
3. Select **"App Store Connect"**
4. Click **"Upload"**
5. Select **"Automatically manage signing"**
6. Click **"Upload"**
7. Wait for upload to complete (10-30 minutes depending on file size)

#### 10.2 Using Command Line (Alternative)

```bash
# Archive and upload in one command
flutter build ipa

# The IPA will be at: build/ios/ipa/*.ipa

# Upload using Transporter app or altool
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/notification_center.ipa \
  --username "your@email.com" \
  --password "app-specific-password"
```

**Generate App-Specific Password:**
1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in
3. Security → App-Specific Passwords
4. Generate new password
5. Save it securely

---

### **STEP 11: Submit for Review**

#### 11.1 Complete App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Click **"Prepare for Submission"**

**Build:**
- Select the build you just uploaded

**Version Information:**
- **What's New in This Version:** (max 4000 characters)
```
Initial release of SmartPOS Notification Center

NEW FEATURES:
• Real-time push notifications
• Customizable notification preferences
• Multi-channel delivery (Push, SMS, Email)
• Notification history and search
• Do-not-disturb scheduling
• Priority-based alerts

Thank you for using SmartPOS!
```

**App Review Information:**
- **Contact Information:**
  - First Name, Last Name
  - Phone Number
  - Email Address
- **Sign-In Required:** Yes/No
  - If yes, provide demo account credentials
- **Notes:** Any special instructions for reviewers

**Version Release:**
- Automatically release this version
- OR Manually release this version

#### 11.2 Submit for Review

1. Click **"Add for Review"**
2. Review all information
3. Click **"Submit for Review"**

---

### **STEP 12: Wait for Review**

**Timeline:**
- Average review time: **24-48 hours**
- Can be as fast as a few hours or up to 7 days
- Check status in App Store Connect

**Possible Outcomes:**
1. **Approved** ✅
   - App is live on App Store
   - Users can download immediately

2. **Rejected** ❌
   - Review team provides reasons
   - Fix issues and resubmit
   - Common rejection reasons:
     - Crashes or bugs
     - Incomplete features
     - Privacy policy issues
     - Misleading description
     - Design issues

3. **Metadata Rejected** ⚠️
   - Only description/screenshots need changes
   - Faster to fix and resubmit

---

## 🔧 Common Issues and Solutions

### Issue 1: "Unable to install"
**Solution:** Delete app from device, clean build folder, rebuild

### Issue 2: "Code signing failed"
**Solution:**
- Verify Bundle ID is unique
- Check Apple Developer account is active
- Regenerate certificates and provisioning profiles

### Issue 3: "Pod install fails"
**Solution:**
```bash
cd ios
rm -rf Pods/ Podfile.lock
pod install --repo-update
```

### Issue 4: "GoogleService-Info.plist not found"
**Solution:** Make sure file is added to Runner target in Xcode

### Issue 5: "Archive fails with Bitcode error"
**Solution:** Set `ENABLE_BITCODE = NO` in Build Settings

### Issue 6: "App stuck in 'Processing'"
**Solution:** Wait 30-60 minutes. If still processing after 2 hours, contact Apple

---

## 📊 Post-Launch Checklist

After app is live:
- [ ] Test download from App Store
- [ ] Monitor crash reports in App Store Connect
- [ ] Check reviews and respond
- [ ] Monitor analytics (downloads, usage)
- [ ] Set up App Store optimization (ASO)
- [ ] Plan updates and new features

---

## 🎯 Tips for Faster Approval

1. ✅ Test thoroughly before submission
2. ✅ Provide clear, accurate screenshots
3. ✅ Write detailed app description
4. ✅ Include demo account for reviewers
5. ✅ Respond quickly to reviewer questions
6. ✅ Follow Apple Human Interface Guidelines
7. ✅ Ensure app works without internet (if possible)
8. ✅ Handle errors gracefully
9. ✅ Provide privacy policy and terms

---

## 📞 Support Resources

- **Apple Developer Forums:** [developer.apple.com/forums](https://developer.apple.com/forums)
- **App Store Connect Help:** [help.apple.com/app-store-connect](https://help.apple.com/app-store-connect)
- **Technical Support:** Available in App Store Connect
- **Phone Support:** 1-800-633-2152 (Apple Developer Support)

---

**Last Updated:** 2025-01-10
**Document Version:** 1.0
**Maintained By:** SmartPOS Development Team
