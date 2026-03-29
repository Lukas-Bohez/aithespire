import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class TermuxSetupScreen extends StatefulWidget {
  const TermuxSetupScreen({super.key});

  @override
  State<TermuxSetupScreen> createState() => _TermuxSetupScreenState();
}

class _TermuxSetupScreenState extends State<TermuxSetupScreen> {
  int _currentStep = 0;
  bool _isChecking = false;

  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.termux';

  Future<void> _openPlayStore() async {
    final uri = Uri.parse(_playStoreUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // fallback nothing
    }
  }

  Future<void> _checkConnection() async {
    if (!mounted) return;
    setState(() {
      _isChecking = true;
    });

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://localhost:11434',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final response = await dio.get('/api/version');
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Ollama is running on localhost.')),
        );
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Cannot connect to Ollama on localhost:11434')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termux Setup')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() {
              _currentStep++;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Install Termux'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Install Termux from Google Play Store.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _openPlayStore,
                  child: const Text('Open Termux on Play Store'),
                ),
              ],
            ),
            isActive: _currentStep >= 0,
            state:
                _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Run setup command'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SelectableText(
                  'pkg update && pkg upgrade -y && pkg install ollama -y',
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(
                        text:
                            'pkg update && pkg upgrade -y && pkg install ollama -y',
                      ),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Command copied to clipboard')),
                      );
                    }
                  },
                  child: const Text('Copy command'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Paste this into Termux and press Enter. This may take a few minutes.',
                ),
              ],
            ),
            isActive: _currentStep >= 1,
            state:
                _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Start Ollama server'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SelectableText('ollama serve'),
                const SizedBox(height: 8),
                const Text('Run this in Termux. Keep Termux open in the background.'),
                const SizedBox(height: 8),
                const Text(
                  "Tip: Enable 'Disable child process restrictions' in Developer Options for stable background operation.",
                ),
              ],
            ),
            isActive: _currentStep >= 2,
            state:
                _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Return to AIthespire'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: _isChecking ? null : _checkConnection,
                  child: _isChecking
                      ? const CircularProgressIndicator.adaptive()
                      : const Text('Check connection'),
                ),
              ],
            ),
            isActive: _currentStep >= 3,
            state: StepState.indexed,
          ),
        ],
      ),
    );
  }
}
