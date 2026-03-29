import '../entities/chat_message.dart';
import '../entities/chat_session.dart';

abstract class ChatRepository {
  Future<ChatSession> createSession({
    required String model,
    String? systemPrompt,
  });
  Future<void> deleteSession(int sessionId);
  Future<List<ChatSession>> getSessions();
  Future<ChatSession?> getSession(int sessionId);
  Future<List<ChatMessage>> getMessages(String sessionId);
  Future<void> updateSession({
    required int sessionId,
    String? title,
    DateTime? lastUpdatedAt,
    int? messageCount,
    bool? pinned,
  });
  Future<Stream<String>> sendMessage({
    required String sessionId,
    required String model,
    required List<Map<String, dynamic>> messages,
    String? systemPrompt,
  });
  Future<ChatMessage> storeMessage(ChatMessage message);
}
