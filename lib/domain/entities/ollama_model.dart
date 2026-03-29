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

  factory OllamaModel.fromJson(Map<String, dynamic> json) {
    return OllamaModel(
      id: json['id'] is int ? json['id'] as int : 0,
      name: json['name']?.toString() ?? '',
      tag: json['tag']?.toString() ?? '',
      size: json['size'] is int
          ? json['size'] as int
          : int.tryParse(json['size']?.toString() ?? '0') ?? 0,
      installedAt: DateTime.tryParse(json['installedAt'] ?? '') ?? DateTime.now(),
      lastUsedAt: DateTime.tryParse(json['lastUsedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
