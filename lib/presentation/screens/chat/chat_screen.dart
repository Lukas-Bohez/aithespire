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

    final messages = chatState.maybeWhen(data: (list) => list, orElse: () => <ChatMessage>[]);
    final isLoading = chatState is AsyncLoading;

    if (!_activeModel.isNotEmpty && settings.defaultModel.isNotEmpty) {
      _activeModel = settings.defaultModel;
    }

    final availableModels = modelsState.maybeWhen(data: (models) => models.map((m) => m.name).toList(), orElse: () => <String>[]);
    final hasTyping = messages.any((m) => m.isStreaming);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Select model', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...availableModels.map((model) {
                      return ListTile(
                        title: Text(model),
                        selected: model == currentModel,
                        onTap: () {
                          setState(() {
                            _activeModel = model;
                          });
                          ref.read(settingsProvider.notifier).updateDefaultModel(model);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3D3BF3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currentModel,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
            onPressed: () {
              ref.read(chatProvider.notifier).resetSession();
              _controller.clear();
              _scrollToBottom();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CustomPaint(
                            painter: _LargeSparkPainter(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('AIthespire', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Ask anything. Runs locally.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: [
                            'Explain quantum computing',
                            'Write me a Python script',
                            'What are you capable of?'
                          ].map((prompt) {
                            return ActionChip(
                              label: Text(prompt),
                              onPressed: () {
                                _controller.text = prompt;
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (hasTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (hasTyping && index == messages.length) {
                        return _TypingIndicator();
                      }
                      final msg = messages[index];
                      return MessageBubble(
                        message: msg,
                        onRetry: msg.isError
                            ? () => notifier.retryMessage(
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

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: Color(0xFF3D3BF3), shape: BoxShape.circle),
            child: const Center(child: Text('A', style: TextStyle(color: Colors.white, fontSize: 14))),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: const Color(0xFF3D3BF3), width: 3)),
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return FadeTransition(
                  opacity: Tween(begin: 0.3, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Interval(index * 0.2, 0.8 + index * 0.05, curve: Curves.easeInOut),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF3D3BF3), shape: BoxShape.circle),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeSparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3D3BF3);
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();
    path.moveTo(center.dx, 0);
    path.lineTo(center.dx + size.width * 0.18, center.dy - size.height * 0.06);
    path.lineTo(size.width, center.dy);
    path.lineTo(center.dx + size.width * 0.18, center.dy + size.height * 0.06);
    path.lineTo(center.dx, size.height);
    path.lineTo(center.dx - size.width * 0.18, center.dy + size.height * 0.06);
    path.lineTo(0, center.dy);
    path.lineTo(center.dx - size.width * 0.18, center.dy - size.height * 0.06);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

