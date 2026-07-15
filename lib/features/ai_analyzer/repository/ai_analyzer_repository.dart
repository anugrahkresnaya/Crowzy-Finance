import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/ai_transaction_suggestion.dart';

class AiParseException implements Exception {
  const AiParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AiAnalyzerRepository {
  AiAnalyzerRepository(this._client);

  final SupabaseClient _client;

  Future<AiTransactionSuggestion> parseTransactionText(String text) async {
    final response = await _client.functions.invoke(
      'parse-transaction',
      body: {
        'text': text,
        'clientNow': DateTime.now().toIso8601String(),
      },
    );

    final data = response.data;
    if (data is! Map || data['ok'] != true) {
      final message = data is Map ? data['error'] as String? : null;
      throw AiParseException(message ?? 'Could not parse that transaction.');
    }

    return AiTransactionSuggestion.fromJson(
      Map<String, dynamic>.from(data['suggestion'] as Map),
    );
  }
}
