import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/staff_models.dart';
import '../../providers/staff_providers.dart';

/// Shift Schedule View - Calendar view of staff shifts
class ShiftScheduleView extends ConsumerStatefulWidget {
  const ShiftScheduleView({super.key});

  @override
  ConsumerState<ShiftScheduleView> createState() => _ShiftScheduleViewState();
}

class _ShiftScheduleViewState extends ConsumerState<ShiftScheduleView> {
  DateTime _selectedWeekStart = _getWeekStart(DateTime.now());

  static DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final shifts = ref.watch(shiftsProvider);
    final staff = ref.watch(staffMembersProvider);
    final weekDays = List.generate(7, (i) => _selectedWeekStart.add(Duration(days: i)));

    return Column(
      children: [
        // Week Navigation
        _buildWeekNavigation(),

        // Schedule Grid
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(OdooSpacing.lg),
            child: Column(
              children: weekDays.map((day) {
                final dayShifts = _getShiftsForDay(shifts, day);
                return _buildDayCard(context, day, dayShifts, staff);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekNavigation() {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: OdooColors.border),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedWeekStart =
                    _selectedWeekStart.subtract(const Duration(days: 7));
              });
            },
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Week',
          ),
          Expanded(
            child: Center(
              child: Text(
                '${DateFormat('MMM d').format(_selectedWeekStart)} - ${DateFormat('MMM d, yyyy').format(_selectedWeekStart.add(const Duration(days: 6)))}',
                style: OdooTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedWeekStart =
                    _selectedWeekStart.add(const Duration(days: 7));
              });
            },
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Week',
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    DateTime day,
    List<Shift> shifts,
    List<StaffMember> staff,
  ) {
    final isToday = _isToday(day);

    return Card(
      margin: const EdgeInsets.only(bottom: OdooSpacing.lg),
      color: isToday ? OdooColors.primary.withOpacity(0.05) : null,
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(day),
                      style: OdooTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isToday ? OdooColors.primary : null,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(day),
                      style: OdooTypography.bodySmall.copyWith(
                        color: OdooColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (isToday) ...[
                  const SizedBox(width: OdooSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OdooSpacing.sm,
                      vertical: OdooSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: OdooColors.primary,
                      borderRadius:
                          BorderRadius.circular(OdooSpacing.radiusStandard),
                    ),
                    child: Text(
                      'Today',
                      style: OdooTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '${shifts.length} shifts',
                  style: OdooTypography.bodyMedium.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (shifts.isNotEmpty) ...[
              const SizedBox(height: OdooSpacing.lg),
              ...shifts.map((shift) {
                final member = staff.firstWhere(
                  (s) => s.id == shift.staffId,
                  orElse: () => staff.first,
                );
                return _buildShiftRow(context, shift, member);
              }),
            ] else ...[
              const SizedBox(height: OdooSpacing.lg),
              Center(
                child: Text(
                  'No shifts scheduled',
                  style: OdooTypography.bodyMedium.copyWith(
                    color: OdooColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShiftRow(
    BuildContext context,
    Shift shift,
    StaffMember member,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: OdooSpacing.sm),
      padding: const EdgeInsets.all(OdooSpacing.md),
      decoration: BoxDecoration(
        color: _getShiftTypeColor(shift.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        border: Border.all(
          color: _getShiftTypeColor(shift.type).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _getShiftTypeColor(shift.type),
            child: Text(
              member.initials,
              style: OdooTypography.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: OdooSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: OdooTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_formatTime(shift.startTime)} - ${_formatTime(shift.endTime)}',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: OdooSpacing.sm,
              vertical: OdooSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: shift.isConfirmed
                  ? OdooColors.success.withOpacity(0.1)
                  : OdooColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
            child: Text(
              shift.isConfirmed ? 'Confirmed' : 'Pending',
              style: OdooTypography.labelSmall.copyWith(
                color: shift.isConfirmed ? OdooColors.success : OdooColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Shift> _getShiftsForDay(List<Shift> shifts, DateTime day) {
    return shifts
        .where((shift) =>
            shift.date.year == day.year &&
            shift.date.month == day.month &&
            shift.date.day == day.day)
        .toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getShiftTypeColor(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return OdooColors.warning;
      case ShiftType.afternoon:
        return OdooColors.info;
      case ShiftType.evening:
        return OdooColors.secondary;
      case ShiftType.night:
        return OdooColors.primary;
      case ShiftType.fullDay:
        return OdooColors.success;
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
