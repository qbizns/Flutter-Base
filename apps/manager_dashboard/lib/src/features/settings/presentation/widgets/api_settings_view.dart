import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/settings_models.dart';
import '../../providers/settings_providers.dart';

/// API Settings View
///
/// Contains:
/// - API Base URL
/// - Organization ID
/// - API Key
/// - Timeout settings
/// - Test connection button
class ApiSettingsView extends ConsumerStatefulWidget {
  const ApiSettingsView({super.key});

  @override
  ConsumerState<ApiSettingsView> createState() => _ApiSettingsViewState();
}

class _ApiSettingsViewState extends ConsumerState<ApiSettingsView> {
  late TextEditingController _baseUrlController;
  late TextEditingController _organizationIdController;
  late TextEditingController _apiKeyController;

  final _formKey = GlobalKey<FormState>();
  bool _isTestingConnection = false;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final apiConfig = ref.read(settingsProvider).apiConfig;
    _baseUrlController = TextEditingController(text: apiConfig.baseUrl);
    _organizationIdController = TextEditingController(text: apiConfig.organizationId);
    _apiKeyController = TextEditingController(text: apiConfig.apiKey);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _organizationIdController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final apiConfig = settings.apiConfig;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Configuration Card
            _buildCard(
              title: 'API Configuration',
              icon: Icons.cloud_outlined,
              children: [
                TextFormField(
                  controller: _baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'API Base URL',
                    hintText: 'https://api.example.com',
                    prefixIcon: Icon(Icons.link),
                    helperText: 'The base URL for API requests',
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'API Base URL is required';
                    }
                    if (!value.startsWith('http://') &&
                        !value.startsWith('https://')) {
                      return 'URL must start with http:// or https://';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _updateApiConfig(baseUrl: value);
                  },
                ),
                const SizedBox(height: OdooSpacing.lg),
                TextFormField(
                  controller: _organizationIdController,
                  decoration: const InputDecoration(
                    labelText: 'Organization ID',
                    hintText: 'Enter your organization ID',
                    prefixIcon: Icon(Icons.business),
                    helperText: 'Your unique organization identifier',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Organization ID is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _updateApiConfig(organizationId: value);
                  },
                ),
                const SizedBox(height: OdooSpacing.lg),
                TextFormField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    hintText: 'Enter your API key (optional)',
                    prefixIcon: const Icon(Icons.vpn_key),
                    helperText: 'Optional authentication key',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureApiKey = !_obscureApiKey;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureApiKey,
                  onChanged: (value) {
                    _updateApiConfig(apiKey: value);
                  },
                ),
                const SizedBox(height: OdooSpacing.lg),
                DropdownButtonFormField<int>(
                  value: apiConfig.timeoutSeconds,
                  decoration: const InputDecoration(
                    labelText: 'Request Timeout',
                    prefixIcon: Icon(Icons.timer_outlined),
                    helperText: 'Timeout for API requests',
                  ),
                  items: [10, 20, 30, 60, 120].map((seconds) {
                    return DropdownMenuItem(
                      value: seconds,
                      child: Text('$seconds seconds'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _updateApiConfig(timeoutSeconds: value);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: OdooSpacing.lg),

            // Connection Test Card
            _buildCard(
              title: 'Connection Test',
              icon: Icons.speed_outlined,
              children: [
                Text(
                  'Test your API connection to verify that the settings are correct.',
                  style: OdooTypography.bodyMedium.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
                const SizedBox(height: OdooSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isTestingConnection ? null : _testConnection,
                    icon: _isTestingConnection
                        ? const SizedBox(
                            width: OdooIconSizes.md,
                            height: OdooIconSizes.md,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cable),
                    label: Text(
                      _isTestingConnection
                          ? 'Testing Connection...'
                          : 'Test Connection',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: OdooColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: OdooSpacing.md,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: OdooSpacing.lg),

            // Information Card
            _buildInfoBox(
              'Note: Changes to API settings will affect how the application communicates with your backend services. Make sure to test the connection after making changes.',
              Icons.info_outline,
              OdooColors.info,
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

  Widget _buildInfoBox(String message, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: OdooIconSizes.lg,
          ),
          const SizedBox(width: OdooSpacing.md),
          Expanded(
            child: Text(
              message,
              style: OdooTypography.bodySmall.copyWith(
                color: OdooColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateApiConfig({
    String? baseUrl,
    String? organizationId,
    String? apiKey,
    int? timeoutSeconds,
  }) {
    final currentConfig = ref.read(settingsProvider).apiConfig;
    final updatedConfig = currentConfig.copyWith(
      baseUrl: baseUrl,
      organizationId: organizationId,
      apiKey: apiKey,
      timeoutSeconds: timeoutSeconds,
    );
    ref.read(settingsProvider.notifier).updateApiConfig(updatedConfig);
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isTestingConnection = true;
    });

    // Simulate API connection test
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isTestingConnection = false;
      });

      // For demonstration, randomly succeed or fail
      final success = DateTime.now().second % 2 == 0;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: OdooSpacing.md),
              Expanded(
                child: Text(
                  success
                      ? 'Connection successful!'
                      : 'Connection failed. Please check your settings.',
                ),
              ),
            ],
          ),
          backgroundColor: success ? OdooColors.success : OdooColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          ),
        ),
      );
    }
  }
}
