import 'package:flutter/material.dart';
import '../../../../domain/entities/chat_message.dart';
import 'markdown_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final background = isUser
        ? Theme.of(context).colorScheme.surfaceVariant
        : Colors.transparent;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.smart_toy, size: 20),
                ),
              Expanded(child: MarkdownMessage(content: message.content)),
            ],
          ),
        ),
      ],
    );
  }
}
