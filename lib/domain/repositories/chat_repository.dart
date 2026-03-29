import '../entities/chat_message.dart';
import '../entities/chat_session.dart';

abstract class ChatRepository {
  Future<ChatSession> createSession({
    required String model,
    String? systemPrompt,
  });
  Future<void> deleteSession(int sessionId);
  Future<List<ChatSession>> getSessions();
  Future<List<ChatMessage>> getMessages(String sessionId);
  Future<Stream<String>> sendMessage({
    required String sessionId,
    required String model,
    required List<Map<String, dynamic>> messages,
    String? systemPrompt,
  });
  Future<ChatMessage> storeMessage(ChatMessage message);
}
