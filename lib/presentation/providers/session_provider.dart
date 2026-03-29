import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/datasources/local_datasource.dart';
import '../../presentation/providers/dio_provider.dart';
import '../../domain/entities/chat_session.dart';

part 'session_provider.g.dart';

@riverpod
class SessionProvider extends _$SessionProvider {
  late final ChatRepositoryImpl repository;

  @override
  Future<List<ChatSession>> build() async {
    repository = ChatRepositoryImpl(
      localDatasource: ref.read(localDatasourceProvider),
      remoteDatasource: ref.read(ollamaRemoteDatasourceProvider),
    );
    return await repository.getSessions();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    try {
      final sessions = await repository.getSessions();
      state = AsyncValue.data(sessions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSession(int id) async {
    await repository.deleteSession(id);
    await reload();
  }

  Future<void> pinSession(int id, bool pinned) async {
    // TODO: implement pin with persistence
    await reload();
  }
}

final sessionProvider = sessionProviderProvider;
