/// Session Open Page
/// Vodo-style page for opening a new POS session
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../../application/session_providers.dart';
import '../../domain/models/cash_count.dart';
import '../widgets/cash_count_widget.dart';

/// Session open page
class SessionOpenPage extends ConsumerStatefulWidget {
  const SessionOpenPage({super.key});

  @override
  ConsumerState<SessionOpenPage> createState() => _SessionOpenPageState();
}

class _SessionOpenPageState extends ConsumerState<SessionOpenPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  // Default register ID (would come from device config in production)
  String _registerId = 'register-001';
  double _openingCash = 0.0;

  // Cash count state
  CashCount _cashCount = CashCount(
    type: CashCountType.opening,
    denominations: USDenominations.all,
  );

  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleOpenSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(currentSessionProvider.notifier);

      final success = await controller.openSession(
        openingCash: _openingCash,
        registerId: _registerId,
        cashCount: _cashCount, // Pass denomination details (Odoo pattern)
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        // Show success message with session number
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session opened successfully! Ready to take orders.'),
            backgroundColor: VodoColors.success,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate back or to main POS screen
        Navigator.of(context).pop();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open session. Please try again.'),
            backgroundColor: VodoColors.danger,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleCashCountChanged(CashCount cashCount) {
    setState(() {
      _cashCount = cashCount;
      _openingCash = cashCount.totalAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: VodoColors.primary,
        foregroundColor: VodoColors.textOnPrimary,
        title: const Text(
          'Open POS Session',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: VodoDimensions.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome message card
              Card(
                elevation: VodoDimensions.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: VodoDimensions.borderRadiusMd,
                ),
                child: Padding(
                  padding: VodoDimensions.cardPaddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: VodoDimensions.paddingMd,
                            decoration: BoxDecoration(
                              color: VodoColors.primaryLight.withOpacity(0.2),
                              borderRadius: VodoDimensions.borderRadiusMd,
                            ),
                            child: const Icon(
                              Icons.point_of_sale,
                              color: VodoColors.primary,
                              size: VodoDimensions.iconSizeLg,
                            ),
                          ),
                          const SizedBox(width: VodoDimensions.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Your Shift',
                                  style: VodoTextStyles.headlineSmall,
                                ),
                                const SizedBox(height: VodoDimensions.spacingXs),
                                Text(
                                  'Count your opening cash to begin',
                                  style: VodoTextStyles.bodyMedium.copyWith(
                                    color: VodoColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: VodoDimensions.spacingLg),

              // Register selection card
              Card(
                elevation: VodoDimensions.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: VodoDimensions.borderRadiusMd,
                ),
                child: Padding(
                  padding: VodoDimensions.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register Information',
                        style: VodoTextStyles.titleMedium,
                      ),
                      const SizedBox(height: VodoDimensions.spacingMd),
                      DropdownButtonFormField<String>(
                        value: _registerId,
                        decoration: const InputDecoration(
                          labelText: 'Select Register',
                          prefixIcon: Icon(Icons.desktop_windows),
                        ),
                        items: [
                          'register-001',
                          'register-002',
                          'register-003',
                        ].map((id) {
                          return DropdownMenuItem(
                            value: id,
                            child: Text('Register ${id.split('-').last}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _registerId = value);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a register';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: VodoDimensions.spacingLg),

              // Cash count widget
              CashCountWidget(
                cashCount: _cashCount,
                onChanged: _handleCashCountChanged,
              ),

              const SizedBox(height: VodoDimensions.spacingLg),

              // Notes card
              Card(
                elevation: VodoDimensions.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: VodoDimensions.borderRadiusMd,
                ),
                child: Padding(
                  padding: VodoDimensions.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes (Optional)',
                        style: VodoTextStyles.titleMedium,
                      ),
                      const SizedBox(height: VodoDimensions.spacingMd),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Add any notes about this session...',
                          prefixIcon: Icon(Icons.note),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: VodoDimensions.spacingXl),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, VodoDimensions.buttonHeightLg),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: VodoDimensions.spacingMd),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleOpenSession,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, VodoDimensions.buttonHeightLg),
                        backgroundColor: VodoColors.success,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  VodoColors.textOnPrimary,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_open),
                                const SizedBox(width: VodoDimensions.spacingSm),
                                Text(
                                  'Open Session - \$${_openingCash.toStringAsFixed(2)}',
                                  style: VodoTextStyles.button,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: VodoDimensions.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}
