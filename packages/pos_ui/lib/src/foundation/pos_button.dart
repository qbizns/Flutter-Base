import 'package:flutter/material.dart';

/// POS-styled button component.
/// Provides consistent button styling across all POS apps.
class PosButton extends StatelessWidget {
  const PosButton({
    required this.onPressed,
    required this.child,
    this.variant = PosButtonVariant.primary,
    this.size = PosButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final PosButtonVariant variant;
  final PosButtonSize size;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button;

    switch (variant) {
      case PosButtonVariant.primary:
        button = FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: _getLoadingSize(),
                  width: _getLoadingSize(),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : child,
        );
        break;
      case PosButtonVariant.secondary:
        button = FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: _getLoadingSize(),
                  width: _getLoadingSize(),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : child,
        );
        break;
      case PosButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: _getLoadingSize(),
                  width: _getLoadingSize(),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : child,
        );
        break;
      case PosButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: _getLoadingSize(),
                  width: _getLoadingSize(),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : child,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  double _getLoadingSize() {
    switch (size) {
      case PosButtonSize.small:
        return 16.0;
      case PosButtonSize.medium:
        return 20.0;
      case PosButtonSize.large:
        return 24.0;
    }
  }
}

enum PosButtonVariant {
  primary,
  secondary,
  outlined,
  text,
}

enum PosButtonSize {
  small,
  medium,
  large,
}
