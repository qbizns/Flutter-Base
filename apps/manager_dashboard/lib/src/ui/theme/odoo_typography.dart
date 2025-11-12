import 'package:flutter/material.dart';

/// Odoo Typography System
///
/// Following Odoo 17 design specifications with Lato font family.
class OdooTypography {
  OdooTypography._();

  /// Font family - Lato (Odoo standard)
  static const String fontFamily = 'Lato';

  // ============================================================================
  // Text Styles - Material 3 Typography
  // ============================================================================

  /// Display Large - 57px
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    height: 1.12,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  /// Display Medium - 45px
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    height: 1.16,
    fontWeight: FontWeight.w400,
  );

  /// Display Small - 36px
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    height: 1.22,
    fontWeight: FontWeight.w400,
  );

  /// Headline Large - 32px
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w400,
  );

  /// Headline Medium - 28px
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.29,
    fontWeight: FontWeight.w400,
  );

  /// Headline Small - 24px
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w400,
  );

  /// Title Large - 22px
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w500,
  );

  /// Title Medium - 16px (Medium weight)
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.50,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  /// Title Small - 14px (Medium weight)
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Body Large - 16px
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.50,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  /// Body Medium - 14px
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  /// Body Small - 12px
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  /// Label Large - 14px (Medium weight)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Label Medium - 12px (Medium weight)
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// Label Small - 11px (Medium weight)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.45,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ============================================================================
  // Special Purpose Text Styles (Odoo specific)
  // ============================================================================

  /// Page title - 28px Bold
  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.29,
    fontWeight: FontWeight.w700,
  );

  /// Card title - 18px Bold
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w700,
  );

  /// Stat value (large numbers) - 32px Bold
  static const TextStyle statValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );

  /// Button text - 14px Medium
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Table header - 13px Bold
  static const TextStyle tableHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.38,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  /// Table cell - 14px Regular
  static const TextStyle tableCell = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w400,
  );

  // ============================================================================
  // Material 3 Typography Factory
  // ============================================================================

  /// Creates Material 3 TextTheme
  static TextTheme textTheme() {
    return const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}

// ============================================================================
// Spacing System (4px base unit)
// ============================================================================

/// Odoo Spacing Constants
///
/// Based on 4px base unit following Odoo design system
class OdooSpacing {
  OdooSpacing._();

  static const double unit = 4.0;

  static const double xs = unit; // 4px
  static const double sm = unit * 2; // 8px
  static const double md = unit * 3; // 12px
  static const double lg = unit * 4; // 16px
  static const double xl = unit * 6; // 24px
  static const double xxl = unit * 8; // 32px
  static const double xxxl = unit * 12; // 48px

  /// Border radius (Odoo standard is 3px)
  static const double radiusStandard = 3.0;
  static const double radiusSmall = 2.0;
  static const double radiusLarge = 6.0;

  /// Sidebar width
  static const double sidebarWidth = 250.0;

  /// Top bar height
  static const double topBarHeight = 56.0;

  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// Page padding
  static const EdgeInsets pagePadding = EdgeInsets.all(xl);

  /// Section spacing
  static const double sectionSpacing = xl;
}

// ============================================================================
// Icon Sizes
// ============================================================================

/// Odoo Icon Sizes
class OdooIconSizes {
  OdooIconSizes._();

  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
