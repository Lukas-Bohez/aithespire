import 'package:isar/isar.dart';

import '../../domain/entities/ollama_model.dart';

part 'ollama_model_model.g.dart';

@collection
class OllamaModelModel {
  Id id = Isar.autoIncrement;

  late String name;

  late String tag;

  late int size;

  late DateTime installedAt;

  late DateTime lastUsedAt;

  OllamaModel toEntity() {
    return OllamaModel(
      id: id,
      name: name,
      tag: tag,
      size: size,
      installedAt: installedAt,
      lastUsedAt: lastUsedAt,
    );
  }

  static OllamaModelModel fromEntity(OllamaModel entity) {
    return OllamaModelModel()
      ..id = entity.id
      ..name = entity.name
      ..tag = entity.tag
      ..size = entity.size
      ..installedAt = entity.installedAt
      ..lastUsedAt = entity.lastUsedAt;
  }
}
