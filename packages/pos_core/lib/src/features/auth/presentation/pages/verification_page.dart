import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_sizes.dart';

/// Verification page for OTP input.
/// Used for password reset and other verification flows.
class VerificationPage extends ConsumerStatefulWidget {
  const VerificationPage({
    required this.identifier,
    required this.flow,
    super.key,
  });

  final String identifier;
  final String flow; // 'password_reset', 'signup', etc.

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isCodeVerified = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.verifyCode(
        identifier: widget.identifier,
        code: _codeController.text.trim(),
      );

      result.when(
        success: (_) {
          if (mounted) {
            setState(() => _isCodeVerified = true);
            _showSuccess('Code verified successfully');
          }
        },
        failure: (failure) {
          if (mounted) {
            _showError(failure.message);
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.resetPassword(
        identifier: widget.identifier,
        code: _codeController.text.trim(),
        newPassword: _newPasswordController.text,
      );

      result.when(
        success: (_) {
          if (mounted) {
            _showSuccess('Password reset successfully');
            // Navigate back to sign in
            context.go(Routes.signIn);
          }
        },
        failure: (failure) {
          if (mounted) {
            _showError(failure.message);
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Sizes.p24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Icon(
                      Icons.verified_user_outlined,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: Sizes.p24),

                    // Title
                    Text(
                      'Enter Verification Code',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Sizes.p8),

                    // Subtitle
                    Text(
                      'We sent a code to ${widget.identifier}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Sizes.p32),

                    // Code field
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Verification Code',
                        hintText: 'Enter the code',
                        prefixIcon: Icon(Icons.key_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                      enabled: !_isCodeVerified,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the code';
                        }
                        if (value.length < 4) {
                          return 'Code must be at least 4 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: Sizes.p24),

                    // Verify button (only if not verified yet)
                    if (!_isCodeVerified)
                      FilledButton(
                        onPressed: _isLoading ? null : _handleVerifyCode,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Verify Code'),
                      ),

                    // Password reset form (only after code is verified)
                    if (_isCodeVerified && widget.flow == 'password_reset') ...[
                      const SizedBox(height: Sizes.p24),
                      const Divider(),
                      const SizedBox(height: Sizes.p24),

                      Text(
                        'Set New Password',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Sizes.p16),

                      TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          hintText: 'Enter your new password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Sizes.p24),

                      FilledButton(
                        onPressed: _isLoading ? null : _handleResetPassword,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Reset Password'),
                      ),
                    ],

                    // Resend code
                    const SizedBox(height: Sizes.p16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement resend code
                          },
                          child: const Text('Resend'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
