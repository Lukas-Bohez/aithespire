import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class OllamaInstallerService {
  Future<bool> isOllamaInstalled() async {
    try {
      final result = await Process.run('ollama', ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<void> installOnWindows() async {
    try {
      final result = await Process.run(
        'winget',
        [
          'install',
          '--id',
          'Ollama.Ollama',
          '-e',
          '--silent',
          '--accept-package-agreements',
          '--accept-source-agreements',
        ],
        runInShell: true,
      );
      if (result.exitCode == 0) {
        return;
      }
    } catch (_) {}

    await launchUrl(Uri.parse('https://ollama.com/download/windows'));
  }

  Future<void> installOnMac() async {
    try {
      final result = await Process.run('brew', ['install', 'ollama']);
      if (result.exitCode == 0) {
        await Process.run('brew', ['services', 'start', 'ollama']);
        return;
      }
    } catch (_) {}

    await launchUrl(Uri.parse('https://ollama.com/download/mac'));
  }

  Future<void> startOllamaServer() async {
    if (Platform.isWindows) {
      await Process.start(
        'ollama',
        ['serve'],
        mode: ProcessStartMode.detached,
        runInShell: true,
      );
    } else if (Platform.isMacOS) {
      await Process.start(
        'ollama',
        ['serve'],
        mode: ProcessStartMode.detached,
      );
    }
  }
}
