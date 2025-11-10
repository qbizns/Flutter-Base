# Windows Deployment Guide - Microsoft Store

## 💻 Complete Guide to Deploy Flutter Apps to Windows

---

## 🎯 Overview

Deploy your SmartPOS Flutter apps to the Microsoft Store for Windows 10/11.

**Timeline:** 1-2 days
**Cost:** $19 (individual) or $99 (company) one-time

---

## ✅ Prerequisites

- [ ] Windows 10/11 PC
- [ ] Flutter SDK 3.24.0+ with Windows support enabled
- [ ] Visual Studio 2022 with "Desktop development with C++" workload
- [ ] Microsoft Partner Center account

---

## 📋 Step-by-Step Process

### **STEP 1: Enable Windows Support**

```bash
# Enable Windows desktop
flutter config --enable-windows-desktop

# Verify
flutter devices

# Should show:
# Windows (desktop) • windows • windows-x64
```

---

### **STEP 2: Create Windows Project Files**

```bash
cd apps/notification_center
flutter create --platforms=windows .
```

This creates `windows/` folder with:
- CMakeLists.txt
- runner/
- flutter/ (Flutter engine files)

---

### **STEP 3: Configure Windows App**

#### 3.1 Edit windows/runner/main.cpp

Update window title:
```cpp
Win32Window::Point origin(10, 10);
Win32Window::Size size(1280, 720);
if (!window.Create(L"SmartPOS Notification Center", origin, size)) {
  return EXIT_FAILURE;
}
```

#### 3.2 Update App Icon

1. Create 256x256 PNG icon
2. Convert to ICO format using [Converticon.com](https://converticon.com)
3. Replace `windows/runner/resources/app_icon.ico`

---

### **STEP 4: Build Windows App**

```bash
# Build release
flutter build windows --release

# Output: build/windows/runner/Release/
# Files:
# - notification_center.exe (main executable)
# - flutter_windows.dll (Flutter engine)
# - data/ folder (app resources)
```

---

### **STEP 5: Test Windows Build**

```bash
# Run release build
.\build\windows\runner\Release\notification_center.exe

# Or debug build
flutter run -d windows
```

---

### **STEP 6: Create MSIX Package (for Microsoft Store)**

#### 6.1 Add msix Package

Edit `pubspec.yaml`:
```yaml
dev_dependencies:
  msix: ^3.16.7
```

#### 6.2 Configure MSIX

Add to `pubspec.yaml`:
```yaml
msix_config:
  display_name: SmartPOS Notification Center
  publisher_display_name: SmartPOS Inc
  identity_name: SmartPOS.NotificationCenter
  msix_version: 1.0.0.0
  logo_path: assets/icon/icon.png
  capabilities: 'internetClient,location'
  publisher: CN=SmartPOS Inc, O=SmartPOS Inc, L=City, S=State, C=US
  
  # Store details
  store: true
```

#### 6.3 Generate MSIX

```bash
flutter pub get
flutter pub run msix:create

# Output: build/windows/runner/Release/notification_center.msix
```

---

### **STEP 7: Sign MSIX (Required for Store)**

#### 7.1 Get Code Signing Certificate

**Option A: Use Microsoft Partner Center**
- Automatic signing when you upload to Partner Center

**Option B: Get certificate from CA**
- Purchase from DigiCert, Sectigo, etc.
- Or use self-signed cert for testing

#### 7.2 Sign with signtool

```powershell
# If you have certificate file:
signtool sign /fd SHA256 /f MyCertificate.pfx /p PASSWORD build/windows/runner/Release/notification_center.msix
```

---

### **STEP 8: Register Microsoft Partner Center**

#### 8.1 Create Account

1. Go to [Microsoft Partner Center](https://partner.microsoft.com/dashboard)
2. Sign in with Microsoft Account
3. Enroll in Microsoft Store:
   - Individual: $19 one-time
   - Company: $99 one-time
4. Complete verification (1-2 days)

#### 8.2 Reserve App Name

1. Go to Dashboard → Apps and games
2. Click "New product" → "App"
3. Enter name: "SmartPOS Notification Center"
4. Click "Reserve product name"

---

### **STEP 9: Create Store Listing**

#### 9.1 Product Identity

Copy these values to `pubspec.yaml msix_config`:
- Package/Identity/Name
- Package/Identity/Publisher
- Package/Properties/PublisherDisplayName

#### 9.2 Properties

- **Category:** Business
- **Subcategory:** Tools
- **Privacy policy URL:** https://smartpos.com/privacy
- **Terms of use URL:** https://smartpos.com/terms
- **Support contact:** support@smartpos.com

#### 9.3 Age Ratings

Complete questionnaire:
- Select "Business" app
- Target audience: 18+
- Content type: Business/Productivity

#### 9.4 Store Listing

**Description:**
```
SmartPOS Notification Center is your central hub for managing all notifications across the SmartPOS restaurant management ecosystem.

KEY FEATURES:
• Real-time push notifications
• Multi-channel delivery (Push, SMS, Email)
• Customizable preferences
• Notification history
• Do-not-disturb scheduling

PERFECT FOR:
• Restaurant managers
• Kitchen staff
• Delivery drivers
• Front-of-house staff

Download today and streamline your operations!
```

**Screenshots:**
- Minimum: 1 screenshot
- Recommended: 3-5 screenshots
- Size: 1366 x 768 or higher
- Format: PNG or JPEG

**System Requirements:**
- OS: Windows 10 version 17763.0 or higher
- Architecture: x64, ARM64

---

### **STEP 10: Upload MSIX Package**

1. Go to Packages section
2. Click "Upload package"
3. Select `build/windows/runner/Release/notification_center.msix`
4. Wait for validation (5-10 minutes)
5. Fill in "What's new in this version"

---

### **STEP 11: Submit for Certification**

1. Review all sections (must be complete)
2. Click "Submit for certification"
3. Wait for review (usually 24-48 hours)

**Certification Process:**
- Security testing
- Technical compliance
- Content policy review
- Metadata review

---

## 🔧 Common Issues

### Issue 1: "Flutter engine not found"
**Solution:** Ensure `flutter_windows.dll` is in same directory as .exe

### Issue 2: "MSIX creation failed"
**Solution:** Update msix package, check pubspec.yaml syntax

### Issue 3: "Certification failed - app crashes"
**Solution:** Test thoroughly on clean Windows install

---

## 📊 Post-Launch

- [ ] Monitor crash reports in Partner Center
- [ ] Check analytics
- [ ] Respond to reviews
- [ ] Plan updates

---

## 💡 Tips

- Test on Windows 10 and 11
- Test on different screen resolutions
- Ensure high DPI support
- Test without internet connection
- Handle errors gracefully

---

**Last Updated:** 2025-01-10
**Document Version:** 1.0
