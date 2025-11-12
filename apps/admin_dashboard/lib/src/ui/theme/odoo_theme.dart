/// Odoo Theme
/// Complete theme configuration following Odoo design system
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'odoo_colors.dart';
import 'odoo_typography.dart';

/// Odoo Theme Data
/// Creates MaterialApp theme following Odoo design guidelines
class OdooTheme {
  OdooTheme._();

  /// Light theme (Odoo default)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color scheme
      colorScheme: ColorScheme.light(
        primary: OdooColors.primary,
        primaryContainer: OdooColors.primaryLight,
        secondary: OdooColors.secondary,
        secondaryContainer: OdooColors.secondary.withOpacity(0.1),
        error: OdooColors.danger,
        errorContainer: OdooColors.dangerLight,
        surface: OdooColors.surface,
        surfaceContainerHighest: OdooColors.surfaceVariant,
        onPrimary: OdooColors.textOnPrimary,
        onSecondary: OdooColors.textOnPrimary,
        onSurface: OdooColors.textPrimary,
        onError: OdooColors.textOnPrimary,
        outline: OdooColors.border,
      ),

      // Scaffold
      scaffoldBackgroundColor: OdooColors.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: OdooColors.surface,
        foregroundColor: OdooColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: OdooTypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: OdooColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: OdooColors.textPrimary,
          size: OdooIconSizes.lg,
        ),
      ),

      // Card
      cardTheme: CardTheme(
        color: OdooColors.surface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: OdooSpacing.borderRadiusStandard,
          side: const BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(OdooSpacing.md),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OdooColors.primary,
          foregroundColor: OdooColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: OdooSpacing.lg,
            vertical: OdooSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: OdooSpacing.borderRadiusStandard,
          ),
          textStyle: OdooTypography.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OdooColors.primary,
          side: const BorderSide(
            color: OdooColors.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: OdooSpacing.lg,
            vertical: OdooSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: OdooSpacing.borderRadiusStandard,
          ),
          textStyle: OdooTypography.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OdooColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: OdooSpacing.md,
            vertical: OdooSpacing.sm,
          ),
          textStyle: OdooTypography.button,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OdooColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: OdooSpacing.md,
          vertical: OdooSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: OdooSpacing.borderRadiusStandard,
          borderSide: const BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: OdooSpacing.borderRadiusStandard,
          borderSide: const BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: OdooSpacing.borderRadiusStandard,
          borderSide: const BorderSide(
            color: OdooColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: OdooSpacing.borderRadiusStandard,
          borderSide: const BorderSide(
            color: OdooColors.danger,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: OdooSpacing.borderRadiusStandard,
          borderSide: const BorderSide(
            color: OdooColors.danger,
            width: 2,
          ),
        ),
        labelStyle: OdooTypography.bodyMedium,
        hintStyle: OdooTypography.bodyMedium.copyWith(
          color: OdooColors.textTertiary,
        ),
        errorStyle: OdooTypography.bodySmall.copyWith(
          color: OdooColors.danger,
        ),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return OdooColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(OdooColors.textOnPrimary),
        side: const BorderSide(
          color: OdooColors.border,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusXS),
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return OdooColors.primary;
          }
          return OdooColors.border;
        }),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return OdooColors.primary;
          }
          return OdooColors.gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return OdooColors.primary.withOpacity(0.5);
          }
          return OdooColors.gray300;
        }),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: OdooColors.border,
        thickness: 1,
        space: 1,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: OdooColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusLG),
        ),
        titleTextStyle: OdooTypography.titleLarge,
        contentTextStyle: OdooTypography.bodyMedium,
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: OdooColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(OdooSpacing.radiusLG),
          ),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: OdooColors.gray800,
        contentTextStyle: OdooTypography.bodyMedium.copyWith(
          color: OdooColors.textOnDark,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: OdooSpacing.borderRadiusStandard,
        ),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: OdooColors.gray800,
          borderRadius: OdooSpacing.borderRadiusStandard,
        ),
        textStyle: OdooTypography.bodySmall.copyWith(
          color: OdooColors.textOnDark,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: OdooSpacing.sm,
          vertical: OdooSpacing.xs,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: OdooColors.gray100,
        selectedColor: OdooColors.primaryLight,
        secondarySelectedColor: OdooColors.secondaryVariant.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(
          horizontal: OdooSpacing.sm,
          vertical: OdooSpacing.xs,
        ),
        labelStyle: OdooTypography.labelSmall,
        shape: RoundedRectangleBorder(
          borderRadius: OdooSpacing.borderRadiusStandard,
        ),
      ),

      // Data table
      dataTableTheme: DataTableThemeData(
        headingTextStyle: OdooTypography.tableHeader,
        dataTextStyle: OdooTypography.tableCell,
        headingRowColor: WidgetStateProperty.all(OdooColors.gray100),
        dividerThickness: 1,
      ),

      // Tab bar
      tabBarTheme: TabBarTheme(
        labelColor: OdooColors.primary,
        unselectedLabelColor: OdooColors.textSecondary,
        indicatorColor: OdooColors.primary,
        labelStyle: OdooTypography.labelLarge,
        unselectedLabelStyle: OdooTypography.labelLarge,
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: OdooColors.primary,
        linearTrackColor: OdooColors.gray200,
        circularTrackColor: OdooColors.gray200,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: OdooTypography.displayLarge,
        displayMedium: OdooTypography.displayMedium,
        displaySmall: OdooTypography.displaySmall,
        headlineLarge: OdooTypography.headlineLarge,
        headlineMedium: OdooTypography.headlineMedium,
        headlineSmall: OdooTypography.headlineSmall,
        titleLarge: OdooTypography.titleLarge,
        titleMedium: OdooTypography.titleMedium,
        titleSmall: OdooTypography.titleSmall,
        bodyLarge: OdooTypography.bodyLarge,
        bodyMedium: OdooTypography.bodyMedium,
        bodySmall: OdooTypography.bodySmall,
        labelLarge: OdooTypography.labelLarge,
        labelMedium: OdooTypography.labelMedium,
        labelSmall: OdooTypography.labelSmall,
      ),
    );
  }

  /// Dark theme (optional)
  static ThemeData get darkTheme {
    // TODO: Implement dark theme if needed
    return lightTheme;
  }
}
