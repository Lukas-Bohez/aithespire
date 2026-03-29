import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/model_repository_impl.dart';
import '../../presentation/providers/dio_provider.dart';
import '../../domain/entities/ollama_model.dart';

part 'models_provider.g.dart';

@riverpod
class ModelsProvider extends _$ModelsProvider {
  late final ModelRepositoryImpl repository;

  @override
  Future<List<OllamaModel>> build() async {
    repository = ModelRepositoryImpl(ref.read(ollamaRemoteDatasourceProvider));
    try {
      return await repository.fetchModels();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Cannot reach Ollama. Is it running?');
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final models = await repository.fetchModels();
      state = AsyncValue.data(models);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        state = AsyncValue.error(
            Exception('Cannot reach Ollama. Is it running?'),
            StackTrace.current);
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Stream<Map<String, dynamic>> pullModel(String modelName) {
    return repository.pullModel(modelName);
  }

  Future<void> deleteModel(String modelName) async {
    await repository.deleteModel(modelName);
    await refresh();
  }
}

final modelsProvider = modelsProviderProvider;
