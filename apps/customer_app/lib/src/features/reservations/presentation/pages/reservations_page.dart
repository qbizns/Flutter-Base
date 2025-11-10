import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Table Reservation Page
///
/// Features:
/// - Date and time selection
/// - Party size selector
/// - Table preference
/// - Special requests
/// - Reservation confirmation
class ReservationsPage extends ConsumerStatefulWidget {
  const ReservationsPage({super.key});

  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _partySize = 2;
  String _tablePreference = 'No Preference';
  final _specialRequestsController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Reservation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Text(
                  'Reserve Your Table',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Book a table at your favorite restaurant',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 32),

                // Date selection
                _buildSection(
                  context,
                  title: 'Date',
                  child: _buildDateSelector(theme),
                ),

                const SizedBox(height: 24),

                // Time selection
                _buildSection(
                  context,
                  title: 'Time',
                  child: _buildTimeSelector(theme),
                ),

                const SizedBox(height: 24),

                // Party size
                _buildSection(
                  context,
                  title: 'Party Size',
                  child: _buildPartySizeSelector(theme),
                ),

                const SizedBox(height: 24),

                // Table preference
                _buildSection(
                  context,
                  title: 'Table Preference',
                  child: _buildTablePreferenceSelector(theme),
                ),

                const SizedBox(height: 24),

                // Special requests
                _buildSection(
                  context,
                  title: 'Special Requests (Optional)',
                  child: TextField(
                    controller: _specialRequestsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Any special requests or dietary requirements...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Info card
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Reservations are held for 15 minutes. Please arrive on time.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reserve button
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _isProcessing ? null : _makeReservation,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Confirm Reservation',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? now,
          firstDate: now,
          lastDate: now.add(const Duration(days: 90)),
        );

        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? dateFormat.format(_selectedDate!)
                    : 'Select a date',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _selectedDate != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(ThemeData theme) {
    // Available time slots
    final timeSlots = [
      '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
      '1:00 PM', '1:30 PM', '2:00 PM', '2:30 PM',
      '5:00 PM', '5:30 PM', '6:00 PM', '6:30 PM',
      '7:00 PM', '7:30 PM', '8:00 PM', '8:30 PM',
      '9:00 PM', '9:30 PM',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: timeSlots.map((time) {
        final isSelected = _selectedTime != null &&
            _formatTimeOfDay(_selectedTime!) == time;

        return FilterChip(
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedTime = _parseTime(time);
              });
            }
          },
          label: Text(time),
        );
      }).toList(),
    );
  }

  Widget _buildPartySizeSelector(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _partySize > 1
                      ? () {
                          setState(() {
                            _partySize--;
                          });
                        }
                      : null,
                ),
                Column(
                  children: [
                    Text(
                      '$_partySize',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      _partySize == 1 ? 'Guest' : 'Guests',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _partySize < 20
                      ? () {
                          setState(() {
                            _partySize++;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTablePreferenceSelector(ThemeData theme) {
    final preferences = [
      'No Preference',
      'Window Seat',
      'Outdoor Patio',
      'Quiet Area',
      'Near Bar',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: preferences.map((preference) {
        final isSelected = _tablePreference == preference;

        return FilterChip(
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _tablePreference = preference;
              });
            }
          },
          label: Text(preference),
        );
      }).toList(),
    );
  }

  Future<void> _makeReservation() async {
    // Validate
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate reservation processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Show confirmation
    final dateFormat = DateFormat('EEEE, MMMM d');
    final confirmationNumber = DateTime.now().millisecondsSinceEpoch % 100000;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
          size: 64,
        ),
        title: const Text('Reservation Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your table has been reserved.'),
            const SizedBox(height: 16),
            _buildConfirmationRow(
              Icons.confirmation_number,
              'Confirmation #',
              '$confirmationNumber',
            ),
            _buildConfirmationRow(
              Icons.calendar_today,
              'Date',
              dateFormat.format(_selectedDate!),
            ),
            _buildConfirmationRow(
              Icons.access_time,
              'Time',
              _formatTimeOfDay(_selectedTime!),
            ),
            _buildConfirmationRow(
              Icons.people,
              'Party Size',
              '$_partySize ${_partySize == 1 ? 'guest' : 'guests'}',
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );

    setState(() {
      _isProcessing = false;
    });
  }

  Widget _buildConfirmationRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final period = parts[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }
}
