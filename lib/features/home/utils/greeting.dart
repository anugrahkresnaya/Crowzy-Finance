/// "Good morning" until noon, "Good afternoon" until 6 pm, then "Good evening".
String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 18) return 'Good afternoon';
  return 'Good evening';
}

/// A first name to greet the user with, taken from the start of the email
/// address ("kaze.dev@example.com" becomes "Kaze"). Null when there is no
/// usable email.
String? friendlyName(String? email) {
  if (email == null) return null;
  final local = email.split('@').first;
  final first = local.split(RegExp(r'[._+\-]')).firstWhere((s) => s.isNotEmpty, orElse: () => '');
  if (first.isEmpty) return null;
  return first[0].toUpperCase() + first.substring(1);
}
