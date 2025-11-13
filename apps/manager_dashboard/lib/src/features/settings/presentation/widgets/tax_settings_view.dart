import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/settings_models.dart';
import '../../providers/settings_providers.dart';

/// Tax Settings View
///
/// Contains:
/// - Default tax rate
/// - Tax inclusive/exclusive toggle
/// - Multiple tax rates management
class TaxSettingsView extends ConsumerWidget {
  const TaxSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final taxSettings = settings.taxSettings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Tax Settings Card
          _buildCard(
            title: 'General Tax Settings',
            icon: Icons.percent_outlined,
            children: [
              TextFormField(
                initialValue: taxSettings.defaultTaxRate.toString(),
                decoration: const InputDecoration(
                  labelText: 'Default Tax Rate (%)',
                  hintText: 'Enter tax rate',
                  prefixIcon: Icon(Icons.percent),
                  helperText: 'Default tax rate applied to products',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  final rate = double.tryParse(value) ?? 0.0;
                  ref.read(settingsProvider.notifier).updateTaxSettings(
                        taxSettings.copyWith(defaultTaxRate: rate),
                      );
                },
              ),
              const SizedBox(height: OdooSpacing.lg),
              SwitchListTile(
                value: taxSettings.taxInclusive,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateTaxSettings(
                        taxSettings.copyWith(taxInclusive: value),
                      );
                },
                title: Text(
                  'Tax Inclusive Pricing',
                  style: OdooTypography.labelLarge,
                ),
                subtitle: Text(
                  taxSettings.taxInclusive
                      ? 'Prices include tax'
                      : 'Tax added to prices',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
                activeColor: OdooColors.primary,
                secondary: Icon(
                  taxSettings.taxInclusive
                      ? Icons.check_circle_outline
                      : Icons.add_circle_outline,
                  color: OdooColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: OdooSpacing.lg),

          // Tax Rates Card
          _buildCard(
            title: 'Tax Rates',
            icon: Icons.list_alt_outlined,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Manage multiple tax rates for different products or categories',
                      style: OdooTypography.bodyMedium.copyWith(
                        color: OdooColors.textSecondary,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showAddTaxRateDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Tax Rate'),
                    style: FilledButton.styleFrom(
                      backgroundColor: OdooColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OdooSpacing.lg),
              if (taxSettings.taxRates.isEmpty)
                Container(
                  padding: const EdgeInsets.all(OdooSpacing.xl),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: OdooIconSizes.xxl,
                        color: OdooColors.gray400,
                      ),
                      const SizedBox(height: OdooSpacing.md),
                      Text(
                        'No custom tax rates configured',
                        style: OdooTypography.bodyMedium.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...taxSettings.taxRates.map((taxRate) {
                  return _buildTaxRateItem(context, ref, taxRate);
                }),
            ],
          ),

          const SizedBox(height: OdooSpacing.lg),

          // Information Card
          _buildInfoBox(
            'Tax settings affect how prices are calculated throughout the application. Make sure to review your local tax regulations.',
            Icons.info_outline,
            OdooColors.info,
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

  Widget _buildTaxRateItem(
    BuildContext context,
    WidgetRef ref,
    TaxRate taxRate,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: OdooSpacing.md),
      padding: const EdgeInsets.all(OdooSpacing.md),
      decoration: BoxDecoration(
        color: taxRate.isDefault ? OdooColors.primary.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        border: Border.all(
          color: taxRate.isDefault ? OdooColors.primary : OdooColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_outlined,
            color: taxRate.isDefault ? OdooColors.primary : OdooColors.textSecondary,
          ),
          const SizedBox(width: OdooSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      taxRate.name,
                      style: OdooTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (taxRate.isDefault) ...[
                      const SizedBox(width: OdooSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OdooSpacing.sm,
                          vertical: OdooSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: OdooColors.primary,
                          borderRadius: BorderRadius.circular(OdooSpacing.radiusSmall),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: OdooTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: OdooSpacing.xs),
                Text(
                  '${taxRate.rate}%',
                  style: OdooTypography.bodyMedium.copyWith(
                    color: OdooColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: OdooColors.primary,
            onPressed: () => _showEditTaxRateDialog(context, ref, taxRate),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: OdooColors.danger,
            onPressed: () => _confirmDeleteTaxRate(context, ref, taxRate),
          ),
        ],
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

  Future<void> _showAddTaxRateDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final rateController = TextEditingController();
    bool isDefault = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Tax Rate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tax Name',
                  hintText: 'e.g., Sales Tax, VAT',
                ),
              ),
              const SizedBox(height: OdooSpacing.md),
              TextField(
                controller: rateController,
                decoration: const InputDecoration(
                  labelText: 'Tax Rate (%)',
                  hintText: 'e.g., 10.5',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: OdooSpacing.md),
              CheckboxListTile(
                value: isDefault,
                onChanged: (value) {
                  setState(() {
                    isDefault = value ?? false;
                  });
                },
                title: const Text('Set as default'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    rateController.text.isNotEmpty) {
                  final taxRate = TaxRate(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    rate: double.parse(rateController.text),
                    isDefault: isDefault,
                  );

                  ref.read(settingsProvider.notifier).addTaxRate(taxRate);
                  Navigator.of(context).pop();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: OdooColors.primary,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditTaxRateDialog(
    BuildContext context,
    WidgetRef ref,
    TaxRate taxRate,
  ) async {
    final nameController = TextEditingController(text: taxRate.name);
    final rateController = TextEditingController(text: taxRate.rate.toString());
    bool isDefault = taxRate.isDefault;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Tax Rate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tax Name',
                ),
              ),
              const SizedBox(height: OdooSpacing.md),
              TextField(
                controller: rateController,
                decoration: const InputDecoration(
                  labelText: 'Tax Rate (%)',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: OdooSpacing.md),
              CheckboxListTile(
                value: isDefault,
                onChanged: (value) {
                  setState(() {
                    isDefault = value ?? false;
                  });
                },
                title: const Text('Set as default'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    rateController.text.isNotEmpty) {
                  final updatedTaxRate = taxRate.copyWith(
                    name: nameController.text,
                    rate: double.parse(rateController.text),
                    isDefault: isDefault,
                  );

                  ref
                      .read(settingsProvider.notifier)
                      .updateTaxRate(taxRate.id, updatedTaxRate);
                  Navigator.of(context).pop();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: OdooColors.primary,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTaxRate(
    BuildContext context,
    WidgetRef ref,
    TaxRate taxRate,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tax Rate'),
        content: Text('Are you sure you want to delete "${taxRate.name}"?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: OdooColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(settingsProvider.notifier).removeTaxRate(taxRate.id);
    }
  }
}
