import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/settings_models.dart';
import '../../providers/settings_providers.dart';

/// Business Settings View
///
/// Contains:
/// - Operating days checkboxes
/// - Business hours for each day
/// - Holiday management
class BusinessSettingsView extends ConsumerWidget {
  const BusinessSettingsView({super.key});

  static const List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operating Hours Card
          _buildCard(
            title: 'Operating Hours',
            icon: Icons.schedule_outlined,
            children: [
              Text(
                'Set your restaurant operating hours for each day of the week',
                style: OdooTypography.bodyMedium.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
              const SizedBox(height: OdooSpacing.lg),
              ..._dayNames.asMap().entries.map((entry) {
                final dayIndex = entry.key + 1; // Monday = 1
                final dayName = entry.value;
                final hours = settings.businessHours[dayIndex] ?? BusinessHours.closed();

                return _buildDayRow(
                  context,
                  ref,
                  dayIndex,
                  dayName,
                  hours,
                );
              }),
            ],
          ),

          const SizedBox(height: OdooSpacing.lg),

          // Holidays Card
          _buildCard(
            title: 'Holidays',
            icon: Icons.event_outlined,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Manage dates when your restaurant will be closed',
                      style: OdooTypography.bodyMedium.copyWith(
                        color: OdooColors.textSecondary,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _addHoliday(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Holiday'),
                    style: FilledButton.styleFrom(
                      backgroundColor: OdooColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OdooSpacing.lg),
              if (settings.holidays.isEmpty)
                Container(
                  padding: const EdgeInsets.all(OdooSpacing.xl),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: OdooIconSizes.xxl,
                        color: OdooColors.gray400,
                      ),
                      const SizedBox(height: OdooSpacing.md),
                      Text(
                        'No holidays scheduled',
                        style: OdooTypography.bodyMedium.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...settings.holidays.map((holiday) {
                  return ListTile(
                    leading: Icon(
                      Icons.event,
                      color: OdooColors.primary,
                    ),
                    title: Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(holiday),
                      style: OdooTypography.bodyMedium,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: OdooColors.danger,
                      onPressed: () {
                        ref.read(settingsProvider.notifier).removeHoliday(holiday);
                      },
                    ),
                  );
                }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        side: BorderSide(
          color: OdooColors.border,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: OdooIconSizes.lg,
                  color: OdooColors.primary,
                ),
                const SizedBox(width: OdooSpacing.md),
                Text(
                  title,
                  style: OdooTypography.cardTitle.copyWith(
                    color: OdooColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: OdooSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: OdooSpacing.lg),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(
    BuildContext context,
    WidgetRef ref,
    int dayIndex,
    String dayName,
    BusinessHours hours,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: OdooSpacing.md),
      padding: const EdgeInsets.all(OdooSpacing.md),
      decoration: BoxDecoration(
        color: hours.isOpen ? OdooColors.gray50 : Colors.transparent,
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        border: Border.all(
          color: hours.isOpen ? OdooColors.primary.withOpacity(0.2) : OdooColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  dayName,
                  style: OdooTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: hours.isOpen,
                onChanged: (value) {
                  if (value) {
                    ref.read(settingsProvider.notifier).updateBusinessHours(
                          dayIndex,
                          BusinessHours.defaultHours(),
                        );
                  } else {
                    ref.read(settingsProvider.notifier).updateBusinessHours(
                          dayIndex,
                          BusinessHours.closed(),
                        );
                  }
                },
                activeColor: OdooColors.primary,
              ),
              const SizedBox(width: OdooSpacing.md),
              if (!hours.isOpen)
                Text(
                  'Closed',
                  style: OdooTypography.bodyMedium.copyWith(
                    color: OdooColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          if (hours.isOpen && hours.openTime != null && hours.closeTime != null)
            Padding(
              padding: const EdgeInsets.only(top: OdooSpacing.md),
              child: Row(
                children: [
                  const SizedBox(width: 120),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectTime(
                              context,
                              ref,
                              dayIndex,
                              hours,
                              true,
                            ),
                            icon: const Icon(Icons.access_time, size: OdooIconSizes.sm),
                            label: Text(
                              hours.openTime!.format(context),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: OdooSpacing.md),
                          child: Text(
                            'to',
                            style: OdooTypography.bodyMedium.copyWith(
                              color: OdooColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectTime(
                              context,
                              ref,
                              dayIndex,
                              hours,
                              false,
                            ),
                            icon: const Icon(Icons.access_time, size: OdooIconSizes.sm),
                            label: Text(
                              hours.closeTime!.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    WidgetRef ref,
    int dayIndex,
    BusinessHours hours,
    bool isOpenTime,
  ) async {
    final initialTime = isOpenTime ? hours.openTime : hours.closeTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      final updatedHours = hours.copyWith(
        openTime: isOpenTime ? picked : hours.openTime,
        closeTime: isOpenTime ? hours.closeTime : picked,
      );

      ref.read(settingsProvider.notifier).updateBusinessHours(
            dayIndex,
            updatedHours,
          );
    }
  }

  Future<void> _addHoliday(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      ref.read(settingsProvider.notifier).addHoliday(picked);
    }
  }
}
