import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/ollama_remote_datasource.dart';
import '../../presentation/providers/dio_provider.dart';
import '../../domain/entities/chat_message.dart';

part 'chat_provider.g.dart';

@riverpod
class ChatProvider extends _$ChatProvider {
  @override
  Future<List<ChatMessage>> build() async {
    return [];
  }

  Future<void> sendMessage({
    required String sessionId,
    required String model,
    required List<Map<String, dynamic>> messages,
    String? systemPrompt,
  }) async {
    final existing = state.maybeWhen(data: (value) => value, orElse: () => <ChatMessage>[]);

    final userContent = messages
            .lastWhere((m) => m['role'] == 'user', orElse: () => <String, dynamic>{})['content']
            ?.toString() ??
        '';

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      sessionId: sessionId,
      role: 'user',
      content: userContent,
      createdAt: DateTime.now(),
      isStreaming: false,
    );

    state = AsyncValue.data([...existing, userMessage]);

    final buffer = StringBuffer();
    ChatMessage assistantMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch + 1,
      sessionId: sessionId,
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    state = AsyncValue.data([...existing, userMessage, assistantMessage]);

    try {
      final dio = ref.read(dioProvider);
      final datasource = OllamaRemoteDatasource(dio: dio);
      final stream = await datasource.chatStream(
        model: model,
        messages: messages,
        systemPrompt: systemPrompt ?? AppConstants.defaultSystemPrompt,
      );

      await for (final chunk in stream) {
        buffer.write(chunk);
        assistantMessage = assistantMessage.copyWith(
          content: buffer.toString(),
          isStreaming: true,
        );

        state = AsyncValue.data([...existing, userMessage, assistantMessage]);
      }

      assistantMessage = assistantMessage.copyWith(isStreaming: false);
      state = AsyncValue.data([...existing, userMessage, assistantMessage]);
    } on DioException catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch + 2,
        sessionId: sessionId,
        role: 'assistant',
        content: 'Send failed: ${e.message ?? 'unknown error'}',
        createdAt: DateTime.now(),
        isStreaming: false,
        isError: true,
        retryContent: userContent,
      );
      state = AsyncValue.data([...existing, userMessage, errorMessage]);
    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch + 2,
        sessionId: sessionId,
        role: 'assistant',
        content: 'Send failed: ${e.toString()}',
        createdAt: DateTime.now(),
        isStreaming: false,
        isError: true,
        retryContent: userContent,
      );
      state = AsyncValue.data([...existing, userMessage, errorMessage]);
    }
  }

  Future<void> retryMessage({
    required String sessionId,
    required String model,
    required String retryContent,
  }) async {
    await sendMessage(
      sessionId: sessionId,
      model: model,
      messages: [
        {'role': 'user', 'content': retryContent}
      ],
    );
  }
}

final chatProvider = chatProviderProvider;
