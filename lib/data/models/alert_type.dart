import 'package:json_annotation/json_annotation.dart';

enum AlertType {
  @JsonValue('category_spike')
  categorySpike,
  @JsonValue('overspend')
  overspend,
  @JsonValue('wishlist_off_pace')
  wishlistOffPace,
  // Reserved for a possible future rule — not produced by evaluate_alerts()
  // today (see claude.md's Data Model vs. Trigger Conditions discrepancy).
  @JsonValue('income_drop')
  incomeDrop,
}
