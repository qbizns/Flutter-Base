import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

/// Platform information utility.
/// Provides helper methods to determine current platform.
class PlatformInfo {
  const PlatformInfo._();

  /// Check if running on mobile (iOS or Android).
  static bool get isMobile => isIOS || isAndroid;

  /// Check if running on desktop (Windows, macOS, or Linux).
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// Check if running on iOS.
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// Check if running on Android.
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Check if running on Windows.
  static bool get isWindows {
    if (kIsWeb) return false;
    return Platform.isWindows;
  }

  /// Check if running on macOS.
  static bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  /// Check if running on Linux.
  static bool get isLinux {
    if (kIsWeb) return false;
    return Platform.isLinux;
  }

  /// Check if running on web.
  static bool get isWeb => kIsWeb;

  /// Get platform name.
  static String get platformName {
    if (isWeb) return 'Web';
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }
}
