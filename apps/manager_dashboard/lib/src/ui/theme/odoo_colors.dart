import 'package:flutter/material.dart';

/// Odoo Color System
///
/// Official Odoo design colors following Odoo 17 specifications.
/// These colors should be used throughout the application for consistency.
class OdooColors {
  OdooColors._();

  // ============================================================================
  // Primary Brand Colors
  // ============================================================================

  /// Odoo primary purple - Main brand color
  static const Color primary = Color(0xFF714B67);

  /// Odoo secondary teal - Accent color
  static const Color secondary = Color(0xFF00A09D);

  // ============================================================================
  // Sidebar Colors (Dark Theme)
  // ============================================================================

  /// Sidebar background - Dark gray (#2C2C36)
  static const Color sidebarBackground = Color(0xFF2C2C36);

  /// Sidebar text color
  static const Color sidebarText = Color(0xFFE8E8E8);

  /// Sidebar active/selected item background
  static const Color sidebarActive = Color(0xFF3E3E4A);

  /// Sidebar hover state
  static const Color sidebarHover = Color(0xFF353542);

  // ============================================================================
  // Semantic Colors
  // ============================================================================

  /// Success - Green
  static const Color success = Color(0xFF28A745);
  static const Color successLight = Color(0xFFD4EDDA);

  /// Warning - Orange
  static const Color warning = Color(0xFFF0AD4E);
  static const Color warningLight = Color(0xFFFFF3CD);

  /// Danger/Error - Red
  static const Color danger = Color(0xFFDC3545);
  static const Color dangerLight = Color(0xFFF8D7DA);

  /// Info - Blue
  static const Color info = Color(0xFF17A2B8);
  static const Color infoLight = Color(0xFFD1ECF1);

  // ============================================================================
  // Status Colors (for orders, items, etc.)
  // ============================================================================

  /// Draft status
  static const Color statusDraft = Color(0xFF6C757D);

  /// Pending status
  static const Color statusPending = Color(0xFFFFC107);

  /// In Progress status
  static const Color statusInProgress = Color(0xFF17A2B8);

  /// Confirmed status
  static const Color statusConfirmed = Color(0xFF28A745);

  /// Cancelled status
  static const Color statusCancelled = Color(0xFFDC3545);

  /// Completed status
  static const Color statusCompleted = Color(0xFF20C997);

  // ============================================================================
  // Chart Colors (for analytics)
  // ============================================================================

  static const List<Color> chartColors = [
    Color(0xFF5B9BD5), // Blue
    Color(0xFF70AD47), // Green
    Color(0xFFFFC000), // Yellow
    Color(0xFFED7D31), // Orange
    Color(0xFF7030A0), // Purple
    Color(0xFFC00000), // Red
    Color(0xFF44546A), // Dark Blue
    Color(0xFF00B050), // Bright Green
    Color(0xFFFF6600), // Bright Orange
    Color(0xFF9933FF), // Bright Purple
  ];

  // ============================================================================
  // Gray Scale
  // ============================================================================

  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // ============================================================================
  // Background Colors
  // ============================================================================

  /// Main background (light mode)
  static const Color backgroundLight = Color(0xFFF9F9F9);

  /// Card background (light mode)
  static const Color cardBackground = Colors.white;

  /// Border color
  static const Color border = Color(0xFFE0E0E0);

  // ============================================================================
  // Text Colors
  // ============================================================================

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // ============================================================================
  // Color Scheme Factory
  // ============================================================================

  /// Creates Material 3 ColorScheme for light mode
  static ColorScheme lightColorScheme() {
    return ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE8D5E4),
      onPrimaryContainer: const Color(0xFF2D1C2A),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFCCF5F4),
      onSecondaryContainer: const Color(0xFF003735),
      error: danger,
      onError: Colors.white,
      errorContainer: dangerLight,
      onErrorContainer: const Color(0xFF5A0000),
      surface: Colors.white,
      onSurface: textPrimary,
      surfaceContainerHighest: gray100,
      outline: border,
    );
  }

  /// Creates Material 3 ColorScheme for dark mode
  static ColorScheme darkColorScheme() {
    return ColorScheme.dark(
      primary: const Color(0xFFD4A5CC),
      onPrimary: const Color(0xFF3F2639),
      primaryContainer: const Color(0xFF583D53),
      onPrimaryContainer: const Color(0xFFEFD9EB),
      secondary: const Color(0xFF4DD8D5),
      onSecondary: const Color(0xFF00504E),
      secondaryContainer: const Color(0xFF006A67),
      onSecondaryContainer: const Color(0xFFCCF5F4),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: dangerLight,
      surface: sidebarBackground,
      onSurface: sidebarText,
      surfaceContainerHighest: const Color(0xFF3E3E4A),
      outline: const Color(0xFF575766),
    );
  }
}
