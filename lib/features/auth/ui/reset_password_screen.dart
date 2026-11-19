import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_layout.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _linkController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).resetPasswordWithRecoveryLink(
          recoveryUrl: _linkController.text.trim(),
          newPassword: _passwordController.text,
        );
    if (mounted && ref.read(authControllerProvider).hasValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. Please log in again.')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          final message = error is AuthException
              ? error.message
              : 'Could not reset password. Make sure you pasted the full link.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthLayout(
      formKey: _formKey,
      title: 'Reset password',
      children: [
        Text(
          'Paste the full password reset link from your email below.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textMuted, height: 1.45),
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: _linkController,
          label: 'Reset link',
          minLines: 2,
          maxLines: 4,
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'Paste the reset link' : null,
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _passwordController,
          label: 'New password',
          isPassword: true,
          validator: Validators.password,
          enabled: !isLoading,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _confirmPasswordController,
          label: 'Confirm new password',
          isPassword: true,
          validator: (value) => Validators.confirmPassword(value, _passwordController.text),
          enabled: !isLoading,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 28),
        AuthSubmitButton(label: 'Update password', isLoading: isLoading, onPressed: _submit),
      ],
    );
  }
}
