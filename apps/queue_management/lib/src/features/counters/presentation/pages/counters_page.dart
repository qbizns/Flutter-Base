import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Service Counters - Counter and agent management
class CountersPage extends ConsumerWidget {
  const CountersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock counter data
    final counters = [
      CounterInfo('Counter 1', CounterStatus.serving, 'Sarah Johnson', 'Q01-045', 'General Inquiry', DateTime.now().subtract(const Duration(minutes: 3)), 45, 8.2, 92.5),
      CounterInfo('Counter 2', CounterStatus.serving, 'Mike Davis', 'Q02-112', 'Order Pickup', DateTime.now().subtract(const Duration(minutes: 8)), 38, 6.5, 95.8),
      CounterInfo('Counter 3', CounterStatus.idle, null, null, null, null, 0, 0, 0),
      CounterInfo('Counter 4', CounterStatus.serving, 'Emily Brown', 'Q03-078', 'Returns', DateTime.now().subtract(const Duration(minutes: 12)), 52, 9.8, 88.3),
      CounterInfo('Express Counter', CounterStatus.onBreak, 'David Wilson', null, null, DateTime.now().subtract(const Duration(minutes: 5)), 68, 4.2, 97.1),
    ];

    // Mock agent performance data
    final agents = [
      AgentPerformance('Sarah Johnson', AgentStatus.active, 'Counter 1', 45, 8.2, 7.5, 92.5, DateTime(2024, 1, 15)),
      AgentPerformance('Mike Davis', AgentStatus.active, 'Counter 2', 38, 6.5, 6.8, 95.8, DateTime(2023, 8, 22)),
      AgentPerformance('Emily Brown', AgentStatus.active, 'Counter 4', 52, 9.8, 8.2, 88.3, DateTime(2024, 3, 10)),
      AgentPerformance('David Wilson', AgentStatus.onBreak, 'Express Counter', 68, 4.2, 5.5, 97.1, DateTime(2023, 5, 5)),
      AgentPerformance('Jessica Taylor', AgentStatus.offline, null, 0, 0, 7.2, 94.2, DateTime(2024, 2, 18)),
    ];

    final activeCount = counters.where((c) => c.status == CounterStatus.serving).length;
    final idleCount = counters.where((c) => c.status == CounterStatus.idle).length;
    final totalTicketsToday = counters.fold<int>(0, (sum, c) => sum + c.ticketsServed);
    final avgServiceTime = counters.where((c) => c.avgServiceTime > 0).fold<double>(0, (sum, c) => sum + c.avgServiceTime) / counters.where((c) => c.avgServiceTime > 0).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Service Counters')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(
            children: [
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
                            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Active Counters', style: TextStyle(color: Colors.green.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$activeCount/${counters.length}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                        Text('Serving customers', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.weekend, color: Colors.grey.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Idle', style: TextStyle(color: Colors.grey.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$idleCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                        Text('Available', style: TextStyle(fontSize: 12, color: Colors.grey.shade700.withOpacity(0.7))),
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
                            Icon(Icons.confirmation_number, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Tickets Today', style: TextStyle(color: Colors.blue.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$totalTicketsToday', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                        Text('Completed', style: TextStyle(fontSize: 12, color: Colors.blue.shade700.withOpacity(0.7))),
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
                            Icon(Icons.speed, color: Colors.purple.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Avg Service', style: TextStyle(color: Colors.purple.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${avgServiceTime.toStringAsFixed(1)} min', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                        Text('Per ticket', style: TextStyle(fontSize: 12, color: Colors.purple.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Counters
          Text('Active Counters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...counters.map((counter) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
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
                  ? Text('${counter.agentName} • ${counter.currentTicket} • ${counter.serviceType}')
                  : (counter.status == CounterStatus.onBreak
                      ? Text('${counter.agentName} • Break started ${_formatTime(counter.statusChangedAt!)}')
                      : const Text('Available for service')),
              trailing: counter.status == CounterStatus.serving
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${DateTime.now().difference(counter.statusChangedAt!).inMinutes} min',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text('serving', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )
                  : null,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('Counter', counter.name),
                      if (counter.agentName != null) _buildInfoRow('Agent', counter.agentName!),
                      _buildInfoRow('Status', counter.status.displayName),
                      if (counter.currentTicket != null) _buildInfoRow('Current Ticket', counter.currentTicket!),
                      if (counter.serviceType != null) _buildInfoRow('Service Type', counter.serviceType!),
                      _buildInfoRow('Tickets Today', '${counter.ticketsServed}'),
                      if (counter.avgServiceTime > 0) _buildInfoRow('Avg Service Time', '${counter.avgServiceTime.toStringAsFixed(1)} min'),
                      if (counter.satisfaction > 0) _buildInfoRow('Satisfaction', '${counter.satisfaction.toStringAsFixed(1)}%'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (counter.status == CounterStatus.serving) ...([
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: const Text('Complete'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.pause, size: 18),
                                label: const Text('Break'),
                              ),
                            ),
                          ]),
                          if (counter.status == CounterStatus.idle) ...([
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: const Text('Call Next'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Close Counter'),
                              ),
                            ),
                          ]),
                          if (counter.status == CounterStatus.onBreak) ...([
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: const Text('Resume'),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 24),

          // Agent Performance
          Text('Agent Performance', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...agents.map((agent) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getAgentStatusColor(agent.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person, color: _getAgentStatusColor(agent.status), size: 24),
              ),
              title: Row(
                children: [
                  Text(agent.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getAgentStatusColor(agent.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      agent.status.displayName,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getAgentStatusColor(agent.status)),
                    ),
                  ),
                ],
              ),
              subtitle: agent.counter != null
                  ? Text('${agent.counter} • ${agent.ticketsToday} tickets • ${agent.avgServiceTime.toStringAsFixed(1)} min avg • ${agent.satisfaction.toStringAsFixed(1)}% rating')
                  : Text('Joined ${DateFormat('MMM yyyy').format(agent.joinDate)} • ${agent.avgServiceTime.toStringAsFixed(1)} min avg • ${agent.satisfaction.toStringAsFixed(1)}% rating'),
              trailing: agent.status == AgentStatus.active
                  ? Text('${agent.ticketsToday}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue))
                  : null,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _getCounterStatusColor(CounterStatus status) {
    switch (status) {
      case CounterStatus.serving: return Colors.green;
      case CounterStatus.idle: return Colors.grey;
      case CounterStatus.onBreak: return Colors.orange;
    }
  }

  Color _getAgentStatusColor(AgentStatus status) {
    switch (status) {
      case AgentStatus.active: return Colors.green;
      case AgentStatus.onBreak: return Colors.orange;
      case AgentStatus.offline: return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Models
class CounterInfo {
  final String name;
  final CounterStatus status;
  final String? agentName;
  final String? currentTicket;
  final String? serviceType;
  final DateTime? statusChangedAt;
  final int ticketsServed;
  final double avgServiceTime;
  final double satisfaction;

  CounterInfo(
    this.name,
    this.status,
    this.agentName,
    this.currentTicket,
    this.serviceType,
    this.statusChangedAt,
    this.ticketsServed,
    this.avgServiceTime,
    this.satisfaction,
  );
}

class AgentPerformance {
  final String name;
  final AgentStatus status;
  final String? counter;
  final int ticketsToday;
  final double avgServiceTime;
  final double avgServiceTimeOverall;
  final double satisfaction;
  final DateTime joinDate;

  AgentPerformance(
    this.name,
    this.status,
    this.counter,
    this.ticketsToday,
    this.avgServiceTime,
    this.avgServiceTimeOverall,
    this.satisfaction,
    this.joinDate,
  );
}

enum CounterStatus {
  serving('SERVING'),
  idle('IDLE'),
  onBreak('ON BREAK');

  final String displayName;
  const CounterStatus(this.displayName);
}

enum AgentStatus {
  active('ACTIVE'),
  onBreak('ON BREAK'),
  offline('OFFLINE');

  final String displayName;
  const AgentStatus(this.displayName);
}
