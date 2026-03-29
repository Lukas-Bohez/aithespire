class OllamaModel {
  final int id;
  final String name;
  final String tag;
  final int size;
  final DateTime installedAt;
  final DateTime lastUsedAt;

  OllamaModel({
    required this.id,
    required this.name,
    required this.tag,
    required this.size,
    required this.installedAt,
    required this.lastUsedAt,
  });

  OllamaModel copyWith({
    int? id,
    String? name,
    String? tag,
    int? size,
    DateTime? installedAt,
    DateTime? lastUsedAt,
  }) {
    return OllamaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      size: size ?? this.size,
      installedAt: installedAt ?? this.installedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }
}
