import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Time Tracking Page
///
/// Features:
/// - Clock in/out functionality
/// - Break tracking
/// - Daily attendance summary
/// - Weekly timesheet
/// - Overtime tracking
class TimeTrackingPage extends ConsumerStatefulWidget {
  const TimeTrackingPage({super.key});

  @override
  ConsumerState<TimeTrackingPage> createState() => _TimeTrackingPageState();
}

class _TimeTrackingPageState extends ConsumerState<TimeTrackingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isClockedIn = false;
  bool _isOnBreak = false;
  DateTime? _clockInTime;
  DateTime? _breakStartTime;
  Duration _totalBreakTime = Duration.zero;

  // Mock timesheet data
  final List<TimeEntry> _timeEntries = [
    TimeEntry(
      date: DateTime.now(),
      clockIn: DateTime.now().copyWith(hour: 9, minute: 0),
      clockOut: DateTime.now().copyWith(hour: 17, minute: 30),
      breakDuration: const Duration(minutes: 45),
      totalHours: 7.75,
    ),
    TimeEntry(
      date: DateTime.now().subtract(const Duration(days: 1)),
      clockIn: DateTime.now().subtract(const Duration(days: 1)).copyWith(hour: 8, minute: 30),
      clockOut: DateTime.now().subtract(const Duration(days: 1)).copyWith(hour: 16, minute: 45),
      breakDuration: const Duration(minutes: 30),
      totalHours: 7.75,
    ),
    TimeEntry(
      date: DateTime.now().subtract(const Duration(days: 2)),
      clockIn: DateTime.now().subtract(const Duration(days: 2)).copyWith(hour: 14, minute: 0),
      clockOut: DateTime.now().subtract(const Duration(days: 2)).copyWith(hour: 22, minute: 15),
      breakDuration: const Duration(minutes: 60),
      totalHours: 7.25,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Time Clock'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Clock'),
            Tab(text: 'Timesheet'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClockTab(theme),
          _buildTimesheetTab(theme),
        ],
      ),
    );
  }

  Widget _buildClockTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current time
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE, MMMM dd').format(DateTime.now()),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Text(
                      DateFormat('HH:mm:ss').format(DateTime.now()),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Clock in/out button
        SizedBox(
          height: 200,
          child: Card(
            color: _isClockedIn
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.primaryContainer,
            child: InkWell(
              onTap: _toggleClock,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isClockedIn ? Icons.logout : Icons.login,
                      size: 64,
                      color: _isClockedIn
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isClockedIn ? 'CLOCK OUT' : 'CLOCK IN',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isClockedIn
                            ? theme.colorScheme.onErrorContainer
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (_isClockedIn && _clockInTime != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Clocked in at ${DateFormat('HH:mm').format(_clockInTime!)}',
                        style: TextStyle(
                          color: _isClockedIn
                              ? theme.colorScheme.onErrorContainer.withOpacity(0.8)
                              : theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Break button
        if (_isClockedIn)
          SizedBox(
            height: 120,
            child: Card(
              color: _isOnBreak
                  ? theme.colorScheme.tertiaryContainer
                  : theme.colorScheme.secondaryContainer,
              child: InkWell(
                onTap: _toggleBreak,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isOnBreak ? Icons.play_arrow : Icons.pause,
                        size: 48,
                        color: _isOnBreak
                            ? theme.colorScheme.onTertiaryContainer
                            : theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isOnBreak ? 'END BREAK' : 'START BREAK',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isOnBreak
                              ? theme.colorScheme.onTertiaryContainer
                              : theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      if (_isOnBreak && _breakStartTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Started at ${DateFormat('HH:mm').format(_breakStartTime!)}',
                          style: TextStyle(
                            color: theme.colorScheme.onTertiaryContainer.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),

        // Today's summary
        if (_isClockedIn) ...[
          Text(
            'Today\'s Summary',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  theme,
                  'Hours Worked',
                  _calculateWorkedHours(),
                  Icons.access_time,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  theme,
                  'Break Time',
                  _formatDuration(_totalBreakTime),
                  Icons.coffee,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTimesheetTab(ThemeData theme) {
    final weekTotal = _timeEntries.fold<double>(
      0,
      (sum, entry) => sum + entry.totalHours,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Week summary
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${weekTotal.toStringAsFixed(2)} hours',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: theme.colorScheme.onPrimary,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Time entries
        Text(
          'Recent Time Entries',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._timeEntries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTimeEntryCard(theme, entry),
            )),
        const SizedBox(height: 16),

        // Overtime alert
        if (weekTotal > 40)
          Card(
            color: Colors.amber.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overtime Alert',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'You have ${(weekTotal - 40).toStringAsFixed(2)} hours of overtime this week',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(
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
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildTimeEntryCard(ThemeData theme, TimeEntry entry) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMM dd').format(entry.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entry.totalHours.toStringAsFixed(2)}h',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimeDetail(
                    theme,
                    'Clock In',
                    DateFormat('HH:mm').format(entry.clockIn),
                    Icons.login,
                  ),
                ),
                Expanded(
                  child: _buildTimeDetail(
                    theme,
                    'Clock Out',
                    DateFormat('HH:mm').format(entry.clockOut),
                    Icons.logout,
                  ),
                ),
                Expanded(
                  child: _buildTimeDetail(
                    theme,
                    'Break',
                    _formatDuration(entry.breakDuration),
                    Icons.coffee,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDetail(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  void _toggleClock() {
    setState(() {
      _isClockedIn = !_isClockedIn;
      if (_isClockedIn) {
        _clockInTime = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clocked in at ${DateFormat('HH:mm').format(_clockInTime!)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final clockOutTime = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clocked out at ${DateFormat('HH:mm').format(clockOutTime)}'),
            backgroundColor: Colors.red,
          ),
        );
        _clockInTime = null;
        _isOnBreak = false;
        _breakStartTime = null;
        _totalBreakTime = Duration.zero;
      }
    });
  }

  void _toggleBreak() {
    setState(() {
      _isOnBreak = !_isOnBreak;
      if (_isOnBreak) {
        _breakStartTime = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Break started'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        if (_breakStartTime != null) {
          _totalBreakTime += DateTime.now().difference(_breakStartTime!);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Break ended'),
            backgroundColor: Colors.blue,
          ),
        );
        _breakStartTime = null;
      }
    });
  }

  String _calculateWorkedHours() {
    if (_clockInTime == null) return '0.00h';

    var worked = DateTime.now().difference(_clockInTime!);
    worked = worked - _totalBreakTime;

    if (_isOnBreak && _breakStartTime != null) {
      worked = worked - DateTime.now().difference(_breakStartTime!);
    }

    return '${(worked.inMinutes / 60).toStringAsFixed(2)}h';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

// Models
class TimeEntry {
  final DateTime date;
  final DateTime clockIn;
  final DateTime clockOut;
  final Duration breakDuration;
  final double totalHours;

  TimeEntry({
    required this.date,
    required this.clockIn,
    required this.clockOut,
    required this.breakDuration,
    required this.totalHours,
  });
}
