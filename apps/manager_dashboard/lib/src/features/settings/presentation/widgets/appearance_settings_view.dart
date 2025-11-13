import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/settings_models.dart';
import '../../providers/settings_providers.dart';

/// Appearance Settings View
///
/// Contains:
/// - Theme mode (Light/Dark/System)
/// - Primary color picker
/// - Font size selection
class AppearanceSettingsView extends ConsumerWidget {
  const AppearanceSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme Mode Card
          _buildCard(
            title: 'Theme Mode',
            icon: Icons.brightness_6_outlined,
            children: [
              Text(
                'Choose how the app looks',
                style: OdooTypography.bodyMedium.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
              const SizedBox(height: OdooSpacing.lg),
              ...AppThemeMode.values.map((mode) {
                return RadioListTile<AppThemeMode>(
                  value: mode,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).updateAppearanceSettings(
                            themeMode: value,
                          );
                    }
                  },
                  title: Text(_getThemeModeTitle(mode)),
                  subtitle: Text(_getThemeModeDescription(mode)),
                  secondary: Icon(_getThemeModeIcon(mode)),
                  activeColor: OdooColors.primary,
                );
              }),
            ],
          ),

          const SizedBox(height: OdooSpacing.lg),

          // Primary Color Card
          _buildCard(
            title: 'Primary Color',
            icon: Icons.palette_outlined,
            children: [
              Text(
                'Customize the primary color used throughout the app',
                style: OdooTypography.bodyMedium.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
              const SizedBox(height: OdooSpacing.lg),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: settings.primaryColor,
                      borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                      border: Border.all(
                        color: OdooColors.border,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: OdooSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Color',
                          style: OdooTypography.labelLarge,
                        ),
                        const SizedBox(height: OdooSpacing.xs),
                        Text(
                          '#${settings.primaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
                          style: OdooTypography.bodySmall.copyWith(
                            color: OdooColors.textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showColorPicker(context, ref, settings.primaryColor),
                    icon: const Icon(Icons.colorize),
                    label: const Text('Choose Color'),
                    style: FilledButton.styleFrom(
                      backgroundColor: OdooColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OdooSpacing.lg),
              const Divider(),
              const SizedBox(height: OdooSpacing.lg),
              Text(
                'Preset Colors',
                style: OdooTypography.labelLarge,
              ),
              const SizedBox(height: OdooSpacing.md),
              Wrap(
                spacing: OdooSpacing.md,
                runSpacing: OdooSpacing.md,
                children: _presetColors.map((color) {
                  final isSelected = settings.primaryColor.value == color.value;
                  return InkWell(
                    onTap: () {
                      ref.read(settingsProvider.notifier).updateAppearanceSettings(
                            primaryColor: color,
                          );
                    },
                    borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                        border: Border.all(
                          color: isSelected ? OdooColors.textPrimary : OdooColors.border,
                          width: isSelected ? 3 : 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: OdooSpacing.lg),

          // Font Size Card
          _buildCard(
            title: 'Font Size',
            icon: Icons.format_size,
            children: [
              Text(
                'Adjust the base font size for better readability',
                style: OdooTypography.bodyMedium.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
              const SizedBox(height: OdooSpacing.lg),
              Row(
                children: [
                  Icon(
                    Icons.text_fields,
                    size: OdooIconSizes.sm,
                    color: OdooColors.textSecondary,
                  ),
                  Expanded(
                    child: Slider(
                      value: settings.fontSize,
                      min: 12.0,
                      max: 18.0,
                      divisions: 6,
                      label: '${settings.fontSize.toStringAsFixed(0)}px',
                      activeColor: OdooColors.primary,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).updateAppearanceSettings(
                              fontSize: value,
                            );
                      },
                    ),
                  ),
                  Icon(
                    Icons.text_fields,
                    size: OdooIconSizes.lg,
                    color: OdooColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: OdooSpacing.md),
              Center(
                child: Text(
                  'Preview Text (${settings.fontSize.toStringAsFixed(0)}px)',
                  style: TextStyle(
                    fontSize: settings.fontSize,
                    fontFamily: OdooTypography.fontFamily,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: OdooSpacing.lg),

          // Preview Card
          _buildCard(
            title: 'Preview',
            icon: Icons.visibility_outlined,
            children: [
              Text(
                'Sample heading with current settings',
                style: OdooTypography.headlineSmall.copyWith(
                  color: settings.primaryColor,
                  fontSize: settings.fontSize * 1.5,
                ),
              ),
              const SizedBox(height: OdooSpacing.md),
              Text(
                'This is sample body text that shows how your content will look with the current appearance settings applied.',
                style: TextStyle(
                  fontSize: settings.fontSize,
                  fontFamily: OdooTypography.fontFamily,
                  color: OdooColors.textPrimary,
                ),
              ),
              const SizedBox(height: OdooSpacing.md),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: settings.primaryColor,
                ),
                child: const Text('Sample Button'),
              ),
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

  String _getThemeModeTitle(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light Mode';
      case AppThemeMode.dark:
        return 'Dark Mode';
      case AppThemeMode.system:
        return 'System Default';
    }
  }

  String _getThemeModeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Always use light theme';
      case AppThemeMode.dark:
        return 'Always use dark theme';
      case AppThemeMode.system:
        return 'Follow system theme preference';
    }
  }

  IconData _getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  void _showColorPicker(BuildContext context, WidgetRef ref, Color currentColor) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
            enableAlpha: false,
            displayThumbColor: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateAppearanceSettings(
                    primaryColor: pickerColor,
                  );
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: OdooColors.primary,
            ),
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  static const List<Color> _presetColors = [
    Color(0xFF714B67), // Odoo Purple (default)
    Color(0xFF00A09D), // Odoo Teal
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF607D8B), // Blue Gray
  ];
}
