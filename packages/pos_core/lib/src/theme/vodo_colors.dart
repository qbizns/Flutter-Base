/// Vodo Design System - Color Palette
/// Inspired by modern ERP systems with purple/teal accent scheme
library;

import 'package:flutter/material.dart';

/// Vodo color palette following enterprise design standards
class VodoColors {
  VodoColors._();

  // Primary Colors (Purple scheme)
  static const Color primary = Color(0xFF714B67);
  static const Color primaryDark = Color(0xFF5A3A52);
  static const Color primaryLight = Color(0xFF8F6B83);
  static const Color primaryLighter = Color(0xFFB39BA9);

  // Accent Colors
  static const Color accent = Color(0xFF00A09D);
  static const Color accentDark = Color(0xFF008080);
  static const Color accentLight = Color(0xFF33B3B0);

  // Semantic Colors
  static const Color success = Color(0xFF28A745);
  static const Color successLight = Color(0xFF5CB85C);
  static const Color successDark = Color(0xFF218838);

  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFFFA000);

  static const Color danger = Color(0xFFDC3545);
  static const Color dangerLight = Color(0xFFE57373);
  static const Color dangerDark = Color(0xFFC82333);

  static const Color info = Color(0xFF17A2B8);
  static const Color infoLight = Color(0xFF5DADE2);
  static const Color infoDark = Color(0xFF117A8B);

  // Neutral Colors (Grey Scale)
  static const Color grey50 = Color(0xFFF8F9FA);
  static const Color grey100 = Color(0xFFE9ECEF);
  static const Color grey200 = Color(0xFFDEE2E6);
  static const Color grey300 = Color(0xFFCED4DA);
  static const Color grey400 = Color(0xFFADB5BD);
  static const Color grey500 = Color(0xFF6C757D);
  static const Color grey600 = Color(0xFF495057);
  static const Color grey700 = Color(0xFF343A40);
  static const Color grey800 = Color(0xFF212529);
  static const Color grey900 = Color(0xFF000000);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF8F9FA);
  static const Color backgroundTertiary = Color(0xFFE9ECEF);

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceOverlay = Color(0x1F000000);

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFFADB5BD);
  static const Color textDisabled = Color(0xFFCED4DA);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFDEE2E6);
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color borderDark = Color(0xFFCED4DA);

  // Shadow Colors
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x26000000);

  // Status Colors (for orders, transactions, etc.)
  static const Color statusNew = Color(0xFF17A2B8);
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusInProgress = Color(0xFF007BFF);
  static const Color statusCompleted = Color(0xFF28A745);
  static const Color statusCancelled = Color(0xFFDC3545);
  static const Color statusDraft = Color(0xFF6C757D);

  // Priority Colors
  static const Color priorityLow = Color(0xFF28A745);
  static const Color priorityNormal = Color(0xFF17A2B8);
  static const Color priorityHigh = Color(0xFFFFC107);
  static const Color priorityUrgent = Color(0xFFDC3545);

  // POS Specific Colors
  static const Color cashPayment = Color(0xFF28A745);
  static const Color cardPayment = Color(0xFF007BFF);
  static const Color mobilePayment = Color(0xFF6F42C1);
  static const Color splitPayment = Color(0xFFFD7E14);

  // Kitchen Station Colors
  static const Color stationGrill = Color(0xFFDC3545);
  static const Color stationFry = Color(0xFFFFC107);
  static const Color stationSalad = Color(0xFF28A745);
  static const Color stationDessert = Color(0xFFE83E8C);
  static const Color stationDrinks = Color(0xFF17A2B8);
  static const Color stationPizza = Color(0xFFFD7E14);

  /// Get color by status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return statusNew;
      case 'pending':
        return statusPending;
      case 'in_progress':
      case 'preparing':
        return statusInProgress;
      case 'completed':
      case 'done':
      case 'ready':
        return statusCompleted;
      case 'cancelled':
      case 'canceled':
        return statusCancelled;
      case 'draft':
        return statusDraft;
      default:
        return grey500;
    }
  }

  /// Get color by priority
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return priorityLow;
      case 'normal':
      case 'medium':
        return priorityNormal;
      case 'high':
        return priorityHigh;
      case 'urgent':
      case 'critical':
        return priorityUrgent;
      default:
        return priorityNormal;
    }
  }

  /// Get color by payment method
  static Color getPaymentColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return cashPayment;
      case 'card':
      case 'credit':
      case 'debit':
        return cardPayment;
      case 'mobile':
      case 'wallet':
        return mobilePayment;
      case 'split':
        return splitPayment;
      default:
        return grey500;
    }
  }
}
