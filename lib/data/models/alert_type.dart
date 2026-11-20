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
  // What the server sends when a category goes over its budget.
  @JsonValue('budget_exceeded')
  budgetExceeded,
  // The next three are not produced by the live server; they stay so an alert
  // of that kind, if one ever appears, still reads.
  @JsonValue('budget_limit')
  budgetLimit,
  @JsonValue('income_received')
  incomeReceived,
  @JsonValue('goal_on_track')
  goalOnTrack,
}

extension AlertTypeX on AlertType {
  /// Alerts that report something going well rather than something to watch.
  bool get isGoodNews => this == AlertType.incomeReceived || this == AlertType.goalOnTrack;
}
