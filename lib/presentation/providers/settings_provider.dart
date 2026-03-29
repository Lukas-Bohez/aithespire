import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
        if (saved != null) {
          final savedTheme = ThemeMode.values.firstWhere(
            (value) => value.toString().split('.').last == saved.themeMode,
            orElse: () => ThemeMode.system,
          );
          state = defaultSettings.copyWith(
            themeMode: savedTheme,
            fontSize: saved.fontSize,
          );
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
    ));
  }
}

final settingsProvider = settingsProviderProvider;
