import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/ollama_remote_datasource.dart';

final ollamaUrlProvider = StateProvider<String>((ref) {
  return AppConstants.ollamaDefaultUrl;
});

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(ollamaUrlProvider).trim();
  final normalizedUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
  return Dio(BaseOptions(
    baseUrl: normalizedUrl,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
  ));
});

final ollamaRemoteDatasourceProvider = Provider<OllamaRemoteDatasource>((ref) {
  return OllamaRemoteDatasource(dio: ref.watch(dioProvider));
});
