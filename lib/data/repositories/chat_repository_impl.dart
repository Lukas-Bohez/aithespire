import '../../data/datasources/local_datasource.dart';
import '../../data/datasources/ollama_remote_datasource.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final LocalDatasource localDatasource;
  final OllamaRemoteDatasource remoteDatasource;

  ChatRepositoryImpl({required this.localDatasource, required this.remoteDatasource});

  @override
  Future<ChatSession> createSession({
    required String model,
    String? systemPrompt,
  }) async {
    return localDatasource.createSession(model: model, systemPrompt: systemPrompt);
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    await localDatasource.deleteSession(sessionId);
  }

  @override
  Future<List<ChatSession>> getSessions() async {
    return localDatasource.getSessions();
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId) async {
    return localDatasource.getMessages(sessionId);
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
    return localDatasource.storeMessage(message);
  }
}

