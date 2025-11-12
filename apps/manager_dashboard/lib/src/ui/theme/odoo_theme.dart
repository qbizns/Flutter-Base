import 'package:flutter/material.dart';
import 'odoo_colors.dart';
import 'odoo_typography.dart';

/// Odoo Theme Configuration
///
/// Complete Material 3 theme following Odoo 17 design specifications.
class OdooTheme {
  OdooTheme._();

  /// Light theme
  static ThemeData light() {
    final colorScheme = OdooColors.lightColorScheme();
    final textTheme = OdooTypography.textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: OdooTypography.fontFamily,
      scaffoldBackgroundColor: OdooColors.backgroundLight,

      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: OdooColors.textPrimary,
        titleTextStyle: OdooTypography.titleLarge.copyWith(
          color: OdooColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: OdooColors.textPrimary,
          size: OdooIconSizes.lg,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 0,
        color: OdooColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          side: const BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(OdooSpacing.sm),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: OdooTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: OdooSpacing.lg,
            vertical: OdooSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          ),
          elevation: 0,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: OdooTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: OdooSpacing.lg,
            vertical: OdooSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: OdooTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: OdooSpacing.lg,
            vertical: OdooSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          ),
          side: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: OdooTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: OdooSpacing.md,
            vertical: OdooSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: OdooSpacing.md,
          vertical: OdooSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          borderSide: const BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          borderSide: const BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          borderSide: const BorderSide(
            color: OdooColors.danger,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          borderSide: const BorderSide(
            color: OdooColors.danger,
            width: 2,
          ),
        ),
        labelStyle: OdooTypography.bodyMedium.copyWith(
          color: OdooColors.textSecondary,
        ),
        hintStyle: OdooTypography.bodyMedium.copyWith(
          color: OdooColors.textDisabled,
        ),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusSmall),
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return OdooColors.textSecondary;
        }),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return OdooColors.gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return OdooColors.gray300;
        }),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusLarge),
        ),
        titleTextStyle: OdooTypography.titleLarge.copyWith(
          color: OdooColors.textPrimary,
        ),
        contentTextStyle: OdooTypography.bodyMedium.copyWith(
          color: OdooColors.textPrimary,
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(OdooSpacing.radiusLarge),
          ),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: OdooColors.gray800,
        contentTextStyle: OdooTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Data table theme
      dataTableTheme: DataTableThemeData(
        headingTextStyle: OdooTypography.tableHeader.copyWith(
          color: OdooColors.textPrimary,
        ),
        dataTextStyle: OdooTypography.tableCell.copyWith(
          color: OdooColors.textPrimary,
        ),
        headingRowColor: WidgetStateProperty.all(OdooColors.gray50),
        dataRowMinHeight: 48,
        dataRowMaxHeight: 64,
        horizontalMargin: OdooSpacing.lg,
        columnSpacing: OdooSpacing.xl,
        dividerThickness: 1,
      ),

      // Tab bar theme
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: OdooColors.textSecondary,
        labelStyle: OdooTypography.labelLarge,
        unselectedLabelStyle: OdooTypography.labelLarge,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: OdooColors.gray100,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: OdooTypography.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: OdooSpacing.md,
          vertical: OdooSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: OdooColors.border,
        thickness: 1,
        space: 1,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: OdooColors.textSecondary,
        size: OdooIconSizes.lg,
      ),
    );
  }

  /// Dark theme
  static ThemeData dark() {
    final colorScheme = OdooColors.darkColorScheme();
    final textTheme = OdooTypography.textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: OdooTypography.fontFamily,
      scaffoldBackgroundColor: OdooColors.sidebarBackground,
      brightness: Brightness.dark,

      // Similar theme configurations for dark mode
      // (abbreviated for brevity - would include all the same properties
      // with appropriate dark mode colors)

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: OdooColors.sidebarBackground,
        foregroundColor: OdooColors.sidebarText,
        titleTextStyle: OdooTypography.titleLarge.copyWith(
          color: OdooColors.sidebarText,
        ),
      ),

      cardTheme: CardTheme(
        elevation: 0,
        color: const Color(0xFF3E3E4A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          side: const BorderSide(
            color: Color(0xFF575766),
            width: 1,
          ),
        ),
      ),
    );
  }
}
