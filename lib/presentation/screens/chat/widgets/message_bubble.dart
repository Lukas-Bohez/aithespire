import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/chat_message.dart';
import 'markdown_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;

  const MessageBubble({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final bubbleColor = isUser ? const Color(0xFF3D3BF3) : Colors.transparent;
    final textColor = isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleBorder = isUser
        ? BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: const Radius.circular(18),
            bottomRight: const Radius.circular(4),
          )
        : BorderRadius.circular(12);

    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (!isUser)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF3D3BF3),
              radius: 14,
              child: const Text('A', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.75 : 0.85),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: bubbleBorder,
            border: isUser
                ? null
                : Border(left: BorderSide(color: const Color(0xFF3D3BF3), width: 3)),
          ),
          child: DefaultTextStyle(
            style: TextStyle(color: textColor ?? Colors.black),
            child: MarkdownMessage(content: message.content),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: isUser ? 8 : 0, left: isUser ? 0 : 8),
          child: Text(
            '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
        if (message.isError && onRetry != null)
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ),
      ],
    );
  }
}
