import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Tickets - Ticket lifecycle management and tracking
class TicketsPage extends ConsumerStatefulWidget {
  const TicketsPage({super.key});

  @override
  ConsumerState<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends ConsumerState<TicketsPage> {
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock ticket data
    final tickets = [
      Ticket('Q01-045', 'General Inquiry', TicketStatus.serving, TicketPriority.normal, 'Sarah Johnson', 'Counter 1', 'Jane Doe', '+1 555-0101', DateTime.now().subtract(const Duration(minutes: 8)), DateTime.now().subtract(const Duration(minutes: 3)), null, 3),
      Ticket('Q02-112', 'Order Pickup', TicketStatus.serving, TicketPriority.normal, 'Mike Davis', 'Counter 2', 'John Smith', '+1 555-0102', DateTime.now().subtract(const Duration(minutes: 12)), DateTime.now().subtract(const Duration(minutes: 8)), null, 8),
      Ticket('Q03-078', 'Returns', TicketStatus.serving, TicketPriority.priority, 'Emily Brown', 'Counter 4', 'Alice Johnson', '+1 555-0103', DateTime.now().subtract(const Duration(minutes: 18)), DateTime.now().subtract(const Duration(minutes: 12)), null, 12),
      Ticket('Q01-046', 'General Inquiry', TicketStatus.waiting, TicketPriority.normal, null, null, 'Bob Wilson', '+1 555-0104', DateTime.now().subtract(const Duration(minutes: 5)), null, null, 0),
      Ticket('Q04-015', 'Technical Support', TicketStatus.waiting, TicketPriority.vip, null, null, 'Carol White', '+1 555-0105', DateTime.now().subtract(const Duration(minutes: 2)), null, null, 0),
      Ticket('Q02-113', 'Order Pickup', TicketStatus.waiting, TicketPriority.normal, null, null, 'David Lee', '+1 555-0106', DateTime.now().subtract(const Duration(minutes: 8)), null, null, 0),
      Ticket('Q01-044', 'General Inquiry', TicketStatus.completed, TicketPriority.normal, 'Sarah Johnson', 'Counter 1', 'Eve Martinez', '+1 555-0107', DateTime.now().subtract(const Duration(minutes: 28)), DateTime.now().subtract(const Duration(minutes: 23)), DateTime.now().subtract(const Duration(minutes: 18)), 5),
      Ticket('Q05-032', 'Catering Services', TicketStatus.completed, TicketPriority.priority, 'David Wilson', 'Express Counter', 'Frank Garcia', '+1 555-0108', DateTime.now().subtract(const Duration(hours: 1)), DateTime.now().subtract(const Duration(minutes: 52)), DateTime.now().subtract(const Duration(minutes: 45)), 7),
      Ticket('Q03-077', 'Returns', TicketStatus.cancelled, TicketPriority.normal, null, null, 'Grace Taylor', '+1 555-0109', DateTime.now().subtract(const Duration(hours: 2)), null, DateTime.now().subtract(const Duration(hours: 1, minutes: 45)), 0),
    ];

    // Apply filters
    final filteredTickets = tickets.where((ticket) {
      if (_selectedStatus != 'All' && ticket.status.name != _selectedStatus.toLowerCase()) return false;
      if (_selectedPriority != 'All' && ticket.priority.name != _selectedPriority.toLowerCase()) return false;
      return true;
    }).toList();

    final waitingCount = tickets.where((t) => t.status == TicketStatus.waiting).length;
    final servingCount = tickets.where((t) => t.status == TicketStatus.serving).length;
    final completedToday = tickets.where((t) => t.status == TicketStatus.completed).length;
    final cancelledCount = tickets.where((t) => t.status == TicketStatus.cancelled).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Tickets')),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.hourglass_empty, color: Colors.orange.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$waitingCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                          Text('Waiting', style: theme.textTheme.bodySmall),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.support_agent, color: Colors.blue.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$servingCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                          Text('Serving', style: theme.textTheme.bodySmall),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$completedToday', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          Text('Completed', style: theme.textTheme.bodySmall),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.cancel, color: Colors.grey.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text('$cancelledCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          Text('Cancelled', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Waiting', 'Serving', 'Completed', 'Cancelled']
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedStatus = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Normal', 'Priority', 'VIP']
                        .map((priority) => DropdownMenuItem(value: priority, child: Text(priority)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedPriority = value!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tickets list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTickets.length,
              itemBuilder: (context, index) {
                final ticket = filteredTickets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(ticket.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.confirmation_number, color: _getStatusColor(ticket.status), size: 24),
                    ),
                    title: Row(
                      children: [
                        Text(ticket.number, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(ticket.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ticket.status.displayName,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(ticket.status)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(ticket.priority).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ticket.priority.displayName,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getPriorityColor(ticket.priority)),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${ticket.serviceType} • ${ticket.customerName}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        if (ticket.status == TicketStatus.serving)
                          Text('${ticket.counterName} • ${ticket.agentName} • ${ticket.serveTime} min', style: const TextStyle(fontSize: 11, color: Colors.grey))
                        else if (ticket.status == TicketStatus.waiting)
                          Text('Issued ${DateFormat('h:mm a').format(ticket.issuedAt)}', style: const TextStyle(fontSize: 11, color: Colors.grey))
                        else
                          Text('Completed ${DateFormat('h:mm a').format(ticket.completedAt!)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    trailing: ticket.status == TicketStatus.waiting
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${DateTime.now().difference(ticket.issuedAt).inMinutes} min',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Text('wait time', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          )
                        : null,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Ticket Number', ticket.number),
                            _buildInfoRow('Service Type', ticket.serviceType),
                            _buildInfoRow('Status', ticket.status.displayName),
                            _buildInfoRow('Priority', ticket.priority.displayName),
                            _buildInfoRow('Customer', ticket.customerName),
                            _buildInfoRow('Phone', ticket.customerPhone),
                            _buildInfoRow('Issued', DateFormat('MMM dd, yyyy h:mm a').format(ticket.issuedAt)),
                            if (ticket.calledAt != null)
                              _buildInfoRow('Called', DateFormat('MMM dd, yyyy h:mm a').format(ticket.calledAt!)),
                            if (ticket.completedAt != null)
                              _buildInfoRow('Completed', DateFormat('MMM dd, yyyy h:mm a').format(ticket.completedAt!)),
                            if (ticket.agentName != null)
                              _buildInfoRow('Agent', ticket.agentName!),
                            if (ticket.counterName != null)
                              _buildInfoRow('Counter', ticket.counterName!),
                            if (ticket.status == TicketStatus.serving || ticket.status == TicketStatus.completed)
                              _buildInfoRow('Service Time', '${ticket.serveTime} minutes'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (ticket.status == TicketStatus.waiting) ...([
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.call, size: 18),
                                      label: const Text('Call Ticket'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.sms, size: 18),
                                      label: const Text('Send SMS'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.cancel, size: 18),
                                      label: const Text('Cancel'),
                                    ),
                                  ),
                                ]),
                                if (ticket.status == TicketStatus.serving) ...([
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
                                      icon: const Icon(Icons.transfer_within_a_station, size: 18),
                                      label: const Text('Transfer'),
                                    ),
                                  ),
                                ]),
                                if (ticket.status == TicketStatus.completed) ...([
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.print, size: 18),
                                      label: const Text('Print Receipt'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.star, size: 18),
                                      label: const Text('Feedback'),
                                    ),
                                  ),
                                ]),
                                if (ticket.status == TicketStatus.cancelled) ...([
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Delete'),
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
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

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.waiting: return Colors.orange;
      case TicketStatus.serving: return Colors.blue;
      case TicketStatus.completed: return Colors.green;
      case TicketStatus.cancelled: return Colors.grey;
    }
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.normal: return Colors.blue;
      case TicketPriority.priority: return Colors.orange;
      case TicketPriority.vip: return Colors.red;
    }
  }
}

// Models
class Ticket {
  final String number;
  final String serviceType;
  final TicketStatus status;
  final TicketPriority priority;
  final String? agentName;
  final String? counterName;
  final String customerName;
  final String customerPhone;
  final DateTime issuedAt;
  final DateTime? calledAt;
  final DateTime? completedAt;
  final int serveTime;

  Ticket(
    this.number,
    this.serviceType,
    this.status,
    this.priority,
    this.agentName,
    this.counterName,
    this.customerName,
    this.customerPhone,
    this.issuedAt,
    this.calledAt,
    this.completedAt,
    this.serveTime,
  );
}

enum TicketStatus {
  waiting('WAITING'),
  serving('SERVING'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  final String displayName;
  const TicketStatus(this.displayName);
}

enum TicketPriority {
  normal('NORMAL'),
  priority('PRIORITY'),
  vip('VIP');

  final String displayName;
  const TicketPriority(this.displayName);
}
