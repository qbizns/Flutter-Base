import 'package:flutter/material.dart';
import '../../../../core/widgets/responsive_layout.dart';

/// Welcome screen header widget.
/// Displays app logo, name, and tagline.
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({
    required this.title,
    required this.tagline,
    super.key,
  });

  final String title;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceType = ResponsiveLayout.getDeviceType(context);

    // Responsive sizes
    final logoSize = deviceType.isMobile
        ? 80.0
        : deviceType.isTablet
            ? 100.0
            : 120.0;

    final titleStyle = deviceType.isMobile
        ? theme.textTheme.headlineMedium
        : theme.textTheme.headlineLarge;

    final taglineStyle = deviceType.isMobile
        ? theme.textTheme.bodyMedium
        : theme.textTheme.bodyLarge;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Logo
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.rocket_launch,
            size: logoSize * 0.6,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: deviceType.isMobile ? 24 : 32),

        // App Name
        Text(
          title,
          style: titleStyle?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Tagline
        Text(
          tagline,
          style: taglineStyle?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
