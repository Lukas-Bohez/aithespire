import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/session_provider.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  String _search = '';

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
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search sessions...',
              ),
              onChanged: (value) => setState(() => _search = value.trim()),
            ),
          ),
          Expanded(
            child: sessionsState.when(
              data: (sessions) {
                final filtered = sessions
                    .where(
                      (s) =>
                          s.title.toLowerCase().contains(_search.toLowerCase()),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('No sessions yet.'));
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final session = filtered[index];
                    return Dismissible(
                      key: ValueKey(session.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => ref
                          .read(sessionProvider.notifier)
                          .deleteSession(session.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        title: Text(session.title),
                        subtitle: Text(
                          '${session.messageCount} messages • ${session.model}',
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            session.pinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                          ),
                          onPressed: () {
                            ref
                                .read(sessionProvider.notifier)
                                .pinSession(session.id, !session.pinned);
                          },
                        ),
                        onTap: () {
                          // TODO: navigate to chat details
                        },
                      ),
                    );
                  },
                );
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
