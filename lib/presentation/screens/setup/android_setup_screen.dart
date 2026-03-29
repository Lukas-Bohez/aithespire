import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AndroidSetupScreen extends StatelessWidget {
  const AndroidSetupScreen({super.key});

  static const _ollamaServerUrl =
      'https://github.com/sunshine0523/OllamaServer/releases/latest';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // ignore failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup AIthespire')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Choose your Ollama setup method',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  return GridView.count(
                    crossAxisCount: isWide ? 3 : 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildCard(
                        context,
                        title: 'Use on this device',
                        subtitle: 'Termux setup',
                        isPrimary: true,
                        description:
                            'Install Termux and run ollama on-device (recommended).',
                        actionLabel: 'Start Termux Wizard',
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed('/setup/termux');
                        },
                      ),
                      _buildCard(
                        context,
                        title: 'Use OllamaServer',
                        subtitle: 'No terminal needed',
                        description:
                            'Download the OllamaServer APK for one-tap startup.',
                        actionLabel: 'Download APK',
                        onTap: () {
                          _openUrl(_ollamaServerUrl);
                        },
                      ),
                      _buildCard(
                        context,
                        title: 'Connect to my PC',
                        subtitle: 'LAN fallback',
                        description:
                            'Use a remote PC running Ollama with local network URL.',
                        actionLabel: 'Enter LAN URL',
                        onTap: () {
                          Navigator.of(context).pushNamed('/setup/lan');
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String actionLabel,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Card(
      elevation: isPrimary ? 6 : 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isPrimary ? Colors.blue : Colors.grey.shade300,
          width: isPrimary ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Expanded(child: Text(description)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onTap, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
