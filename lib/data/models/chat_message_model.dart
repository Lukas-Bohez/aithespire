import 'package:isar/isar.dart';

import '../../domain/entities/chat_message.dart';

part 'chat_message_model.g.dart';

@collection
class ChatMessageModel {
  Id id = Isar.autoIncrement;

  late String sessionId;

  late String role;

  late String content;

  late DateTime createdAt;

  bool isStreaming = false;

  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      sessionId: sessionId,
      role: role,
      content: content,
      createdAt: createdAt,
      isStreaming: isStreaming,
    );
  }

  static ChatMessageModel fromEntity(ChatMessage entity) {
    return ChatMessageModel()
      ..id = entity.id
      ..sessionId = entity.sessionId
      ..role = entity.role
      ..content = entity.content
      ..createdAt = entity.createdAt
      ..isStreaming = entity.isStreaming;
  }
}
