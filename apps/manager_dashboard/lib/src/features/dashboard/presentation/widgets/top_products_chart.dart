import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';

/// Top Products Pie Chart Widget
///
/// Displays a pie chart showing the distribution of top selling products
class TopProductsChart extends StatefulWidget {
  const TopProductsChart({
    required this.products,
    super.key,
  });

  final List<ProductSales> products;

  @override
  State<TopProductsChart> createState() => _TopProductsChartState();
}

class _TopProductsChartState extends State<TopProductsChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Products',
              style: OdooTypography.cardTitle.copyWith(
                color: OdooColors.textPrimary,
              ),
            ),
            const SizedBox(height: OdooSpacing.xl),
            SizedBox(
              height: 250,
              child: widget.products.isEmpty
                  ? _buildEmptyState()
                  : Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildPieChart(),
                        ),
                        const SizedBox(width: OdooSpacing.lg),
                        Expanded(
                          flex: 2,
                          child: _buildLegend(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: OdooColors.gray400,
          ),
          const SizedBox(height: OdooSpacing.md),
          Text(
            'No product sales data available',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: _buildSections(),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = widget.products.fold<double>(
      0,
      (sum, product) => sum + product.sales,
    );

    return widget.products.asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 65.0 : 55.0;
      final fontSize = isTouched ? 14.0 : 12.0;
      final percentage = (product.sales / total * 100);

      return PieChartSectionData(
        color: OdooColors.chartColors[index % OdooColors.chartColors.length],
        value: product.sales,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: OdooTypography.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        final product = widget.products[index];
        final color =
            OdooColors.chartColors[index % OdooColors.chartColors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: OdooSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(OdooSpacing.radiusSmall),
                ),
              ),
              const SizedBox(width: OdooSpacing.sm),
              Expanded(
                child: Text(
                  product.name,
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${product.quantity}',
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Product Sales Data Model
class ProductSales {
  final String name;
  final int quantity;
  final double sales;

  ProductSales({
    required this.name,
    required this.quantity,
    required this.sales,
  });
}
