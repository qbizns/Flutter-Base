# Android Deployment Guide - Google Play Store

## 📱 Complete Guide to Deploy Flutter Apps to Android

---

## 🎯 Overview

This guide covers the complete process of deploying your SmartPOS Flutter applications to the Google Play Store.

**Timeline:** 1-3 days (including Google review time)
**Cost:** $25 one-time registration fee

---

## ✅ Prerequisites

### Required Tools:
- [ ] Android Studio installed (latest version)
- [ ] Flutter SDK 3.24.0+ installed
- [ ] JDK 11 or higher installed
- [ ] Google Play Console account ($25 one-time)

### Required Accounts:
- [ ] Google Account with 2-factor authentication
- [ ] Google Play Console Developer account

---

## 📋 Step-by-Step Deployment Process

### **STEP 1: Register Google Play Console Account**

#### 1.1 Create Developer Account
1. Go to [Google Play Console](https://play.google.com/console)
2. Sign in with your Google Account
3. Pay $25 one-time registration fee
4. Complete account verification (can take 24-48 hours)
5. Accept Developer Distribution Agreement

#### 1.2 Set Up Payment Profile
1. Go to Settings → Payment Profile
2. Add business/personal details
3. Add banking information for payouts
4. Complete tax information (W-9 for US)

---

### **STEP 2: Prepare Your Flutter Project**

#### 2.1 Update pubspec.yaml
```yaml
name: notification_center
description: SmartPOS Notification Center
version: 1.0.0+1  # version+buildNumber

environment:
  sdk: '>=3.5.0 <4.0.0'
```

#### 2.2 Configure android/app/build.gradle

Location: `android/app/build.gradle`

```gradle
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

// Load keystore properties
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    compileSdkVersion 34  // Target latest SDK
    ndkVersion "25.1.8937393"

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.smartpos.notificationcenter"  // MUST BE UNIQUE
        minSdkVersion 21  // Android 5.0 (Lollipop)
        targetSdkVersion 34  // Always target latest
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }

    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
                storePassword keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            
            // Enable ProGuard/R8 for code shrinking
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    
    // Firebase (if using)
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-messaging'
}

// Add at bottom if using Firebase
apply plugin: 'com.google.gms.google-services'
```

#### 2.3 Configure android/build.gradle

```gradle
buildscript {
    ext.kotlin_version = '1.9.22'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'  // Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
```

---

### **STEP 3: Create Signing Keystore**

#### 3.1 Generate Keystore File

```bash
# Run this command (on Mac/Linux):
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload \
  -storepass YOUR_STORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD

# On Windows PowerShell:
keytool -genkey -v -keystore C:\Users\YourName\upload-keystore.jks ^
  -storetype JKS ^
  -keyalg RSA ^
  -keysize 2048 ^
  -validity 10000 ^
  -alias upload
```

You'll be prompted for:
- Password (create a strong password, save it securely!)
- First and last name
- Organizational unit
- Organization
- City/Locality
- State/Province
- Country code (US, UK, etc.)

**IMPORTANT:** 
- Store the keystore file securely (NEVER commit to Git)
- Save passwords in a password manager
- If you lose this, you can NEVER update your app

#### 3.2 Create key.properties File

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/Users/yourname/upload-keystore.jks
```

**Add to .gitignore:**
```bash
echo "android/key.properties" >> .gitignore
echo "*.jks" >> .gitignore
```

---

### **STEP 4: Configure AndroidManifest.xml**

Location: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.smartpos.notificationcenter">

    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="28"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>  <!-- Android 13+ -->

    <!-- Features -->
    <uses-feature android:name="android.hardware.camera" android:required="false"/>
    <uses-feature android:name="android.hardware.location.gps" android:required="false"/>

    <application
        android:label="SmartPOS"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:enableOnBackInvokedCallback="true">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- Deep linking (optional) -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="https" android:host="smartpos.com" />
            </intent-filter>
        </activity>

        <!-- Firebase Messaging -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT"/>
            </intent-filter>
        </service>

        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

---

### **STEP 5: Add App Icons**

#### 5.1 Prepare Icons

You need a **512x512px PNG** icon with transparency.

#### 5.2 Generate Android Icons

Use [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/):
1. Upload your 512x512 icon
2. Download generated icons
3. Extract to `android/app/src/main/res/`

Or use Flutter launcher_icons package:

```yaml
# Add to pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: false  # Configure separately
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/icon.png"
```

Run:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

---

### **STEP 6: Configure Firebase (for Push Notifications)**

#### 6.1 Add Android App to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (or create one)
3. Click "Add app" → Android
4. Android package name: `com.smartpos.notificationcenter`
5. Download `google-services.json`

#### 6.2 Add google-services.json

```bash
# Copy to android/app/
cp ~/Downloads/google-services.json android/app/
```

**Add to .gitignore:**
```bash
echo "android/app/google-services.json" >> .gitignore
```

---

### **STEP 7: Build APK/AAB**

#### 7.1 Build App Bundle (AAB) - Recommended

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release AAB
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

**Why AAB?**
- Smaller download size for users
- Required by Google Play for new apps
- Supports dynamic feature modules

#### 7.2 Build APK (for testing)

```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk

# Or build split APKs (recommended for production)
flutter build apk --split-per-abi

# Outputs:
# app-armeabi-v7a-release.apk  (32-bit ARM)
# app-arm64-v8a-release.apk    (64-bit ARM)
# app-x86_64-release.apk       (64-bit x86)
```

#### 7.3 Test Release Build

```bash
# Install APK on connected device
flutter install build/app/outputs/flutter-apk/app-release.apk

# Or use adb
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

### **STEP 8: Create App in Google Play Console**

#### 8.1 Create New App

1. Go to [Google Play Console](https://play.google.com/console)
2. Click **"Create app"**
3. Fill in details:
   - **App name:** SmartPOS Notification Center
   - **Default language:** English (United States)
   - **App or game:** App
   - **Free or paid:** Free
4. Accept declarations
5. Click **"Create app"**

#### 8.2 Set Up App

**Dashboard → Set up your app:**

1. **App access:**
   - All functionality available without restrictions
   - OR provide test account credentials

2. **Ads:**
   - Does your app contain ads? Yes/No

3. **Content rating:**
   - Click "Start questionnaire"
   - Select category: Business
   - Answer all questions honestly
   - Get rating (Everyone, Teen, Mature 17+, etc.)

4. **Target audience:**
   - Age groups: 18+
   - Appeal to children: No

5. **News app:**
   - Is this a news app? No

6. **COVID-19 contact tracing:**
   - COVID-19 contact tracing or status app? No

7. **Data safety:**
   - Complete data safety form
   - List all data collected:
     - Personal info (name, email, phone)
     - Photos and videos (if applicable)
     - Files and docs (if applicable)
     - App activity (interactions)
     - Device ID
   - Explain security practices

8. **Government apps:**
   - Is this a government app? No

9. **Financial features:**
   - Does your app facilitate financial transactions? No/Yes

10. **App category:**
    - Category: Business
    - Tags: restaurant, pos, notifications

11. **Store listing contact details:**
    - Email: support@smartpos.com
    - Phone: +1-XXX-XXX-XXXX
    - Website: https://smartpos.com

---

### **STEP 9: Create Store Listing**

#### 9.1 Main Store Listing

**App name:** SmartPOS Notification Center (max 30 characters)

**Short description** (max 80 characters):
```
Manage all notifications for SmartPOS restaurant operations
```

**Full description** (max 4000 characters):
```
SmartPOS Notification Center is your central hub for managing all notifications across the SmartPOS restaurant management ecosystem.

🔔 KEY FEATURES:
• Real-time push notifications for orders, kitchen updates, and deliveries
• Multi-channel notifications (Push, SMS, Email, In-App)
• Customizable notification preferences
• Do-not-disturb scheduling
• Notification history and analytics
• Priority-based alerts for urgent matters
• Type-specific filtering (Orders, Kitchen, Delivery, Reservations, etc.)

👥 PERFECT FOR:
• Restaurant managers staying on top of operations
• Kitchen staff receiving real-time order updates
• Delivery drivers tracking assignments
• Front-of-house staff managing reservations
• Inventory managers monitoring stock levels

✨ BENEFITS:
• Never miss critical updates
• Reduce response times
• Improve operational efficiency
• Customize notifications to your preferences
• Stay connected from anywhere

🎯 NOTIFICATION TYPES:
• Order notifications
• Kitchen display updates
• Delivery assignments
• Reservation confirmations
• Inventory alerts
• Staff schedules
• Customer feedback
• Payment updates
• Loyalty rewards
• Marketing campaigns
• System alerts

📱 FEATURES:
• Clean, intuitive interface
• Real-time synchronization
• Offline support
• Mark as read/unread
• Search and filter
• Notification groups
• Sound and vibration customization

Download SmartPOS Notification Center today and streamline your restaurant operations!

For support: support@smartpos.com
Website: https://smartpos.com
```

#### 9.2 Graphics

**App icon:**
- 512 x 512 PNG (32-bit with alpha)
- Upload to Google Play Console

**Feature graphic:**
- 1024 x 500 JPG or PNG
- Required for Play Store listing
- Create in Figma, Canva, or Photoshop

**Phone screenshots:**
- JPEG or PNG (no alpha)
- Minimum: 2 screenshots
- Maximum: 8 screenshots
- Minimum dimension: 320px
- Maximum dimension: 3840px
- Recommended: 1080 x 1920 (9:16 aspect ratio)

**7-inch tablet screenshots:**
- 1200 x 1920 recommended

**10-inch tablet screenshots:**
- 1600 x 2560 recommended

**How to create screenshots:**
```bash
# Run on emulator
flutter run -d emulator-5554

# Take screenshots: Ctrl+S (Windows/Linux) or Cmd+S (Mac)
# Or use Android Studio: View → Tool Windows → Device File Explorer
```

#### 9.3 Video (Optional)

- YouTube video URL
- Shows app in action
- Max 30 seconds recommended

---

### **STEP 10: Upload Build**

#### 10.1 Create Release

1. Go to **Production** → **Create new release**
2. Click **"Choose signing key"**
   - **Google-managed key** (recommended): Google manages signing
   - **Use your own key**: Upload your keystore
3. Click **"Continue"**

#### 10.2 Upload AAB

1. Click **"Upload"**
2. Select `build/app/outputs/bundle/release/app-release.aab`
3. Wait for upload (5-10 minutes)
4. Google Play will analyze your AAB

#### 10.3 Add Release Notes

**Release name:** 1.0.0

**Release notes** (max 500 characters per language):
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

---

### **STEP 11: Review and Publish**

#### 11.1 Review Release

- Check all information is correct
- Verify screenshots look good
- Test APK on device one more time

#### 11.2 Submit for Review

1. Click **"Review release"**
2. Review summary of changes
3. Click **"Start rollout to Production"**

#### 11.3 Rollout Options

**Full rollout:** 100% of users immediately
**Staged rollout:**
- 20% → Monitor for 24 hours
- 50% → Monitor for 24 hours
- 100% → Full release

---

### **STEP 12: Wait for Review**

**Timeline:**
- Initial review: **Few hours to 7 days** (usually < 24 hours)
- Updates: Usually faster

**Status:**
- **Pending publication:** Waiting for review
- **Approved:** Live on Play Store
- **Rejected:** Fix issues and resubmit

---

## 🔧 Common Issues and Solutions

### Issue 1: "App not signed"
**Solution:** Ensure key.properties is configured correctly and keystore exists

### Issue 2: "Duplicate classes" error
**Solution:** Check dependencies for conflicts, use `implementation` instead of `compile`

### Issue 3: "Target API level too low"
**Solution:** Update `targetSdkVersion` to 33 or higher in build.gradle

### Issue 4: "Firebase initialization failed"
**Solution:** Verify google-services.json is in android/app/ and package name matches

### Issue 5: "ProGuard/R8 issues"
**Solution:** Add ProGuard rules in proguard-rules.pro

---

## 📊 Post-Launch

- [ ] Monitor crash reports in Play Console
- [ ] Respond to user reviews
- [ ] Check analytics (downloads, ratings)
- [ ] Plan updates
- [ ] Set up Play Store optimization (ASO)

---

**Last Updated:** 2025-01-10
**Document Version:** 1.0
**Maintained By:** SmartPOS Development Team
