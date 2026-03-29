import 'package:isar/isar.dart';

import '../../domain/entities/chat_session.dart';

part 'chat_session_model.g.dart';

@collection
class ChatSessionModel {
  Id id = Isar.autoIncrement;

  late String title;

  late String model;

  late String systemPrompt;

  late DateTime createdAt;

  late DateTime lastUpdatedAt;

  bool pinned = false;

  int messageCount = 0;

  ChatSession toEntity() {
    return ChatSession(
      id: id,
      title: title,
      model: model,
      systemPrompt: systemPrompt,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt,
      pinned: pinned,
      messageCount: messageCount,
    );
  }

  static ChatSessionModel fromEntity(ChatSession entity) {
    return ChatSessionModel()
      ..id = entity.id
      ..title = entity.title
      ..model = entity.model
      ..systemPrompt = entity.systemPrompt
      ..createdAt = entity.createdAt
      ..lastUpdatedAt = entity.lastUpdatedAt
      ..pinned = entity.pinned
      ..messageCount = entity.messageCount;
  }
}
