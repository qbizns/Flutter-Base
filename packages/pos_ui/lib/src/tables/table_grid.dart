import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart' as pos;
import 'table_card.dart';

/// Grid layout for displaying tables.
///
/// Supports filtering by zone and status.
class TableGrid extends StatelessWidget {
  const TableGrid({
    required this.tables,
    this.onTableTap,
    this.crossAxisCount,
    this.compact = false,
    this.loading = false,
    super.key,
  });

  final List<pos.Table> tables;
  final void Function(pos.Table)? onTableTap;
  final int? crossAxisCount;
  final bool compact;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No tables available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    final effectiveCrossAxisCount = crossAxisCount ?? _getResponsiveColumns(context);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: effectiveCrossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: compact ? 1.5 : 1.0,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return TableCard(
          table: table,
          onTap: () => onTableTap?.call(table),
          compact: compact,
        );
      },
    );
  }

  int _getResponsiveColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }
}
