class ChatMessage {
  final int id;
  final String sessionId;
  final String role;
  final String content;
  final DateTime createdAt;
  final bool isStreaming;
  final bool isError;
  final String? retryContent;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isStreaming = false,
    this.isError = false,
    this.retryContent,
  });

  ChatMessage copyWith({
    int? id,
    String? sessionId,
    String? role,
    String? content,
    DateTime? createdAt,
    bool? isStreaming,
    bool? isError,
    String? retryContent,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
      isError: isError ?? this.isError,
      retryContent: retryContent ?? this.retryContent,
    );
  }
}
