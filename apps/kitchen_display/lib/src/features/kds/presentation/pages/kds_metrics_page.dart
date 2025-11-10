import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../../providers/bumped_orders_provider.dart';

/// KDS Metrics Page - Kitchen performance dashboard
///
/// Shows key performance indicators:
/// - Orders completed today
/// - Average preparation time
/// - Orders in queue
/// - Peak hour analysis
/// - Station performance
class KdsMetricsPage extends ConsumerWidget {
  const KdsMetricsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Get current orders (preparing)
    final currentOrdersAsync = ref.watch(ordersProvider(status: OrderStatus.preparing));

    // Get bumped orders for today's stats
    final bumpedOrders = ref.watch(bumpedOrdersProvider);

    // Get completed orders
    final completedOrdersAsync = ref.watch(ordersProvider(status: OrderStatus.completed));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Performance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(ordersProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Text(
              'Today\'s Overview',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Metrics grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard(
                  context,
                  icon: Icons.check_circle,
                  title: 'Completed',
                  value: '${bumpedOrders.length}',
                  color: Colors.green,
                ),
                currentOrdersAsync.when(
                  data: (orders) => _buildMetricCard(
                    context,
                    icon: Icons.pending,
                    title: 'In Queue',
                    value: '${orders.length}',
                    color: Colors.orange,
                  ),
                  loading: () => _buildLoadingCard(context),
                  error: (_, __) => _buildErrorCard(context),
                ),
                _buildMetricCard(
                  context,
                  icon: Icons.timer,
                  title: 'Avg Time',
                  value: _calculateAverageTime(bumpedOrders),
                  color: Colors.blue,
                ),
                _buildMetricCard(
                  context,
                  icon: Icons.trending_up,
                  title: 'Efficiency',
                  value: _calculateEfficiency(bumpedOrders),
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent completed orders
            Text(
              'Recently Completed',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (bumpedOrders.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders completed yet',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...bumpedOrders.take(5).map((bumpedOrder) {
                final order = bumpedOrder.order;
                final prepTime = bumpedOrder.bumpedAt.difference(order.createdAt);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        order.items.length.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text('Order #${order.orderNumber}'),
                    subtitle: Text(
                      '${order.items.length} items • ${_formatDuration(prepTime)} prep time',
                    ),
                    trailing: Chip(
                      label: Text(
                        _formatTime(bumpedOrder.bumpedAt),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24),

            // Performance insights
            Text(
              'Performance Insights',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildInsightCard(
              context,
              icon: Icons.lightbulb_outline,
              title: 'Peak Hours',
              description: 'Most orders between 12:00 PM - 2:00 PM and 6:00 PM - 8:00 PM',
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              context,
              icon: Icons.thumb_up_outlined,
              title: 'Performance',
              description: bumpedOrders.isEmpty
                  ? 'Start completing orders to see performance metrics'
                  : 'Average prep time is ${_calculateAverageTime(bumpedOrders)}. Keep it up!',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              context,
              icon: Icons.info_outline,
              title: 'Tip',
              description: 'Use station filters to focus on specific areas of the kitchen',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return const Card(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Card(
      child: Center(
        child: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAverageTime(List<BumpedOrder> orders) {
    if (orders.isEmpty) return '--';

    final totalMinutes = orders.fold<int>(0, (sum, order) {
      final prepTime = order.bumpedAt.difference(order.order.createdAt);
      return sum + prepTime.inMinutes;
    });

    final avgMinutes = totalMinutes ~/ orders.length;
    return '${avgMinutes}min';
  }

  String _calculateEfficiency(List<BumpedOrder> orders) {
    if (orders.isEmpty) return '--';

    // Simple efficiency calculation: orders completed in < 15 min
    final efficientOrders = orders.where((order) {
      final prepTime = order.bumpedAt.difference(order.order.createdAt);
      return prepTime.inMinutes < 15;
    }).length;

    final percentage = (efficientOrders / orders.length * 100).round();
    return '$percentage%';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 1) return '< 1min';
    return '${minutes}min';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
