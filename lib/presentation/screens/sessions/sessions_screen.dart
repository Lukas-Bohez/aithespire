import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/chat_session.dart';
import '../../providers/chat_provider.dart';
import '../../providers/session_provider.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  String _search = '';

  String _humanizeDateTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  String _sectionLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays <= 7) return 'This week';
    if (diff.inDays <= 30) return 'This month';
    return 'Older';
  }

  @override
  Widget build(BuildContext context) {
    final sessionsState = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search sessions...',
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _search = ''),
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _search = value.trim()),
            ),
          ),
          Expanded(
            child: sessionsState.when(
              data: (sessions) {
                final filtered = sessions
                    .where((s) => s.title.toLowerCase().contains(_search.toLowerCase()))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('No conversations yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Start a new chat to see it here', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.go('/chat'),
                          child: const Text('Start chatting'),
                        ),
                      ],
                    ),
                  );
                }

                filtered.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
                final sections = <String, List<ChatSession>>{};
                for (final session in filtered) {
                  final label = _sectionLabel(session.lastUpdatedAt);
                  sections.putIfAbsent(label, () => []).add(session);
                }

                final widgets = <Widget>[];
                sections.forEach((label, group) {
                  widgets.add(Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                  ));
                  for (final session in group) {
                    widgets.add(Dismissible(
                      key: ValueKey(session.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete session?'),
                            content: const Text('This will permanently delete this conversation.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete != true) return false;

                        final success = await ref.read(sessionProvider.notifier).deleteSession(session.id);
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete session.')));
                          return false;
                        }

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.invalidate(sessionProvider);
                        });
                        return true;
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF3D3BF3),
                          child: Text(
                            session.title.isNotEmpty ? session.title[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          session.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(session.model, style: const TextStyle(fontSize: 11)),
                            ),
                            const SizedBox(width: 6),
                            Text('· ${_humanizeDateTime(session.lastUpdatedAt)}', style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 6),
                            Text('· ${session.messageCount} messages', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(session.pinned ? Icons.push_pin : Icons.push_pin_outlined),
                              onPressed: () {
                                ref.read(sessionProvider.notifier).pinSession(session.id, !session.pinned);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () async {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete session?'),
                                    content: const Text('This will permanently delete this conversation.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      FilledButton(
                                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (shouldDelete == true) {
                                  final success = await ref.read(sessionProvider.notifier).deleteSession(session.id);
                                  if (!success) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete session.')));
                                  }
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    ref.invalidate(sessionProvider);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          await ref.read(chatProvider.notifier).loadSession(session.id);
                          context.go('/chat');
                        },
                      ),
                    ));
                  }
                });

                return ListView(children: widgets);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
