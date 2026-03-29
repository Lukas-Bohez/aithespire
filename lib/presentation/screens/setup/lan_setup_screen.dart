import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_the_spire/core/utils/lan_scanner.dart';
import '../../providers/dio_provider.dart';

class LanSetupScreen extends ConsumerStatefulWidget {
  const LanSetupScreen({super.key});

  @override
  ConsumerState<LanSetupScreen> createState() => _LanSetupScreenState();
}

class _LanSetupScreenState extends ConsumerState<LanSetupScreen> {
  final TextEditingController _controller = TextEditingController();
  late final OllamaLanScanner _scanner;
  bool _isScanning = false;
  List<String> _discovered = [];

  @override
  void initState() {
    super.initState();
    _scanner = OllamaLanScanner(dio: ref.read(dioProvider));
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() {
      _isScanning = true;
      _discovered = [];
    });

    final discovered = await _scanner.scanLocalNetwork();

    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _discovered = discovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LAN Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Ollama LAN URL:'),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration:
                  const InputDecoration(hintText: 'http://192.168.1.100:11434'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final value = _controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.of(context).pop(value);
                }
              },
              child: const Text('Use URL'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Scan local network for Ollama'),
                ElevatedButton(
                  onPressed: _isScanning ? null : _scan,
                  child: _isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Scan'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_discovered.isEmpty)
              const Text('No devices found yet.')
            else ...[
              const Text('Discovered Ollama hosts:'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _discovered.length,
                  itemBuilder: (context, index) {
                    final host = _discovered[index];
                    return ListTile(
                      title: Text(host),
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(host);
                        },
                        child: const Text('Select'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
