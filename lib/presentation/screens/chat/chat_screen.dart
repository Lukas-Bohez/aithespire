import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initialModel;

  const ChatScreen({super.key, this.initialModel});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String _activeModel = '';

  @override
  void initState() {
    super.initState();
    _activeModel = widget.initialModel ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_activeModel.isEmpty) {
      final settings = ref.read(settingsProvider);
      _activeModel = settings.defaultModel;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    Future.microtask(() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final currentModel = _activeModel.isNotEmpty ? _activeModel : settings.defaultModel;

    final messages = chatState.maybeWhen(data: (list) => list, orElse: () => <ChatMessage>[]);
    final isLoading = chatState is AsyncLoading;

    if (!_activeModel.isNotEmpty && settings.defaultModel.isNotEmpty) {
      _activeModel = settings.defaultModel;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('Start the conversation.'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return MessageBubble(
                        message: msg,
                        onRetry: msg.isError
                            ? () => notifier.retryMessage(
                                  sessionId: 'default',
                                  model: currentModel,
                                  retryContent: msg.retryContent ?? '',
                                )
                            : null,
                      );
                    },
                  ),
          ),
          if (isLoading) const LinearProgressIndicator(),
          ChatInputBar(
            controller: _controller,
            onSend: () async {
              final text = _controller.text.trim();
              if (text.isEmpty) return;

              await notifier.sendMessage(
                sessionId: 'default',
                model: currentModel,
                messages: [
                  {'role': 'user', 'content': text},
                ],
              );
              _controller.clear();
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}
