import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../providers/dio_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _initialized = false;
  late String _ollamaUrl;
  late String _defaultModel;
  late String _defaultSystemPrompt;
  late ThemeMode _themeMode;
  late double _fontSize;
  late bool _streamResponses;
  late bool _saveHistory;
  bool _showTimestamps = true;
  bool _isTesting = false;
  bool _isConnected = false;

  final _urlController = TextEditingController();
  final _defaultModelController = TextEditingController();
  final _promptController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _defaultModelController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isTesting = true;
    });
    final datasource = ref.read(ollamaRemoteDatasourceProvider);
    final success = await datasource.checkVersion();
    setState(() {
      _isConnected = success;
      _isTesting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Ollama connection successful' : 'Ollama offline')),
    );
  }

  void _saveSettings() {
    final notifier = ref.read(settingsProvider.notifier);
    final current = ref.read(settingsProvider);
    notifier.update(current.copyWith(
      ollamaBaseUrl: _ollamaUrl,
      defaultModel: _defaultModel,
      defaultSystemPrompt: _defaultSystemPrompt,
      themeMode: _themeMode,
      fontSize: _fontSize,
      streamResponses: _streamResponses,
      saveHistory: _saveHistory,
    ));
    ref.invalidate(ollamaUrlProvider);
    ref.invalidate(dioProvider);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    if (!_initialized) {
      _ollamaUrl = settings.ollamaBaseUrl;
      _defaultModel = settings.defaultModel;
      _defaultSystemPrompt = settings.defaultSystemPrompt;
      _themeMode = settings.themeMode;
      _fontSize = settings.fontSize;
      _streamResponses = settings.streamResponses;
      _saveHistory = settings.saveHistory;
      _urlController.text = _ollamaUrl;
      _defaultModelController.text = _defaultModel;
      _promptController.text = _defaultSystemPrompt;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Connection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(labelText: 'Ollama URL'),
                    onChanged: (value) {
                      _ollamaUrl = value;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_isConnected ? 'Connected' : 'Disconnected', style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      FilledButton(
                        onPressed: _isTesting ? null : _checkConnection,
                        child: _isTesting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Test connection'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _saveSettings,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.light, label: Icon(Icons.wb_sunny)),
                      ButtonSegment(value: ThemeMode.dark, label: Icon(Icons.nightlight_round)),
                      ButtonSegment(value: ThemeMode.system, label: Icon(Icons.phone_android)),
                    ],
                    selected: {_themeMode},
                    onSelectionChanged: (values) {
                      if (values.isNotEmpty) {
                        setState(() => _themeMode = values.first);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Font size'),
                      Text('${_fontSize.toInt()}'),
                    ],
                  ),
                  Slider(
                    value: _fontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    label: _fontSize.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() => _fontSize = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('The quick brown fox jumps over the lazy dog', style: TextStyle(fontSize: _fontSize)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      Colors.indigo,
                      Colors.purple,
                      Colors.teal,
                      Colors.green,
                      Colors.orange,
                      Colors.red,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          // optional accent color application
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chat defaults', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _defaultModelController,
                    decoration: const InputDecoration(labelText: 'Default model'),
                    onChanged: (value) => _defaultModel = value,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _promptController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Default system prompt'),
                    onChanged: (value) => _defaultSystemPrompt = value,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Stream responses'),
                    value: _streamResponses,
                    onChanged: (v) => setState(() => _streamResponses = v),
                  ),
                  SwitchListTile(
                    title: const Text('Show timestamps'),
                    value: _showTimestamps,
                    onChanged: (v) => setState(() => _showTimestamps = v),
                  ),
                ],
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Save history'),
                    value: _saveHistory,
                    onChanged: (v) => setState(() => _saveHistory = v),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported chats (stub)')));
                    },
                    child: const Text('Export all chats'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear all history'),
                          content: const Text('This will delete all conversations. Continue?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        // TODO: clear history in DB
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All history cleared (stub)')));
                      }
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Clear all history'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
