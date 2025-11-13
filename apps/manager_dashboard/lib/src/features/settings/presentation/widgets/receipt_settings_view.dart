import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../providers/settings_providers.dart';

/// Receipt Settings View
///
/// Contains:
/// - Receipt header/footer text
/// - Logo display toggle
/// - Print settings (auto-print, copies)
/// - QR code toggle
class ReceiptSettingsView extends ConsumerStatefulWidget {
  const ReceiptSettingsView({super.key});

  @override
  ConsumerState<ReceiptSettingsView> createState() =>
      _ReceiptSettingsViewState();
}

class _ReceiptSettingsViewState extends ConsumerState<ReceiptSettingsView> {
  late TextEditingController _headerController;
  late TextEditingController _footerController;

  @override
  void initState() {
    super.initState();
    final receiptSettings = ref.read(settingsProvider).receiptSettings;
    _headerController = TextEditingController(text: receiptSettings.headerText);
    _footerController = TextEditingController(text: receiptSettings.footerText);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final receiptSettings = settings.receiptSettings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt Content Card
          _buildCard(
            title: 'Receipt Content',
            icon: Icons.receipt_outlined,
            children: [
              TextFormField(
                controller: _headerController,
                decoration: const InputDecoration(
                  labelText: 'Header Text',
                  hintText: 'Printed at the top of receipts',
                  prefixIcon: Icon(Icons.title),
                  helperText: 'e.g., Thank you for visiting!',
                ),
                maxLines: 3,
                onChanged: (value) {
                  _updateReceiptSettings(headerText: value);
                },
              ),
              const SizedBox(height: OdooSpacing.lg),
              TextFormField(
                controller: _footerController,
                decoration: const InputDecoration(
                  labelText: 'Footer Text',
                  hintText: 'Printed at the bottom of receipts',
                  prefixIcon: Icon(Icons.notes),
                  helperText: 'e.g., Visit us again!',
                ),
                maxLines: 3,
                onChanged: (value) {
                  _updateReceiptSettings(footerText: value);
                },
              ),
              const SizedBox(height: OdooSpacing.lg),
              SwitchListTile(
                value: receiptSettings.showLogo,
                onChanged: (value) {
                  _updateReceiptSettings(showLogo: value);
                },
                title: Text(
                  'Show Restaurant Logo',
                  style: OdooTypography.labelLarge,
                ),
                subtitle: Text(
                  'Display your restaurant logo on receipts',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
                activeColor: OdooColors.primary,
                secondary: Icon(
                  Icons.image_outlined,
                  color: OdooColors.primary,
                ),
              ),
              const Divider(),
              SwitchListTile(
                value: receiptSettings.showQRCode,
                onChanged: (value) {
                  _updateReceiptSettings(showQRCode: value);
                },
                title: Text(
                  'Show QR Code',
                  style: OdooTypography.labelLarge,
                ),
                subtitle: Text(
                  'Include a QR code for digital receipt access',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
                activeColor: OdooColors.primary,
                secondary: Icon(
                  Icons.qr_code,
                  color: OdooColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: OdooSpacing.lg),

          // Print Settings Card
          _buildCard(
            title: 'Print Settings',
            icon: Icons.print_outlined,
            children: [
              SwitchListTile(
                value: receiptSettings.autoPrint,
                onChanged: (value) {
                  _updateReceiptSettings(autoPrint: value);
                },
                title: Text(
                  'Auto Print',
                  style: OdooTypography.labelLarge,
                ),
                subtitle: Text(
                  'Automatically print receipts after payment',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
                activeColor: OdooColors.primary,
                secondary: Icon(
                  Icons.print,
                  color: OdooColors.primary,
                ),
              ),
              const SizedBox(height: OdooSpacing.lg),
              const Divider(),
              const SizedBox(height: OdooSpacing.lg),
              Row(
                children: [
                  Icon(
                    Icons.copy_outlined,
                    color: OdooColors.primary,
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Number of Copies',
                          style: OdooTypography.labelLarge,
                        ),
                        Text(
                          'How many receipt copies to print',
                          style: OdooTypography.bodySmall.copyWith(
                            color: OdooColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  _buildCopyCounter(receiptSettings.numberOfCopies),
                ],
              ),
            ],
          ),

          const SizedBox(height: OdooSpacing.lg),

          // Receipt Preview Card
          _buildCard(
            title: 'Receipt Preview',
            icon: Icons.visibility_outlined,
            children: [
              Container(
                padding: const EdgeInsets.all(OdooSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                  border: Border.all(
                    color: OdooColors.border,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Logo
                    if (receiptSettings.showLogo)
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(bottom: OdooSpacing.md),
                        decoration: BoxDecoration(
                          color: OdooColors.gray200,
                          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          size: OdooIconSizes.xl,
                          color: OdooColors.gray500,
                        ),
                      ),

                    // Header Text
                    if (_headerController.text.isNotEmpty) ...[
                      Text(
                        _headerController.text,
                        style: OdooTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: OdooSpacing.md),
                      const Divider(),
                    ],

                    // Sample Receipt Content
                    const SizedBox(height: OdooSpacing.md),
                    Text(
                      settings.restaurantName,
                      style: OdooTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: OdooSpacing.xs),
                    Text(
                      'Receipt #12345',
                      style: OdooTypography.bodyMedium.copyWith(
                        color: OdooColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: OdooSpacing.md),
                    const Divider(),
                    const SizedBox(height: OdooSpacing.md),

                    // Sample Items
                    _buildReceiptLine('Burger', '\$12.99'),
                    _buildReceiptLine('Fries', '\$3.99'),
                    _buildReceiptLine('Soda', '\$2.50'),

                    const SizedBox(height: OdooSpacing.md),
                    const Divider(),
                    const SizedBox(height: OdooSpacing.md),

                    _buildReceiptLine(
                      'Subtotal',
                      '\$19.48',
                      bold: true,
                    ),
                    _buildReceiptLine(
                      'Tax (${settings.taxSettings.defaultTaxRate}%)',
                      '\$1.56',
                    ),
                    const SizedBox(height: OdooSpacing.sm),
                    _buildReceiptLine(
                      'TOTAL',
                      '\$21.04',
                      bold: true,
                      large: true,
                    ),

                    // QR Code
                    if (receiptSettings.showQRCode) ...[
                      const SizedBox(height: OdooSpacing.lg),
                      const Divider(),
                      const SizedBox(height: OdooSpacing.md),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: OdooColors.gray200,
                          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                        ),
                        child: Icon(
                          Icons.qr_code,
                          size: OdooIconSizes.xxl,
                          color: OdooColors.gray500,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.sm),
                      Text(
                        'Scan for digital receipt',
                        style: OdooTypography.bodySmall.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                      ),
                    ],

                    // Footer Text
                    if (_footerController.text.isNotEmpty) ...[
                      const SizedBox(height: OdooSpacing.md),
                      const Divider(),
                      const SizedBox(height: OdooSpacing.md),
                      Text(
                        _footerController.text,
                        style: OdooTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
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

  Widget _buildCopyCounter(int value) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: OdooColors.border),
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > 1
                ? () {
                    _updateReceiptSettings(numberOfCopies: value - 1);
                  }
                : null,
            iconSize: OdooIconSizes.sm,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: OdooSpacing.md),
            child: Text(
              value.toString(),
              style: OdooTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value < 5
                ? () {
                    _updateReceiptSettings(numberOfCopies: value + 1);
                  }
                : null,
            iconSize: OdooIconSizes.sm,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptLine(
    String label,
    String value, {
    bool bold = false,
    bool large = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OdooSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: (large ? OdooTypography.titleMedium : OdooTypography.bodyMedium)
                .copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: (large ? OdooTypography.titleMedium : OdooTypography.bodyMedium)
                .copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _updateReceiptSettings({
    String? headerText,
    String? footerText,
    bool? showLogo,
    bool? autoPrint,
    int? numberOfCopies,
    bool? showQRCode,
  }) {
    final currentSettings = ref.read(settingsProvider).receiptSettings;
    final updatedSettings = currentSettings.copyWith(
      headerText: headerText,
      footerText: footerText,
      showLogo: showLogo,
      autoPrint: autoPrint,
      numberOfCopies: numberOfCopies,
      showQRCode: showQRCode,
    );
    ref.read(settingsProvider.notifier).updateReceiptSettings(updatedSettings);
  }
}
