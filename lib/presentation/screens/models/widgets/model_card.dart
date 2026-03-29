import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/ollama_model.dart';

class ModelCard extends StatelessWidget {
  final OllamaModel model;

  const ModelCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(model.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(model.tag, style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () {
                    context.go('/chat', extra: model.name);
                  },
                  child: const Text('Chat'),
                ),
                OutlinedButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(model.name,
                                style:
                                    Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('Size: ${model.size}'),
                            Text('Tag: ${model.tag}'),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  child: const Text('Info'),
                ),
                TextButton(onPressed: () {}, child: const Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
