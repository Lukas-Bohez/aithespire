class ChatSession {
  final int id;
  final String title;
  final String model;
  final String systemPrompt;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final bool pinned;
  final int messageCount;

  ChatSession({
    required this.id,
    required this.title,
    required this.model,
    required this.systemPrompt,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.pinned = false,
    this.messageCount = 0,
  });

  ChatSession copyWith({
    int? id,
    String? title,
    String? model,
    String? systemPrompt,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    bool? pinned,
    int? messageCount,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      model: model ?? this.model,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      pinned: pinned ?? this.pinned,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}
