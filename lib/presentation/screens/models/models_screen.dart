import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/models_provider.dart';
import '../../providers/dio_provider.dart';
import '../../providers/settings_provider.dart';
import '../../../domain/entities/ollama_model.dart';

class ModelsScreen extends ConsumerStatefulWidget {
  const ModelsScreen({super.key});

  @override
  ConsumerState<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends ConsumerState<ModelsScreen> {
  final _pullController = TextEditingController();
  String? _selectedModelName;
  bool _showPullPanel = false;
  bool _isPulling = false;
  double _pullProgress = 0;
  String _pullInfo = '';
  CancelToken? _cancelToken;

  final _suggestedModels = ['tinyllama', 'llama3.2:1b', 'phi3:mini', 'gemma2:2b'];

  @override
  void dispose() {
    _pullController.dispose();
    super.dispose();
  }

  void _selectModel(String modelName) {
    setState(() {
      _selectedModelName = modelName;
      _showPullPanel = false;
    });
    ref.read(settingsProvider.notifier).updateDefaultModel(modelName);
  }

  Future<void> _pullModel(String modelName) async {
    final datasource = ref.read(ollamaRemoteDatasourceProvider);
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    setState(() {
      _isPulling = true;
      _pullProgress = 0;
      _pullInfo = 'Starting pull...';
    });

    try {
      await for (final event in datasource.pullModelStream(modelName, cancelToken: _cancelToken)) {
        if (_cancelToken?.isCancelled ?? false) break;

        if (event['status'] == 'downloading') {
          final total = (event['total'] as num?)?.toDouble() ?? 0;
          final completed = (event['completed'] as num?)?.toDouble() ?? 0;
          setState(() {
            _pullProgress = total <= 0 ? 0 : (completed / total).clamp(0.0, 1.0);
            _pullInfo = 'Downloading ${(100 * _pullProgress).toStringAsFixed(1)}%';
          });
        } else if (event['status'] == 'success') {
          setState(() {
            _pullProgress = 1.0;
            _pullInfo = 'Completed';
          });
        } else {
          setState(() {
            _pullInfo = event['status']?.toString() ?? '';
          });
        }
      }
      if (!(_cancelToken?.isCancelled ?? false)) {
        ref.refresh(modelsProvider);
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        setState(() {
          _pullInfo = 'Pull canceled';
        });
      } else {
        setState(() {
          _pullInfo = 'Pull failed: ${e.message}';
        });
      }
    } catch (e) {
      setState(() {
        _pullInfo = 'Pull failed: $e';
      });
    } finally {
      setState(() {
        _isPulling = false;
      });
    }
  }

  Future<void> _deleteModel(String modelName) async {
    final datasource = ref.read(ollamaRemoteDatasourceProvider);
    try {
      await datasource.deleteModel(modelName);
      ref.refresh(modelsProvider);
      if (_selectedModelName == modelName) {
        _selectedModelName = null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final modelsState = ref.watch(modelsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Models')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: modelsState.when(
          data: (models) {
            if (_selectedModelName == null || !_selectedModelName.toString().isNotEmpty) {
              _selectedModelName = models.firstWhere(
                (model) => model.name == settings.defaultModel,
                orElse: () => models.isNotEmpty ? models.first : OllamaModel(id: 0, name: '', tag: '', size: 0, installedAt: DateTime.now(), lastUsedAt: DateTime.now()),
              ).name;
            }

            final selectedModel = models.firstWhere(
              (m) => m.name == _selectedModelName,
              orElse: () => models.isNotEmpty
                  ? models.first
                  : OllamaModel(id: 0, name: '', tag: '', size: 0, installedAt: DateTime.now(), lastUsedAt: DateTime.now()),
            );

            final hasModel = models.isNotEmpty && selectedModel.name.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: models.map((model) {
                      final isSelected = model.name == selectedModel.name;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(model.name),
                          selected: isSelected,
                          onSelected: (_) => _selectModel(model.name),
                          selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                if (hasModel)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedModel.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Size: ${selectedModel.size}'),
                          const SizedBox(height: 4),
                          Chip(label: Text(selectedModel.tag.isNotEmpty ? selectedModel.tag : 'unknown tag')),
                        ],
                      ),
                    ),
                  )
                else
                  const Center(child: Text('No models installed.')),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      if (_showPullPanel) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _pullController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. llama3, phi3:mini, mistral',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _isPulling
                                  ? null
                                  : () {
                                      final name = _pullController.text.trim();
                                      if (name.isNotEmpty) {
                                        _pullModel(name);
                                      }
                                    },
                              child: const Text('Start Pull'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: _pullProgress),
                        const SizedBox(height: 4),
                        Text(_pullInfo),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isPulling
                                ? () {
                                    _cancelToken?.cancel();
                                    setState(() {
                                      _isPulling = false;
                                      _pullInfo = 'Canceled';
                                    });
                                  }
                                : () {
                                    setState(() {
                                      _showPullPanel = false;
                                    });
                                  },
                            child: Text(_isPulling ? 'Cancel' : 'Close'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _suggestedModels.map((model) {
                            return ActionChip(
                              label: Text(model),
                              onPressed: () {
                                setState(() {
                                  _pullController.text = model;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ]
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton(
                        onPressed: hasModel
                            ? () => context.go('/chat', extra: selectedModel.name)
                            : null,
                        child: const Text('Chat with this model'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _showPullPanel = !_showPullPanel;
                          });
                        },
                        child: const Text('Pull new model'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: hasModel
                            ? () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete model?'),
                                    content: Text('Delete ${selectedModel.name}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  await _deleteModel(selectedModel.name);
                                }
                              }
                            : null,
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete this model'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded,
                    size: 48, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 16),
                Text('Ollama is not running', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Start Ollama on your machine to see your models.',
                    style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
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
    );
  }
}
