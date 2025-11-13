/// Odoo Design System - Colors
/// Following Odoo's official color palette and design guidelines
library;

import 'package:flutter/material.dart';

/// Odoo Official Colors
/// Based on Odoo 17+ design system
class OdooColors {
  OdooColors._();

  // ========================================
  // Primary Colors
  // ========================================

  /// Primary brand color - Odoo Purple
  static const Color primary = Color(0xFF714B67);

  /// Primary variant - Lighter purple
  static const Color primaryVariant = Color(0xFF875A7B);

  /// Primary dark - Darker purple
  static const Color primaryDark = Color(0xFF5B3D54);

  /// Primary light - Very light purple
  static const Color primaryLight = Color(0xFFF4F0F3);

  // ========================================
  // Secondary Colors
  // ========================================

  /// Secondary color - Teal
  static const Color secondary = Color(0xFF00A09D);

  /// Secondary variant - Dark teal
  static const Color secondaryVariant = Color(0xFF008784);

  // ========================================
  // Semantic Colors
  // ========================================

  /// Success - Green
  static const Color success = Color(0xFF28A745);
  static const Color successLight = Color(0xFFD4EDDA);
  static const Color successDark = Color(0xFF1E7E34);

  /// Warning - Orange
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color warningDark = Color(0xFFE0A800);

  /// Danger/Error - Red
  static const Color danger = Color(0xFFDC3545);
  static const Color dangerLight = Color(0xFFF8D7DA);
  static const Color dangerDark = Color(0xFFC82333);

  /// Info - Blue
  static const Color info = Color(0xFF17A2B8);
  static const Color infoLight = Color(0xFFD1ECF1);
  static const Color infoDark = Color(0xFF117A8B);

  // ========================================
  // Neutral Colors
  // ========================================

  /// Background colors
  static const Color background = Color(0xFFF9F9F9);
  static const Color backgroundDark = Color(0xFFF0F0F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAFAFA);

  /// Border colors
  static const Color border = Color(0xFFDEE2E6);
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color borderDark = Color(0xFFCED4DA);

  /// Text colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Gray scale
  static const Color gray900 = Color(0xFF212529);
  static const Color gray800 = Color(0xFF343A40);
  static const Color gray700 = Color(0xFF495057);
  static const Color gray600 = Color(0xFF6C757D);
  static const Color gray500 = Color(0xFFADB5BD);
  static const Color gray400 = Color(0xFFCED4DA);
  static const Color gray300 = Color(0xFFDEE2E6);
  static const Color gray200 = Color(0xFFE9ECEF);
  static const Color gray100 = Color(0xFFF8F9FA);

  // ========================================
  // Sidebar & Navigation
  // ========================================

  /// Sidebar background - Dark gray
  static const Color sidebarBackground = Color(0xFF2C2C36);
  static const Color sidebarHover = Color(0xFF3A3A47);
  static const Color sidebarActive = Color(0xFF714B67);
  static const Color sidebarText = Color(0xFFE0E0E0);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);
  static const Color sidebarIcon = Color(0xFFB0B0B0);
  static const Color sidebarIconActive = Color(0xFFFFFFFF);

  // ========================================
  // Status Colors
  // ========================================

  /// Order/Item statuses
  static const Color statusDraft = Color(0xFF6C757D);
  static const Color statusNew = Color(0xFF007BFF);
  static const Color statusInProgress = Color(0xFFFFC107);
  static const Color statusDone = Color(0xFF28A745);
  static const Color statusCancelled = Color(0xFFDC3545);

  // ========================================
  // Chart Colors
  // ========================================

  static const List<Color> chartColors = [
    Color(0xFF714B67), // Purple
    Color(0xFF00A09D), // Teal
    Color(0xFFFFC107), // Yellow
    Color(0xFF28A745), // Green
    Color(0xFFDC3545), // Red
    Color(0xFF17A2B8), // Blue
    Color(0xFFFF6B6B), // Coral
    Color(0xFF4ECDC4), // Turquoise
    Color(0xFFFFE66D), // Light yellow
    Color(0xFF95E1D3), // Mint
  ];

  // ========================================
  // Helper Methods
  // ========================================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get status color based on status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
      case 'pending':
        return statusDraft;
      case 'new':
      case 'confirmed':
        return statusNew;
      case 'in_progress':
      case 'processing':
        return statusInProgress;
      case 'done':
      case 'completed':
      case 'delivered':
        return statusDone;
      case 'cancelled':
      case 'failed':
        return statusCancelled;
      default:
        return gray600;
    }
  }
}

/// Odoo Shadows
class OdooShadows {
  OdooShadows._();

  /// Card shadow
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Card hover shadow
  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Dialog shadow
  static const List<BoxShadow> dialog = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  /// Floating action button shadow
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Subtle shadow
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
}
