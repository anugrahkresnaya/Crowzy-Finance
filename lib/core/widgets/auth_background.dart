import 'package:flutter/material.dart';

/// Placeholder wrapper for the auth screens. The redesign drops the old violet
/// glows, so this now just returns [child]; it goes away when the auth screens
/// are rebuilt to the new sign-in design.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
