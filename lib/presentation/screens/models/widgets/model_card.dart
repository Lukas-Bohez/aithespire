import 'package:flutter/material.dart';
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
                FilledButton(onPressed: () {}, child: const Text('Chat')),
                OutlinedButton(onPressed: () {}, child: const Text('Info')),
                TextButton(onPressed: () {}, child: const Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
