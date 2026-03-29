import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/datasources/ollama_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../presentation/providers/dio_provider.dart';
import '../../domain/entities/chat_message.dart';

part 'chat_provider.g.dart';

@riverpod
class ChatProvider extends _$ChatProvider {
  late final ChatRepositoryImpl repository;
  int? currentSessionId;

  @override
  Future<List<ChatMessage>> build() async {
    repository = ChatRepositoryImpl(
      localDatasource: ref.read(localDatasourceProvider),
      remoteDatasource: OllamaRemoteDatasource(dio: ref.read(dioProvider)),
    );
    return [];
  }

  Future<void> loadSession(int sessionId) async {
    final messages = await repository.getMessages(sessionId.toString());
    currentSessionId = sessionId;
    state = AsyncValue.data(messages);
  }

  Future<void> sendMessage({
    required String sessionId,
    required String model,
    required List<Map<String, dynamic>> messages,
    String? systemPrompt,
  }) async {
    var sessionIdInt = int.tryParse(sessionId) ?? 0;
    if (sessionIdInt <= 0) {
      final newSession = await repository.createSession(model: model, systemPrompt: systemPrompt);
      sessionIdInt = newSession.id;
      currentSessionId = sessionIdInt;
    }

    final existing = state.maybeWhen(data: (value) => value, orElse: () => <ChatMessage>[]);

    final userContent = messages
            .lastWhere((m) => m['role'] == 'user', orElse: () => <String, dynamic>{})['content']
            ?.toString() ??
        '';

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      sessionId: sessionIdInt.toString(),
      role: 'user',
      content: userContent,
      createdAt: DateTime.now(),
      isStreaming: false,
    );

    // Save user message immediately
    await repository.storeMessage(userMessage);

    // Update session metadata
    final session = await repository.getSession(sessionIdInt);
    final updatedTitle = (session?.title == 'New conversation' || session?.title.isEmpty == true)
        ? (userContent.length <= 40 ? userContent : '${userContent.substring(0, 40)}...')
        : session?.title ?? 'New conversation';
    final nextMessageCount = (session?.messageCount ?? 0) + 1;
    await repository.updateSession(
      sessionId: sessionIdInt,
      title: updatedTitle,
      lastUpdatedAt: DateTime.now(),
      messageCount: nextMessageCount,
    );

    state = AsyncValue.data([...existing, userMessage]);

    final buffer = StringBuffer();
    ChatMessage assistantMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch + 1,
      sessionId: sessionIdInt.toString(),
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );

    state = AsyncValue.data([...existing, userMessage, assistantMessage]);

    try {
      final stream = await repository.sendMessage(
        sessionId: sessionIdInt.toString(),
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
      await repository.storeMessage(assistantMessage);

      // Update session on assistant completion
      await repository.updateSession(
        sessionId: sessionIdInt,
        lastUpdatedAt: DateTime.now(),
        messageCount: nextMessageCount + 1,
      );

      state = AsyncValue.data([...existing, userMessage, assistantMessage]);
    } on DioException catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch + 2,
        sessionId: sessionIdInt.toString(),
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
        sessionId: sessionIdInt.toString(),
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
