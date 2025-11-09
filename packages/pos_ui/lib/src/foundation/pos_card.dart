import 'package:flutter/material.dart';

/// POS-styled card component.
/// Provides consistent card styling across all POS apps.
class PosCard extends StatelessWidget {
  const PosCard({
    required this.child,
    this.onTap,
    this.padding,
    this.elevation,
    this.color,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation,
      color: color,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: card,
      );
    }

    return card;
  }
}
