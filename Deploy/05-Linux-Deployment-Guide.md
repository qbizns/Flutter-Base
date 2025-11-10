# Linux Deployment Guide

## 🐧 Complete Guide to Deploy Flutter Apps to Linux

---

## 🎯 Overview

Deploy your SmartPOS Flutter apps to Linux distributions. No app store required!

**Timeline:** 1 day
**Cost:** Free

---

## ✅ Prerequisites

- [ ] Linux system (Ubuntu 20.04+ recommended)
- [ ] Flutter SDK 3.24.0+
- [ ] Build essentials installed

---

## 📋 Step-by-Step Process

### **STEP 1: Install Dependencies**

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

# Fedora
sudo dnf install clang cmake ninja-build gtk3-devel

# Arch
sudo pacman -S base-devel clang cmake ninja gtk3
```

---

### **STEP 2: Enable Linux Support**

```bash
# Enable Linux desktop
flutter config --enable-linux-desktop

# Verify
flutter devices

# Should show:
# Linux (desktop) • linux • linux-x64
```

---

### **STEP 3: Create Linux Project**

```bash
cd apps/notification_center
flutter create --platforms=linux .
```

Creates `linux/` folder with CMake configuration.

---

### **STEP 4: Build Linux App**

```bash
# Build release
flutter build linux --release

# Output: build/linux/x64/release/bundle/
# Contains:
# - notification_center (executable)
# - lib/ (shared libraries)
# - data/ (app resources)
```

---

### **STEP 5: Test the Build**

```bash
# Run the executable
./build/linux/x64/release/bundle/notification_center

# Or run with Flutter
flutter run -d linux
```

---

### **STEP 6: Package for Distribution**

#### Option A: Snap Package (Recommended)

**6.1 Install snapcraft:**
```bash
sudo snap install snapcraft --classic
```

**6.2 Create snapcraft.yaml:**

Create `snap/snapcraft.yaml`:
```yaml
name: smartpos-notification-center
version: '1.0.0'
summary: SmartPOS Notification Center
description: |
  Manage all notifications for SmartPOS restaurant operations.
  
  Features:
  - Real-time push notifications
  - Multi-channel delivery
  - Customizable preferences
  - Notification history

grade: stable
confinement: strict
base: core22

apps:
  smartpos-notification-center:
    command: notification_center
    extensions: [gnome]
    plugs:
      - network
      - network-bind
      - desktop
      - desktop-legacy
      - x11
      - wayland
      - opengl
      - home

parts:
  smartpos:
    plugin: flutter
    source: .
    flutter-target: lib/main.dart
    build-packages:
      - libgtk-3-dev
      - liblzma-dev
    stage-packages:
      - libgtk-3-0
      - liblzma5
```

**6.3 Build Snap:**
```bash
snapcraft

# Output: smartpos-notification-center_1.0.0_amd64.snap
```

**6.4 Test Snap:**
```bash
sudo snap install --dangerous smartpos-notification-center_1.0.0_amd64.snap

# Run
smartpos-notification-center
```

**6.5 Publish to Snap Store:**
```bash
# Login
snapcraft login

# Upload
snapcraft upload smartpos-notification-center_1.0.0_amd64.snap --release=stable
```

---

#### Option B: AppImage

**6.1 Install appimagetool:**
```bash
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
```

**6.2 Create AppDir structure:**
```bash
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/lib
mkdir -p AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps

# Copy app
cp -r build/linux/x64/release/bundle/* AppDir/usr/bin/

# Create desktop file
cat > AppDir/usr/share/applications/smartpos.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=SmartPOS Notification Center
Exec=notification_center
Icon=smartpos
Categories=Office;Business;
EOF

# Copy icon
cp assets/icon/icon.png AppDir/usr/share/icons/hicolor/256x256/apps/smartpos.png

# Create AppRun
cat > AppDir/AppRun << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin/:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib/:${LD_LIBRARY_PATH}"
exec "${HERE}/usr/bin/notification_center" "$@"
EOF

chmod +x AppDir/AppRun
```

**6.3 Build AppImage:**
```bash
./appimagetool-x86_64.AppImage AppDir SmartPOS-Notification-Center-x86_64.AppImage

# Output: SmartPOS-Notification-Center-x86_64.AppImage
```

**6.4 Run AppImage:**
```bash
chmod +x SmartPOS-Notification-Center-x86_64.AppImage
./SmartPOS-Notification-Center-x86_64.AppImage
```

---

#### Option C: Flatpak

**6.1 Install flatpak-builder:**
```bash
sudo apt install flatpak-builder
```

**6.2 Create com.smartpos.NotificationCenter.yml:**
```yaml
app-id: com.smartpos.NotificationCenter
runtime: org.freedesktop.Platform
runtime-version: '23.08'
sdk: org.freedesktop.Sdk
command: notification_center

finish-args:
  - --share=ipc
  - --socket=x11
  - --socket=wayland
  - --device=dri
  - --share=network

modules:
  - name: smartpos-notification-center
    buildsystem: simple
    build-commands:
      - install -Dm755 notification_center /app/bin/notification_center
      - install -Dm644 com.smartpos.NotificationCenter.desktop /app/share/applications/com.smartpos.NotificationCenter.desktop
      - install -Dm644 icon.png /app/share/icons/hicolor/256x256/apps/com.smartpos.NotificationCenter.png
    sources:
      - type: dir
        path: build/linux/x64/release/bundle
```

**6.3 Build Flatpak:**
```bash
flatpak-builder --force-clean build-dir com.smartpos.NotificationCenter.yml
flatpak-builder --repo=repo --force-clean build-dir com.smartpos.NotificationCenter.yml
```

---

#### Option D: Debian Package (.deb)

**6.1 Create package structure:**
```bash
mkdir -p smartpos-notification-center_1.0.0/DEBIAN
mkdir -p smartpos-notification-center_1.0.0/usr/bin
mkdir -p smartpos-notification-center_1.0.0/usr/share/applications
mkdir -p smartpos-notification-center_1.0.0/usr/share/icons/hicolor/256x256/apps

# Copy files
cp -r build/linux/x64/release/bundle/* smartpos-notification-center_1.0.0/usr/bin/
cp assets/icon/icon.png smartpos-notification-center_1.0.0/usr/share/icons/hicolor/256x256/apps/smartpos.png
```

**6.2 Create control file:**
```bash
cat > smartpos-notification-center_1.0.0/DEBIAN/control << 'EOF'
Package: smartpos-notification-center
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, liblzma5
Maintainer: SmartPOS Inc <support@smartpos.com>
Description: SmartPOS Notification Center
 Manage all notifications for SmartPOS restaurant operations.
 Features real-time push notifications, multi-channel delivery,
 and customizable preferences.
EOF
```

**6.3 Create desktop file:**
```bash
cat > smartpos-notification-center_1.0.0/usr/share/applications/smartpos.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=SmartPOS Notification Center
Exec=/usr/bin/notification_center
Icon=smartpos
Categories=Office;Business;
Terminal=false
EOF
```

**6.4 Build .deb:**
```bash
dpkg-deb --build smartpos-notification-center_1.0.0

# Output: smartpos-notification-center_1.0.0.deb
```

**6.5 Install .deb:**
```bash
sudo dpkg -i smartpos-notification-center_1.0.0.deb
sudo apt-get install -f  # Fix dependencies if needed
```

---

### **STEP 7: Distribution**

#### Snap Store:
1. Go to [snapcraft.io/account](https://snapcraft.io/account)
2. Register app name
3. Upload snap package
4. Choose release channel (stable, candidate, beta, edge)

#### Flathub:
1. Fork [flathub/flathub](https://github.com/flathub/flathub)
2. Create app manifest
3. Submit pull request
4. Wait for review

#### Direct Download:
- Host .deb, .AppImage, or .tar.gz on your website
- Provide installation instructions

---

## 🔧 Common Issues

### Issue 1: "GTK not found"
**Solution:** Install libgtk-3-dev

### Issue 2: "Snap confinement denied"
**Solution:** Add required plugs to snapcraft.yaml

### Issue 3: "App doesn't start"
**Solution:** Check all shared libraries are included, use `ldd` to check dependencies

---

## 📊 Testing

Test on multiple distributions:
- [ ] Ubuntu 20.04/22.04
- [ ] Debian 11/12
- [ ] Fedora 38+
- [ ] Arch Linux
- [ ] Pop!_OS
- [ ] Linux Mint

---

## 💡 Best Practices

1. Use Snap for universal distribution
2. Provide both Snap and AppImage
3. Include README with installation instructions
4. Test on clean Linux installs
5. Handle missing dependencies gracefully

---

**Last Updated:** 2025-01-10
**Document Version:** 1.0
