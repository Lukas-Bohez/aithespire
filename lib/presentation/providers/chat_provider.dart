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
  late final OllamaRemoteDatasource datasource;

  @override
  Future<List<ChatMessage>> build() async {
    datasource = ref.read(ollamaRemoteDatasourceProvider);
    return [];
  }

  Future<void> sendMessage({
    required String sessionId,
    required String model,
    required List<Map<String, dynamic>> messages,
    String? systemPrompt,
  }) async {
    state = const AsyncValue.loading();

    try {
      final stream = datasource.chatStream(
        model: model,
        messages: messages,
        systemPrompt: systemPrompt ?? AppConstants.defaultSystemPrompt,
      );
      final List<ChatMessage> collected = [];
      final buffer = StringBuffer();
      await for (final chunk in stream) {
        buffer.write(chunk);
        state = AsyncValue.data([
          ...collected,
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch,
            sessionId: sessionId,
            role: 'assistant',
            content: buffer.toString(),
            createdAt: DateTime.now(),
            isStreaming: true,
          ),
        ]);
      }
      final finalMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        sessionId: sessionId,
        role: 'assistant',
        content: buffer.toString(),
        createdAt: DateTime.now(),
        isStreaming: false,
      );
      collected.add(finalMessage);
      state = AsyncValue.data(collected);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        state = AsyncValue.error(
            Exception('Cannot reach Ollama. Is it running?'),
            StackTrace.current);
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final chatProvider = chatProviderProvider;
