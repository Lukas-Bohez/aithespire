import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../constants/app_constants.dart';

final Logger log = Logger('OllamaConnectionService');

enum AndroidOllamaMode { termux, ollamaServer, lan, notConfigured }

class OllamaConnectionService {
  final Dio _dio;
  final Future<String?> Function() getSavedOllamaUrl;

  OllamaConnectionService({
    Dio? dio,
    required this.getSavedOllamaUrl,
  }) : _dio = dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.ollamaDefaultUrl.replaceAll(RegExp(r'/+$'), ''),
              connectTimeout: AppConstants.connectTimeout,
              receiveTimeout: AppConstants.receiveTimeout,
            ),
          );

  Future<bool> _pingOllama(String url) async {
    final normalizedUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final pingUrl = Uri.parse(normalizedUrl)
        .resolve(AppConstants.ollamaApiVersionPath)
        .toString();

    log.info('Pinging Ollama at: $pingUrl');

    try {
      final response = await _dio.get(
        pingUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      );
      return response.statusCode == 200;
    } catch (e, st) {
      log.warning('Ping to Ollama failed', e, st);
      return false;
    }
  }

  Future<AndroidOllamaMode> detectAndroidMode() async {
    if (await _pingOllama(AppConstants.ollamaDefaultUrl)) {
      return AndroidOllamaMode.termux;
    }

    final savedUrl = await getSavedOllamaUrl();

    if (savedUrl != null &&
        savedUrl.isNotEmpty &&
        savedUrl != AppConstants.ollamaDefaultUrl &&
        await _pingOllama(savedUrl)) {
      return AndroidOllamaMode.lan;
    }

    return AndroidOllamaMode.notConfigured;
  }
}
