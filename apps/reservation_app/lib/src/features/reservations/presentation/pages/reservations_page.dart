import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

/// Reservations Page
///
/// Table reservation management with calendar view.
/// Features:
/// - Calendar view for reservations
/// - Time slot selection
/// - Party size and guest info
/// - Table preferences
/// - Confirmation and notifications
class ReservationsPage extends ConsumerStatefulWidget {
  const ReservationsPage({super.key});

  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  // Mock reservation data
  final Map<DateTime, List<Reservation>> _reservations = {
    DateTime.now(): [
      Reservation(
        id: '1',
        guestName: 'John Smith',
        guestPhone: '+1 (555) 123-4567',
        partySize: 4,
        time: DateTime.now().copyWith(hour: 18, minute: 30),
        status: ReservationStatus.confirmed,
        tableNumber: 5,
        specialRequests: 'Window seat if possible',
      ),
      Reservation(
        id: '2',
        guestName: 'Sarah Johnson',
        guestPhone: '+1 (555) 234-5678',
        partySize: 2,
        time: DateTime.now().copyWith(hour: 19, minute: 0),
        status: ReservationStatus.confirmed,
        tableNumber: 12,
        specialRequests: '',
      ),
    ],
    DateTime.now().add(const Duration(days: 1)): [
      Reservation(
        id: '3',
        guestName: 'Michael Chen',
        guestPhone: '+1 (555) 345-6789',
        partySize: 6,
        time: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 19, minute: 30),
        status: ReservationStatus.pending,
        tableNumber: null,
        specialRequests: 'Birthday celebration',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Calendar'),
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarTab(theme),
          _buildTodayTab(theme),
          _buildUpcomingTab(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewReservationDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Reservation'),
      ),
    );
  }

  Widget _buildCalendarTab(ThemeData theme) {
    return Column(
      children: [
        // Calendar
        Card(
          margin: const EdgeInsets.all(16),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return _reservations[key] ?? [];
            },
            calendarStyle: CalendarStyle(
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

        // Selected day reservations
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM dd').format(_selectedDay),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_getReservationsForDay(_selectedDay).length} reservations',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _getReservationsForDay(_selectedDay).isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reservations',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _getReservationsForDay(_selectedDay).length,
                        itemBuilder: (context, index) {
                          final reservation = _getReservationsForDay(_selectedDay)[index];
                          return _buildReservationCard(theme, reservation);
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTab(ThemeData theme) {
    final todayReservations = _getReservationsForDay(DateTime.now())
      ..sort((a, b) => a.time.compareTo(b.time));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Total',
                todayReservations.length.toString(),
                Icons.event,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                'Confirmed',
                todayReservations
                    .where((r) => r.status == ReservationStatus.confirmed)
                    .length
                    .toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                'Guests',
                todayReservations
                    .fold<int>(0, (sum, r) => sum + r.partySize)
                    .toString(),
                Icons.people,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Reservations list
        Text(
          'Today\'s Reservations',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (todayReservations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reservations today',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...todayReservations.map((reservation) => _buildReservationCard(theme, reservation)),
      ],
    );
  }

  Widget _buildUpcomingTab(ThemeData theme) {
    final upcomingReservations = _reservations.entries
        .where((entry) => entry.key.isAfter(DateTime.now()))
        .expand((entry) => entry.value)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Upcoming Reservations',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (upcomingReservations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.event_note,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming reservations',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...upcomingReservations.map((reservation) => _buildReservationCard(theme, reservation)),
      ],
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
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
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

  Widget _buildReservationCard(ThemeData theme, Reservation reservation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showReservationDetails(context, reservation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getStatusColor(reservation.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(reservation.time),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(reservation.status),
                      ),
                    ),
                    Text(
                      '${reservation.partySize}p',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(reservation.status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.guestName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reservation.guestPhone,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (reservation.tableNumber != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.table_restaurant,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Table ${reservation.tableNumber}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(reservation.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reservation.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(reservation.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Reservation> _getReservationsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _reservations[key] ?? [];
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.seated:
        return Colors.blue;
      case ReservationStatus.completed:
        return Colors.grey;
      case ReservationStatus.noShow:
        return Colors.red;
      case ReservationStatus.cancelled:
        return Colors.red;
    }
  }

  void _showReservationDetails(BuildContext context, Reservation reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reservation Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Divider(height: 32),
              _buildDetailRow('Guest Name', reservation.guestName),
              _buildDetailRow('Phone', reservation.guestPhone),
              _buildDetailRow('Party Size', '${reservation.partySize} guests'),
              _buildDetailRow('Date', DateFormat('EEEE, MMMM dd, yyyy').format(reservation.time)),
              _buildDetailRow('Time', DateFormat('h:mm a').format(reservation.time)),
              if (reservation.tableNumber != null)
                _buildDetailRow('Table', reservation.tableNumber.toString()),
              _buildDetailRow('Status', reservation.status.name.toUpperCase()),
              if (reservation.specialRequests.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Special Requests',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(reservation.specialRequests),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Check In'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showNewReservationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Reservation'),
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
                  labelText: 'Date & Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
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
                const SnackBar(content: Text('Reservation created successfully')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

// Models
class Reservation {
  final String id;
  final String guestName;
  final String guestPhone;
  final int partySize;
  final DateTime time;
  final ReservationStatus status;
  final int? tableNumber;
  final String specialRequests;

  Reservation({
    required this.id,
    required this.guestName,
    required this.guestPhone,
    required this.partySize,
    required this.time,
    required this.status,
    this.tableNumber,
    required this.specialRequests,
  });
}

enum ReservationStatus {
  pending,
  confirmed,
  seated,
  completed,
  noShow,
  cancelled,
}
