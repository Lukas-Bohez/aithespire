import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/local/app_database.dart';

part 'settings_provider.g.dart';

class AppSettings {
  final String ollamaBaseUrl;
  final String defaultModel;
  final String defaultSystemPrompt;
  final ThemeMode themeMode;
  final double fontSize;
  final bool streamResponses;
  final bool saveHistory;

  AppSettings({
    required this.ollamaBaseUrl,
    required this.defaultModel,
    required this.defaultSystemPrompt,
    required this.themeMode,
    required this.fontSize,
    required this.streamResponses,
    required this.saveHistory,
  });

  AppSettings copyWith({
    String? ollamaBaseUrl,
    String? defaultModel,
    String? defaultSystemPrompt,
    ThemeMode? themeMode,
    double? fontSize,
    bool? streamResponses,
    bool? saveHistory,
  }) {
    return AppSettings(
      ollamaBaseUrl: ollamaBaseUrl ?? this.ollamaBaseUrl,
      defaultModel: defaultModel ?? this.defaultModel,
      defaultSystemPrompt: defaultSystemPrompt ?? this.defaultSystemPrompt,
      themeMode: themeMode ?? this.themeMode,
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
    final defaultSettings = AppSettings(
      ollamaBaseUrl: 'http://localhost:11434',
      defaultModel: 'llama3',
      defaultSystemPrompt: 'You are a helpful assistant.',
      themeMode: ThemeMode.system,
      fontSize: 15.0,
      streamResponses: true,
      saveHistory: true,
    );

    Future.microtask(() async {
      final db = AppDatabase();
      try {
        final saved = await db.settingsDao.getSettings();
        String selectedModel = defaultSettings.defaultModel;

        if (saved != null) {
          selectedModel = saved.defaultModel.isNotEmpty ? saved.defaultModel : selectedModel;
          final savedTheme = ThemeMode.values.firstWhere(
            (value) => value.toString().split('.').last == saved.themeMode,
            orElse: () => ThemeMode.system,
          );
          state = defaultSettings.copyWith(
            themeMode: savedTheme,
            fontSize: saved.fontSize,
            defaultModel: selectedModel,
            ollamaBaseUrl: saved.ollamaBaseUrl.isNotEmpty ? saved.ollamaBaseUrl : defaultSettings.ollamaBaseUrl,
            defaultSystemPrompt: saved.defaultSystemPrompt.isNotEmpty ? saved.defaultSystemPrompt : defaultSettings.defaultSystemPrompt,
            streamResponses: saved.streamResponses,
            saveHistory: saved.saveHistory,
          );
        }

        if (selectedModel.isEmpty) {
          final installedModels = await ref.read(localDatasourceProvider).getOllamaModels();
          if (installedModels.isNotEmpty) {
            selectedModel = installedModels.first.name;
          }
        }

        if (selectedModel.isNotEmpty) {
          state = state.copyWith(defaultModel: selectedModel);
          await db.settingsDao.upsertSettings(SettingsCompanion(
            themeMode: Value(state.themeMode.toString().split('.').last),
            fontSize: Value(state.fontSize),
            defaultModel: Value(selectedModel),
            ollamaBaseUrl: Value(state.ollamaBaseUrl),
            defaultSystemPrompt: Value(state.defaultSystemPrompt),
            streamResponses: Value(state.streamResponses),
            saveHistory: Value(state.saveHistory),
          ));
        }
      } catch (_) {
        // ignore
      }
    });

    return defaultSettings;
  }

  void update(AppSettings settings) {
    state = settings;
    final db = AppDatabase();
    db.settingsDao.upsertSettings(SettingsCompanion(
      themeMode: Value(settings.themeMode.toString().split('.').last),
      fontSize: Value(settings.fontSize),
      defaultModel: Value(settings.defaultModel),
      ollamaBaseUrl: Value(settings.ollamaBaseUrl),
      defaultSystemPrompt: Value(settings.defaultSystemPrompt),
      streamResponses: Value(settings.streamResponses),
      saveHistory: Value(settings.saveHistory),
    ));
  }

  void updateDefaultModel(String modelName) {
    state = state.copyWith(defaultModel: modelName);
    final db = AppDatabase();
    db.settingsDao.upsertSettings(SettingsCompanion(
      themeMode: Value(state.themeMode.toString().split('.').last),
      fontSize: Value(state.fontSize),
      defaultModel: Value(modelName),
      ollamaBaseUrl: Value(state.ollamaBaseUrl),
      defaultSystemPrompt: Value(state.defaultSystemPrompt),
      streamResponses: Value(state.streamResponses),
      saveHistory: Value(state.saveHistory),
    ));
  }

  void updateOllamaBaseUrl(String baseUrl) {
    state = state.copyWith(ollamaBaseUrl: baseUrl);
    final db = AppDatabase();
    db.settingsDao.upsertSettings(SettingsCompanion(
      themeMode: Value(state.themeMode.toString().split('.').last),
      fontSize: Value(state.fontSize),
      defaultModel: Value(state.defaultModel),
      ollamaBaseUrl: Value(baseUrl),
      defaultSystemPrompt: Value(state.defaultSystemPrompt),
      streamResponses: Value(state.streamResponses),
      saveHistory: Value(state.saveHistory),
    ));
  }
}

final settingsProvider = settingsProviderProvider;
