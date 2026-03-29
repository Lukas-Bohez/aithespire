class AppConstants {
  AppConstants._();

  static const String ollamaDefaultUrl = 'http://localhost:11434';
  static const String appName = 'AIthespire';
  static const String packageId = 'com.aithespire.app';

  static const String defaultSystemPrompt = 'You are a helpful assistant.';

  static const double defaultFontSize = 15.0;
  static const double sidebarWidth = 270.0;
  static const double maxBubbleWidthFraction = 0.85;

  static const String ollamaApiChatPath = '/api/chat';
  static const String ollamaApiTagsPath = '/api/tags';
  static const String ollamaApiPullPath = '/api/pull';
  static const String ollamaApiDeletePath = '/api/delete';
  static const String ollamaApiShowPath = '/api/show';
  static const String ollamaApiVersionPath = '/api/version';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 120);

  // Local storage keys or collection names
  static const String isarDbName = 'aithespire';

  static const String playStorePrivacyPolicyUrl =
      'https://example.com/privacy-policy';
}
