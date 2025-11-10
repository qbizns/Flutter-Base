import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Waitlist Page
///
/// Manage walk-in waitlist and queue.
/// Features:
/// - Add walk-in guests to waitlist
/// - Estimated wait time
/// - SMS notifications when table ready
/// - Queue position tracking
/// - No-show management
class WaitlistPage extends ConsumerStatefulWidget {
  const WaitlistPage({super.key});

  @override
  ConsumerState<WaitlistPage> createState() => _WaitlistPageState();
}

class _WaitlistPageState extends ConsumerState<WaitlistPage> {
  // Mock waitlist data
  final List<WaitlistEntry> _waitlist = [
    WaitlistEntry(
      id: '1',
      guestName: 'Tom Wilson',
      guestPhone: '+1 (555) 111-2222',
      partySize: 4,
      addedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      estimatedWait: 20,
      status: WaitlistStatus.waiting,
    ),
    WaitlistEntry(
      id: '2',
      guestName: 'Lisa Anderson',
      guestPhone: '+1 (555) 222-3333',
      partySize: 2,
      addedAt: DateTime.now().subtract(const Duration(minutes: 8)),
      estimatedWait: 25,
      status: WaitlistStatus.waiting,
    ),
    WaitlistEntry(
      id: '3',
      guestName: 'Robert Garcia',
      guestPhone: '+1 (555) 333-4444',
      partySize: 6,
      addedAt: DateTime.now().subtract(const Duration(minutes: 3)),
      estimatedWait: 35,
      status: WaitlistStatus.notified,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waitlist'),
      ),
      body: Column(
        children: [
          // Stats cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'In Queue',
                    _waitlist.where((e) => e.status != WaitlistStatus.seated).length.toString(),
                    Icons.people_outline,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Avg. Wait',
                    '${(_waitlist.isEmpty ? 0 : _waitlist.map((e) => e.estimatedWait).reduce((a, b) => a + b) ~/ _waitlist.length)} min',
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Total Guests',
                    _waitlist.fold<int>(0, (sum, e) => sum + e.partySize).toString(),
                    Icons.people,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Waitlist
          Expanded(
            child: _waitlist.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 80,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No guests in waitlist',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _waitlist.length,
                    itemBuilder: (context, index) {
                      final entry = _waitlist[index];
                      final waitingTime = DateTime.now().difference(entry.addedAt).inMinutes;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Position indicator
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(entry.status).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '#${index + 1}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(entry.status),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Guest info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.guestName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.people,
                                              size: 14,
                                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                            const SizedBox(width: 4),
                                            Text('${entry.partySize} guests'),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.schedule,
                                              size: 14,
                                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                            const SizedBox(width: 4),
                                            Text('$waitingTime min ago'),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.guestPhone,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(entry.status).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          _getStatusIcon(entry.status),
                                          size: 20,
                                          color: _getStatusColor(entry.status),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${entry.estimatedWait} min',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: _getStatusColor(entry.status),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _notifyGuest(entry),
                                      icon: const Icon(Icons.notifications, size: 18),
                                      label: const Text('Notify'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => _seatGuest(entry),
                                      icon: const Icon(Icons.chair, size: 18),
                                      label: const Text('Seat'),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _removeFromWaitlist(entry),
                                    icon: const Icon(Icons.close),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddToWaitlistDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add to Waitlist'),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(WaitlistStatus status) {
    switch (status) {
      case WaitlistStatus.waiting:
        return Colors.orange;
      case WaitlistStatus.notified:
        return Colors.blue;
      case WaitlistStatus.seated:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(WaitlistStatus status) {
    switch (status) {
      case WaitlistStatus.waiting:
        return Icons.access_time;
      case WaitlistStatus.notified:
        return Icons.notifications_active;
      case WaitlistStatus.seated:
        return Icons.check_circle;
    }
  }

  void _notifyGuest(WaitlistEntry entry) {
    setState(() {
      entry.status = WaitlistStatus.notified;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('SMS sent to ${entry.guestName}')),
    );
  }

  void _seatGuest(WaitlistEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seat Guest'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seating ${entry.guestName} (${entry.partySize} guests)'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Table Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                entry.status = WaitlistStatus.seated;
                _waitlist.remove(entry);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Guest seated successfully')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _removeFromWaitlist(WaitlistEntry entry) {
    setState(() {
      _waitlist.remove(entry);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${entry.guestName} removed from waitlist'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _waitlist.add(entry);
            });
          },
        ),
      ),
    );
  }

  void _showAddToWaitlistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Waitlist'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Guest Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Party Size',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Estimated Wait (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to waitlist')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Models
class WaitlistEntry {
  final String id;
  final String guestName;
  final String guestPhone;
  final int partySize;
  final DateTime addedAt;
  final int estimatedWait;
  WaitlistStatus status;

  WaitlistEntry({
    required this.id,
    required this.guestName,
    required this.guestPhone,
    required this.partySize,
    required this.addedAt,
    required this.estimatedWait,
    required this.status,
  });
}

enum WaitlistStatus {
  waiting,
  notified,
  seated,
}
