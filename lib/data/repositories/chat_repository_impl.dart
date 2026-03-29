import '../../data/datasources/ollama_remote_datasource.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final OllamaRemoteDatasource remoteDatasource;

  final List<ChatSession> _sessions = [];
  final Map<String, List<ChatMessage>> _messages = {};
  int _nextSessionId = 1;

  ChatRepositoryImpl(this.remoteDatasource);

  @override
  Future<ChatSession> createSession({
    required String model,
    String? systemPrompt,
  }) async {
    final now = DateTime.now();
    final session = ChatSession(
      id: _nextSessionId++,
      title: 'New conversation',
      model: model,
      systemPrompt: systemPrompt ?? '',
      createdAt: now,
      lastUpdatedAt: now,
    );
    _sessions.add(session);
    _messages[session.id.toString()] = [];
    return session;
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    _sessions.removeWhere((session) => session.id == sessionId);
    _messages.remove(sessionId.toString());
  }

  @override
  Future<List<ChatSession>> getSessions() async {
    return List<ChatSession>.from(_sessions);
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId) async {
    return List<ChatMessage>.from(_messages[sessionId] ?? []);
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
    final sessionMessages = _messages[message.sessionId.toString()];
    if (sessionMessages != null) {
      sessionMessages.add(message);
    } else {
      _messages[message.sessionId.toString()] = [message];
    }

    final sessionIndex = _sessions.indexWhere((s) => s.id == message.sessionId);
    if (sessionIndex != -1) {
      final session = _sessions[sessionIndex];
      _sessions[sessionIndex] = session.copyWith(lastUpdatedAt: DateTime.now());
    }

    return message;
  }
}

