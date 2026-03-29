import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_the_spire/data/datasources/ollama_remote_datasource.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:11434'));
  try {
    final r = await dio.get('/api/version');
    debugPrint('✅ Ollama reachable: ${r.data}');

    final datasource = OllamaRemoteDatasource(dio: dio);
    final models = await datasource.fetchModels();
    debugPrint('Fetched models in main: ${models.length}');
  } catch (e) {
    debugPrint('❌ Ollama not reachable: $e');
    return;
  }

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
