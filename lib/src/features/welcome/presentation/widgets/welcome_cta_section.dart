import 'package:flutter/material.dart';
import '../../../../core/widgets/responsive_layout.dart';

/// Welcome screen call-to-action section.
/// Displays primary and secondary action buttons.
class WelcomeCtaSection extends StatelessWidget {
  const WelcomeCtaSection({
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    super.key,
  });

  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType.isMobile;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Button
        SizedBox(
          height: isMobile ? 48 : 56,
          child: ElevatedButton(
            onPressed: onPrimaryPressed,
            child: Text(primaryButtonText),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        // Secondary Button
        SizedBox(
          height: isMobile ? 48 : 56,
          child: TextButton(
            onPressed: onSecondaryPressed,
            child: Text(secondaryButtonText),
          ),
        ),
      ],
    );
  }
}
