import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/ollama_remote_datasource.dart';
import '../../presentation/providers/dio_provider.dart';
import '../../domain/entities/ollama_model.dart';

part 'models_provider.g.dart';

@riverpod
Future<List<OllamaModel>> models(ModelsRef ref) async {
  final dio = ref.watch(dioProvider);
  final datasource = OllamaRemoteDatasource(dio: dio);
  return datasource.fetchModels();
}

