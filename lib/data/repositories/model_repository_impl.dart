import '../../data/datasources/ollama_remote_datasource.dart';
import '../../domain/entities/ollama_model.dart';
import '../../domain/repositories/model_repository.dart';

class ModelRepositoryImpl implements ModelRepository {
  final OllamaRemoteDatasource remoteDatasource;

  ModelRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<OllamaModel>> fetchModels() async {
    final result = await remoteDatasource.fetchModels();
    return result
        .map(
          (data) => OllamaModel(
            id: 0,
            name: data['name']?.toString() ?? '',
            tag: data['tag']?.toString() ?? '',
            size: data['size'] is int
                ? data['size']
                : int.tryParse(data['size']?.toString() ?? '0') ?? 0,
            installedAt: DateTime.now(),
            lastUsedAt: DateTime.now(),
          ),
        )
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getModelInfo(String modelName) async {
    return remoteDatasource.modelInfo(modelName);
  }

  @override
  Future<void> deleteModel(String modelName) async {
    return remoteDatasource.deleteModel(modelName);
  }

  @override
  Stream<Map<String, dynamic>> pullModel(String modelName) {
    return remoteDatasource.pullModelStream(modelName);
  }
}
