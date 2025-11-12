/// Vodo Design System - Typography
/// Enterprise-grade text styles for consistency across all apps
library;

import 'package:flutter/material.dart';
import 'vodo_colors.dart';

/// Vodo typography system
class VodoTextStyles {
  VodoTextStyles._();

  // Base font family
  static const String fontFamily = 'Roboto';
  static const String fontFamilyMono = 'RobotoMono';

  // Display Styles (Large headers)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.50,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    fontFamily: fontFamily,
    color: VodoColors.textSecondary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    fontFamily: fontFamily,
    color: VodoColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    fontFamily: fontFamily,
    color: VodoColors.textSecondary,
  );

  // Custom Vodo Styles

  /// Page header style (purple)
  static const TextStyle pageHeader = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    fontFamily: fontFamily,
    color: VodoColors.primary,
  );

  /// Section header style
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.44,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  /// Card title style
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  /// Card subtitle style
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    fontFamily: fontFamily,
    color: VodoColors.textSecondary,
  );

  /// Button text style
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    height: 1.43,
    fontFamily: fontFamily,
    color: VodoColors.textOnPrimary,
  );

  /// Button large text style
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
    height: 1.50,
    fontFamily: fontFamily,
    color: VodoColors.textOnPrimary,
  );

  /// Price text style (large, bold)
  static const TextStyle price = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.33,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  /// Price text style (medium)
  static const TextStyle priceMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.44,
    fontFamily: fontFamily,
    color: VodoColors.textPrimary,
  );

  /// Price text style (small)
  static const TextStyle priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.43,
    fontFamily: fontFamily,
    color: VodoColors.textSecondary,
  );

  /// Monospace text style (for order numbers, IDs)
  static const TextStyle monospace = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.43,
    fontFamily: fontFamilyMono,
    color: VodoColors.textPrimary,
  );

  /// Badge text style
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
    fontFamily: fontFamily,
    color: VodoColors.textOnPrimary,
  );

  /// Error text style
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    fontFamily: fontFamily,
    color: VodoColors.danger,
  );

  /// Helper text style
  static const TextStyle helper = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    fontFamily: fontFamily,
    color: VodoColors.textSecondary,
  );

  /// Caption style (very small text)
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.45,
    fontFamily: fontFamily,
    color: VodoColors.textTertiary,
  );

  /// Overline style (small caps)
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.60,
    fontFamily: fontFamily,
    color: VodoColors.textSecondary,
  );
}
