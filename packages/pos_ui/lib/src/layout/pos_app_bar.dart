import 'package:flutter/material.dart';

/// POS-styled app bar component.
/// Provides consistent app bar styling across all POS apps.
class PosAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PosAppBar({
    this.title,
    this.leading,
    this.actions,
    this.elevation,
    this.backgroundColor,
    this.centerTitle = true,
    super.key,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final double? elevation;
  final Color? backgroundColor;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      elevation: elevation,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
