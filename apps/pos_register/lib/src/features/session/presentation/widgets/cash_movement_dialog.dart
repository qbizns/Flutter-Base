/// Cash Movement Dialog
/// Odoo-style dialog for recording cash in/out movements during session
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_core/pos_core.dart';
import '../../domain/models/cash_movement.dart';

/// Dialog for adding cash movement to session
class CashMovementDialog extends StatefulWidget {
  final CashMovementType initialType;
  final double currentBalance;

  const CashMovementDialog({
    super.key,
    required this.initialType,
    required this.currentBalance,
  });

  @override
  State<CashMovementDialog> createState() => _CashMovementDialogState();
}

class _CashMovementDialogState extends State<CashMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _customReasonController = TextEditingController();
  final _notesController = TextEditingController();

  late CashMovementType _type;
  CashMovementReason _reason = CashMovementReason.safeDeposit;
  double _amount = 0.0;
  bool _requiresApproval = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _customReasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleAmountChanged(String value) {
    final amount = double.tryParse(value) ?? 0.0;
    setState(() {
      _amount = amount;
      // Require approval for large amounts (>$500)
      _requiresApproval = amount > 500.0;
    });
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Return the cash movement data
    Navigator.of(context).pop({
      'type': _type,
      'amount': _amount,
      'reason': _reason,
      'custom_reason': _reason == CashMovementReason.other
          ? _customReasonController.text.trim()
          : null,
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      'requires_approval': _requiresApproval,
    });
  }

  String _getDialogTitle() {
    return _type == CashMovementType.cashIn
        ? 'Add Cash to Register'
        : 'Remove Cash from Register';
  }

  String _getAmountLabel() {
    return _type == CashMovementType.cashIn
        ? 'Amount to Add'
        : 'Amount to Remove';
  }

  Color _getAccentColor() {
    return _type == CashMovementType.cashIn
        ? VodoColors.success
        : VodoColors.warning;
  }

  IconData _getIcon() {
    return _type == CashMovementType.cashIn
        ? Icons.add_circle
        : Icons.remove_circle;
  }

  List<CashMovementReason> _getReasonOptions() {
    if (_type == CashMovementType.cashIn) {
      return [
        CashMovementReason.changeRequest,
        CashMovementReason.loanIn,
        CashMovementReason.other,
      ];
    } else {
      return [
        CashMovementReason.safeDeposit,
        CashMovementReason.bankDeposit,
        CashMovementReason.expense,
        CashMovementReason.loanOut,
        CashMovementReason.other,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: VodoDimensions.paddingLg,
                  decoration: BoxDecoration(
                    color: _getAccentColor().withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(VodoDimensions.radiusMd),
                      topRight: Radius.circular(VodoDimensions.radiusMd),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIcon(),
                        color: _getAccentColor(),
                        size: VodoDimensions.iconSizeLg,
                      ),
                      const SizedBox(width: VodoDimensions.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getDialogTitle(),
                              style: VodoTextStyles.titleLarge,
                            ),
                            const SizedBox(height: VodoDimensions.spacingXs),
                            Text(
                              'Current balance: \$${widget.currentBalance.toStringAsFixed(2)}',
                              style: VodoTextStyles.bodyMedium.copyWith(
                                color: VodoColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: VodoColors.textSecondary,
                      ),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: VodoDimensions.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Movement type toggle
                      Container(
                        decoration: BoxDecoration(
                          color: VodoColors.backgroundSecondary,
                          borderRadius: VodoDimensions.borderRadiusMd,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _MovementTypeButton(
                                label: 'Cash In',
                                icon: Icons.add_circle,
                                isSelected: _type == CashMovementType.cashIn,
                                color: VodoColors.success,
                                onTap: () {
                                  setState(() {
                                    _type = CashMovementType.cashIn;
                                    _reason = CashMovementReason.changeRequest;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: _MovementTypeButton(
                                label: 'Cash Out',
                                icon: Icons.remove_circle,
                                isSelected: _type == CashMovementType.cashOut,
                                color: VodoColors.warning,
                                onTap: () {
                                  setState(() {
                                    _type = CashMovementType.cashOut;
                                    _reason = CashMovementReason.safeDeposit;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: VodoDimensions.spacingLg),

                      // Amount input
                      TextFormField(
                        controller: _amountController,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: _getAmountLabel(),
                          prefixText: '\$ ',
                          prefixStyle: VodoTextStyles.titleMedium,
                          helperText: _requiresApproval
                              ? 'Manager approval required for amounts over \$500'
                              : null,
                          helperStyle: TextStyle(
                            color: VodoColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: VodoTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: _handleAmountChanged,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          if (_type == CashMovementType.cashOut &&
                              amount > widget.currentBalance) {
                            return 'Insufficient balance in register';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: VodoDimensions.spacingLg),

                      // Reason dropdown
                      DropdownButtonFormField<CashMovementReason>(
                        value: _reason,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _getReasonOptions().map((reason) {
                          return DropdownMenuItem(
                            value: reason,
                            child: Text(reason.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _reason = value);
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a reason';
                          }
                          return null;
                        },
                      ),

                      // Custom reason field (if Other selected)
                      if (_reason == CashMovementReason.other) ...[
                        const SizedBox(height: VodoDimensions.spacingMd),
                        TextFormField(
                          controller: _customReasonController,
                          decoration: const InputDecoration(
                            labelText: 'Specify Reason',
                            prefixIcon: Icon(Icons.edit_note),
                          ),
                          validator: (value) {
                            if (_reason == CashMovementReason.other &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Please specify the reason';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: VodoDimensions.spacingLg),

                      // Notes field
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Add any additional notes...',
                          prefixIcon: Icon(Icons.note),
                        ),
                      ),

                      // Approval notice
                      if (_requiresApproval) ...[
                        const SizedBox(height: VodoDimensions.spacingMd),
                        Container(
                          padding: VodoDimensions.paddingMd,
                          decoration: BoxDecoration(
                            color: VodoColors.warning.withOpacity(0.1),
                            borderRadius: VodoDimensions.borderRadiusSm,
                            border: Border.all(
                              color: VodoColors.warning.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: VodoColors.warning,
                                size: VodoDimensions.iconSizeMd,
                              ),
                              const SizedBox(width: VodoDimensions.spacingMd),
                              Expanded(
                                child: Text(
                                  'This transaction requires manager approval',
                                  style: VodoTextStyles.bodySmall.copyWith(
                                    color: VodoColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: VodoDimensions.spacingXl),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(
                                  0,
                                  VodoDimensions.buttonHeightLg,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: VodoDimensions.spacingMd),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(
                                  0,
                                  VodoDimensions.buttonHeightLg,
                                ),
                                backgroundColor: _getAccentColor(),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_getIcon()),
                                  const SizedBox(
                                    width: VodoDimensions.spacingSm,
                                  ),
                                  Text(
                                    _type == CashMovementType.cashIn
                                        ? 'Add Cash'
                                        : 'Remove Cash',
                                    style: VodoTextStyles.button,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Movement type toggle button
class _MovementTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _MovementTypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: VodoDimensions.borderRadiusMd,
      child: Container(
        padding: VodoDimensions.paddingMd,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: VodoDimensions.borderRadiusMd,
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : VodoColors.textSecondary,
              size: VodoDimensions.iconSizeMd,
            ),
            const SizedBox(width: VodoDimensions.spacingSm),
            Text(
              label,
              style: VodoTextStyles.titleSmall.copyWith(
                color: isSelected ? color : VodoColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
