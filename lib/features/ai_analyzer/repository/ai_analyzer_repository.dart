import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/ai_correction_intent.dart';
import '../../../data/models/ai_transaction_suggestion.dart';
import '../../../data/models/chat_message.dart';

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

  Future<String> askQuestion({
    required List<ChatMessage> history,
    required Map<String, dynamic> context,
  }) async {
    final response = await _client.functions.invoke(
      'chat-qa',
      body: {
        'messages': [
          for (final m in history) {'role': m.role.name, 'content': m.content},
        ],
        'context': context,
        'clientNow': DateTime.now().toIso8601String(),
      },
    );

    final data = response.data;
    if (data is! Map || data['ok'] != true) {
      final message = data is Map ? data['error'] as String? : null;
      throw AiParseException(message ?? 'Could not answer that.');
    }

    return data['answer'] as String;
  }

  Future<AiCorrectionIntent> parseCorrectionIntent(String text) async {
    final response = await _client.functions.invoke(
      'parse-correction',
      body: {
        'text': text,
        'clientNow': DateTime.now().toIso8601String(),
      },
    );

    final data = response.data;
    if (data is! Map || data['ok'] != true) {
      final message = data is Map ? data['error'] as String? : null;
      throw AiParseException(message ?? 'Could not process that.');
    }

    return AiCorrectionIntent.fromJson(
      Map<String, dynamic>.from(data['intent'] as Map),
    );
  }
}
