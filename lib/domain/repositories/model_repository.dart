import '../entities/ollama_model.dart';

abstract class ModelRepository {
  Future<List<OllamaModel>> fetchModels();
  Future<Map<String, dynamic>> getModelInfo(String modelName);
  Future<void> deleteModel(String modelName);
  Stream<Map<String, dynamic>> pullModel(String modelName);
}
