import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

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
              baseUrl: AppConstants.defaultOllamaUrl,
              connectTimeout:
                  const Duration(seconds: AppConstants.networkTimeoutConnectSeconds),
              receiveTimeout:
                  const Duration(seconds: AppConstants.networkTimeoutReceiveSeconds),
            ),
          );

  Future<bool> _pingOllama(String url) async {
    try {
      final response = await _dio.get(
        '$url/api/version',
        options: Options(
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<AndroidOllamaMode> detectAndroidMode() async {
    if (await _pingOllama(AppConstants.defaultOllamaUrl)) {
      return AndroidOllamaMode.termux;
    }

    final savedUrl = await getSavedOllamaUrl();

    if (savedUrl != null &&
        savedUrl.isNotEmpty &&
        savedUrl != AppConstants.defaultOllamaUrl &&
        await _pingOllama(savedUrl)) {
      return AndroidOllamaMode.lan;
    }

    return AndroidOllamaMode.notConfigured;
  }
}
