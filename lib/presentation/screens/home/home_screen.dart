import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_the_spire/presentation/providers/dio_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/models_provider.dart';
import '../../widgets/app_scaffold.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final _remote = ref.read(ollamaRemoteDatasourceProvider);

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final sessionsState = ref.watch(sessionProvider);
    final modelsState = ref.watch(modelsProvider);
    final greeting = _greeting();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('$greeting,', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('What would you like to explore today?', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _QuickCard(title: 'New Chat', icon: Icons.chat_bubble, onTap: () => context.go('/chat')),
              _QuickCard(title: 'Browse Models', icon: Icons.storage, onTap: () => context.go('/models')),
              _QuickCard(title: 'Recent Sessions', icon: Icons.history, onTap: () => context.go('/sessions')),
              _QuickCard(title: 'Settings', icon: Icons.settings, onTap: () => context.go('/settings')),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          sessionsState.when(
            data: (sessions) {
              final recent = sessions.toList()..sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
              if (recent.isEmpty) {
                return const Text('No sessions yet. Start a new chat.');
              }
              return Column(
                children: recent.take(3).map((session) {
                  return ListTile(
                    title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${session.messageCount} messages'),
                    onTap: () async {
                      await ref.read(chatProvider.notifier).loadSession(session.id);
                      context.go('/chat');
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Error loading sessions: $e'),
          ),
          const SizedBox(height: 24),
          FutureBuilder<bool>(
            future: _remote.checkVersion(),
            builder: (context, snapshot) {
              final isOnline = snapshot.data ?? false;
              final modelCount = modelsState.maybeWhen(data: (models) => models.length, orElse: () => 0);
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(isOnline ? Icons.check_circle : Icons.error, color: isOnline ? Colors.green : Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOnline ? 'Ollama online' : 'Ollama offline',
                              style: TextStyle(fontWeight: FontWeight.bold, color: isOnline ? Colors.green : Colors.orange),
                            ),
                            const SizedBox(height: 4),
                            Text(isOnline ? 'Models installed: $modelCount' : 'Start Ollama to use the app'),
                          ],
                        ),
                      ),
                      if (!isOnline)
                        FilledButton(
                          onPressed: () => _remote.checkVersion().then((available) {
                            if (available) {
                              setState(() {});
                            }
                          }),
                          child: const Text('Start Ollama'),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3D3BF3)),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
