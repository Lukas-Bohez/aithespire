import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/ollama_installer_service.dart';
import '../../data/datasources/ollama_remote_datasource.dart';

class OllamaStatusBanner extends StatefulWidget {
  const OllamaStatusBanner({super.key});

  @override
  State<OllamaStatusBanner> createState() => _OllamaStatusBannerState();
}

class _OllamaStatusBannerState extends State<OllamaStatusBanner> {
  final _installer = OllamaInstallerService();
  final _datasource = OllamaRemoteDatasource();
  bool _visible = true;
  bool _isConnecting = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final online = await _datasource.checkVersion();
      if (online && mounted) {
        setState(() {
          _visible = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Ollama connected')),
        );
      }
    });
  }

  Future<void> _retry() async {
    setState(() {
      _isConnecting = true;
    });
    final success = await _datasource.checkVersion();

    if (mounted) {
      setState(() {
        _isConnecting = false;
      });
      if (success) {
        setState(() {
          _visible = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Ollama connected')),
        );
      }
    }
  }

  Future<void> _startServer() async {
    setState(() {
      _isConnecting = true;
    });
    await _installer.startOllamaServer();
    await Future.delayed(const Duration(seconds: 3));
    await _retry();
  }

  Future<void> _install() async {
    setState(() {
      _isConnecting = true;
    });

    if (Theme.of(context).platform == TargetPlatform.windows) {
      await _installer.installOnWindows();
    } else if (Theme.of(context).platform == TargetPlatform.macOS) {
      await _installer.installOnMac();
    }

    await _retry();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Material(
      color: Colors.yellow[700],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('⚠ Ollama is not running.'),
            ),
            TextButton(
              onPressed: _isConnecting ? null : _install,
              child: _isConnecting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Install automatically'),
            ),
            TextButton(
              onPressed: _isConnecting ? null : _startServer,
              child: const Text('Start Ollama'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _visible = false;
                });
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }
}
