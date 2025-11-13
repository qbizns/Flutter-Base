import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../providers/settings_providers.dart';

/// General Settings View
///
/// Contains:
/// - Restaurant name, location, contact information
/// - Timezone selection
/// - Currency selection
/// - Language selection
class GeneralSettingsView extends ConsumerStatefulWidget {
  const GeneralSettingsView({super.key});

  @override
  ConsumerState<GeneralSettingsView> createState() =>
      _GeneralSettingsViewState();
}

class _GeneralSettingsViewState extends ConsumerState<GeneralSettingsView> {
  late TextEditingController _restaurantNameController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final _formKey = GlobalKey<FormState>();

  // Common timezones
  static const List<String> _timezones = [
    'UTC',
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Paris',
    'Asia/Tokyo',
    'Asia/Shanghai',
    'Australia/Sydney',
  ];

  // Common currencies
  static const List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CNY',
    'AUD',
    'CAD',
    'CHF',
    'INR',
  ];

  // Languages
  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'zh', 'name': 'Chinese'},
    {'code': 'ja', 'name': 'Japanese'},
  ];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _restaurantNameController = TextEditingController(text: settings.restaurantName);
    _locationController = TextEditingController(text: settings.location);
    _emailController = TextEditingController(text: settings.contactEmail);
    _phoneController = TextEditingController(text: settings.contactPhone);
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Information Card
            _buildCard(
              title: 'Restaurant Information',
              icon: Icons.store_outlined,
              children: [
                TextFormField(
                  controller: _restaurantNameController,
                  decoration: const InputDecoration(
                    labelText: 'Restaurant Name',
                    hintText: 'Enter your restaurant name',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Restaurant name is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateGeneralSettings(
                          restaurantName: value,
                        );
                  },
                ),
                const SizedBox(height: OdooSpacing.lg),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter restaurant address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  maxLines: 2,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateGeneralSettings(
                          location: value,
                        );
                  },
                ),
              ],
            ),

            const SizedBox(height: OdooSpacing.lg),

            // Contact Information Card
            _buildCard(
              title: 'Contact Information',
              icon: Icons.contact_mail_outlined,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'contact@restaurant.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateGeneralSettings(
                          contactEmail: value,
                        );
                  },
                ),
                const SizedBox(height: OdooSpacing.lg),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: '+1 (555) 123-4567',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateGeneralSettings(
                          contactPhone: value,
                        );
                  },
                ),
              ],
            ),

            const SizedBox(height: OdooSpacing.lg),

            // Regional Settings Card
            _buildCard(
              title: 'Regional Settings',
              icon: Icons.language_outlined,
              children: [
                DropdownButtonFormField<String>(
                  value: settings.timezone,
                  decoration: const InputDecoration(
                    labelText: 'Timezone',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  items: _timezones.map((timezone) {
                    return DropdownMenuItem(
                      value: timezone,
                      child: Text(timezone),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).updateGeneralSettings(
                            timezone: value,
                          );
                    }
                  },
                ),
                const SizedBox(height: OdooSpacing.lg),
                DropdownButtonFormField<String>(
                  value: settings.currency,
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  items: _currencies.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).updateGeneralSettings(
                            currency: value,
                          );
                    }
                  },
                ),
                const SizedBox(height: OdooSpacing.lg),
                DropdownButtonFormField<String>(
                  value: settings.language,
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    prefixIcon: Icon(Icons.translate),
                  ),
                  items: _languages.map((language) {
                    return DropdownMenuItem(
                      value: language['code'],
                      child: Text(language['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).updateGeneralSettings(
                            language: value,
                          );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
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
}
