import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../providers/models_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int? sessionId;
  final String? initialModel;

  const ChatScreen({super.key, this.sessionId, this.initialModel});

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
    if (widget.sessionId != null) {
      Future.microtask(() => ref.read(chatProvider.notifier).loadSession(widget.sessionId!));
    }
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
    final modelsState = ref.watch(modelsProvider);
    final currentModel = _activeModel.isNotEmpty ? _activeModel : settings.defaultModel;

    final sessionId = widget.sessionId?.toString() ?? 'default';
    final messages = chatState.maybeWhen(data: (list) => list, orElse: () => <ChatMessage>[]);
    final isLoading = chatState is AsyncLoading;

    if (!_activeModel.isNotEmpty && settings.defaultModel.isNotEmpty) {
      _activeModel = settings.defaultModel;
    }

    final availableModels = modelsState.maybeWhen(data: (models) => models.map((m) => m.name).toList(), orElse: () => <String>[]);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Chat'),
            const SizedBox(width: 12),
            if (currentModel.isNotEmpty)
              PopupMenuButton<String>(
                tooltip: 'Select model',
                initialValue: currentModel,
                onSelected: (model) {
                  setState(() {
                    _activeModel = model;
                  });
                  ref.read(settingsProvider.notifier).updateDefaultModel(model);
                },
                itemBuilder: (context) {
                  if (availableModels.isEmpty) {
                    return [
                      const PopupMenuItem(value: '', child: Text('No models available')),
                    ];
                  }
                  return availableModels
                      .map(
                        (name) => PopupMenuItem(
                          value: name,
                          child: Text(name),
                        ),
                      )
                      .toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currentModel, style: const TextStyle(fontSize: 14)),
                      const Icon(Icons.expand_more, size: 16),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
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
                                  sessionId: sessionId,
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
                sessionId: sessionId,
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
