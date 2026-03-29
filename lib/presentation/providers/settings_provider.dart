import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

class AppSettings {
  final String ollamaBaseUrl;
  final String defaultModel;
  final String defaultSystemPrompt;
  final String theme;
  final double fontSize;
  final bool streamResponses;
  final bool saveHistory;

  AppSettings({
    required this.ollamaBaseUrl,
    required this.defaultModel,
    required this.defaultSystemPrompt,
    required this.theme,
    required this.fontSize,
    required this.streamResponses,
    required this.saveHistory,
  });

  AppSettings copyWith({
    String? ollamaBaseUrl,
    String? defaultModel,
    String? defaultSystemPrompt,
    String? theme,
    double? fontSize,
    bool? streamResponses,
    bool? saveHistory,
  }) {
    return AppSettings(
      ollamaBaseUrl: ollamaBaseUrl ?? this.ollamaBaseUrl,
      defaultModel: defaultModel ?? this.defaultModel,
      defaultSystemPrompt: defaultSystemPrompt ?? this.defaultSystemPrompt,
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      streamResponses: streamResponses ?? this.streamResponses,
      saveHistory: saveHistory ?? this.saveHistory,
    );
  }
}

@riverpod
class SettingsProvider extends _$SettingsProvider {
  @override
  AppSettings build() {
    return AppSettings(
      ollamaBaseUrl: 'http://localhost:11434',
      defaultModel: 'llama3',
      defaultSystemPrompt: 'You are a helpful assistant.',
      theme: 'system',
      fontSize: 15.0,
      streamResponses: true,
      saveHistory: true,
    );
  }

  void update(AppSettings settings) {
    state = settings;
  }
}

final settingsProvider = settingsProviderProvider;
