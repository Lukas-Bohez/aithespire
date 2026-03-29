import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

class OllamaLanScanner {
  final Dio _dio;

  OllamaLanScanner([Dio? dio]) : _dio = dio ?? Dio();

  Future<List<String>> scanLocalNetwork() async {
    final results = <String>[];
    final subnets = ['192.168.1', '192.168.0', '10.0.0'];

    for (final subnet in subnets) {
      final futures = List.generate(255, (i) => _tryHost('$subnet.${i + 1}'));
      final found = await Future.wait(futures);
      results.addAll(found.whereType<String>());
    }

    return results;
  }

  Future<String?> _tryHost(String ip) async {
    try {
      final url = 'http://$ip:${AppConstants.ollamaDefaultUrl.split(':').last}${AppConstants.ollamaApiVersionPath}';
      final response = await _dio.get(
        url,
        options: Options(
          sendTimeout: const Duration(milliseconds: 500),
          receiveTimeout: const Duration(milliseconds: 500),
        ),
      );
      if (response.statusCode == 200) {
        return 'http://$ip:${AppConstants.ollamaDefaultUrl.split(':').last}';
      }
    } catch (_) {
      // ignore
    }
    return null;
  }
}
