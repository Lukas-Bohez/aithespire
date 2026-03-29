import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../providers/dio_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              initialValue: settings.ollamaBaseUrl,
              decoration: const InputDecoration(labelText: 'Ollama Base URL'),
              onChanged: (value) {
                notifier.update(settings.copyWith(ollamaBaseUrl: value));
                ref.invalidate(ollamaUrlProvider);
                ref.invalidate(dioProvider);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: settings.defaultModel,
              decoration: const InputDecoration(labelText: 'Default model'),
              onChanged: (value) =>
                  notifier.update(settings.copyWith(defaultModel: value)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: settings.defaultSystemPrompt,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Default system prompt',
              ),
              onChanged: (value) => notifier.update(
                settings.copyWith(defaultSystemPrompt: value),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Theme'),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (values) {
                if (values.isNotEmpty) {
                  notifier.update(settings.copyWith(themeMode: values.first));
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Font size'),
                Text('${settings.fontSize.toInt()}'),
              ],
            ),
            Slider(
              value: settings.fontSize,
              min: 12,
              max: 20,
              divisions: 8,
              label: settings.fontSize.toStringAsFixed(0),
              onChanged: (value) =>
                  notifier.update(settings.copyWith(fontSize: value)),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Stream responses'),
              value: settings.streamResponses,
              onChanged: (value) =>
                  notifier.update(settings.copyWith(streamResponses: value)),
            ),
            SwitchListTile(
              title: const Text('Save history'),
              value: settings.saveHistory,
              onChanged: (value) =>
                  notifier.update(settings.copyWith(saveHistory: value)),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                // TODO: clear history in storage
              },
              child: const Text('Clear all history'),
            ),
          ],
        ),
      ),
    );
  }
}
