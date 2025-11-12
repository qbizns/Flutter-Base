import 'package:flutter/material.dart';
import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';

/// KPI Card Widget
///
/// Displays a single key performance indicator with Odoo styling
class KpiCard extends StatelessWidget {
  const KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.trend,
    this.trendUp = true,
    this.color,
    this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final String? trend; // e.g., "+12.5%"
  final bool trendUp;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? OdooColors.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        child: Padding(
          padding: const EdgeInsets.all(OdooSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon and trend row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(OdooSpacing.sm),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(OdooSpacing.radiusStandard),
                    ),
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: OdooIconSizes.lg,
                    ),
                  ),
                  const Spacer(),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OdooSpacing.sm,
                        vertical: OdooSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: trendUp
                            ? OdooColors.successLight
                            : OdooColors.dangerLight,
                        borderRadius:
                            BorderRadius.circular(OdooSpacing.radiusStandard),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendUp
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: OdooIconSizes.sm,
                            color: trendUp
                                ? OdooColors.success
                                : OdooColors.danger,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            trend!,
                            style: OdooTypography.labelSmall.copyWith(
                              color: trendUp
                                  ? OdooColors.success
                                  : OdooColors.danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: OdooSpacing.lg),

              // Value
              Text(
                value,
                style: OdooTypography.statValue.copyWith(
                  color: OdooColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: OdooSpacing.xs),

              // Title
              Text(
                title,
                style: OdooTypography.bodyMedium.copyWith(
                  color: OdooColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Subtitle (optional)
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
