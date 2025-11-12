/// Simple Bar Chart Widget
/// Custom bar chart following Odoo dashboard patterns
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Bar chart data point
class BarChartData {
  final String label;
  final double value;
  final Color? color;

  BarChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

/// Simple Bar Chart Widget
/// Displays data as vertical bars
class SimpleBarChart extends StatelessWidget {
  final List<BarChartData> data;
  final String title;
  final String? subtitle;
  final Color barColor;
  final double maxValue;
  final bool showLabels;
  final bool showValues;

  const SimpleBarChart({
    super.key,
    required this.data,
    required this.title,
    this.subtitle,
    this.barColor = VodoColors.primary,
    double? maxValue,
    this.showLabels = true,
    this.showValues = false,
  }) : maxValue = maxValue ?? 0;

  double get _maxValue {
    if (maxValue > 0) return maxValue;
    if (data.isEmpty) return 100;
    return data.map((d) => d.value).reduce((a, b) => a > b ? a : b) * 1.1;
  }

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
            Text(
              title,
              style: VodoTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: VodoTextStyles.bodySmall.copyWith(
                  color: VodoColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: VodoDimensions.spacingLg),

            // Chart
            SizedBox(
              height: 200,
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'No data available',
                        style: VodoTextStyles.bodyMedium.copyWith(
                          color: VodoColors.textTertiary,
                        ),
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: data.map((point) {
                        return Expanded(
                          child: _buildBar(point),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BarChartData point) {
    final height = (point.value / _maxValue * 180).clamp(4.0, 180.0);
    final color = point.color ?? barColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Value label (optional)
          if (showValues) ...[
            Text(
              point.value.toStringAsFixed(0),
              style: VodoTextStyles.caption.copyWith(
                color: VodoColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Bar
          Tooltip(
            message: '${point.label}: ${point.value.toStringAsFixed(1)}',
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ),

          // Label
          if (showLabels) ...[
            const SizedBox(height: 4),
            Text(
              point.label,
              style: VodoTextStyles.caption.copyWith(
                color: VodoColors.textTertiary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Horizontal Bar Chart
class HorizontalBarChart extends StatelessWidget {
  final List<BarChartData> data;
  final String title;
  final Color barColor;

  const HorizontalBarChart({
    super.key,
    required this.data,
    required this.title,
    this.barColor = VodoColors.primary,
  });

  double get _maxValue {
    if (data.isEmpty) return 100;
    return data.map((d) => d.value).reduce((a, b) => a > b ? a : b) * 1.1;
  }

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
            Text(
              title,
              style: VodoTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: VodoDimensions.spacingLg),

            // Bars
            ...data.map((point) => _buildHorizontalBar(point)),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBar(BarChartData point) {
    final width = (point.value / _maxValue).clamp(0.0, 1.0);
    final color = point.color ?? barColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: VodoDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                point.label,
                style: VodoTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                point.value.toStringAsFixed(1),
                style: VodoTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Background
                Container(
                  height: 8,
                  color: VodoColors.backgroundSecondary,
                ),

                // Filled portion
                FractionallySizedBox(
                  widthFactor: width,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withOpacity(0.7),
                        ],
                      ),
                    ),
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

/// Simple Line Chart (points connected with lines)
class SimpleLineChart extends StatelessWidget {
  final List<BarChartData> data;
  final String title;
  final String? subtitle;
  final Color lineColor;
  final bool showArea;

  const SimpleLineChart({
    super.key,
    required this.data,
    required this.title,
    this.subtitle,
    this.lineColor = VodoColors.primary,
    this.showArea = true,
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
            Text(
              title,
              style: VodoTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: VodoTextStyles.bodySmall.copyWith(
                  color: VodoColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: VodoDimensions.spacingLg),

            // Chart
            SizedBox(
              height: 150,
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'No data available',
                        style: VodoTextStyles.bodyMedium.copyWith(
                          color: VodoColors.textTertiary,
                        ),
                      ),
                    )
                  : CustomPaint(
                      painter: _LineChartPainter(
                        data: data,
                        lineColor: lineColor,
                        showArea: showArea,
                      ),
                      child: Container(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Line chart painter
class _LineChartPainter extends CustomPainter {
  final List<BarChartData> data;
  final Color lineColor;
  final bool showArea;

  _LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.showArea,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return;

    final stepX = size.width / (data.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i].value / maxValue * size.height);
      points.add(Offset(x, y));
    }

    // Draw area
    if (showArea) {
      final areaPath = Path();
      areaPath.moveTo(0, size.height);

      for (final point in points) {
        areaPath.lineTo(point.dx, point.dy);
      }

      areaPath.lineTo(size.width, size.height);
      areaPath.close();

      final areaPaint = Paint()
        ..color = lineColor.withOpacity(0.2)
        ..style = PaintingStyle.fill;

      canvas.drawPath(areaPath, areaPaint);
    }

    // Draw line
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Draw points
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = lineColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
