import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/entrance.dart';

/// Shared frame for the sign-in flow: a centred, scrollable form. With [brand]
/// it opens with the monogram, name and tagline (the sign-in screen); without
/// it, the screen gets a plain app bar showing [title].
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.formKey,
    required this.children,
    this.title,
    this.brand = false,
  }) : assert(brand || title != null, 'A screen without the brand header needs a title');

  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final String? title;
  final bool brand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: brand ? null : AppBar(title: Text(title!)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (brand) ...[const _Brand(), const SizedBox(height: 48)],
                  ...children,
                ],
              ).entrance(context, duration: AppMotion.slow),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.brassOutline),
          ),
          child: Text('C', style: AppText.amount(context, size: 38, color: AppColors.brass)),
        ),
        const SizedBox(height: 20),
        Text(
          'Crowzy Finance',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 40),
        ),
        const SizedBox(height: 6),
        Text(
          'YOUR MONEY, IN ORDER',
          style: AppText.eyebrow(context).copyWith(letterSpacing: 11 * 0.22),
        ),
      ],
    );
  }
}

/// The primary button of an auth form, showing a spinner while [isLoading].
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
