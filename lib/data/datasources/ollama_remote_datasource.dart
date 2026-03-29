import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';

class OllamaRemoteDatasource {
  OllamaRemoteDatasource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<bool> checkVersion() async {
    try {
      final response = await _dio.get(AppConstants.ollamaApiVersionPath);
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return false;
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchModels() async {
    final response = await _dio.get(AppConstants.ollamaApiTagsPath);
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data);
    }
    throw DioError(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  Future<Map<String, dynamic>> modelInfo(String modelName) async {
    final response = await _dio
        .post(AppConstants.ollamaApiShowPath, data: {'model': modelName});
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    throw DioError(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  Future<void> deleteModel(String modelName) async {
    final response = await _dio.delete(
      AppConstants.ollamaApiDeletePath,
      data: {'model': modelName},
    );
    if (response.statusCode != 200) {
      throw DioError(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  Stream<Map<String, dynamic>> pullModelStream(String modelName) async* {
    final response = await _dio.post(
      AppConstants.ollamaApiPullPath,
      data: {'model': modelName},
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in stream) {
      if (line.trim().isEmpty) continue;
      try {
        final parsed = json.decode(line);
        if (parsed is Map<String, dynamic>) {
          yield parsed;
        }
      } catch (_) {
        // Skip malformed lines
      }
    }
  }

  Stream<String> chatStream({
    required String model,
    required List<Map<String, dynamic>> messages,
    String? systemPrompt,
  }) async* {
    final body = {
      'model': model,
      'messages': messages,
      if (systemPrompt != null) 'system': systemPrompt,
      'stream': true,
    };
    final response = await _dio.post(
      AppConstants.ollamaApiChatPath,
      data: body,
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in stream) {
      if (line.trim().isEmpty) continue;
      try {
        final event = json.decode(line);
        if (event is Map<String, dynamic>) {
          final message = event['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('content')) {
            yield message['content']?.toString() ?? '';
          }
          if (event['done'] == true) {
            break;
          }
        }
      } catch (_) {
        // ignore malformed chunks
      }
    }
  }
}
