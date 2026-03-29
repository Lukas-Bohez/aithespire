import '../../data/datasources/ollama_remote_datasource.dart';
import '../../domain/entities/ollama_model.dart';
import '../../domain/repositories/model_repository.dart';

class ModelRepositoryImpl implements ModelRepository {
  final OllamaRemoteDatasource remoteDatasource;
  final Map<String, OllamaModel> _cache = {};

  ModelRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<OllamaModel>> fetchModels() async {
    final result = await remoteDatasource.fetchModels();
    final models = result
        .map(
          (data) {
            final name = data['name']?.toString() ?? '';
            final tag = data['tag']?.toString() ?? '';
            final size = data['size'] is int
                ? data['size'] as int
                : int.tryParse(data['size']?.toString() ?? '0') ?? 0;
            final now = DateTime.now();
            return OllamaModel(
              id: _cache.containsKey(name) ? _cache[name]!.id : _cache.length + 1,
              name: name,
              tag: tag,
              size: size,
              installedAt: now,
              lastUsedAt: now,
            );
          },
        )
        .toList();
    for (final model in models) {
      _cache[model.name] = model;
    }
    return models;
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
