import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_text.dart';

/// Text field with its label set above it as a small letter-spaced caption,
/// rather than floating inside the border.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.enabled = true,
    this.prefixIcon,
    this.minLines,
    this.maxLines = 1,
    this.textInputAction,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;

  /// Example text shown inside the field while it is empty.
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool enabled;
  final IconData? prefixIcon;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(widget.label.toUpperCase(), style: AppText.eyebrow(context)),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: widget.label,
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscure,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            minLines: widget.isPassword ? 1 : widget.minLines,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
