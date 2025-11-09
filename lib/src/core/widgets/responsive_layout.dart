import 'package:flutter/material.dart';

/// Breakpoint values for responsive layouts.
class Breakpoints {
  const Breakpoints._();

  /// Mobile breakpoint (< 600px).
  static const double mobile = 600;

  /// Tablet breakpoint (>= 600px, < 1024px).
  static const double tablet = 1024;

  /// Desktop breakpoint (>= 1024px).
  static const double desktop = 1024;

  /// Large desktop breakpoint (>= 1440px).
  static const double largeDesktop = 1440;
}

/// Device type based on screen width.
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop;

  bool get isMobile => this == DeviceType.mobile;
  bool get isTablet => this == DeviceType.tablet;
  bool get isDesktop => this == DeviceType.desktop;
  bool get isLargeDesktop => this == DeviceType.largeDesktop;
}

/// Responsive layout widget that adapts to different screen sizes.
/// Provides different builders for mobile, tablet, and desktop layouts.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  /// Get device type based on screen width.
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.largeDesktop) {
      return DeviceType.largeDesktop;
    } else if (width >= Breakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  /// Check if current device is mobile.
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if current device is tablet.
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if current device is desktop.
  static bool isDesktop(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.desktop || type == DeviceType.largeDesktop;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= Breakpoints.tablet) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive value that changes based on device type.
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;

  /// Get value for current device type.
  T getValue(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    switch (deviceType) {
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

/// Responsive padding helper.
class ResponsivePadding {
  const ResponsivePadding._();

  /// Get horizontal padding based on device type.
  static double getHorizontalPadding(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    switch (deviceType) {
      case DeviceType.largeDesktop:
        return 120;
      case DeviceType.desktop:
        return 80;
      case DeviceType.tablet:
        return 40;
      case DeviceType.mobile:
        return 16;
    }
  }

  /// Get vertical padding based on device type.
  static double getVerticalPadding(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    switch (deviceType) {
      case DeviceType.largeDesktop:
      case DeviceType.desktop:
        return 48;
      case DeviceType.tablet:
        return 32;
      case DeviceType.mobile:
        return 16;
    }
  }

  /// Get content max width based on device type.
  static double getContentMaxWidth(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    switch (deviceType) {
      case DeviceType.largeDesktop:
        return 1440;
      case DeviceType.desktop:
        return 1200;
      case DeviceType.tablet:
        return 900;
      case DeviceType.mobile:
        return double.infinity;
    }
  }
}
