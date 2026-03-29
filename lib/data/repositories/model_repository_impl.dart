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
    for (final model in result) {
      _cache[model.name] = model;
    }
    return result;
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
