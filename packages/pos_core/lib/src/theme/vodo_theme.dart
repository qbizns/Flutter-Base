/// Vodo Design System - Main Theme
/// Complete Material 3 theme configuration
library;

import 'package:flutter/material.dart';
import 'vodo_colors.dart';
import 'vodo_text_styles.dart';
import 'vodo_dimensions.dart';

/// Vodo theme configuration
class VodoTheme {
  VodoTheme._();

  /// Light theme (default)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: VodoColors.primary,
        onPrimary: VodoColors.textOnPrimary,
        primaryContainer: VodoColors.primaryLight,
        onPrimaryContainer: VodoColors.textPrimary,
        secondary: VodoColors.accent,
        onSecondary: VodoColors.textOnAccent,
        secondaryContainer: VodoColors.accentLight,
        onSecondaryContainer: VodoColors.textPrimary,
        tertiary: VodoColors.info,
        onTertiary: VodoColors.textOnPrimary,
        error: VodoColors.danger,
        onError: VodoColors.textOnPrimary,
        errorContainer: VodoColors.dangerLight,
        onErrorContainer: VodoColors.dangerDark,
        background: VodoColors.background,
        onBackground: VodoColors.textPrimary,
        surface: VodoColors.surface,
        onSurface: VodoColors.textPrimary,
        surfaceVariant: VodoColors.backgroundSecondary,
        onSurfaceVariant: VodoColors.textSecondary,
        outline: VodoColors.border,
        outlineVariant: VodoColors.borderLight,
        shadow: VodoColors.shadowMedium,
        scrim: VodoColors.surfaceOverlay,
        inverseSurface: VodoColors.grey800,
        onInverseSurface: VodoColors.textOnPrimary,
        inversePrimary: VodoColors.primaryLight,
      ),

      // Typography
      textTheme: const TextTheme(
        displayLarge: VodoTextStyles.displayLarge,
        displayMedium: VodoTextStyles.displayMedium,
        displaySmall: VodoTextStyles.displaySmall,
        headlineLarge: VodoTextStyles.headlineLarge,
        headlineMedium: VodoTextStyles.headlineMedium,
        headlineSmall: VodoTextStyles.headlineSmall,
        titleLarge: VodoTextStyles.titleLarge,
        titleMedium: VodoTextStyles.titleMedium,
        titleSmall: VodoTextStyles.titleSmall,
        bodyLarge: VodoTextStyles.bodyLarge,
        bodyMedium: VodoTextStyles.bodyMedium,
        bodySmall: VodoTextStyles.bodySmall,
        labelLarge: VodoTextStyles.labelLarge,
        labelMedium: VodoTextStyles.labelMedium,
        labelSmall: VodoTextStyles.labelSmall,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: VodoColors.primary,
        foregroundColor: VodoColors.textOnPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: VodoColors.textOnPrimary,
        ),
        iconTheme: IconThemeData(
          color: VodoColors.textOnPrimary,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: VodoDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: VodoDimensions.borderRadiusMd,
        ),
        color: VodoColors.surface,
        shadowColor: VodoColors.shadowMedium,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VodoColors.primary,
          foregroundColor: VodoColors.textOnPrimary,
          elevation: 2,
          padding: VodoDimensions.buttonPaddingMd,
          shape: RoundedRectangleBorder(
            borderRadius: VodoDimensions.borderRadiusMd,
          ),
          textStyle: VodoTextStyles.button,
          minimumSize: const Size(0, VodoDimensions.buttonHeightMd),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VodoColors.primary,
          padding: VodoDimensions.buttonPaddingMd,
          shape: RoundedRectangleBorder(
            borderRadius: VodoDimensions.borderRadiusMd,
          ),
          textStyle: VodoTextStyles.button,
          minimumSize: const Size(0, VodoDimensions.buttonHeightMd),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VodoColors.primary,
          side: const BorderSide(color: VodoColors.border, width: 1),
          padding: VodoDimensions.buttonPaddingMd,
          shape: RoundedRectangleBorder(
            borderRadius: VodoDimensions.borderRadiusMd,
          ),
          textStyle: VodoTextStyles.button,
          minimumSize: const Size(0, VodoDimensions.buttonHeightMd),
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: VodoColors.textPrimary,
          highlightColor: VodoColors.primaryLight.withOpacity(0.1),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: VodoColors.accent,
        foregroundColor: VodoColors.textOnAccent,
        elevation: 4,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VodoColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: VodoDimensions.borderRadiusMd,
          borderSide: const BorderSide(color: VodoColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: VodoDimensions.borderRadiusMd,
          borderSide: const BorderSide(color: VodoColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: VodoDimensions.borderRadiusMd,
          borderSide: const BorderSide(color: VodoColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: VodoDimensions.borderRadiusMd,
          borderSide: const BorderSide(color: VodoColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: VodoDimensions.borderRadiusMd,
          borderSide: const BorderSide(color: VodoColors.danger, width: 2),
        ),
        contentPadding: VodoDimensions.inputPadding,
        labelStyle: VodoTextStyles.labelLarge,
        hintStyle: VodoTextStyles.bodyMedium.copyWith(color: VodoColors.textTertiary),
        errorStyle: VodoTextStyles.error,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: VodoColors.backgroundSecondary,
        deleteIconColor: VodoColors.textSecondary,
        labelStyle: VodoTextStyles.labelMedium,
        padding: VodoDimensions.chipPadding,
        shape: RoundedRectangleBorder(
          borderRadius: VodoDimensions.borderRadiusFull,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: VodoColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: VodoDimensions.borderRadiusLg,
        ),
        titleTextStyle: VodoTextStyles.headlineSmall,
        contentTextStyle: VodoTextStyles.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: VodoColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(VodoDimensions.radiusXl),
            topRight: Radius.circular(VodoDimensions.radiusXl),
          ),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: VodoColors.grey800,
        contentTextStyle: VodoTextStyles.bodyMedium.copyWith(
          color: VodoColors.textOnPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: VodoDimensions.borderRadiusMd,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: VodoColors.border,
        thickness: VodoDimensions.dividerThickness,
        space: VodoDimensions.spacing16,
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: VodoDimensions.listItemPadding,
        minLeadingWidth: VodoDimensions.iconSizeLg,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return VodoColors.primary;
          }
          return VodoColors.grey400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return VodoColors.primaryLight;
          }
          return VodoColors.grey300;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return VodoColors.primary;
          }
          return VodoColors.grey400;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: VodoDimensions.borderRadiusSm,
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return VodoColors.primary;
          }
          return VodoColors.grey400;
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: VodoColors.primary,
        linearTrackColor: VodoColors.grey200,
        circularTrackColor: VodoColors.grey200,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: VodoColors.grey800,
          borderRadius: VodoDimensions.borderRadiusSm,
        ),
        textStyle: VodoTextStyles.bodySmall.copyWith(
          color: VodoColors.textOnPrimary,
        ),
        padding: VodoDimensions.paddingSm,
      ),

      // Scrollbar Theme
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(VodoColors.grey400),
        trackColor: MaterialStateProperty.all(VodoColors.grey200),
        radius: const Radius.circular(VodoDimensions.radiusFull),
        thickness: MaterialStateProperty.all(8.0),
      ),

      // Navigation Bar Theme
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: VodoColors.surface,
        indicatorColor: VodoColors.primaryLight,
        elevation: 1,
        height: VodoDimensions.bottomNavHeight,
        labelTextStyle: MaterialStatePropertyAll(VodoTextStyles.labelSmall),
      ),

      // Navigation Rail Theme
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: VodoColors.surface,
        selectedIconTheme: IconThemeData(color: VodoColors.primary),
        unselectedIconTheme: IconThemeData(color: VodoColors.textSecondary),
        selectedLabelTextStyle: VodoTextStyles.labelMedium,
        unselectedLabelTextStyle: VodoTextStyles.labelMedium,
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: VodoColors.primary,
        unselectedLabelColor: VodoColors.textSecondary,
        indicatorColor: VodoColors.primary,
        labelStyle: VodoTextStyles.titleMedium,
        unselectedLabelStyle: VodoTextStyles.titleMedium,
      ),

      // Badge Theme
      badgeTheme: const BadgeThemeData(
        backgroundColor: VodoColors.danger,
        textColor: VodoColors.textOnPrimary,
        textStyle: VodoTextStyles.badge,
      ),
    );
  }

  /// Dark theme (optional)
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: VodoColors.primaryLight,
        onPrimary: VodoColors.textPrimary,
        primaryContainer: VodoColors.primaryDark,
        onPrimaryContainer: VodoColors.textOnPrimary,
        secondary: VodoColors.accentLight,
        onSecondary: VodoColors.textPrimary,
        secondaryContainer: VodoColors.accentDark,
        onSecondaryContainer: VodoColors.textOnPrimary,
        tertiary: VodoColors.infoLight,
        onTertiary: VodoColors.textPrimary,
        error: VodoColors.dangerLight,
        onError: VodoColors.textPrimary,
        errorContainer: VodoColors.dangerDark,
        onErrorContainer: VodoColors.textOnPrimary,
        background: VodoColors.grey900,
        onBackground: VodoColors.grey50,
        surface: VodoColors.grey800,
        onSurface: VodoColors.grey50,
        surfaceVariant: VodoColors.grey700,
        onSurfaceVariant: VodoColors.grey300,
        outline: VodoColors.grey600,
        outlineVariant: VodoColors.grey700,
        shadow: VodoColors.shadowDark,
        scrim: VodoColors.surfaceOverlay,
        inverseSurface: VodoColors.grey50,
        onInverseSurface: VodoColors.textPrimary,
        inversePrimary: VodoColors.primaryDark,
      ),
    );
  }
}
