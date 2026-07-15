import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

enum ChatRole { user, assistant }

/// Ephemeral, in-memory-only chat turn for the "Ask" Q&A tab. Never persisted
/// to Hive/Supabase — cleared when the screen is left or the app restarts.
@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required ChatRole role,
    required String content,
    @Default(false) bool isError,
  }) = _ChatMessage;
}
