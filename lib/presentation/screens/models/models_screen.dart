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

  final Map<String, List<Map<String, String>>> _suggestedModelsByCategory = {
    'POPULAR': [
      {'name': 'llama3.2:1b', 'size': '1.3 GB'},
      {'name': 'llama3.2:3b', 'size': '2.0 GB'},
      {'name': 'llama3:latest', 'size': '4.7 GB'},
      {'name': 'llama3.1:8b', 'size': '4.7 GB'},
      {'name': 'phi4', 'size': '9.1 GB'},
      {'name': 'phi3:mini', 'size': '2.3 GB'},
      {'name': 'gemma3:1b', 'size': '815 MB'},
      {'name': 'gemma3:4b', 'size': '2.5 GB'},
      {'name': 'mistral', 'size': '4.1 GB'},
      {'name': 'qwen2.5:7b', 'size': '4.7 GB'},
      {'name': 'deepseek-r1:7b', 'size': '4.7 GB'},
      {'name': 'tinyllama', 'size': '637 MB'},
    ],
    'UNCENSORED': [
      {'name': 'llama2-uncensored', 'size': '3.8 GB'},
      {'name': 'mistral-openorca', 'size': '4.1 GB'},
      {'name': 'dolphin-mixtral', 'size': '26 GB'},
      {'name': 'dolphin-llama3:8b', 'size': '4.7 GB'},
      {'name': 'dolphin-phi', 'size': '1.6 GB'},
      {'name': 'wizard-vicuna-uncensored', 'size': '3.8 GB'},
      {'name': 'wizardlm-uncensored', 'size': '3.8 GB'},
      {'name': 'nous-hermes2', 'size': '4.1 GB'},
      {'name': 'openhermes', 'size': '4.1 GB'},
      {'name': 'neural-chat', 'size': '4.1 GB'},
    ],
    'CODING': [
      {'name': 'qwen2.5-coder:1.5b', 'size': '986 MB'},
      {'name': 'qwen2.5-coder:7b', 'size': '4.7 GB'},
      {'name': 'deepseek-coder-v2', 'size': '8.9 GB'},
      {'name': 'codellama:7b', 'size': '3.8 GB'},
      {'name': 'starcoder2:3b', 'size': '1.7 GB'},
    ],
  };

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

  Color _familyColor(String name) {
    if (name.contains('llama')) return Colors.orange;
    if (name.contains('phi')) return Colors.blue;
    if (name.contains('gemma')) return Colors.green;
    if (name.contains('mistral')) return Colors.purple;
    if (name.contains('qwen')) return Colors.red;
    if (name.contains('dolphin')) return Colors.teal;
    return Colors.grey;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(1)} GB';
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
                const Text('Installed models', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (models.isEmpty)
                  Column(
                    children: [
                      Icon(Icons.storage_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text('No models installed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Pull a model below to get started', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                    ],
                  ),
                if (models.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
                      itemCount: models.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final model = models[idx];
                        final isSelected = model.name == selectedModel.name;
                        final family = model.name.toLowerCase();
                        final color = _familyColor(family);
                        return Container(
                          decoration: isSelected
                              ? BoxDecoration(
                                  border: Border(left: BorderSide(color: const Color(0xFF3D3BF3), width: 4)),
                                  color: Colors.grey.shade50,
                                )
                              : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color,
                              child: const Icon(Icons.storage, color: Colors.white),
                            ),
                            title: Text(model.name, style: const TextStyle(fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis)),
                            subtitle: Text('${_formatSize(model.size)}'),
                            trailing: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                FilledButton(
                                  onPressed: () => context.go('/chat', extra: model.name),
                                  child: const Text('Chat'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete model?'),
                                        content: Text('Delete ${model.name}?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await _deleteModel(model.name);
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () => _selectModel(model.name),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                const Text('Add a model', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pullController,
                        decoration: const InputDecoration(
                          hintText: 'Model name e.g. llama3, phi4',
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
                      child: const Text('Pull'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: _isPulling ? _pullProgress : null),
                const SizedBox(height: 4),
                Text(_pullInfo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestedModelsByCategory.entries.expand((entry) {
                    final category = entry.key;
                    final categoryModels = entry.value;
                    return [
                      Chip(label: Text(category)),
                      ...categoryModels.take(3).map((m) {
                        final name = m['name']!;
                        return ActionChip(
                          label: Text(name),
                          onPressed: () => setState(() {
                            _pullController.text = name;
                          }),
                        );
                      }),
                    ];
                  }).toList(),
                ),
                const SizedBox(height: 16),
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
