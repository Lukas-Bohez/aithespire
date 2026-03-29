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
    final background = isUser
        ? Theme.of(context).colorScheme.surfaceVariant
        : Colors.transparent;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * AppConstants.maxBubbleWidthFraction,
          ),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: message.isError ? Colors.red.shade50 : background,
            borderRadius: BorderRadius.circular(14),
            border: message.isError
                ? Border.all(color: Colors.red.shade300)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Icon(Icons.smart_toy, size: 20),
                ),
              MarkdownMessage(content: message.content),
              if (message.isError && onRetry != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
