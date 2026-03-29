import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import '../models/chat_message_model.dart';
import '../models/chat_session_model.dart';
import '../models/ollama_model_model.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/aithespire.db');
    return NativeDatabase(file);
  });
}

@DriftDatabase(
  tables: [ChatSessions, ChatMessages, OllamaModels],
  daos: [ChatSessionDao, ChatMessageDao, OllamaModelDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

@DriftAccessor(tables: [ChatSessions])
class ChatSessionDao extends DatabaseAccessor<AppDatabase> with _$ChatSessionDaoMixin {
  ChatSessionDao(AppDatabase db) : super(db);

  Future<int> createSession(ChatSessionsCompanion entry) => into(chatSessions).insert(entry);
  Future<List<ChatSessionModel>> getAllSessions() => select(chatSessions).get();
  Future<ChatSessionModel?> getById(int id) => (select(chatSessions)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  Future<bool> updateSession(ChatSessionsCompanion entry) => update(chatSessions).replace(entry);
  Future<int> deleteSession(int id) => (delete(chatSessions)..where((tbl) => tbl.id.equals(id))).go();
}

@DriftAccessor(tables: [ChatMessages])
class ChatMessageDao extends DatabaseAccessor<AppDatabase> with _$ChatMessageDaoMixin {
  ChatMessageDao(AppDatabase db) : super(db);

  Future<int> createMessage(ChatMessagesCompanion entry) => into(chatMessages).insert(entry);
  Future<List<ChatMessageModel>> getAllMessages() => select(chatMessages).get();
  Future<List<ChatMessageModel>> getMessagesForSession(String sessionId) =>
      (select(chatMessages)..where((tbl) => tbl.sessionId.equals(sessionId))).get();
  Future<int> deleteMessagesForSession(String sessionId) =>
      (delete(chatMessages)..where((tbl) => tbl.sessionId.equals(sessionId))).go();
  Future<int> deleteMessage(int id) =>
      (delete(chatMessages)..where((tbl) => tbl.id.equals(id))).go();
}

@DriftAccessor(tables: [OllamaModels])
class OllamaModelDao extends DatabaseAccessor<AppDatabase> with _$OllamaModelDaoMixin {
  OllamaModelDao(AppDatabase db) : super(db);

  Future<int> createOllamaModel(OllamaModelsCompanion entry) => into(ollamaModels).insert(entry);
  Future<List<OllamaModelModel>> getAllModels() => select(ollamaModels).get();
  Future<int> deleteOllamaModel(int id) => (delete(ollamaModels)..where((tbl) => tbl.id.equals(id))).go();
}
