/// Vodo Design System - Dimensions & Spacing
/// Consistent spacing, sizing, and layout values
library;

import 'package:flutter/material.dart';
import 'vodo_colors.dart';

/// Vodo spacing and dimension system
class VodoDimensions {
  VodoDimensions._();

  // Spacing Scale
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // Common spacing aliases
  static const double spacingXs = spacing4;
  static const double spacingSm = spacing8;
  static const double spacingMd = spacing16;
  static const double spacingLg = spacing24;
  static const double spacingXl = spacing32;
  static const double spacingXxl = spacing48;

  // Padding
  static const EdgeInsets paddingXs = EdgeInsets.all(spacing4);
  static const EdgeInsets paddingSm = EdgeInsets.all(spacing8);
  static const EdgeInsets paddingMd = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingLg = EdgeInsets.all(spacing24);
  static const EdgeInsets paddingXl = EdgeInsets.all(spacing32);

  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(horizontal: spacing4);
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: spacing8);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: spacing16);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: spacing24);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: spacing32);

  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(vertical: spacing4);
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: spacing8);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: spacing16);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: spacing24);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: spacing32);

  // Border Radius
  static const double radiusXs = 2.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusXxl = BorderRadius.all(Radius.circular(radiusXxl));

  // Border Width
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 3.0;

  // Icon Sizes
  static const double iconSizeXs = 12.0;
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 48.0;
  static const double iconSizeXxl = 64.0;

  // Button Sizes
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;
  static const double buttonHeightLg = 48.0;
  static const double buttonHeightXl = 56.0;

  static const EdgeInsets buttonPaddingSm = EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  static const EdgeInsets buttonPaddingMd = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets buttonPaddingLg = EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  static const EdgeInsets buttonPaddingXl = EdgeInsets.symmetric(horizontal: 32, vertical: 16);

  // Card Sizes
  static const double cardElevation = 1.0;
  static const double cardElevationHover = 4.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(spacing16);
  static const EdgeInsets cardPaddingLg = EdgeInsets.all(spacing24);

  // Input Field Sizes
  static const double inputHeightSm = 36.0;
  static const double inputHeightMd = 44.0;
  static const double inputHeightLg = 52.0;

  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const EdgeInsets inputPaddingLg = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  // AppBar Sizes
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 64.0;
  static const EdgeInsets appBarPadding = EdgeInsets.symmetric(horizontal: spacing16);

  // Sidebar/Drawer Sizes
  static const double sidebarWidth = 240.0;
  static const double sidebarWidthCollapsed = 72.0;
  static const double sidebarItemHeight = 48.0;

  // Bottom Navigation
  static const double bottomNavHeight = 56.0;
  static const double bottomNavIconSize = 24.0;

  // Dialog Sizes
  static const double dialogMaxWidth = 560.0;
  static const double dialogMaxWidthLg = 800.0;
  static const EdgeInsets dialogPadding = EdgeInsets.all(spacing24);

  // Modal Sizes
  static const double modalMaxWidth = 640.0;
  static const double modalMaxHeight = 720.0;

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = spacing16;

  // Shadows
  static const List<BoxShadow> shadowNone = [];

  static const List<BoxShadow> shadowXs = [
    BoxShadow(
      color: VodoColors.shadowLight,
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: VodoColors.shadowLight,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: VodoColors.shadowMedium,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: VodoColors.shadowMedium,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: VodoColors.shadowDark,
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // Elevation shadows for Material Design
  static List<BoxShadow> getElevationShadow(double elevation) {
    if (elevation <= 0) return shadowNone;
    if (elevation <= 1) return shadowXs;
    if (elevation <= 2) return shadowSm;
    if (elevation <= 4) return shadowMd;
    if (elevation <= 8) return shadowLg;
    return shadowXl;
  }

  // Grid Spacing
  static const double gridSpacing = spacing16;
  static const double gridSpacingSm = spacing8;
  static const double gridSpacingLg = spacing24;

  // List Item Sizes
  static const double listItemHeight = 56.0;
  static const double listItemHeightSm = 48.0;
  static const double listItemHeightLg = 72.0;
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing12);

  // Avatar Sizes
  static const double avatarSizeXs = 24.0;
  static const double avatarSizeSm = 32.0;
  static const double avatarSizeMd = 40.0;
  static const double avatarSizeLg = 56.0;
  static const double avatarSizeXl = 72.0;
  static const double avatarSizeXxl = 96.0;

  // Chip/Badge Sizes
  static const double chipHeight = 32.0;
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  static const double badgeSize = 20.0;
  static const double badgeSizeSm = 16.0;

  // Progress Indicator Sizes
  static const double progressSizeSm = 16.0;
  static const double progressSizeMd = 24.0;
  static const double progressSizeLg = 48.0;

  // Breakpoints (responsive design)
  static const double breakpointMobile = 640.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;
  static const double breakpointWide = 1280.0;
  static const double breakpointUltraWide = 1920.0;

  // Container Max Widths
  static const double containerMaxWidthSm = 640.0;
  static const double containerMaxWidthMd = 768.0;
  static const double containerMaxWidthLg = 1024.0;
  static const double containerMaxWidthXl = 1280.0;
  static const double containerMaxWidthXxl = 1536.0;

  // Z-Index (for stacking)
  static const int zIndexBase = 0;
  static const int zIndexDropdown = 1000;
  static const int zIndexModal = 2000;
  static const int zIndexPopover = 3000;
  static const int zIndexTooltip = 4000;
  static const int zIndexToast = 5000;

  /// Helper method to check if screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointMobile;
  }

  /// Helper method to check if screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointMobile && width < breakpointDesktop;
  }

  /// Helper method to check if screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }
}
