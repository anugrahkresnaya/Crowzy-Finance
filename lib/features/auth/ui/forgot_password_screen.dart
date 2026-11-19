import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_layout.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(_emailController.text.trim());
    if (ref.read(authControllerProvider).hasValue) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          final message = error is AuthException ? error.message : 'Something went wrong';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    final textTheme = Theme.of(context).textTheme;

    return AuthLayout(
      formKey: _formKey,
      title: 'Forgot password',
      children: [
        Text(
          'Enter your email and we\'ll send you a password reset link.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted, height: 1.45),
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          enabled: !isLoading,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 28),
        AuthSubmitButton(label: 'Send reset link', isLoading: isLoading, onPressed: _sendResetEmail),
        if (_emailSent) ...[
          const SizedBox(height: 20),
          Text(
            'Check your email for the reset link.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.income),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => pushSlide(context, const ResetPasswordScreen()),
          child: const Text('I have my reset link'),
        ),
      ],
    );
  }
}
