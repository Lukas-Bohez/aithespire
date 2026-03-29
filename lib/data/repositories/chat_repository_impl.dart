import '../../data/datasources/ollama_remote_datasource.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final OllamaRemoteDatasource remoteDatasource;

  ChatRepositoryImpl(this.remoteDatasource);

  @override
  Future<ChatSession> createSession({
    required String model,
    String? systemPrompt,
  }) async {
    final now = DateTime.now();
    return ChatSession(
      id: 0,
      title: 'New conversation',
      model: model,
      systemPrompt: systemPrompt ?? '',
      createdAt: now,
      lastUpdatedAt: now,
    );
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    // TODO: implement with Isar
    return;
  }

  @override
  Future<List<ChatSession>> getSessions() async {
    // TODO: implement with Isar
    return [];
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId) async {
    // TODO: implement with Isar
    return [];
  }

  @override
  Future<Stream<String>> sendMessage({
    required String sessionId,
    required String model,
    required List<Map<String, dynamic>> messages,
    String? systemPrompt,
  }) async {
    final stream = remoteDatasource.chatStream(
      model: model,
      messages: messages,
      systemPrompt: systemPrompt,
    );
    return stream;
  }

  @override
  Future<ChatMessage> storeMessage(ChatMessage message) async {
    // TODO: persist to Isar
    return message;
  }
}
