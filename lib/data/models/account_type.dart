import 'package:json_annotation/json_annotation.dart';

enum AccountType {
  @JsonValue('bank')
  bank,
  @JsonValue('e_wallet')
  ewallet,
  @JsonValue('cash')
  cash;

  String get label => switch (this) {
        bank => 'Bank',
        ewallet => 'E-wallet',
        cash => 'Cash',
      };
}
