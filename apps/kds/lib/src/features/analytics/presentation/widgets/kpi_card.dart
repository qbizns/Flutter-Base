/// KPI Card Widget
/// Performance indicator cards following Odoo dashboard patterns
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// KPI Card Widget
/// Displays a single key performance indicator
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: VodoDimensions.borderRadiusMd,
        child: Container(
          padding: VodoDimensions.paddingLg,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: VodoDimensions.borderRadiusMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: VodoDimensions.borderRadiusSm,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: VodoDimensions.spacingSm),
                  Expanded(
                    child: Text(
                      title,
                      style: VodoTextStyles.bodyMedium.copyWith(
                        color: VodoColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: VodoDimensions.spacingMd),

              // Value
              Text(
                value,
                style: VodoTextStyles.display.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 36,
                ),
              ),

              // Subtitle or trend
              if (subtitle != null || trend != null) ...[
                const SizedBox(height: VodoDimensions.spacingXs),
                Row(
                  children: [
                    if (subtitle != null)
                      Expanded(
                        child: Text(
                          subtitle!,
                          style: VodoTextStyles.bodySmall.copyWith(
                            color: VodoColors.textTertiary,
                          ),
                        ),
                      ),
                    if (trend != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isPositiveTrend
                                  ? VodoColors.success
                                  : VodoColors.danger)
                              .withOpacity(0.1),
                          borderRadius: VodoDimensions.borderRadiusSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositiveTrend
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 12,
                              color: isPositiveTrend
                                  ? VodoColors.success
                                  : VodoColors.danger,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              trend!,
                              style: VodoTextStyles.caption.copyWith(
                                color: isPositiveTrend
                                    ? VodoColors.success
                                    : VodoColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact KPI Card for smaller displays
class CompactKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const CompactKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: VodoDimensions.paddingMd,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: VodoDimensions.borderRadiusSm,
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: VodoDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: VodoTextStyles.titleLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: VodoTextStyles.caption.copyWith(
                    color: VodoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Performance Rating Card
class PerformanceRatingCard extends StatelessWidget {
  final String title;
  final double score;
  final String rating;
  final String emoji;
  final Color color;

  const PerformanceRatingCard({
    super.key,
    required this.title,
    required this.score,
    required this.rating,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Container(
        padding: VodoDimensions.paddingLg,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: VodoDimensions.borderRadiusMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: VodoTextStyles.titleMedium.copyWith(
                color: VodoColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: VodoDimensions.spacingMd),

            // Score and emoji
            Row(
              children: [
                // Score
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${score.toStringAsFixed(0)}%',
                        style: VodoTextStyles.display.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 48,
                        ),
                      ),
                      Text(
                        rating,
                        style: VodoTextStyles.titleMedium.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Emoji
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ],
            ),

            const SizedBox(height: VodoDimensions.spacingSm),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: VodoColors.backgroundSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat comparison card (before vs after, target vs actual)
class StatComparisonCard extends StatelessWidget {
  final String title;
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;
  final IconData icon;
  final Color color;

  const StatComparisonCard({
    super.key,
    required this.title,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Container(
        padding: VodoDimensions.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: VodoDimensions.spacingSm),
                Text(
                  title,
                  style: VodoTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: VodoDimensions.spacingMd),

            // Comparison
            Row(
              children: [
                // Left
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leftLabel,
                        style: VodoTextStyles.caption.copyWith(
                          color: VodoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        leftValue,
                        style: VodoTextStyles.titleLarge.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  width: 2,
                  height: 40,
                  color: VodoColors.border,
                  margin: const EdgeInsets.symmetric(
                    horizontal: VodoDimensions.spacingMd,
                  ),
                ),

                // Right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rightLabel,
                        style: VodoTextStyles.caption.copyWith(
                          color: VodoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rightValue,
                        style: VodoTextStyles.titleLarge.copyWith(
                          color: VodoColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
