import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/models_provider.dart';
import '../../providers/dio_provider.dart';
import 'widgets/model_card.dart';
import 'widgets/pull_progress_tile.dart';

class ModelsScreen extends ConsumerStatefulWidget {
  const ModelsScreen({super.key});

  @override
  ConsumerState<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends ConsumerState<ModelsScreen> {
  final _pullController = TextEditingController();
  double _progress = 0;
  String _progressInfo = '';

  @override
  void dispose() {
    _pullController.dispose();
    super.dispose();
  }

  Widget _recommendedModelTile(String model, String size, String ram) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(model, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Size: $size'),
          Text('RAM needed: $ram'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Recommended for mobile',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pullModel(String modelName) async {
    final datasource = ref.read(ollamaRemoteDatasourceProvider);
    await for (final event in datasource.pullModelStream(modelName)) {
      if (event['status'] == 'downloading') {
        final total = (event['total'] as num?)?.toDouble() ?? 0;
        final completed = (event['completed'] as num?)?.toDouble() ?? 0;
        setState(() {
          _progress = total <= 0 ? 0 : (completed / total).clamp(0.0, 1.0);
          _progressInfo =
              'Downloading ${(100 * _progress).toStringAsFixed(1)}%';
        });
      } else if (event['status'] == 'success') {
        setState(() {
          _progress = 1.0;
          _progressInfo = 'Completed';
        });
        ref.refresh(modelsProvider);
      } else {
        setState(() {
          _progressInfo = event['status']?.toString() ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelsState = ref.watch(modelsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Models')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _pullController,
              decoration: InputDecoration(
                labelText: 'Model name',
                hintText: 'e.g. llama3',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    final name = _pullController.text.trim();
                    if (name.isNotEmpty) {
                      _pullModel(name);
                    }
                  },
                ),
              ),
            ),
            if (_progress > 0 && _progress < 1)
              PullProgressTile(progress: _progress, info: _progressInfo),
            if (Platform.isAndroid) ...[
              const Text(
                'Recommended Android models',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _recommendedModelTile('tinyllama', '637 MB', '2 GB'),
                    _recommendedModelTile('llama3.2:1b', '1.3 GB', '3 GB'),
                    _recommendedModelTile('llama3.2:3b', '2.0 GB', '4 GB'),
                    _recommendedModelTile('phi3:mini', '2.3 GB', '4 GB'),
                    _recommendedModelTile('gemma2:2b', '1.6 GB', '3 GB'),
                    _recommendedModelTile('mistral:7b', '4.1 GB', '8 GB'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: modelsState.when(
                data: (models) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                        ),
                    itemCount: models.length,
                    itemBuilder: (context, index) {
                      final model = models[index];
                      return ModelCard(model: model);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 16),
                      Text('Ollama is not running',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Start Ollama on your machine to see your models.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => ref.refresh(modelsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Browse Models')),
          ],
        ),
      ),
    );
  }
}
