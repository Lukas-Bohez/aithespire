import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/app_database.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/ollama_model.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final localDatasourceProvider = Provider<LocalDatasource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalDatasource(db);
});

class LocalDatasource {
  final AppDatabase _database;

  LocalDatasource(this._database);

  Future<ChatSession> createSession({
    required String model,
    String? systemPrompt,
  }) async {
    final entry = ChatSessionsCompanion.insert(
      title: 'New conversation',
      model: model,
      systemPrompt: systemPrompt ?? '',
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );
    final id = await _database.chatSessionDao.createSession(entry);
    return ChatSession(
      id: id,
      title: 'New conversation',
      model: model,
      systemPrompt: systemPrompt ?? '',
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
      pinned: false,
      messageCount: 0,
    );
  }

  Future<List<ChatSession>> getSessions() async {
    final rows = await _database.chatSessionDao.getAllSessions();
    return rows
        .map((row) => ChatSession(
              id: row.id,
              title: row.title,
              model: row.model,
              systemPrompt: row.systemPrompt,
              createdAt: row.createdAt,
              lastUpdatedAt: row.lastUpdatedAt,
              pinned: row.pinned,
              messageCount: row.messageCount,
            ))
        .toList();
  }

  Future<void> deleteSession(int sessionId) async {
    await _database.chatSessionDao.deleteSession(sessionId);
    await _database.chatMessageDao.deleteMessagesForSession(sessionId.toString());
  }

  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final rows = await _database.chatMessageDao.getMessagesForSession(sessionId);
    return rows
        .map((row) => ChatMessage(
              id: row.id,
              sessionId: row.sessionId,
              role: row.role,
              content: row.content,
              createdAt: row.createdAt,
              isStreaming: row.isStreaming,
            ))
        .toList();
  }

  Future<ChatMessage> storeMessage(ChatMessage message) async {
    final entry = ChatMessagesCompanion.insert(
      sessionId: message.sessionId,
      role: message.role,
      content: message.content,
      createdAt: message.createdAt,
      isStreaming: Value(message.isStreaming),
    );
    final id = await _database.chatMessageDao.createMessage(entry);
    return message.copyWith(id: id);
  }

  Future<List<OllamaModel>> getOllamaModels() async {
    final rows = await _database.ollamaModelDao.getAllModels();
    return rows
        .map((row) => OllamaModel(
              id: row.id,
              name: row.name,
              tag: row.tag,
              size: row.size,
              installedAt: row.installedAt,
              lastUsedAt: row.lastUsedAt,
            ))
        .toList();
  }

  Future<OllamaModel> createOllamaModel(OllamaModel model) async {
    final entry = OllamaModelsCompanion.insert(
      name: model.name,
      tag: model.tag,
      size: model.size,
      installedAt: model.installedAt,
      lastUsedAt: model.lastUsedAt,
    );
    final id = await _database.ollamaModelDao.createOllamaModel(entry);
    return model.copyWith(id: id);
  }
}
