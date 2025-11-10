import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Queue Dashboard - Real-time queue monitoring and management
class QueueDashboardPage extends ConsumerWidget {
  const QueueDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock service counter data
    final counters = [
      ServiceCounter('Counter 1', CounterStatus.serving, 'Sarah Johnson', 'Q01-045', 'General Inquiry', 3),
      ServiceCounter('Counter 2', CounterStatus.serving, 'Mike Davis', 'Q02-112', 'Order Pickup', 8),
      ServiceCounter('Counter 3', CounterStatus.idle, null, null, null, 0),
      ServiceCounter('Counter 4', CounterStatus.serving, 'Emily Brown', 'Q03-078', 'Returns', 12),
      ServiceCounter('Express Counter', CounterStatus.onBreak, 'David Wilson', null, null, 0),
    ];

    // Mock queue data
    final queues = [
      QueueData('General Inquiry', 12, 8, 4, 18.5),
      QueueData('Order Pickup', 8, 5, 3, 12.3),
      QueueData('Returns', 15, 10, 5, 22.8),
      QueueData('Technical Support', 6, 4, 2, 25.5),
      QueueData('Catering Services', 3, 2, 1, 15.0),
      QueueData('Loyalty Program', 5, 3, 2, 10.2),
    ];

    final totalWaiting = queues.fold<int>(0, (sum, q) => sum + q.waiting);
    final totalServing = queues.fold<int>(0, (sum, q) => sum + q.serving);
    final avgWaitTime = queues.fold<double>(0, (sum, q) => sum + q.avgWaitTime) / queues.length;
    final activeCounters = counters.where((c) => c.status == CounterStatus.serving).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Queue Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people, color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Waiting', style: TextStyle(color: Colors.orange.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$totalWaiting', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                        Text('In queue', style: TextStyle(fontSize: 12, color: Colors.orange.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Serving', style: TextStyle(color: Colors.blue.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$totalServing', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                        Text('Currently serving', style: TextStyle(fontSize: 12, color: Colors.blue.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.purple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.purple.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Avg Wait', style: TextStyle(color: Colors.purple.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${avgWaitTime.toStringAsFixed(1)} min', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                        Text('Average time', style: TextStyle(fontSize: 12, color: Colors.purple.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.countertops, color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Active Counters', style: TextStyle(color: Colors.green.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$activeCounters/${counters.length}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                        Text('Counters active', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Service Counters
          Text('Service Counters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...counters.map((counter) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getCounterStatusColor(counter.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.countertops, color: _getCounterStatusColor(counter.status), size: 24),
              ),
              title: Row(
                children: [
                  Text(counter.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCounterStatusColor(counter.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      counter.status.displayName,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getCounterStatusColor(counter.status)),
                    ),
                  ),
                ],
              ),
              subtitle: counter.status == CounterStatus.serving
                  ? Text('${counter.agentName} • Serving ${counter.currentTicket} • ${counter.serviceType} • ${counter.serveTime} min')
                  : (counter.status == CounterStatus.onBreak
                      ? Text('${counter.agentName} • On Break')
                      : const Text('Available')),
              trailing: counter.status == CounterStatus.serving
                  ? OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Complete'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    )
                  : (counter.status == CounterStatus.idle
                      ? FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Call Next'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        )
                      : null),
            ),
          )),
          const SizedBox(height: 24),

          // Queue Overview
          Text('Queue Overview', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...queues.map((queue) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.queue, color: theme.colorScheme.onPrimaryContainer, size: 24),
              ),
              title: Text(queue.serviceType, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${queue.waiting} waiting • ${queue.serving} serving • ${queue.avgWaitTime.toStringAsFixed(1)} min avg wait'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${queue.waiting}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('waiting', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildQueueMetric('Waiting', queue.waiting, Colors.orange),
                      const SizedBox(height: 12),
                      _buildQueueMetric('Serving', queue.serving, Colors.blue),
                      const SizedBox(height: 12),
                      _buildQueueMetric('Completed Today', queue.completed, Colors.green),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20, color: Colors.grey),
                          const SizedBox(width: 12),
                          const Text('Average Wait Time', style: TextStyle(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text('${queue.avgWaitTime.toStringAsFixed(1)} min', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('View Queue'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('New Ticket'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.confirmation_number),
        label: const Text('New Ticket'),
      ),
    );
  }

  Widget _buildQueueMetric(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Color _getCounterStatusColor(CounterStatus status) {
    switch (status) {
      case CounterStatus.serving: return Colors.green;
      case CounterStatus.idle: return Colors.grey;
      case CounterStatus.onBreak: return Colors.orange;
    }
  }
}

// Models
class ServiceCounter {
  final String name;
  final CounterStatus status;
  final String? agentName;
  final String? currentTicket;
  final String? serviceType;
  final int serveTime;

  ServiceCounter(this.name, this.status, this.agentName, this.currentTicket, this.serviceType, this.serveTime);
}

class QueueData {
  final String serviceType;
  final int waiting;
  final int serving;
  final int completed;
  final double avgWaitTime;

  QueueData(this.serviceType, this.waiting, this.serving, this.completed, this.avgWaitTime);
}

enum CounterStatus {
  serving('SERVING'),
  idle('IDLE'),
  onBreak('ON BREAK');

  final String displayName;
  const CounterStatus(this.displayName);
}
